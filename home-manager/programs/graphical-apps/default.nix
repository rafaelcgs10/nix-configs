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
    pkgs.pcmanfm

    pkgs.flameshot
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
