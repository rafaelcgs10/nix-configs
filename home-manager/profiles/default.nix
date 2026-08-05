{ config, pkgs, lib, ... }:

{
  imports = [
    ../programs/languages/default.nix
    ../programs/doom/default.nix
    ../programs/zsh/default.nix
    ../programs/nvim/default.nix
    ../programs/cosmic/default.nix
    ../programs/jedit/default.nix
    ../programs/graphical-apps/default.nix
    ../programs/non-arm/default.nix
    ../programs/wine-apps/default.nix
  ];
}
