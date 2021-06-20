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
    ./programs/xmonad/default.nix
    ./programs/doom/default.nix
    ./programs/zsh/default.nix
    ./programs/nvim/default.nix
    ./programs/alacritty/default.nix
    ./programs/rofi/default.nix
    ./programs/X-themes/default.nix
    ./programs/polybar/default.nix
    ./programs/rd-docker/default.nix
  ];

  home.username = "rafael";
  home.homeDirectory = "/home/rafael";

  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "vim";
    DOOMDIR = "$HOME/nix-configs/doom.d";
    EMACSDIR = "$HOME/.emacs.d";
    DOOMLOCALDIR = "$HOME/.doom_local";
    DIRENV_ALLOW_NIX = 1;
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.ripgrep
    pkgs.jq
    pkgs.tree
    pkgs.zsh
    pkgs.rnix-lsp
    pkgs.lazydocker
    pkgs.libgccjit
    pkgs.neofetch
    pkgs.inxi
    pkgs.pciutils
    pkgs.lm_sensors
    (pkgs.aspellWithDicts (d: [d.en]))

    unstable.vivaldi
    pkgs.evince
    pkgs.gimp
    pkgs.lxappearance
    pkgs.feh
    pkgs.gpicview
    pkgs.pscircle
    pkgs.qbittorrent
    pkgs.spotify
    pkgs.pcmanfm

    pkgs.whatsapp-for-linux
    pkgs.tdesktop
    pkgs.slack
    unstable.discord

    pkgs.flameshot
    pkgs.copyq
    pkgs.networkmanagerapplet
    pkgs.pa_applet
    pkgs.xorg.xwininfo
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.glxinfo

    # emacsPkgs.emacsGcc
    pkgs.emacs
  ];

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
