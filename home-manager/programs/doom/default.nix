{ lib, pkgs, options, config, specialArgs, modulesPath }:

let
  emacs-overlay = builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/918199aeaa2c9b9d0f73e304a187a05b99fd9050.tar.gz;};
  # pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
in {
  home = {
    sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
    sessionVariables = {
      DOOMDIR = ~/nix-configs/home-manager/programs/doom/doom.d;
      DOOMLOCALDIR = ~/.doom-local;
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
  home.packages = [ pkgs.emacs ];
}
