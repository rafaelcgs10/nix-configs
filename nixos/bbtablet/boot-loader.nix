{ config, lib, pkgs, ... }:

{
  # systemd-boot (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # systemd-boot keeps every generation's kernel + initrd on the ESP (~25MB
  # each), so an unbounded list eventually fills the partition and breaks
  # nixos-rebuild. Cap the menu; older generations are pruned on GC.
  boot.loader.systemd-boot.configurationLimit = 10;
}
