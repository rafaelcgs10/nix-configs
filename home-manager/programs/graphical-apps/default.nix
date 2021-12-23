{ pkgs, ...}:
let
  unstable = import <nixpkgs-unstable> {};
in
{
  home.packages = [
    pkgs.evince
    pkgs.okular
    unstable.isabelle
    unstable.coq
    pkgs.gimp
    pkgs.vlc
    pkgs.lxappearance
    pkgs.feh
    pkgs.gpicview
    pkgs.pscircle
    (pkgs.calibre.override { unrarSupport = true; })
    pkgs.remmina
    pkgs.pcmanfm
    pkgs.libappindicator
    pkgs.gdk-pixbuf
    pkgs.gparted
    pkgs.gnomeExtensions.topicons-plus
    pkgs.gnomeExtensions.appindicator
    unstable.qmplay2
    pkgs.sc-controller
    unstable.zulip

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
