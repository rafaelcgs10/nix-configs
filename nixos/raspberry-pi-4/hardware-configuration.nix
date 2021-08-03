{ config, pkgs, lib, ... }:

{
  imports = [
    "${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/5a6756294553fc3aa41e11563882db78c2dfbb4c.tar.gz" }/raspberry-pi/4"
      ../modules/qbittorrent.nix
      ./fan-control/default.nix
  ];

  my.raspberry-pi = {
    fan-control.enable = true;
  };

  boot.loader.raspberryPi.firmwareConfig = ''
    arm_freq=1750
    over_voltage=1
    dtparam=sd_poll_once=on
  '';

  boot.kernelParams = [ "mitigations=off" ];

  fileSystems."/bighd" =
    { device = "/dev/disk/by-label/bighd";
      fsType = "ext4";
    };


  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # zramSwap = {
  #   enable = true;
  #   priority = 6;
  #   memoryPercent = 50;
  #   algorithm = "zstd";
  # };

  hardware = {
    # Enable GPU acceleration
    raspberry-pi."4".fkms-3d = {
      enable = true;
      cma = 512;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xmonad";

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
    workgroup = WORKGROUP
    server string = smbnix
    netbios name = smbnix
    security = user
    #use sendfile = yes
    #max protocol = smb2
    hosts allow = 192.168.15.1/24 192.168.15.118
    map to guest = bad user
  '';
    shares = {
      private = {
        path = "/bighd/downloader";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "downloader";
        "force group" = "users";
      };
    };
  };

  services.xserver = {
    resolutions = [ { x = 1280; y = 720; } { x = 1024; y = 768; }];
  };

  services.xserver.autorun = false;

  users.users.downloader = {
    isNormalUser = true;
    home = "/bighd/downloader";
    extraGroups = [ "wheel" "networkmanager" "users" ];
  };

  # services = {
  #   udev.extraRules = ''
  #     ACTION=="add|change", KERNEL=="sd[ab][!0-9]", ATTR{queue/scheduler}="kyber"
  #   '';
  #   irqbalance.enable = true;
  # };

  services.earlyoom {
    enable = true;
    useKernelOOMKiller = true;
    freeMemThreshold = 20;
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "downloader";
    group = "users";
  };

  services.vsftpd = {
    enable = true;
    localUsers = true;
    writeEnable = true;
    anonymousUser = true;
    extraConfig = ''
      pasv_enable=YES
      pasv_min_port=64000
      pasv_max_port=64000
      port_enable=YES
    '';
  };

  services.qbittorrent.enable = true;
  users.users.qbittorrent.isSystemUser = true;

  # Enable cron service
  services.cron = {
    enable = true;
    systemCronJobs = [
      "40 0 */1 * *      downloader    find /bighd/downloader/Downloads -mtime +2 -type f -delete"
      "1 5 */1 * *      root          reboot"
    ];
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 1d";
    };

    daemonIONiceLevel = 10;
    daemonNiceLevel = 5;
    buildCores = 2;
  };

  services.syncthing = {
    user = "rafael";
    group = "users";
    dataDir = "/bighd/Syncthing";
    enable = true;
    relay.enable = true;
  };

  systemd.services.syncthing.serviceConfig = {
    Nice = 10;
    IOSchedulingClass = "idle";
    IOSchedulingPriority = 6;
  };
}
