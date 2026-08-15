{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;

      # systemd-boot keeps every generation's kernel + initrd on the ESP
      # (~25MB each), so an unbounded list eventually fills the partition and
      # breaks nixos-rebuild. Cap the menu; older generations are pruned on GC.
      configurationLimit = 10;

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
