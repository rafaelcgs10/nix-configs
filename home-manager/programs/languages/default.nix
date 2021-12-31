{ pkgs, lib, options, config, specialArgs, modulesPath }:
let
  inherit (pkgs) haskellPackages;

  haskellDeps = ps: with ps; [
    base
    QuickCheck
  ];

  ghc = haskellPackages.ghcWithPackages haskellDeps;
in
{
  home.packages = [
    pkgs.cargo
    pkgs.rustc
    pkgs.texlab
    (pkgs.texlive.combine { inherit (pkgs.texlive) scheme-small wrapfig capt-of; })
    pkgs.rust-analyzer
    pkgs.go
    pkgs.cmake
    pkgs.clang
    pkgs.clang-tools
    pkgs.ccls
    ghc
    pkgs.haskellPackages.haskell-language-server
    pkgs.haskellPackages.hlint
    pkgs.haskellPackages.apply-refact
    pkgs.haskellPackages.hoogle
    pkgs.isabelle
    pkgs.coq
    pkgs.pythonFull
    # pkgs.pythonPackages.python-language-server marked as broken
    pkgs.ruby
    pkgs.solargraph
    pkgs.rubyPackages.yard
    pkgs.rubocop
  ];
}
