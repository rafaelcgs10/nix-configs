{ pkgs, lib, config, pkgsUnstable, pkgsDarktable, pkgsLmstudio, spektrafilmPackages, ...}:

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
    pkgsUnstable.zulip
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
    pkgsLmstudio.lmstudio

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
    pkgsUnstable.signal-desktop
    # pkgs.jetbrains.idea-ultimate
    # pkgs.pavucontrol
    pkgsUnstable.freetube
    # darktable built from the spektrafilm PR branch (native C spektrafilm
    # module). Replaces the stock pkgsDarktable.darktable; the
    # runtime data pack and AI models are linked in via home.file below.
    spektrafilmPackages.darktable-spektrafilm-ai
    spektrafilmPackages.spektrafilm
    spektrafilmPackages.spektrafilm-art
    pkgs.vkdt
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

  # Film & print data pack for the darktable spektrafilm module. The module
  # reads pack.json + spectra_lut.f32 + profiles/ from this exact path
  # (dt_loc_get_user_config_dir()/spektrafilm), so link the pinned pack in.
  home.file.".config/darktable/spektrafilm".source =
    spektrafilmPackages.spektrafilm-data-pack;

  # Offline AI models for darktable's AI modules (denoise / upscale / object
  # masking). The fork reports version 5.8.0, which has no auto-download match,
  # so we bundle them here and link them into darktable's models dir (read-only;
  # darktable only scans it). Not used by spektrafilm itself.
  home.file.".local/share/darktable/models".source =
    spektrafilmPackages.darktable-ai-models;

  home.file.".local/share/darktable/raster-masks/.keep".text = "";

  # darktable stores the raster-mask export directory in darktablerc. Keep the
  # generated PNG masks out of $HOME without taking ownership of the full file.
  home.activation.setDarktableRasterMaskPath = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_file="${config.home.homeDirectory}/.config/darktable/darktablerc"
    mask_dir="${config.home.homeDirectory}/.local/share/darktable/raster-masks"

    ${pkgs.coreutils}/bin/mkdir -p "$mask_dir" "$(${pkgs.coreutils}/bin/dirname "$config_file")"
    ${pkgs.coreutils}/bin/touch "$config_file"

    if ${pkgs.gnugrep}/bin/grep -q '^plugins/darkroom/segments/def_path=' "$config_file"; then
      ${pkgs.gnused}/bin/sed -i \
        "s|^plugins/darkroom/segments/def_path=.*|plugins/darkroom/segments/def_path=$mask_dir|" \
        "$config_file"
    else
      printf '\nplugins/darkroom/segments/def_path=%s\n' "$mask_dir" >> "$config_file"
    fi
  '';

  # Chromium command-line flags. Chromium reads ~/.config/chromium-flags.conf
  # on startup and appends each line as an extra argv. Keep Chromium native on
  # Wayland at fractional scale and enable the WebRTC PipeWire camera backend.
  home.file.".config/chromium-flags.conf".text = ''
    --ozone-platform-hint=auto
    --enable-features=WaylandWindowDecorations,WebRtcPipeWireCamera
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
    # Keep Brave native on Wayland at fractional scale and enable the WebRTC
    # PipeWire camera backend for portal/libcamera cameras.
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=WaylandWindowDecorations,WebRtcPipeWireCamera"
    ];
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
