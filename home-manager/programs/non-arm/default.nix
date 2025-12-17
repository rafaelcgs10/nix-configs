{ pkgs, ...}:

let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; overlays = [(self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball "https://discord.com/api/download?platform=linux&format=tar.gz"; });})];};
  newer_pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/897876e4c484f1e8f92009fd11b7d988a121a4e7.tar.gz";
  }) {};
in
{
  home.packages = [
    # pkgs.spotify
    # pkgs.whatsapp-for-linux
    pkgs.insomnia
    pkgs.telegram-desktop
    pkgs.caprine-bin
    pkgs.obs-studio
    pkgs.synology-drive-client
    # unstable.lutris
    pkgs.tlaplusToolbox
    pkgs.discord
    # (pkgs.callPackage ../iopaint/default.nix {})
    # (newer_pkgs.qt6Packages.callPackage ../gpt4all.nix {})

    # pkgs.google-cloud-sdk
  ];
}
