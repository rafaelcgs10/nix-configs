# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.supportedFilesystems = [ "nfs" ];

  boot.blacklistedKernelModules = [ "rtl8821cu" "rtw88_8821cu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl88xxau-aircrack ];
  # boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821au ];
  # boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821cu ];
  hardware.wirelessRegulatoryDatabase = true;
  hardware.bluetooth.enable = true;
  boot.kernelParams = [
    "mitigations=off"
    "nvidia.NVreg_EnableGpuFirmware=0" # Disable GSP (GPU offloading) to fix Wayland performance
  ];


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2409ac65-2c0c-4321-bc6a-777e2097f025";
      fsType = "ext4";
    };

  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/rafael_mounts" = {
    device = "//192.168.0.104/hdd";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=10,x-systemd.device-timeout=5s,x-systemd.mount-timeout=2s";

    in ["${automount_opts},credentials=/home/rafael/.smb-secrets,uid=1000,gid=100,_netdev" "cache=loose"];
  };

  systemd = {
    extraConfig = "DefaultTimeoutStopSec=10s";
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 3;
  };

  swapDevices = [ ];

  programs.xwayland.enable = true;
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  programs.steam.enable = true;

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  powerManagement = {
    cpuFreqGovernor = "performance";
  };

  # Docker config
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  systemd.services.docker.serviceConfig.KillMode = "mixed";

  virtualisation.virtualbox.host.enable = true;
  nixpkgs.config.virtualbox.host.enableExtensionPack = true;

  users.extraGroups.vboxusers.members = [ "rafael" ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f0u7.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  networking.hostName = "bbstation";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}