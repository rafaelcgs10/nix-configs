{ pkgs, lib, ...}:

let
  bitwarden-rofi = pkgs.callPackage ../bitwarden-rofi { };
in
{

  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ./theme.slate;
    cycle = true;
  };
  home.packages = [
    bitwarden-rofi
  ];
}
