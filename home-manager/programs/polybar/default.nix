{ pkgs, ...}:

let
  pkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/4d2b37a84fad1091b9de401eb450aae66f1a741e.tar.gz";
    }) {};
  mypolybar = pkgs.polybar;
in
{
  services.polybar = {
    enable = true;
    package = mypolybar;
    config = ./config.ini;
    script = ''
      ${pkgs.gawk} 2> /devl/null
      for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1 | ${pkgs.coreutils}/bin/head -n 1); do
          MONITOR=$m polybar mybar &
      done
    '';
  };
}
