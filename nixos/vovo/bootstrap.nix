{ config, lib, pkgs, ... }:

# First-boot bootstrap: a freshly flashed card ends up like the running one
# without manual steps (see vovo-bootstrap.py).
#
#   vovo-bootstrap   HA owner + MA admin "rafaelcgs" (password from agenix),
#                    long-lived API tokens in /var/lib/vovo/{ha,ma}-token
#   vovo-reconcile   integrations, voice pipeline, Assist exposure, Music
#                    Assistant providers (incl. the HA login plugin), players
#
# Everything else is declarative: HA's YAML config, Music Assistant's
# providers (ma-ensure-settings), the Syncthing identity, Wi-Fi.
# Not restored: HA history and Music Assistant favourites/play history (the
# library itself is rescanned from ~/Music, which Syncthing brings back).
let
  bootstrap = pkgs.writers.writePython3Bin "vovo-bootstrap" {
    libraries = [ pkgs.python3Packages.websockets ];
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./vovo-bootstrap.py);
in
{
  age.secrets.vovo-admin-password.file = ../../secrets/vovo-admin-password.age;

  # Read by rafael's services (reconcile, greeting, YouTube fetcher, names).
  systemd.tmpfiles.rules = [ "d /var/lib/vovo 0750 rafael users -" ];

  systemd.services.vovo-bootstrap = {
    description = "Create vovo's Home Assistant / Music Assistant accounts and API tokens";
    wantedBy = [ "multi-user.target" ];
    after = [ "home-assistant.service" "music-assistant.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    environment.VOVO_ADMIN_PASSWORD_FILE = config.age.secrets.vovo-admin-password.path;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${bootstrap}/bin/vovo-bootstrap";
      TimeoutStartSec = "20min"; # first boot: HA and MA take a while
    };
  };
}
