{ pkgs, ...}:

let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; overlays = [(self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball "https://discord.com/api/download?platform=linux&format=tar.gz"; });})];};
in
{
  home.packages = [
    pkgs.spotify
    pkgs.whatsapp-for-linux
    pkgs.insomnia
    pkgs.tdesktop
    pkgs.slack
    pkgs.obs-studio
    pkgs.tlaplusToolbox
    unstable.discord
    pkgs.bitwarden

    pkgs.google-cloud-sdk
    pkgs.vivaldi
  ];
}
