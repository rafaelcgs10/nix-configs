{ config, lib, pkgs, ... }:

# Name correction for "play ..." requests (see names/vovo-names.py).
#
#   HA "play X" automation --rest_command--> vovo-names (127.0.0.1:10900)
#        uses the corrected name for the library search, then YouTube
#
# Everything the matcher knows is built by Nix:
#  - Billboard Hot 100 (every US chart entry since 1958), fetched from a
#    pinned commit of utdata/rwd-billboard-data;
#  - a vendored Wikidata snapshot (well-known artists, composers with their
#    aliases, well-known songs and classical works) in ./names. Refresh it with
#    `nix run .#vovo-names-update` from the repo root and commit the diff;
#  - the music library, read from Music Assistant when the service starts.
#
# The service is socket-activated and exits after 10 idle minutes, so it uses
# no RAM between requests; a cold start (load catalog + library) adds about a
# second to the first request.
let
  port = 10900;

  billboard = pkgs.fetchurl {
    # Pinned 2026-11-06 (data through the 2026-11-07 chart). Bump: take the
    # latest commit of github.com/utdata/rwd-billboard-data and update the hash.
    url = "https://raw.githubusercontent.com/utdata/rwd-billboard-data/f23d6584dae433c36f17f3c73c88d54ffc84c326/data-out/hot-100-current.csv";
    sha256 = "1lmxdyrv5my43461c086iycdghsvhyihl5igznm4pbfjmsly4lar";
  };

  python = pkgs.python3.withPackages (p: [ p.rapidfuzz p.jellyfish ]);
  script = ./names/vovo-names.py;

  catalog = pkgs.runCommand "vovo-names-catalog.json" { } ''
    ${python}/bin/python3 -I ${script} build $out ${billboard} \
      ${./names/wikidata-artists.csv} ${./names/wikidata-works.csv}
  '';
in
{
  systemd.sockets.vovo-names = {
    description = "Artist/song name correction for vovo's voice commands";
    wantedBy = [ "sockets.target" ];
    socketConfig.ListenStream = "127.0.0.1:${toString port}";
  };

  systemd.services.vovo-names = {
    description = "Artist/song name correction for vovo's voice commands";
    environment = {
      MA_TOKEN_FILE = "/var/lib/vovo/ma-token"; # bootstrap.nix
      MOODS_FILE = pkgs.writeText "vovo-moods.json" (builtins.toJSON (import ./moods.nix));
      PLAYLIST_TERMS_FILE = pkgs.writeText "vovo-playlist-terms.json" (builtins.toJSON (import ./playlist-terms.nix));
    };
    serviceConfig = {
      ExecStart = "${python}/bin/python3 -I ${script} serve ${catalog}";
      User = "rafael";
      Group = "users";
      # On the path of every "play" command: not background work.
      MemoryHigh = "150M";
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
    };
  };

  services.home-assistant.config.rest_command.vovo_names = {
    url = "http://127.0.0.1:${toString port}/correct";
    method = "post";
    content_type = "application/json";
    payload = ''{"mode": {{ mode | to_json }}, "name": {{ name | to_json }}}'';
    timeout = 20;
  };
}
