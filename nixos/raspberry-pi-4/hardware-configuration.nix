{ config, pkgs, lib, ... }:

{
  imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/5a6756294553fc3aa41e11563882db78c2dfbb4c.tar.gz" }/raspberry-pi/4"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  zramSwap = {
    enable = true;
    priority = 6;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # Enable GPU acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  services.xrdp.enable = true;
  networking.firewall.allowedTCPPorts = [ 3389 ];
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

  services.plex = {
    enable = true;
    openFirewall = true;
  };
}
