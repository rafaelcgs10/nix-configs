{ pkgs, ...}:

let
  pkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/8a5fcd583fd14ebbcd6654fbcbd35ec14aa96a28.tar.gz";
    }) {};
  mypolybar = pkgs.polybar;
in
{
  services.polybar = {
    enable = true;
    package = mypolybar;
    config = ./config.ini;
    script = ''
      for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1 | ${pkgs.coreutils}/bin/head -n 1); do
          MONITOR=$m polybar mybar &
      done
    '';
  };
}
