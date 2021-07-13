{ pkgs, ...}:

{
  home.packages = [
    pkgs.evince
    pkgs.gimp
    pkgs.vlc
    pkgs.lxappearance
    pkgs.feh
    pkgs.gpicview
    pkgs.pscircle
    pkgs.qbittorrent
    pkgs.remmina
    pkgs.obs-studio
    pkgs.pcmanfm
    pkgs.libappindicator
    pkgs.gdk-pixbuf
    pkgs.gparted
    pkgs.gnomeExtensions.topicons-plus
    pkgs.gnomeExtensions.appindicator

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
