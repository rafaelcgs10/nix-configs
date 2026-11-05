{ config, lib, pkgs, ... }:

# Music Assistant (library + YouTube Music) playing through Squeezelite.
#
#   ~/Music (Syncthing) --bind ro--> /srv/music --> Music Assistant (:8095)
#                                                      | slimproto (:3483, local)
#                                                      v
#                                     squeezelite "vovo" (rafael's PipeWire)
{
  services.music-assistant = {
    enable = true;
    providers = [
      "filesystem_local" # ~/Music
      "ytmusic"          # fallback when a song is not in the library
      "squeezelite"      # the local player below
      "hass"             # Home Assistant <-> Music Assistant link
    ];
  };

  # The service is sandboxed with ProtectHome=true and a dynamic user. Instead of
  # opening up /home, bind just the music folder in, read-only.
  systemd.services.music-assistant.serviceConfig = {
    BindReadOnlyPaths = [ "/home/rafael/Music:/srv/music" ];
    MemoryHigh = "350M";
  };
  systemd.tmpfiles.rules = [ "d /srv/music 0755 root root -" ];

  # Web UI and its audio stream port, for the LAN.
  networking.firewall.allowedTCPPorts = [ 8095 8097 ];
}
