{ config, pkgs, lib, ... }:

{
  imports = [
    ../../programs/xmonad/default.nix
    ../../programs/languages/default.nix
    ../../programs/doom/default.nix
    ../../programs/zsh/default.nix
    ../../programs/nvim/default.nix
    ../../programs/copyq/default.nix
    ../../programs/alacritty/default.nix
    ../../programs/rofi/default.nix
    ../../programs/X-themes/default.nix
    ../../programs/polybar/default.nix
    ../../programs/gcloud/default.nix
    ../../programs/graphical-apps/default.nix
    ../../programs/non-arm/default.nix
  ];
}
