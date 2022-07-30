{ pkgs, ...}:
let
  unstable = import <nixpkgs-unstable> {};
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/628884f74d718438364c3c38c632b31f28faebf8.tar.gz") {
    inherit pkgs;
  };
in
{
  home.packages = [
    pkgs.gimp-with-plugins
    pkgs.vlc
    pkgs.kdenlive
    pkgs.lxappearance
    pkgs.feh
    pkgs.qtikz
    pkgs.grsync
    pkgs. gsettings-desktop-schemas
    pkgs.pdfpc
    pkgs.gpicview
    pkgs.pscircle
    (pkgs.calibre.override { unrarSupport = true; })
    pkgs.libreoffice
    pkgs.remmina
    pkgs.cinnamon.nemo
    pkgs.ffmpegthumbnailer
    pkgs.libappindicator
    pkgs.gdk-pixbuf
    pkgs.gparted
    pkgs.gnome.gnome-system-monitor
    pkgs.gnome.gnome-calculator
    pkgs.gnomeExtensions.topicons-plus
    pkgs.gnomeExtensions.appindicator
    unstable.qmplay2
    pkgs.sc-controller
    unstable.zulip
    pkgs.evince
    pkgs.masterpdfeditor4

    pkgs.flameshot
    pkgs.noisetorch
    pkgs.networkmanagerapplet
    pkgs.pa_applet
    pkgs.xorg.xwininfo
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.srandrd
    pkgs.glxinfo

    pkgs.zotero
    pkgs.chromium
    pkgs.simple-scan
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    extensions = with nur.repos.rycee.firefox-addons; [
      bitwarden
      decentraleyes
      privacy-badger
      ublock-origin
      vimium
      grammarly
      darkreader
      i-dont-care-about-cookies
    ];

    profiles = {
      default = {
        isDefault = true;
        settings = {
          "browser.quitShortcut.disabled" = true;
          "browser.ctrlTab.recentlyUsedOrder" = false;
          "extensions.pocket.enabled" = false;
          "middlemouse.paste" = false;
          "browser.casting.enabled" = true;

          # Hardware acceleration related settings.
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.ffmpeg.vaapi-drm-display.enabled" = true;
          "media.navigator.mediadatadecoder_vpx_enabled" = true;
          "media.rdd-vpx.enabled" = false;
          "media.ffvpx.enabled" = false;
          "browser.sessionstore.restore_on_demand" = false;
        };
      };
    };
  };

}
