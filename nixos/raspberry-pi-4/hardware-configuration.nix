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
    server string = raspberry-server
    netbios name = smbnix
    security = user
    #use sendfile = yes
    #max protocol = smb2
    hosts allow = 192.168.15  localhost
    hosts deny = 0.0.0.0/0
    guest account = nobody
    map to guest = bad user
  '';
    shares = {
      private = {
        path = "/home/rafael/share";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "rafael";
      };
    };
  };
}
