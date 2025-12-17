{ config, lib, pkgs, ... }:
let
  # unstable = import <nixpkgs-unstable> {};
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/2292d4b35aa854e312ad2e95c4bb5c293656f21a.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  # ruststable = (nixpkgs.latest.rustChannels.stable.rust.override { extensions = [ "rust-src" "rls-preview" "rust-analysis" "rustfmt-preview" ];});

  # mynixpkgs = import (builtins.fetchTarball {
  #   url = "https://github.com/rafaelcgs10/nixpkgs/archive/4ade716721f543b113bf97857e93972b99c927b8.tar.gz";
  # }) {};

  old_25_05_pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/5cbdb94f3aa2e7de13f3c0a67899ec17427b58ce.tar.gz";
  }) {};

  inherit (pkgs) haskellPackages;
  haskellDeps = ps: with ps; [
    base
    QuickCheck
  ];

  # ghc = haskellPackages.ghcWithPackages haskellDeps;

  # lldb-mi = pkgs.stdenv.mkDerivation {
  #   pname = "lldb-mi";
  #   name = "lldb-mi";

  #   src = pkgs.fetchFromGitHub {
  #     owner = "lldb-tools";
  #     repo = "lldb-mi";
  #     rev = "2388bd74133bc21eac59b2e2bf97f2a30770a315";
  #     sha256 = "1ag7dvdg5hxyzh3ngawxlb84x9n44mix96qa6q4zlrjqccwsc6x8";
  #   };

  #   buildInputs = [
  #     pkgs.cmake
  #     pkgs.llvm_12
  #     pkgs.lldb
  #     pkgs.libllvm
  #     pkgs.clang
  #   ];

  #   buildPhase = ''
  #     cmake .
  #     cmake --build .
  #   '';

  #   installPhase = ''
  #     mkdir -p "$out/bin"
  #     cp src/lldb-mi "$out/bin"
  #   '';

  #   phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  # };
in
{
  # programs.opam.enable = true;

  home.packages = [
    # pkgs.python310Packages.conda
    # pkgs.python310Packages.tensorflow
    # pkgs.python310Packages.venvShellHook
    pkgs.veriT
    pkgs.iprover
    pkgs.cvc5
    pkgs.leo3-bin
    pkgs.satallax
    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.rust-analyzer
    pkgs.valgrind
    pkgs.massif-visualizer
    pkgs.gperftools
    pkgs.clippy
    pkgs.texlab
    # pkgs.llvm_12
    # pkgs.lldb
    # pkgs.adoptopenjdk-hotspot-bin-15
    pkgs.jdk17
    pkgs.jdt-language-server

    pkgs.ant
    pkgs.gdb
    pkgs.gdbgui
    pkgs.libllvm
    pkgs.texlab
    pkgs.nodejs
    # (pkgs.texlive.combine { inherit (pkgs.texlive) scheme-small wrapfig capt-of; })
    pkgs.texlive.combined.scheme-full
    # pkgs.python311Packages.pygments
    pkgs.go
    pkgs.python3
    pkgs.cmake
    pkgs.clang
    pkgs.clang-tools
    pkgs.ccls
    # pkgs.python310Full
    # pkgs.python310Packages.psycopg2
    # pkgs.python312Packages.pygls
    # pkgs.python312Packages.python-lsp-server
    pkgs.pyright
    pkgs.postgresql
    # ghc
    pkgs.haskell.compiler.ghc912
    pkgs.pandoc


    pkgs.haskellPackages.haskell-language-server
    pkgs.haskellPackages.hlint
    pkgs.haskellPackages.stack
    # pkgs.haskellPackages.apply-refact
    pkgs.haskellPackages.hoogle
    # pkgs.haskellPackages.ghc-mod
    # pkgs.lua
    pkgs.haskellPackages.happy
    pkgs.haskellPackages.haskell-src-exts
    # pkgs.coq
    # mynixpkgs.coqPackages_8_15.coqide
    # pkgs.coq_8_5
    # pkgs.coqPackages_8_5.mathcomp-ssreflect
    # pkgs.coqPackages_8_5.mathcomp
    # mynixpkgs.coqPackages_8_15.coq-ext-lib
    # mynixpkgs.coqPackages_8_15.coinduction
    # mynixpkgs.coqPackages_8_15.relation-algebra
    # mynixpkgs.coqPackages_8_15.equations

    # pkgs.pythonFull
    # pkgs.pythonPackages.python-language-server marked as broken
    # pkgs.ruby
    # pkgs.solargraph
    # pkgs.rubyPackages.yard
    # pkgs.rubocop
  ];
}
