{ config, lib, pkgs, modulesPath, ... }:

# Raspberry Pi 4 boot + SD image.
#
# Deliberately NOT nixos-hardware's raspberry-pi/4 module nor nixpkgs'
# sd-image-aarch64.nix:
#   - nixos-hardware swaps in the Raspberry Pi vendor kernel, which is not in
#     cache.nixos.org and would have to be compiled under qemu (hours).
#     The mainline kernel is cached and has everything vovo needs: brcmfmac
#     (Wi-Fi), hci_uart/btbcm (Bluetooth), snd-bcm2835 (3.5 mm jack), USB audio.
#   - sd-image-aarch64.nix pulls in profiles/base.nix (rescue tools, ZFS, ...)
#     and Pi 3/CM firmware. This is the same image recipe, trimmed to the Pi 4.
{
  imports = [ "${modulesPath}/installer/sd-card/sd-image.nix" ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible = {
    enable = true;
    # /boot lives on the small root partition of a 32 GB card.
    configurationLimit = 5;
  };

  boot.kernelPackages = pkgs.linuxPackages;
  boot.initrd.availableKernelModules = [
    "pcie-brcmstb"       # PCIe bus behind the USB 3 controller
    "reset-raspberrypi"  # loads the VL805 USB firmware; without it no USB
    "usbhid"
    "usb_storage"
  ];
  boot.kernelParams = [ "console=tty0" ];

  # Wi-Fi/Bluetooth firmware (BCM43455) incl. the Pi 4 board nvram file. Much
  # smaller than linux-firmware, which is all we would otherwise need it for.
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];

  sdImage = {
    compressImage = true;

    populateFirmwareCommands =
      let
        configTxt = pkgs.writeText "config.txt" ''
          [pi4]
          kernel=u-boot-rpi4.bin
          enable_gic=1
          armstub=armstub8-gic.bin
          disable_overscan=1
          arm_boost=1

          [all]
          arm_64bit=1
          # U-Boot needs this regardless of whether the UART is used.
          enable_uart=1
          avoid_warnings=1
        '';
      in
      ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)
        cp ${configTxt} firmware/config.txt
        cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin
        cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
        cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb firmware/
      '';

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  fileSystems."/".options = [ "noatime" ];
}
