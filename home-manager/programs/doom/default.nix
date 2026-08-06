{ config, lib, pkgs, pkgsEmacs, ... }:

{
  home = {
    sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];
    sessionVariables = {
      DOOMDIR = "${config.home.homeDirectory}/nix-configs/home-manager/programs/doom/doom.d";
      DOOMLOCALDIR = "${config.home.homeDirectory}/.doom-local";
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
  # wordnet provides the `wn' binary + offline WordNet database used by Doom's
  # (lookup +dictionary +offline) backends: wordnut for definitions and
  # synosaurus-wordnet for synonyms.
  home.packages = [ pkgsEmacs.emacs-pgtk pkgsEmacs.hack-font pkgs.wordnet ];
}
