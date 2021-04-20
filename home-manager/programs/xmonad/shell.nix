{ nixpkgs ? import <nixpkgs> {} }:
let
  inherit (nixpkgs) pkgs;
  inherit (pkgs) haskellPackages;

  haskellDeps = ps: with ps; [
    base
    containers
    xmonad
    xmonad-contrib
    xmonad-extras
  ];

  ghc = haskellPackages.ghcWithPackages haskellDeps;

  nixPackages = [
    ghc
    nixpkgs.haskellPackages.haskell-language-server
    nixpkgs.haskellPackages.hlint
    nixpkgs.haskellPackages.hoogle
  ];
in
pkgs.stdenv.mkDerivation {
  name = "env";
  buildInputs = nixPackages;
}
