{ config, pkgs, lib, ... }:

{
  imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/5a6756294553fc3aa41e11563882db78c2dfbb4c.tar.gz" }/raspberry-pi/4"];

  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
    gpu_mem=512
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
    raspberry-pi."4".fkms-3d.enable = true;
    enableRedistributableFirmware = true;
    pulseaudio = {
      enable = true;
      systemWide = true;
      support32Bit = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        unload-module module-native-protocol-unix
        load-module module-native-protocol-unix auth-anonymous=1
        load-module module-switch-on-connect
      '';
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

  services.plex = {
    enable = true;
    openFirewall = true;
  };
}
