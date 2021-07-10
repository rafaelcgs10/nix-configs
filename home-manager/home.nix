{ config, pkgs, lib, ... }:

let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; overlays = [(self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball "https://discord.com/api/download?platform=linux&format=tar.gz"; });})];};
  emacs-overlay = builtins.fetchTarball "https://github.com/nix-community/emacs-overlay/archive/15ed1f372a83ec748ac824bdc5b573039c18b82f.tar.gz";
  emacsPkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "21.03";

  imports = [
    ./imports/default.nix
  ];

  home.username = "rafael";
  home.homeDirectory = "/home/rafael";

  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "vim";
    DIRENV_ALLOW_NIX = 1;
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.ripgrep
    pkgs.jq
    pkgs.tree
    pkgs.nmap
    pkgs.zsh
    pkgs.rnix-lsp
    pkgs.lazydocker
    pkgs.libgccjit
    pkgs.neofetch
    pkgs.inxi
    pkgs.tmux
    pkgs.pciutils
    unstable.x2goclient
    unstable.x2goserver
    pkgs.lm_sensors
    (pkgs.aspellWithDicts (d: [d.en]))

  # Fonts
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk
    pkgs.noto-fonts-emoji
    pkgs.liberation_ttf
    pkgs.dina-font
    pkgs.mononoki
    pkgs.font-awesome_5
    pkgs.papirus-icon-theme
    pkgs.iosevka
    pkgs.emacs-all-the-icons-fonts
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })

  ];


  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    userName = "rafaelcgs10";
    userEmail = "rafaelcgs10@gmail.com";
  };

  services.udiskie = {
    enable = true;
    tray = "always";
  };

  programs.direnv.enable = true;
  programs.direnv.enableNixDirenvIntegration = true;
}
