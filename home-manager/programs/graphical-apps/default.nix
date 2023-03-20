{ pkgs, lib, ...}:
let
  unstable = import <nixpkgs-unstable> {};
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/628884f74d718438364c3c38c632b31f28faebf8.tar.gz") {
    inherit pkgs;
  };

  alt_pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c03f5f557979825bcd34c4fbbd65766d1d44586d.tar.gz";
  }) {};

  purple_facebook =
    pkgs.purple-facebook.overrideAttrs (prev: {
      src = pkgs.fetchFromGitHub {
        owner = "dequis";
        repo = "purple-facebook";
        rev = "1a6711f83d62e374ca2bed41fd4ca25b6bc654a2";
        sha256 = "sha256-cqMsnJD5beYmrkKMkmBrOWFWiHjZ+mK/rJffR0aBOZ0=";
      };
    }) ;

in
{
  home.packages = [
    pkgs.gimp-with-plugins
    # pkgs.inkscape
    # pkgs.vlc
    # pkgs.kdenlive
    pkgs.lxappearance
    pkgs.redshift
    pkgs.xfce.xfce4-xkb-plugin
    pkgs.feh
    pkgs.qtikz
    pkgs.grsync
    pkgs. gsettings-desktop-schemas
    # pkgs.pdfpc
    pkgs.gpicview
    pkgs.pscircle
    # (pkgs.calibre.override { unrarSupport = true; })
    pkgs.libreoffice
    # pkgs.remmina
    pkgs.cinnamon.nemo
    pkgs.ffmpegthumbnailer
    pkgs.libappindicator
    pkgs.gdk-pixbuf
    pkgs.gparted
    pkgs.gnome.gnome-system-monitor
    pkgs.gnome.gnome-calculator
    pkgs.gnome.gnome-calendar
    pkgs.gnomeExtensions.topicons-plus
    pkgs.gnomeExtensions.appindicator
    unstable.qmplay2
    pkgs.sc-controller
    unstable.zulip
    pkgs.evince
    # pkgs.masterpdfeditor4

    pkgs.flameshot
    # pkgs.noisetorch
    pkgs.networkmanagerapplet
    pkgs.pa_applet
    pkgs.xorg.xwininfo
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.srandrd
    pkgs.glxinfo
    pkgs.pavucontrol

    pkgs.zotero
    pkgs.simple-scan
  ];

  programs.brave = {
    enable = true;
    extensions = [
      {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # uBlock Origin
      {id = "dbepggeogbaibhgnhhndojpepiihcmeb";} # Vimium
      {id = "ekhagklcjbdpajgpjgmbionohlpdbjgc";} # Zotero
      {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark reader
      {id = "oldceeleldhonbafppcapldpdifcinji";} # LanguageTool
      {id = "mdjildafknihdffpkfmmpnpoiajfjnjd";} # Consent-O-Matic
      { updateUrl = "https://raw.githubusercontent.com/libredirect/libredirect/master/src/updates/updates.xml"; id = "ongajcjccibkomjojhfmjedolopocllf"; } # LibRedirect
    ];
  };

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
