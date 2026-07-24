{ config, pkgs, pkgsUnstable, lib, getBin, osConfig ? null, ... }:

let
  hostName = if osConfig == null then "" else osConfig.networking.hostName or "";
  isBbtablet = hostName == "bbtablet";
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      "orangessh.rafaelcgs.com" = {
        HostName = "orangessh.rafaelcgs.com";
        User = "rafael";
        ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
      };
    };
  };

  home.stateVersion = "26.05";

  home.username = "rafael";
  home.homeDirectory = "/home/rafael";

  home.sessionVariables = {
    XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS";
    # Prevent Java/Swing apps (like jEdit) from being double-scaled on Wayland/XWayland.
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dsun.java2d.uiScale=1";
    JAVA_OPTS = "-Xverify:none";
    PAGER = "less";
    GTK_USE_PORTAL = "1";
    EDITOR = "vim";
    # LSP_USE_PLISTS = "true";

    # Wayland native rendering for Qt/GTK apps (performance at 4K scaling).
    # Note: do NOT set GDK_BACKEND here. xdg-desktop-portal-gnome 50+ treats
    # *any* explicit GDK_BACKEND as "forced" and refuses to expose dialog
    # interfaces (Access, Camera, FileChooser, …), which breaks portal-using
    # apps like GNOME Snapshot, Firefox getUserMedia, etc. GTK4 already picks
    # Wayland automatically when WAYLAND_DISPLAY is set.
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    # Improve XWayland app rendering (apps that can't use Wayland)
    XCURSOR_SIZE = "32";

    USER_HOME = "/home/rafael";
    DIRENV_ALLOW_NIX = 1;
    CVC5_SOLVER = "/nix/store/wn18dx41k7b81naxgb3bv3qmkllaprsc-home-manager-path/bin/cvc5";
    IPROVER_HOME = "~/.nix-profile/bin";
    SATALLAX_HOME = "~/.nix-profile/bin";
    LEO3_HOME = "~/.nix-profile/bin";
    IQ_AUTH_TOKEN = "MY_TOKEN";
  } // lib.optionalAttrs isBbtablet {
    # Only the tablet needs this IPU3 camera bridge. Do not preload it into
    # desktop compositors such as COSMIC on bbstation.
    LD_PRELOAD = "${pkgs.pipewire}/lib/pipewire-0.3/v4l2/libpw-v4l2.so";
  };

  home.file.".config/winapps/compose.yaml".text = builtins.readFile ../winapps/compose.yaml;

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        # "application/pdf" = [ "org.gnome.Evince.desktop" ];
        # "image/jpeg" = [ "org.gnome.eog.desktop" ];
        # "x-scheme-handler/http=" = [ "brave-browser.desktop" ];
        # "x-scheme-handler/https=" = [ "brave-browser.desktop" ];
        # "x-scheme-handler/chrome" = [ "brave-browser.desktop" ];
        # "text/html" = [ "brave-browser.desktop" ];
        # "application/x-zip" = [ "org.gnome.FileRoller.desktop" ];
        # "application/zip" = "org.gnome.FileRoller.desktop";
        # "application/rar" = "org.gnome.FileRoller.desktop";
        # "application/7z" = "org.gnome.FileRoller.desktop";
        # "application/*tar" = "org.gnome.FileRoller.desktop";
      };
    };
  };

  home.packages = [
    pkgs.gawk
    pkgs.jq
    pkgs.tree
    pkgs.ranger
    pkgs.nmap
    pkgs.unzip
    pkgs.unrar
    pkgs.p7zip
    pkgs.zip
    pkgs.zsh
    pkgs.dig
    pkgs.lazydocker
    pkgs.libgccjit
    pkgs.owofetch
    pkgs.inxi
    pkgs.e2fsprogs
    pkgs.tmux
    pkgs.pciutils
    pkgs.openfortivpn
    pkgs.lm_sensors
    pkgs.bc
    pkgs.pv
    pkgs.s-tui
    pkgs.stress
    pkgs.flamegraph
    # pkgs.perf-tools
    pkgs.git-lfs
    pkgs.kubectl
    pkgs.kubernetes
    pkgs.podman
    pkgs.lazygit
    pkgs.k9s
    pkgs.xclip
    pkgs.direnv
    (pkgs.aspellWithDicts (d: [d.en d.pt_BR]))
    pkgs.hunspell
    pkgs.hunspellDicts.en_US-large
    pkgs.languagetool
    pkgs.ltex-ls
    pkgs.progress
    pkgs.ffmpeg
    pkgs.gcalcli
    pkgs.conky
    pkgs.netcat-gnu
    pkgs.traceroute
    pkgs.dmidecode
    pkgs.sysstat
    pkgs.hdparm
    pkgs.wdisplays
    pkgs.kanshi
    pkgs.fd
    pkgs.imagemagick
    pkgs.zstd
    pkgs.sqlite
    pkgs.android-tools
    # (pkgs.ripgrep.override { withPCRE2 = true; })
    pkgs.ripgrep
    pkgsUnstable.rclone
    pkgs.veracrypt
    pkgs.graphviz
    pkgs.hcxdumptool
    pkgs.hcxtools
    pkgs.hashcat
    pkgs.hashcat-utils
    pkgs.wifite2
    pkgs.iw
    pkgs.macchanger
    pkgs.aircrack-ng
    pkgs.john
    pkgs.bully
    pkgsUnstable.gallery-dl
    # pkgs.youtube-dl
    pkgs.fuse
    pkgs.sshfs
    pkgs.syncthing
    (pkgs.stdenv.mkDerivation {
      pname = "opencode-baseline";
      version = "1.17.6";
      src = pkgs.fetchzip {
        url = "https://github.com/anomalyco/opencode/releases/download/v1.17.6/opencode-linux-x64-baseline.tar.gz";
        hash = "sha256-Q3Y7b29AVyx6RVtxDApTAIeHme8NnAsSLM/3I2Qhtbs=";
        stripRoot = false;
      };
      nativeBuildInputs = [ pkgs.patchelf ];
      dontConfigure = true;
      dontBuild = true;
      dontStrip = true;
      dontPatchELF = true;
      installPhase = ''
        runHook preInstall
        install -Dm755 opencode $out/bin/opencode
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/opencode
        runHook postInstall
      '';
      meta.mainProgram = "opencode";
    })
    pkgs.claude-code
    # pkgs.gnome.file-roller
    # pkgs.gnome.eog

    # Fonts
    pkgs.noto-fonts
    # pkgs.noto-fonts-cjk
    # pkgs.noto-fonts-emoji
    pkgs.liberation_ttf
    pkgs.dina-font
    pkgs.mononoki
    # pkgs.font-awesome_4
    # pkgs.font-awesome_5
    pkgs.papirus-icon-theme
    pkgs.corefonts
    # pkgs.vistafonts
    pkgs.fira-code
    # pkgs.wine64
    # pkgs.wineWow64Packages.full
    # pkgs.wineWowPackages.stable
    pkgs.phockup
    # (pkgs.callPackage ./spotube.nix {})
    pkgs.iosevka
    pkgs.emacs-all-the-icons-fonts
    pkgs.emacsPackages.nerd-icons
    pkgs.emacsPackages.all-the-icons
    # pkgs.emacsPackages.treemacs-all-the-icons
    pkgs.emacsPackages.all-the-icons-nerd-fonts
    pkgs.emacsPackages.all-the-icons-completion
    # (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Mononoki" ]; })

  ];

  home.enableNixpkgsReleaseCheck = false;
  # programs.firejail = {
  #   wrappedBinaries = {
  #     firefox = {
  #       executable = "${pkgs.firefox}/bin/firefox";
  #       profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
  #       # desktop = "''${pkgs.firefox}/share/applications/firefox.desktop";
  #       # extraArgs = [ "--private" ];
  #     };
  #     brave = {
  #       executable = "${pkgs.lib.getBin pkgs.brave}/bin/brave";
  #       profile = "${pkgs.firejail}/etc/firejail/brave.profile";
  #     };
  #   };
  # };

  programs.fzf = {
    enable = true;
  };

  fonts.fontconfig.enable = true;
  home.file.".local/share/fonts/IsabelleDejaVuSansMono.ttf".source = ../fonts/IsabelleDejaVuSansMono.ttf;

  programs.git = {
    enable = true;
    settings.user = {
      name = "rafaelcgs10";
      email = "rafaelcgs10@gmail.com";
    };
  };

  home.file.".languagetool.cfg".text = ''
    #LanguageTool configuration (5.9/2022-09-28 14:38:38 +0000)
    #Mon Apr 03 14:44:01 CEST 2023
    ltVersion=5.9
    #Profile: Default
    #Mon Apr 03 14:44:01 CEST 2023
    enabledRules.en-US=HASH_SYMBOL,E_PRIME_LOOSE,WIKIPEDIA_CONTRACTIONS,WIKIPEDIA_CURRENTLY,E_PRIME_STRICT,READABILITY_RULE_SIMPLE,READABILITY_RULE_DIFFICULT,WIKIPEDIA_12_PM,WIKIPEDIA_12_AM
    serverMode=false
    taggerShowsDisambigLog=false
    font.size=13
    useGUIConfig=false
    font.name=mononoki
    language=en-US
    serverPort=8081
    autoDetect=false
    lookAndFeelName=GTK+
    enabledCategories.en-US=Creative Writing,Text Analysis,Wikipedia
    font.style=0
  '';

  # services.lorri.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
