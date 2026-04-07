{ config, lib, pkgs, ... }:

let
  emacs-overlay = builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/9714d18e3b55f61531a42795779a941365cb2588.tar.gz;};
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
in {
  home = {
    sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
    sessionVariables = {
      DOOMDIR = ~/nix-configs/home-manager/programs/doom/doom.d;
      DOOMLOCALDIR = ~/.doom-local;
      OZONE_PLATFORM = "wayland";
    };
  };
  # xdg = {
  #   enable = true;
  #   configFile = {
  #     "emacs" = {
  #       source = builtins.fetchGit "https://github.com/hlissner/doom-emacs";
  #     };
  #   };
  # };
  home.packages = [ pkgs.emacs-pgtk ];
}
