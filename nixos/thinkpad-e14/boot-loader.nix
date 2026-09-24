{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;

      # systemd-boot keeps every generation's kernel + initrd on the ESP, so an
      # unbounded list eventually fills the partition and breaks nixos-rebuild
      # ("No space left on device" while installing the bootloader). Cap the
      # menu; older generations are pruned on GC.
      #
      # This ESP is only 511MB. Measured 2026-09-24: each *distinct* kernel
      # costs 14MB (bzImage) + 73MB (initrd) = 87MB. Generations sharing a
      # kernel build share those files, but flake.lock auto-updates land a new
      # kernel most days, so "every retained generation has its own kernel" is
      # the normal case here rather than the worst case.
      #
      # The cap must also leave room for the install itself: systemd-boot
      # copies each initrd to a .tmp file before renaming it, so peak usage is
      # steady-state + one initrd (73MB), not just steady-state:
      #
      #   limit 5 -> 439MB + 73MB = 512MB  cannot fit in 511MB
      #   limit 4 -> 352MB + 73MB = 425MB  83%, little margin
      #   limit 3 -> 265MB + 73MB = 338MB  66%, comfortable
      #
      # Lowered from 5 after a switch failed on exactly this 2026-09-24. (That
      # run also had 264MB of stale GRUB-layout copies in /boot/kernels, left
      # from before this host used systemd-boot; removed, and unrelated to the
      # cap being wrong.)
      configurationLimit = 3;

      windows = {
        "windows" =
          let
            # To determine the name of the windows boot drive, boot into edk2 first, then run
            # `map -c` to get drive aliases, and try out running `FS1:`, then `ls EFI` to check
            # which alias corresponds to which EFI partition.
            boot-drive = "HD0b";
          in
          {
            title = "Windows";
            efiDeviceHandle = boot-drive;
            sortKey = "y_windows";
          };
      };

      edk2-uefi-shell.enable = true;
      edk2-uefi-shell.sortKey = "z_edk2";
    };
  };
}
