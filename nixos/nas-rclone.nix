{ config, lib, ... }:

# The NAS share //192.168.0.104/hdd at /rafael_mounts through rclone with a
# local disk cache, declared with home-manager's programs.rclone (the
# `synology` remote). Imported by thinkpad-e14 and bbtablet; bbstation keeps
# its kernel CIFS mount (wired, always home).
#
# ~/.config/rclone/rclone.conf is generated from this at every login
# (rclone-config.service), the password injected from nasRclone.passwordFile.
#
# Why not the others (measured on thinkpad 2026-11-21, 4,711-file RAW folder,
# 5 GHz wifi):
#  - gvfs (the file manager's smb:// mount): every file costs a round trip
#    through gvfsd-fuse -> gvfsd-smb, one at a time; `ls -l` took over 2 min
#    and RapidRAW read ~6.5 KB/s. rclone lists the same folder, with sizes, in
#    0.8 s and reads ~10 MB/s.
#  - kernel cifs: fast, but after leaving the home network it hung the
#    terminal and the file manager.
# rclone downloads only the parts of files that are read and keeps them in
# ~/.cache/rclone, evicting the least recently used above the size cap, so a
# RAW folder opened once is local the next time. Writes (sidecars) land in the
# cache and are uploaded in the background. Away from home, requests fail
# after a few seconds instead of hanging (short timeouts, few retries).
# Same path as the old kernel mounts, so darktable's film rolls and RapidRAW's
# folders under /rafael_mounts keep working.
let
  cfg = config.nasRclone;
in
{
  options.nasRclone = {
    passwordFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        File holding the NAS SMB password alone (no "password=", no newline
        needed), readable by rafael. Read at login by rclone-config.service.
      '';
    };
    cacheSize = lib.mkOption {
      type = lib.types.str;
      default = "20G";
      description = "Upper bound of the local file cache (~/.cache/rclone).";
    };
  };

  config = {
    # Mount point owned by rafael (a user FUSE mount); tmpfiles also fixes the
    # owner of the existing root-owned directory.
    systemd.tmpfiles.rules = [ "d /rafael_mounts 0755 rafael users -" ];

    home-manager.users.rafael = { pkgsUnstable, ... }: {
      programs.rclone = {
        enable = true;
        package = pkgsUnstable.rclone; # the one home.nix installs on every host
        remotes.synology = {
          config = {
            type = "smb";
            host = "192.168.0.104";
            user = "rafael";
            idle_timeout = "1m0s"; # drop the SMB connection when unused
          };
          secrets.pass = cfg.passwordFile; # obscured by `rclone config update`
          mounts.hdd = {
            enable = true;
            mountPoint = "/rafael_mounts";
            options = {
              # vfs-cache-mode = "full" and cache-dir = ~/.cache/rclone are
              # the module's defaults.
              vfs-cache-max-size = cfg.cacheSize;
              vfs-cache-max-age = "720h"; # forget files unused for 30 days
              vfs-fast-fingerprint = true; # size + modtime, no hashing over SMB
              # Read-ahead per open file. The default (16M) downloads a whole
              # ~20 MB CR3 for any read, and RapidRAW reads the EXIF of every
              # file in a folder: 2,272 RAWs became ~48 GB of downloads. With
              # 2M a 64 KB read fetches ~250 KB, and a full RAW still reads at
              # ~4 MB/s+ (measured 2026-11-21).
              buffer-size = "2M";
              # Listings are kept for 30 min (a 4.7k-file folder re-lists in
              # ~1 s); files other machines add meanwhile show up after that.
              dir-cache-time = "30m";
              attr-timeout = "30s";
              # Files and folders are rafael's (755/644), like the old kernel
              # mount's uid=1000,gid=100; explicit so they don't depend on the
              # service's environment.
              uid = 1000;
              gid = 100;
              umask = "022";
              # Fail fast when the NAS is unreachable (left home, NAS asleep)
              # instead of the defaults: 1 min connect timeout x 10 retries.
              contimeout = "5s";
              timeout = "30s";
              low-level-retries = 2;
            };
          };
        };
      };

      # Recover from a dead mount. If the mount is busy when the service stops
      # (a file dialog open on it during nixos-rebuild switch, 2026-11-21),
      # rclone exits without unmounting and leaves "Transport endpoint is not
      # connected" behind; the restart's mkdir then failed 5 times in a second
      # and systemd gave up. Lazily unmount on stop and before every start, and
      # space the retries out.
      systemd.user.services."rclone-mount:hdd@synology" = {
        Service = {
          ExecStartPre = lib.mkForce [
            "-/run/wrappers/bin/fusermount3 -uz /rafael_mounts"
            "/run/current-system/sw/bin/mkdir -p /rafael_mounts"
          ];
          ExecStopPost = "-/run/wrappers/bin/fusermount3 -uz /rafael_mounts";
          RestartSec = 5;
        };
      };
    };
  };
}
