{ config, pkgs, lib, inputs, ... }:

# NixOS running as a WSL2 distribution inside the WinApps Windows 11 VM.
# Built with `common = false` in flake.nix, so none of the laptop/desktop
# plumbing from nixos/configuration.nix is here; this file is the whole
# system half, and the `wsl` home-manager profile is the user half.
#
# Rebuild from inside WSL (a clone of nix-configs in ~/nix-configs):
#   sudo nixos-rebuild switch --flake ~/nix-configs#wsl
{
  wsl = {
    enable = true;
    defaultUser = "rafael";
    # Windows Start menu shortcuts for the desktop entries home-manager
    # installs (e.g. "Emacs (Client)"); GUI apps open through WSLg.
    startMenuLaunchers = true;
  };

  # home.nix gates host-specific bits on osConfig.networking.hostName.
  networking.hostName = "wsl";

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
    trusted-users = [ "root" "rafael" ];
    # Same binary cache as the other hosts (affinity-nix); harmless here.
    extra-substituters = [ "https://cache.forall.systems" ];
    extra-trusted-public-keys = [
      "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
    ];
    download-buffer-size = 524288000;
  };

  # Disk inside the VM is the scarce resource (WSL vhdx inside a qcow2).
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.min-free = 2 * 1024 * 1024 * 1024;
  nix.settings.max-free = 8 * 1024 * 1024 * 1024;

  # The WSL module creates the default user; this only sets the shell and
  # groups. No password: NixOS-WSL gives wheel passwordless sudo.
  users.users.rafael = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  programs.git = {
    enable = true;
    config.safe.directory = "/home/rafael/nix-configs";
  };

  environment.systemPackages = with pkgs; [ git vim wget curl ];

  time.timeZone = "Europe/Copenhagen";

  system.stateVersion = "26.05";
}
