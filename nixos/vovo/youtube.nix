{ config, lib, pkgs, ... }:

# YouTube fallback (no Premium needed): when a request is not in the library,
# Home Assistant hands it to youtube-fetch, which downloads from YouTube Music
# with yt-dlp into ~/Music/Youtube and plays it through Music Assistant.
#
#   HA shell_command --(unix socket)--> youtube-fetch@ (rafael) --> yt-dlp
#                                              |--> Music Assistant API (play)
#                                              '--> HA API (announce errors)
#
# Socket activation decouples the two: HA answers right away ("getting it
# from YouTube") instead of hitting its 60 s shell_command timeout, and the
# downloader can write to rafael's home, which HA's sandbox cannot.
#
# Downloading from YouTube is against its Terms of Service. YouTube changes
# its anti-bot measures often; when this breaks, update nixpkgs (yt-dlp).
let
  socket = "/run/youtube-fetch.sock";

  fetcher = pkgs.writers.writePython3Bin "youtube-fetch" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./youtube-fetch.py);
in
{
  age.secrets = {
    ha-token = { file = ../../secrets/ha-token-vovo.age; owner = "rafael"; };
    ma-token = { file = ../../secrets/ma-token-vovo.age; owner = "rafael"; };
  };

  systemd.sockets.youtube-fetch = {
    description = "YouTube fallback requests from Home Assistant";
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = socket;
      Accept = true;
      SocketUser = "rafael";
      SocketGroup = "hass";
      SocketMode = "0660";
      MaxConnections = 4;
    };
  };

  systemd.services."youtube-fetch@" = {
    description = "Fetch a song/album from YouTube for vovo";
    path = [ pkgs.yt-dlp pkgs.ffmpeg-headless ];
    environment = {
      HA_TOKEN_FILE = config.age.secrets.ha-token.path;
      MA_TOKEN_FILE = config.age.secrets.ma-token.path;
    };
    serviceConfig = {
      ExecStart = "${fetcher}/bin/youtube-fetch";
      User = "rafael";
      Group = "users";
      StandardInput = "socket";
      StandardOutput = "journal";
      StandardError = "journal";
      # Background work: never slow down the voice pipeline (STT, HA).
      Nice = 19;
      CPUWeight = 10;
      IOWeight = 10;
      CPUQuota = "150%";
      RuntimeMaxSec = "30min";
      MemoryHigh = "500M"; # deno (YouTube JS challenge) alone needs ~200 MB
    };
  };

  # What Home Assistant runs: send "<kind> <option> <base64 query>" and return
  # at once. option: replace | add | next (Music Assistant queue option).
  # (shell_command splits arguments without a shell; base64 keeps the query
  # a single safe word.)
  services.home-assistant.config.shell_command.youtube_fetch =
    let
      request = pkgs.writeShellScript "youtube-fetch-request" ''
        printf '%s %s %s\n' "$1" "$2" "$3" | ${pkgs.socat}/bin/socat -u - UNIX-CONNECT:${socket}
      '';
    in
    "${request} {{ kind }} {{ option | default('replace') }} {{ query | base64_encode }}";
}
