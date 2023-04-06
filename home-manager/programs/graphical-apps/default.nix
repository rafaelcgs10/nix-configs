{ pkgs, lib, ...}:
let
  # nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/628884f74d718438364c3c38c632b31f28faebf8.tar.gz") {
  #   inherit pkgs;
  # };
  unstable = import <nixpkgs-unstable> {};

in
{
  home.packages = [
    pkgs.gimp-with-plugins
    # pkgs.inkscape
    # pkgs.vlc
    # pkgs.kdenlive
    # pkgs.lxappearance
    pkgs.redshift
    # pkgs.xfce.xfce4-xkb-plugin
    pkgs.feh
    pkgs.qtikz
    pkgs.grsync
    pkgs.gsettings-desktop-schemas
    # pkgs.pdfpc
    pkgs.gpicview
    pkgs.pscircle
    # (pkgs.calibre.override { unrarSupport = true; })
    pkgs.libreoffice
    pkgs.dialect
    pkgs.kdeconnect
    # pkgs.remmina
    # pkgs.cinnamon.nemo
    unstable.cinnamon.nemo-fileroller
    unstable.cinnamon.nemo-with-extensions
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
      {id = "dphilobhebphkdjbpfohgikllaljmgbn";} # Simple login
      {id = "oldceeleldhonbafppcapldpdifcinji";} # LanguageTool
      {id = "mdjildafknihdffpkfmmpnpoiajfjnjd";} # Consent-O-Matic
      { version = "2.1.0"; crxPath = pkgs.fetchurl {url = "https://github.com/libredirect/libredirect/releases/download/v2.1.0/libredirect-2.1.0.crx"; sha256 = "0zhhpxpzxlmhxmsii85j1h53q5dn8gsyc1g79hi43vrwnggiwhl1"; }; id = "ongajcjccibkomjojhfmjedolopocllf"; } # LibRedirect
    ];
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    profiles = {
      # extensions = with nur.repos.rycee.firefox-addons; [
      #   bitwarden
      #   decentraleyes
      #   privacy-badger
      #   ublock-origin
      #   vimium
      #   grammarly
      #   darkreader
      #   i-dont-care-about-cookies
      # ];
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
