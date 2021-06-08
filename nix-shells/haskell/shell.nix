{ nixpkgs ? import <nixpkgs> {} }:
let
  inherit (nixpkgs) pkgs;
  inherit (pkgs) haskellPackages;

  haskellDeps = ps: with ps; [
    base
    gdp
    QuickCheck
  ];

  ghc = haskellPackages.ghcWithPackages haskellDeps;

  nixPackages = [
    ghc
    nixpkgs.haskellPackages.haskell-language-server
    nixpkgs.haskellPackages.hlint
    nixpkgs.haskellPackages.apply-refact
    nixpkgs.haskellPackages.hoogle
  ];
in
pkgs.stdenv.mkDerivation {
  name = "env";
  buildInputs = nixPackages;
}
