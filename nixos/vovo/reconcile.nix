{ config, lib, pkgs, ... }:

# Keep vovo working across forced power-offs: settings that Home Assistant and
# Music Assistant keep in their own databases (outside Nix) are checked and
# restored automatically.
#
#  - ma-ensure-settings: before every Music Assistant start, repair
#    settings.json (music library with its fixed instance id, squeezelite).
#  - vovo-reconcile: after boot and every 30 min, restore HA integrations,
#    the voice pipeline, Assist exposure and MA player settings via the APIs.
let
  maEnsure = pkgs.writers.writePython3Bin "ma-ensure-settings" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./ma-ensure-settings.py);

  reconcile = pkgs.writers.writePython3Bin "vovo-reconcile" {
    libraries = [ pkgs.python3Packages.websockets ];
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./vovo-reconcile.py);
in
{
  systemd.services.music-assistant.serviceConfig.ExecStartPre =
    [ "+${maEnsure}/bin/ma-ensure-settings /var/lib/private/music-assistant/settings.json" ];

  systemd.services.vovo-reconcile = {
    description = "Restore vovo's Home Assistant / Music Assistant settings";
    after = [ "home-assistant.service" "music-assistant.service" "network-online.target" "vovo-bootstrap.service" ];
    wants = [ "network-online.target" "vovo-bootstrap.service" ];
    environment = {
      HA_TOKEN_FILE = "/var/lib/vovo/ha-token"; # bootstrap.nix
      MA_TOKEN_FILE = "/var/lib/vovo/ma-token";
    };
    serviceConfig = {
      Type = "oneshot";
      User = "rafael";
      ExecStart = "${reconcile}/bin/vovo-reconcile";
      TimeoutStartSec = "20min";
      Nice = 10;
    };
  };
  # Once per boot, when vovo can actually play music (HA up, player and
  # satellite available), say hello through the speaker: one of the
  # "greeting" variants in phrases.nix.
  systemd.services.vovo-greeting = {
    description = "vovo greeting once it is ready";
    wantedBy = [ "multi-user.target" ];
    after = [ "home-assistant.service" "music-assistant.service" "wyoming-satellite.service" "vovo-bootstrap.service" ];
    wants = [ "vovo-bootstrap.service" ];
    path = [ pkgs.curl pkgs.jq pkgs.coreutils ];
    environment.HA_TOKEN_FILE = "/var/lib/vovo/ha-token"; # bootstrap.nix
    script = ''
      tok=$(cat "$HA_TOKEN_FILE")
      state() {
        curl -sf -H "Authorization: Bearer $tok" "http://127.0.0.1:8123/api/states/$1" | jq -r .state
      }
      for _ in $(seq 120); do  # up to 10 minutes
        p=$(state media_player.vovo || true); s=$(state assist_satellite.vovo || true)
        if [ -n "$p" ] && [ "$p" != unavailable ] && [ "$s" = idle ]; then
          sleep 5  # let the Bluetooth speaker settle
          curl -sf -X POST -H "Authorization: Bearer $tok" -H "Content-Type: application/json" \
            http://127.0.0.1:8123/api/services/assist_satellite/announce \
            -d "$(jq -n --arg m "$(jq -r '.greeting | .[now | floor % length]' ${pkgs.writeText "vovo-phrases.json" (builtins.toJSON (import ./phrases.nix))})" \
                  '{entity_id: "assist_satellite.vovo", message: $m}')" >/dev/null
          exit 0
        fi
        sleep 5
      done
      echo "vovo did not become ready within 10 minutes" >&2
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true; # once per boot, not again on every deploy
      User = "rafael";
    };
  };

  systemd.timers.vovo-reconcile = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "30min";
    };
  };
}
