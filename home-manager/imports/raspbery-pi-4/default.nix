{ config, pkgs, lib, ... }:

{
  imports = [
    ../../programs/xmonad/default.nix
    ../../programs/doom/default.nix
    ../../programs/zsh/default.nix
    ../../programs/alacritty/default.nix
    ../../programs/rofi/default.nix
    ../../programs/X-themes/default.nix
    ../../programs/polybar/default.nix
    ../../programs/rd-docker/default.nix
    ../../programs/graphical-apps/default.nix
  ];

  home.sessionVariables = {
    LIBGL_ALWAYS_SOFTWARE = 1;
  };
}
