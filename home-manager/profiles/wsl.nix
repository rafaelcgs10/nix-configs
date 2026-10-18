{ config, pkgs, lib, ... }:

# Home profile for the NixOS-WSL host inside the WinApps Windows VM. Kept to
# the editor stack: no COSMIC, graphical-apps, wine or language toolchains
# (the full languages bundle alone is tens of GB of store, inside a vhdx,
# inside a qcow2). Add modules here as the disk allows.
{
  imports = [
    ../programs/doom/default.nix
    ../programs/zsh/default.nix
    ../programs/nvim/default.nix
    # nix-configs-autoupdate.nix is deliberately NOT imported (same reasoning
    # as the bbtablet profile): this host has no system.autoUpgrade, so it
    # must not push lock bumps it never builds.
  ];

  # The Doom module starts the Emacs daemon with graphical-session.target,
  # which WSL never reaches (no login session manager). Start it with the
  # plain user session instead; `emacsclient -c` then opens a WSLg window.
  services.emacs.startWithUserSession = lib.mkForce true;
}
