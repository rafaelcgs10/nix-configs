{ config, lib, pkgs, ... }:

{
  # Bootloader.
  # nvme0n1p1 is the EFI System Partition (100MB vfat, shared with Windows).
  # NixOS root is on nvme1n1 (WD Black).
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.useOSProber = false;
  boot.loader.grub.extraEntries = ''
    menuentry "Windows Boot Manager" {
      insmod part_gpt
      insmod fat
      insmod chain
      search --no-floppy --fs-uuid --set=root 1A36-4B87
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
}
