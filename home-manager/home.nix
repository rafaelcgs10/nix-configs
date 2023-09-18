{ config, pkgs, lib, getBin,... }:

let
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "23.05";

  imports = [
    ./imports/default.nix
  ];

  home.username = "rafael";
  home.homeDirectory = "/home/rafael";

  home.sessionVariables = {
    XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";
    JAVA_OPTS = "-Xverify:none";
    PAGER = "less";
    EDITOR = "vim";
    # LSP_USE_PLISTS = "true";

    USER_HOME = "/home/rafael";
    DIRENV_ALLOW_NIX = 1;
    CVC5_SOLVER = "/nix/store/wn18dx41k7b81naxgb3bv3qmkllaprsc-home-manager-path/bin/cvc5";
    IPROVER_HOME = "~/.nix-profile/bin";
    SATALLAX_HOME = "~/.nix-profile/bin";
    LEO3_HOME = "~/.nix-profile/bin";
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        # "application/pdf" = [ "org.gnome.Evince.desktop" ];
        # "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "x-scheme-handler/http=" = [ "brave-browser.desktop" ];
        "x-scheme-handler/https=" = [ "brave-browser.desktop" ];
        "x-scheme-handler/chrome" = [ "brave-browser.desktop" ];
        "text/html" = [ "brave-browser.desktop" ];
        # "application/x-zip" = [ "org.gnome.FileRoller.desktop" ];
        # "application/zip" = "org.gnome.FileRoller.desktop";
        # "application/rar" = "org.gnome.FileRoller.desktop";
        # "application/7z" = "org.gnome.FileRoller.desktop";
        # "application/*tar" = "org.gnome.FileRoller.desktop";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.ripgrep
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
    pkgs.lazydocker
    pkgs.libgccjit
    pkgs.neofetch
    pkgs.inxi
    pkgs.e2fsprogs
    pkgs.lightlocker
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
    pkgs.lazygit
    pkgs.k9s
    pkgs.xclip
    pkgs.direnv
    (pkgs.aspellWithDicts (d: [d.en d.pt_BR]))
    pkgs.hunspell
    pkgs.hunspellDicts.en_US-large
    pkgs.languagetool
    pkgs.progress
    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.enhanced-ctorrent
    pkgs.gcalcli
    pkgs.conky
    pkgs.netcat-gnu
    pkgs.traceroute
    pkgs.dmidecode
    pkgs.sysstat
    pkgs.hdparm
    pkgs.wdisplays
    pkgs.kanshi
    # pkgs.gnome.file-roller
    # pkgs.gnome.eog

    # Fonts
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    pkgs.noto-fonts-emoji
    pkgs.liberation_ttf
    pkgs.dina-font
    pkgs.mononoki
    pkgs.font-awesome_4
    pkgs.font-awesome_5
    pkgs.papirus-icon-theme
    # (pkgs.callPackage ./nuclear.nix {})
    # (pkgs.callPackage ./spotube.nix {})
    pkgs.iosevka
    pkgs.emacs-all-the-icons-fonts
    pkgs.emacsPackages.nerd-icons
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Mononoki" ]; })

    pkgs.rawtherapee

  ];
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
    userName = "rafaelcgs10";
    userEmail = "rafaelcgs10@gmail.com";
  };

  services.udiskie = {
    enable = true;
    tray = "auto";
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
