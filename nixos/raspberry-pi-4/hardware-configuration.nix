{ config, pkgs, lib, ... }:

{
  imports = [
    "${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/5a6756294553fc3aa41e11563882db78c2dfbb4c.tar.gz" }/raspberry-pi/4"
      ../modules/qbittorrent.nix
  ];

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

  zramSwap = {
    enable = true;
    priority = 6;
    memoryPercent = 50;
    algorithm = "zstd";
  };

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

  services.transmission = {
    enable = true;
    settings = {
      message-level = 1;
      rpc-port = 9091;
      rpc-enabled = true;
      rpc-authentication-required = false;
      utp-enabled = true;
      port-forwarding-enabled = true;
      rpc-bind-address = "0.0.0.0";
      watch-dir =  "/bighd/downloader/Downloads";
      watch-dir-enabled = true;
      download-dir = "/bighd/downloader/Downloads/";
      incomplete-dir = "/bighd/downloader/Downloads/incomplete";
      incomplete-dir-enabled = true;
      rpc-whitelist-enabled = true;
      rpc-whitelist = "192.168.15.118,192.168.15.200,192.168.*.*,127.0.0.1";
    };
    openFirewall = true;
    home = "/bighd/downloader/.transmission";
    user = "downloader";
    group = "users";
    downloadDirPermissions = "700";
  };

  services = {
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[ab][!0-9]", ATTR{queue/scheduler}="kyber"
    '';
    irqbalance.enable = true;
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

  services.qbittorrent.enable = true;
  users.users.qbittorrent.isSystemUser = true;

  # users.users.jellyfin.extraGroups = [ "wheel" "users" ];
}
