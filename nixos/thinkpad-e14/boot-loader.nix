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
      # This ESP is only 511MB and initrds have grown well past the ~25MB this
      # comment used to assume: measured 2026-09-12, each retained kernel costs
      # ~13.5MB (bzImage) + 40-73MB (initrd), i.e. up to ~86MB. Generations
      # sharing a kernel build share those files, so 12 entries were fitting in
      # 245MB -- but a run of distinct kernels at limit 10 would need ~860MB and
      # cannot fit. 5 bounds the worst case at ~430MB with room for the Windows
      # entry and the edk2 shell.
      configurationLimit = 5;

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
