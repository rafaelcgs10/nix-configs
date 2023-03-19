{ config, pkgs, lib, ... }:

let
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";

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
    pkgs.iosevka
    pkgs.emacs-all-the-icons-fonts
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Mononoki" ]; })

  ];

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

  # services.lorri.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
