{ pkgs, lib, ...}:
let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/f944f5befe39d7cf27cd0b41960ace172f9241b3.tar.gz") {
    inherit pkgs;
  };
  unstable = import <nixpkgs-unstable> {};

  createBraveExtensionFor = browserVersion: { id, sha256, version }:
    {
      inherit id;
      crxPath = builtins.fetchurl {
        url = "https://github.com/libredirect/libredirect/releases/download/v2.5.4/libredirect-2.5.4.crx";
        name = "${id}.crx";
        inherit sha256;
      };
      inherit version;
    };
  createBraveExtension = createBraveExtensionFor (lib.versions.major pkgs.brave.version);
in
{
  home.packages = [
    pkgs.gimp-with-plugins
    # pkgs.inkscape
    # pkgs.vlc
    # pkgs.kdenlive
    # pkgs.lxappearance
    # pkgs.redshift
    # pkgs.xfce.xfce4-xkb-plugin
    pkgs.feh
    pkgs.grsync
    # pkgs.gsettings-desktop-schemas
    # pkgs.pdfpc
    # pkgs.gpicview
    # pkgs.pscircle
    pkgs.inkscape
    # (pkgs.calibre.override { unrarSupport = true; })
    pkgs.libreoffice
    pkgs.dialect
    pkgs.calibre
    # pkgs.kdeconnect
    # pkgs.remmina
    # pkgs.cinnamon.nemo
    # unstable.cinnamon.nemo-fileroller
    # unstable.cinnamon.nemo-with-extensions
    pkgs.ffmpegthumbnailer
    pkgs.libappindicator
    pkgs.gdk-pixbuf
    pkgs.gparted
    # pkgs.gnome.gnome-system-monitor
    # pkgs.gnome.gnome-calculator
    # pkgs.gnome.gnome-calendar
    # pkgs.gnomeExtensions.topicons-plus
    # pkgs.gnomeExtensions.appindicator
    # unstable.qmplay2
    pkgs.sc-controller
    pkgs.vlc
    unstable.zulip
    pkgs.evince
    # pkgs.masterpdfeditor4
    # nur.repos.some-pkgs.llama-cpp
    nur.repos.some-pkgs.alpaca-cpp
    nur.repos.foolnotion.upscayl

    # pkgs.flameshot
    # pkgs.noisetorch
    # pkgs.networkmanagerapplet
    # pkgs.pa_applet
    # pkgs.xorg.xwininfo
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.srandrd
    pkgs.glxinfo
    # pkgs.pavucontrol
    unstable.freetube
    unstable.darktable
    pkgs.focus-stack
    pkgs.hugin
    pkgs.exiftool
    pkgs.element-desktop

    pkgs.zotero
    pkgs.simple-scan
    #
    # FIXME: move to kde things
    pkgs.libsForQt5.kasts
    pkgs.libsForQt5.plasma-browser-integration
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
      # ( createBraveExtension {id = "ongajcjccibkomjojhfmjedolopocllf"; version = "2.5.4"; sha256 = "1rc0r2ld17dswj961baz8fj99wvgvzgrhv7myvjw0w8hgg845mmv";} )
      { version = "2.5.4"; crxPath = pkgs.fetchurl {url = "https://github.com/libredirect/libredirect/releases/download/v2.5.4/libredirect-2.5.4.crx"; sha256 = "1rc0r2ld17dswj961baz8fj99wvgvzgrhv7myvjw0w8hgg845mmv"; }; id = "ongajcjccibkomjojhfmjedolopocllf"; } # LibRedirect
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
