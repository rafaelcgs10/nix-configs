{ pkgs, ...}:
let
  unstable = import <nixpkgs-unstable> {};
in
{
  home.packages = [
    pkgs.evince
    pkgs.gimp
    pkgs.vlc
    pkgs.lxappearance
    pkgs.feh
    pkgs.gpicview
    pkgs.pscircle
    (pkgs.calibre.override { unrarSupport = true; })
    pkgs.qbittorrent
    pkgs.remmina
    pkgs.pcmanfm
    pkgs.libappindicator
    pkgs.gdk-pixbuf
    pkgs.gparted
    pkgs.insomnia
    pkgs.gnomeExtensions.topicons-plus
    pkgs.gnomeExtensions.appindicator
    unstable.qmplay2

    pkgs.flameshot
    pkgs.noisetorch
    pkgs.copyq
    pkgs.networkmanagerapplet
    pkgs.pa_applet
    pkgs.xorg.xwininfo
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.glxinfo

    # emacsPkgs.emacsGcc
  ];
}
