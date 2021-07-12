{ config, pkgs, lib, ... }:

{
  imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/5a6756294553fc3aa41e11563882db78c2dfbb4c.tar.gz" }/raspberry-pi/4"];

  boot.loader.raspberryPi.firmwareConfig = ''
    arm_freq=1750
    over_voltage=1
    dtparam=sd_poll_once=on
  '';

  boot.kernelParams = [ "mitigations=off" ];

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
        path = "/home/rafael/share";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "rafael";
        "force group" = "wheel";
      };
    };
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
      watch-dir =  "/home/rafael/share/.p00";
      watch-dir-enabled = true;
      download-dir = "/home/rafael/share/.p00";
      incomplete-dir = "/home/rafael/share/.p00/incomplete";
      incomplete-dir-enabled = true;
      rpc-whitelist-enabled = true;
      rpc-whitelist = "192.168.15.118,192.168.15.200,192.168.*.*,127.0.0.1";
    };
    openFirewall = true;
    home = "/home/rafael/.transmission";
    user = "rafael";
    group = "wheel";
    downloadDirPermissions = "770";
  };
}
