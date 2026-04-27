{ config, lib, pkgs, ... }:

{
  # Bootloader.
  # nvme0n1p1 is the EFI System Partition (100MB vfat, shared with Windows).
  # NixOS root is on nvme1n1 (WD Black).
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
}
