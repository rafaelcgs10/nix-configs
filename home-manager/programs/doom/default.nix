{ lib, pkgs, options, config, specialArgs, modulesPath }:

let
  emacs-overlay = builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/6d9837126e1be779c8f34ed9fdd609e676a1b891.tar.gz;};
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
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
