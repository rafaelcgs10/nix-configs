# I/O responsiveness tuning for hosts with fast SSDs.
# Keeps the desktop responsive while heavy background I/O runs
# (nix-collect-garbage, btrfs balance, large builds).
# Not imported on bbtablet (weak hardware, slow disk).
{ config, pkgs, lib, ... }:

{
  # Cap the dirty-page writeback backlog with absolute sizes instead of
  # RAM-relative ratios. Default (20% of RAM) lets multi-GiB flush bursts
  # stall interactive processes for seconds; capped, stalls last ~100ms.
  boot.kernel.sysctl = {
    "vm.dirty_bytes" = 314572800; # 300 MB
    "vm.dirty_background_bytes" = 52428800; # 50 MB
  };

  # BFQ I/O scheduler: enforces per-process fairness and is the only
  # scheduler that honors ionice/IOSchedulingClass. Small peak-throughput
  # cost on NVMe, irrelevant for desktop use.
  boot.kernelModules = [ "bfq" ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="bfq"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
  '';

  # All nix-daemon work (builds, substitutions) at idle priority —
  # only effective with BFQ above.
  nix.daemonIOSchedClass = "idle";
  nix.daemonCPUSchedPolicy = "idle";

  # Automated maintenance jobs shouldn't compete with the desktop.
  systemd.services.nix-gc.serviceConfig = {
    IOSchedulingClass = "idle";
    CPUSchedulingPolicy = "idle";
  };
  systemd.services.btrfs-balance = lib.mkIf (config.fileSystems."/".fsType == "btrfs") {
    serviceConfig = {
      IOSchedulingClass = "idle";
      CPUSchedulingPolicy = "idle";
    };
  };
}
