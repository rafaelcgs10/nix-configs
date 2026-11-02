{ config, pkgs, ... }:

# Save-game backups for the Windows games Faugus installs, via Ludusavi
# (installed in extras.nix). Ludusavi's manifest knows where ~20k PC games
# keep their saves; the wildcard root below makes it look inside every Wine
# prefix under ~/Faugus, so a newly installed game needs no configuration
# here, as long as it is in the manifest and saves inside its prefix.
#
# Backups land in ~/Games/saves/pc, inside the Syncthing folder that already
# carries the emulator saves, so they reach the NAS and the other machines.
#
#  - Hourly timer: backs up every detected game (unchanged saves are skipped).
#  - Per game, in Faugus (Edit game > Launch arguments), the wrapper
#      ludusavi wrap --name "<Ludusavi game name>" --force --ask-downgrade --gui --
#    Faugus puts launch arguments right before umu-run, so this restores
#    before the game starts (silently if the backup is newer, asking with a
#    zenity dialog if it is older than the local save), runs the game and
#    backs up when it exits. Faugus' own pre-launch hook is not used: it is
#    started without waiting, so a restore there would race the game.
#    The name is the one Ludusavi shows (GUI search or
#    `ludusavi backup --preview`), e.g. "SimCity 4".
#
# Not covered automatically: games outside the manifest, saves written
# outside the prefix (an install folder elsewhere), and registry-only saves
# (Ludusavi does not back up Wine registries). Those need a customGames entry.
#
# The config file is read-only (managed here); the Ludusavi GUI can still
# back up/restore, but its settings changes do not stick: edit them below.

let
  home = config.home.homeDirectory;
  backupDir = "${home}/Games/saves/pc";

  settings = {
    manifest.enable = true;
    roots = [
      { store = "otherWine"; path = "${home}/Faugus/*"; }
    ];
    backup = {
      path = backupDir;
      # Native Linux game and an emulator's own config: not Faugus saves.
      ignoredGames = [ "Borderlands 2" "Dolphin" ];
      retention = { full = 3; differential = 3; };
      format = {
        chosen = "zip";
        zip.compression = "zstd";
      };
    };
    restore.path = backupDir;
  };
in
{
  # Ludusavi's --gui prompts (the "backup is older than your save" question)
  # are zenity/kdialog dialogs.
  home.packages = [ pkgs.zenity ];

  xdg.configFile."ludusavi/config.yaml".source =
    (pkgs.formats.yaml { }).generate "ludusavi-config.yaml" settings;

  systemd.user.services.ludusavi-backup = {
    Unit.Description = "Back up game saves with Ludusavi";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup --force";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
  systemd.user.timers.ludusavi-backup = {
    Unit.Description = "Hourly Ludusavi save backup";
    Timer = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "5min";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
