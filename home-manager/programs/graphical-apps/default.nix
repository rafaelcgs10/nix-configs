{ pkgs, ...}:
let
  unstable = import <nixpkgs-unstable> {};
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/628884f74d718438364c3c38c632b31f28faebf8.tar.gz") {
    inherit pkgs;
  };
in
{
  home.packages = [
    pkgs.evince
    pkgs.okular
    pkgs.gimp
    pkgs.vlc
    pkgs.lxappearance
    pkgs.feh
    pkgs.gpicview
    pkgs.pscircle
    (pkgs.calibre.override { unrarSupport = true; })
    pkgs.remmina
    pkgs.pcmanfm
    pkgs.ffmpegthumbnailer
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
    pkgs.networkmanagerapplet
    pkgs.pa_applet
    pkgs.xorg.xwininfo
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.glxinfo

    pkgs.mendeley
    pkgs.chromium
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    extensions = with nur.repos.rycee.firefox-addons; [
      bitwarden
      decentraleyes
      https-everywhere
      privacy-badger
      ublock-origin
      vimium
      grammarly
      wayback-machine
      darkreader
    ];

    profiles = {
      default = {
        isDefault = true;
        settings = {
          "browser.quitShortcut.disabled" = true;
          "browser.ctrlTab.recentlyUsedOrder" = false;
          "extensions.pocket.enabled" = false;
          "middlemouse.paste" = false;

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
