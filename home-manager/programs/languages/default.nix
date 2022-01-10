{ pkgs, lib, options, config, specialArgs, modulesPath }:
let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  ruststable = (nixpkgs.latest.rustChannels.stable.rust.override { extensions = [ "rust-src" "rls-preview" "rust-analysis" "rustfmt-preview" ];});

  inherit (pkgs) haskellPackages;

  haskellDeps = ps: with ps; [
    base
    QuickCheck
  ];

  ghc = haskellPackages.ghcWithPackages haskellDeps;

  lldb-mi = pkgs.stdenv.mkDerivation {
    pname = "lldb-mi";
    name = "lldb-mi";

    src = pkgs.fetchFromGitHub {
      owner = "lldb-tools";
      repo = "lldb-mi";
      rev = "2388bd74133bc21eac59b2e2bf97f2a30770a315";
      sha256 = "1ag7dvdg5hxyzh3ngawxlb84x9n44mix96qa6q4zlrjqccwsc6x8";
    };

    buildInputs = [
      pkgs.cmake
      pkgs.llvm_12
      pkgs.lldb
      pkgs.libllvm
      pkgs.clang
    ];

    buildPhase = ''
      cmake .
      cmake --build .
    '';

    installPhase = ''
      mkdir -p "$out/bin"
      cp src/lldb-mi "$out/bin"
    '';

    phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  };
in
{
  home.packages = [
    # ruststable
    lldb-mi
    pkgs.z3
    pkgs.vampire
    pkgs.veriT
    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.clippy
    pkgs.texlab
    pkgs.llvm_12
    pkgs.lldb
    # pkgs.libllvm
    pkgs.gdb
    pkgs.texlab
    pkgs.nodejs-10_x
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
    pkgs.haskellPackages.stack
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
