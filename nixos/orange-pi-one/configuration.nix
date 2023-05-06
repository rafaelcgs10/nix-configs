{ config, pkgs, lib, ... }:

{
  # disabledModules = [ "profiles/installation-device.nix" ];
  nixpkgs.crossSystem.system = "armv7l-linux";
  imports = [ <nixpkgs/nixos/modules/installer/sd-card/sd-image-armv7l-multiplatform-installer.nix> ];

  nix.binaryCaches = lib.mkForce [ "https://cache.armv7l.xyz" ];
  nix.binaryCachePublicKeys = [ "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk=" ];
    

  networking.hostName = "orange-pi-one";
  #networking.hostId = "24ebc6f2";
  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;

  security.sudo.enable = true;
  services.openssh.enable = true;
  #boot.kernel.sysctl."vm.overcommit_memory" = "1";

  # environment.variables.GC_INITIAL_HEAP_SIZE = "100000";
  boot.kernelParams = [
    "console=ttyS0,115200n8"
  ];

  environment.systemPackages = with pkgs; [
    htop
    git
    wirelesstools
    wireguard-tools
    # sysbench
    syncthing
    pkg-config

    # libnotify
    # libdbusmenu
  ];

  system.stateVersion = "23.05"; # Did you read the comment?

  boot.kernelPackages = lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;

  users.extraUsers.rafael = {
    isNormalUser = true;
    uid = 1000;
    password = "rafael";
    home = "/home/rafael";
    extraGroups = [ "wheel" ];
  };
  nix.settings.trusted-users = [ "root" "rafael" ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

}
