{ pkgs, ...}:

let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; overlays = [(self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball "https://discord.com/api/download?platform=linux&format=tar.gz"; });})];};
in
{
  home.packages = [
    pkgs.evince
    pkgs.gimp
    pkgs.lxappearance
    pkgs.feh
    pkgs.gpicview
    pkgs.pscircle
    pkgs.qbittorrent
    pkgs.spotify
    pkgs.pcmanfm

    pkgs.whatsapp-for-linux
    pkgs.tdesktop
    pkgs.slack
    unstable.discord

    pkgs.flameshot
    pkgs.copyq
    pkgs.networkmanagerapplet
    pkgs.pa_applet
    pkgs.xorg.xwininfo
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.glxinfo

    # emacsPkgs.emacsGcc
    pkgs.emacs
    unstable.vivaldi
  ];
}
