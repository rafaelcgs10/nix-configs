{ pkgs, lib, config, ...}:
let
  unstable = import <nixpkgs-unstable> {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };
  };
  new_darktable = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/7eea86e9c4edb957d3fa952f7454e6cbdf1721e5.tar.gz";
    }) {};
  newer_channel = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/ffb547307d66d88c2af80c34818ac064d7958231.tar.gz";
    }) {};

  spektrafilm-flake = builtins.getFlake "github:rafaelcgs10/spektrafilm-art";
  spektrafilm-packages = spektrafilm-flake.packages.${builtins.currentSystem};

  # art-newer = (pkgs.art.overrideAttrs (oldAttrs: {
  #   version = "1.25.11-unstable-2026-04-01";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "artraweditor";
  #     repo = "ART";
  #     rev = "27554bbeab0adcd98335b0470b37c7bd3db1ae80";
  #     hash = "sha256-lCn/qBQ9PEx4pf+0y0fnWHZ2b68Lu6eLKHgcDzNAYio=";
  #   };
  #   postInstall = (oldAttrs.postInstall or "") + ''
  #     mkdir -p $out/share/ART/extlut
  #     cp -r $src/tools/extlut/* $out/share/ART/extlut/
  #   '';
  #   nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
  #   postFixup = (oldAttrs.postFixup or "") + ''
  #     wrapProgram $out/bin/ART \
  #       --prefix PATH : "${spektrafilm-python}/bin"
  #     wrapProgram $out/bin/ART-cli \
  #       --prefix PATH : "${spektrafilm-python}/bin"
  #   '';
  # }));

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
  # pinnedZoomPkgs =
  #   import
  #     (builtins.fetchTarball {
  #       url = "https://github.com/NixOS/nixpkgs/archive/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb.tar.gz";
  #       sha256 = "0ngw2shvl24swam5pzhcs9hvbwrgzsbcdlhpvzqc7nfk8lc28sp3";
  #     })
  #     {
  #       system = "x86_64-linux";
  #       config.allowUnfree = true;
  #     };
  #   pinnedZoom = pinnedZoomPkgs.zoom-us;
in
{
  home.packages = [
    pkgs.gimp3-with-plugins
    pkgs.inkscape
    pkgs.krita
    pkgs.lutris
    pkgs.gamescope
    pkgs.mangohud
    # (pkgs.lutris.override {
    #     extraPkgs = pkgs: [
    #       # List package dependencies here
    #       pkgs.wineWowPackages.stable
    #       pkgs.winetricks
    #     ];
    # })
    pkgs.hydralauncher
    pkgs.ludusavi
    pkgs.protonup-qt 
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
    # pkgs.libreoffice
    pkgs.onlyoffice-desktopeditors
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
    # pkgs.gpt4all
    newer_channel.lmstudio

    # pkgs.flameshot
    # pkgs.noisetorch
    # pkgs.networkmanagerapplet
    # pkgs.pa_applet
    # pkgs.xorg.xwininfo
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.srandrd
    # pkgs.glxinfo
    # pkgs.zoom-us
    pkgs.zoom-us              # picks up libpw-v4l2 via global LD_PRELOAD in home.nix
    unstable.signal-desktop
    # pkgs.jetbrains.idea-ultimate
    # pkgs.pavucontrol
    unstable.freetube
    new_darktable.darktable
    spektrafilm-packages.spektrafilm
    spektrafilm-packages.spektrafilm-art
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
    pkgs.xpra
    #
    # FIXME: move to kde things
    # pkgs.libsForQt5.kasts
    # pkgs.libsForQt5.plasma-browser-integration
    pkgs.proton-vpn
    pkgs.deluge
    # (pkgs.kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   youtube
    # ]))
  ];

  # home.file = {
  #   ".config/darktable/library.db".source = config.lib.file.mkoutofstoresymlink "/home/rafael/darktable/library.db";
  # };

  # Chromium command-line flags. Chromium reads ~/.config/chromium-flags.conf
  # on startup and appends each line as an extra argv. Used here to turn on
  # the WebRTC PipeWire camera backend (same reason as the brave entry below)
  # since chromium is installed as a plain package, not via programs.chromium.
  home.file.".config/chromium-flags.conf".text = ''
    --enable-features=WebRtcPipeWireCamera
  '';

  # LibreWolf: force the WebRTC PipeWire camera backend on. The same pref
  # set via programs.librewolf.settings goes into librewolf.overrides.cfg as
  # `defaultPref`, which is read too late for the `_AtStartup` static-pref
  # mirror — LibreWolf still picks the V4L2 path and enumerates zero cameras
  # on IPU3 hardware (Surface Go). Writing it as `user_pref` in the profile's
  # user.js is read early enough and actually flips the backend selection.
  #
  # NOTE: the profile dir name is the one auto-generated by LibreWolf on first
  # run. If the profile is ever deleted/recreated, update this path to match
  # the new random prefix (see ~/.librewolf/profiles.ini).
  home.file.".librewolf/zeku5s1n.default/user.js".text = ''
    // Managed by home-manager. See graphical-apps/default.nix.
    user_pref("media.webrtc.camera.allow-pipewire", true);
  '';

  programs.brave = {
    enable = true;
    # Enable the WebRTC PipeWire camera backend so the browser can see the
    # Surface Go's IPU3 cameras (no /dev/video* device exists for them — they
    # only show up through libcamera/PipeWire via the desktop portal).
    commandLineArgs = [ "--enable-features=WebRtcPipeWireCamera" ];
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
