{ config, lib, pkgs, ... }:

{
  # Bootloader.
  # GRUB is installed on nvme0n1 (Samsung, Windows drive) — this is what the BIOS boots.
  # NixOS root is on nvme1n1 (WD Black).
  # Windows partitions on nvme0n1: p1=100M vfat (boot), p2=16M MSR, p3=NTFS (OS), p4=NTFS (recovery).
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  # Manual Windows entry: nvme0n1 is hd0 (BIOS boots it first).
  # Disk uses GPT, p1 is the 100MB Windows boot partition.
  # BIOS chainloader: hand off to the partition's boot sector.
  boot.loader.grub.extraEntries = ''
    menuentry "Windows" {
      insmod part_gpt
      insmod ntfs
      insmod chain
      set root=(hd0,gpt1)
      chainloader +1
    }
  '';
}

