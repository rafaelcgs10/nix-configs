{ pkgs, lib, config, ...}:
let
  # nur = import (builtins.fetchTarball "https://github.com/nix-community/nur-combined/archive/fe301d9a7b9346a0d50252696b9a4feeed60f1c4.tar.gz") {
  #   inherit pkgs;
  # };
  unstable = import <nixpkgs-unstable> {};
  new_darktable = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/7eea86e9c4edb957d3fa952f7454e6cbdf1721e5.tar.gz";
    }) {};

  # createBraveExtensionFor = browserVersion: { id, sha256, version }:
  #   {
  #     inherit id;
  #     crxPath = builtins.fetchurl {
  #       url = "https://github.com/libredirect/libredirect/releases/download/v2.5.4/libredirect-2.5.4.crx";
  #       name = "${id}.crx";
  #       inherit sha256;
  #     };
  #     inherit version;
  #   };
  # createBraveExtension = createBraveExtensionFor (lib.versions.major pkgs.brave.version);
  pinnedZoomPkgs =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb.tar.gz";
        sha256 = "0ngw2shvl24swam5pzhcs9hvbwrgzsbcdlhpvzqc7nfk8lc28sp3";
      })
      {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    pinnedZoom = pinnedZoomPkgs.zoom-us;
in
{
  home.packages = [
    unstable.gimp3-with-plugins
    pkgs.inkscape
    pkgs.vlc
    # pkgs.qmplay2
    # pkgs.kdenlive
    # pkgs.lxappearance
    # pkgs.redshift
    # pkgs.xfce.xfce4-xkb-plugin
    pkgs.feh
    # pkgs.grsync
    # pkgs.gsettings-desktop-schemas
    # pkgs.pdfpc
    # pkgs.gpicview
    # pkgs.pscircle
    pkgs.inkscape
    # (pkgs.calibre.override { unrarSupport = true; })
    pkgs.libreoffice
    pkgs.onlyoffice-bin
    pkgs.dialect
    pkgs.calibre
    # pkgs.kdeconnect
    pkgs.remmina
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
    unstable.zulip
    pkgs.pgadmin4-desktopmode
    pkgs.handbrake # ghb
    pkgs.lshw-gui
    pkgs.freerdp
    # pkgs.evince
    # pkgs.masterpdfeditor4
    # nur.repos.some-pkgs.llama-cpp
    # nur.repos.xeals.amdgpu-fan
    # nur.repos.genesis.hdl-batch-installer
    pkgs.upscayl
    pkgs.gpt4all

    # pkgs.flameshot
    # pkgs.noisetorch
    # pkgs.networkmanagerapplet
    # pkgs.pa_applet
    # pkgs.xorg.xwininfo
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.srandrd
    pkgs.glxinfo
    # pkgs.zoom-us
    pinnedZoom
    pkgs.signal-desktop
    pkgs.jetbrains.idea-ultimate
    # pkgs.pavucontrol
    unstable.freetube
    new_darktable.darktable
    pkgs.focus-stack
    pkgs.hugin
    pkgs.exiftool
    pkgs.element-desktop
    pkgs.drawio
    pkgs.qalculate-qt
    pkgs.chromium

    pkgs.koreader
    pkgs.zotero
    pkgs.simple-scan
    pkgs.thunderbird
    pkgs.kdePackages.kalk
    #
    # FIXME: move to kde things
    pkgs.libsForQt5.kasts
    pkgs.libsForQt5.plasma-browser-integration
    pkgs.protonvpn-gui
    pkgs.deluge
    (pkgs.kodi.withPackages (kodiPkgs: with kodiPkgs; [
      youtube
    ]))
  ];

  home.file = {
    ".config/darktable/library.db".source = config.lib.file.mkOutOfStoreSymlink "/home/rafael/darktable/library.db";
  };

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
      # { version = "2.5.4"; crxPath = pkgs.fetchurl {url = "https://github.com/libredirect/libredirect/releases/download/v2.5.4/libredirect-2.5.4.crx"; sha256 = "1rc0r2ld17dswj961baz8fj99wvgvzgrhv7myvjw0w8hgg845mmv"; }; id = "ongajcjccibkomjojhfmjedolopocllf"; } # LibRedirect
    ];
  };

  # programs.firefox = {
  #   enable = true;
  #   package = pkgs.firefox;

  #   profiles = {
  #     # extensions = with nur.repos.rycee.firefox-addons; [
  #     #   bitwarden
  #     #   decentraleyes
  #     #   privacy-badger
  #     #   ublock-origin
  #     #   vimium
  #     #   darkreader
  #     #   i-dont-care-about-cookies
  #     # ];
  #     default = {
  #       isDefault = false;
  #       settings = {
  #         "browser.quitShortcut.disabled" = true;
  #         "browser.ctrlTab.recentlyUsedOrder" = false;
  #         "extensions.pocket.enabled" = false;
  #         "middlemouse.paste" = false;
  #         "browser.casting.enabled" = true;

  #         # Hardware acceleration related settings.
  #         "gfx.webrender.all" = true;
  #         "media.ffmpeg.vaapi.enabled" = true;
  #         "media.ffmpeg.vaapi-drm-display.enabled" = true;
  #         "media.navigator.mediadatadecoder_vpx_enabled" = true;
  #         "media.rdd-vpx.enabled" = false;
  #         "media.ffvpx.enabled" = false;
  #         "browser.sessionstore.restore_on_demand" = false;
  #       };
  #     };
  #   };
  # };

  programs.librewolf = {
    enable = true;
    settings = {
      "webgl.disabled" = false;
      "privacy.resistFingerprinting" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "network.cookie.lifetimePolicy" = 0;
    };

    # profiles = {
    #   # extensions = with nur.repos.rycee.firefox-addons; [
    #   #   bitwarden
    #   #   decentraleyes
    #   #   privacy-badger
    #   #   ublock-origin
    #   #   vimium
    #   #   darkreader
    #   #   i-dont-care-about-cookies
    #   # ];
    #   # default = {
    #   #   isDefault = true;
    #   #   settings = {
    #   #     "browser.quitShortcut.disabled" = true;
    #   #     "browser.ctrlTab.recentlyUsedOrder" = false;
    #   #     "extensions.pocket.enabled" = false;
    #   #     "middlemouse.paste" = false;
    #   #     "browser.casting.enabled" = true;

    #   #     # Hardware acceleration related settings.
    #   #     "gfx.webrender.all" = true;
    #   #     "media.ffmpeg.vaapi.enabled" = true;
    #   #     "media.ffmpeg.vaapi-drm-display.enabled" = true;
    #   #     "media.navigator.mediadatadecoder_vpx_enabled" = true;
    #   #     "media.rdd-vpx.enabled" = false;
    #   #     "media.ffvpx.enabled" = false;
    #   #     "browser.sessionstore.restore_on_demand" = false;
    #   #   };
    #   # };
    # };
  };

}
