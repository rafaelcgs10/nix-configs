with (import <nixpkgs> {});

let
  pkgs2003 = import
  (builtins.fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-20.03.tar.gz)
    { inherit config; };
in
pkgs2003.mkShell {
  name = "c++-env";
  buildInputs = [
    pkgs2003.cmake
    pkgs2003.clang
    pkgs2003.clang-tools
    pkgs2003.ccls
  ];
}
