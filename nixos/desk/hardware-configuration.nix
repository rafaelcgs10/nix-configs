# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/96082114-504a-43e6-8a32-7c0b49097e8a";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/63d991d0-8b79-4821-9cc3-0d28993d4d7d"; }
    ];

  # Xserver basic
  services.xserver = {
    exportConfiguration = true;

    videoDrivers = [ "nvidia" ];

    deviceSection = ''
      Driver         "nvidia"
      VendorName     "NVIDIA Corporation"
      BoardName      "GeForce GTX 1060 6GB"
    '';

    monitorSection = ''
      VendorName     "Unknown"
      ModelName      "LG Electronics LG TV SSCR"
      HorizSync       30.0 - 135.0
      VertRefresh     24.0 - 120.0
      Option         "DPMS"
    '';

    screenSection = ''
      Device         "Device0"
      Monitor        "Monitor0"
      DefaultDepth    24
      Option         "Stereo" "0"
      Option         "DPI" "96 x 96"
      Option         "nvidiaXineramaInfoOrder" "DFP-2"
      Option         "metamodes" "HDMI-0: 4096x2160_60 +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0: 1920x1080_144 +4096+1080 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
      SubSection     "Display"
          Depth       24
      EndSubSection
    '';

  };
}