{ config, pkgs, lib, ... }:

{
  # disabledModules = [ "profiles/installation-device.nix" ];
  nixpkgs.crossSystem.system = "armv7l-linux";
  imports = [ <nixpkgs/nixos/modules/installer/sd-card/sd-image-armv7l-multiplatform-installer.nix> ];

  nix.binaryCaches = lib.mkForce [ "https://cache.armv7l.xyz" ];
  nix.binaryCachePublicKeys = [ "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk=" ];

  networking.hostName = "orange-pi-one";
  #networking.hostId = "24ebc6f2";
  # networking.wireless.iwd.enable = true;

  networking.wireless.enable = true;
  networking.wireless.userControlled.enable = true;
  networking.wireless.networks.Itsawonderfulwifi.pskRaw = "9c14b5c4dd05c191fd73fc96f53d28462058e826867813d3b41b1b14a14076fc";
  networking.wireless.extraConfig = ''
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel
  '';

  systemd.services.wpa_supplicant = {
    wantedBy = lib.mkForce ["multi-user.target" "syncthing.service"];
  };

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
    tmux
    vim
    wirelesstools
    wpa_supplicant
    syncthing
    pkg-config
    cloudflared

  ];

  system.stateVersion = "24.05";

  boot.kernelPackages = lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.extraModulePackages = with config.boot.kernelPackages; [rtw88 rtl8821cu];

  services.syncthing = {
    user = "rafael";
    group = "users";
    dataDir = "/home/rafael";
    enable = true;
    relay.enable = true;
    configDir = "/home/rafael/.config/syncthing";
    guiAddress = "0.0.0.0:8384";
  };
  systemd.services.syncthing = {
    serviceConfig = {
      RestartSec = 10;
      Restart = lib.mkForce "always";
      Type = lib.mkForce "simple";
    };
  };

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

  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";
  zramSwap.priority = 10;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 15;
  };

  networking.firewall.allowedTCPPorts = [ 8384 22 ];
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

}
