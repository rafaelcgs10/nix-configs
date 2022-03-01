{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.qbittorrent;
  configDir = "${cfg.dataDir}/.config";
  openFilesLimit = 4096;
in
{
  options.services.qbittorrent = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Run qBittorrent headlessly as systemwide daemon
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/hugehd/downloader/.qbittorrent";
      description = ''
        The directory where qBittorrent will create files.
      '';
    };

    # qbUser = mkOption {
    #   type = types.str;
    #   default = "admin";
    #   description = ''
    #     Username of qBittorrent Web API
    #   '';
    # };

    # qbPass = mkOption {
    #   type = types.str;
    #   default = "adminadmin";
    #   description = ''
    #     Password of qBittorrent Web API
    #   '';
    # };

    user = mkOption {
      type = types.str;
      default = "downloader";
      description = ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "users";
      description = ''
        Group under which qBittorrent runs.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        qBittorrent web UI port.
      '';
    };

    openFilesLimit = mkOption {
      default = openFilesLimit;
      description = ''
        Number of files to allow qBittorrent to open.
      '';
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.qbittorrent ];

    nixpkgs.overlays = [
      (
        self: super: {
          qbittorrent = super.qbittorrent.override { guiSupport = false; };
        }
      )
    ];

    systemd.services.qbittorrent = {
      after = [ "network.target" "remote-fs.target" ];
      description = "qBittorrent Daemon";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.qbittorrent ];
      serviceConfig = {
        ExecStartPre = ''
          ${pkgs.coreutils}/bin/sleep 10
          '';
        ExecStart = ''
           ${pkgs.qbittorrent}/bin/qbittorrent-nox \
            --profile=${configDir} \
            --webui-port=${toString cfg.port}
        '';
        # To prevent "Quit & shutdown daemon" from working; we want systemd to
        # manage it!
        Restart = "on-success";
        User = cfg.user;
        Group = cfg.group;
        UMask = "0002";
        MemoryMax = "1G";
        CPUQuota = "75%";
        LimitNOFILE = cfg.openFilesLimit;
      };
    };


    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        description = "qBittorrent Daemon user";
      };
    };

    users.groups = mkIf (cfg.group == "qbittorrent") {
      qbittorrent = {
        gid = null;
      };
    };
  };
}
