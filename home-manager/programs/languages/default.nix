{ pkgs, lib, options, stdenv, fetchhg, config, specialArgs, modulesPath }:
let
  unstable = import <nixpkgs-unstable> {};
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  ruststable = (nixpkgs.latest.rustChannels.stable.rust.override { extensions = [ "rust-src" "rls-preview" "rust-analysis" "rustfmt-preview" ];});

  new_isabelle_pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/c100196b085a72aa453bd3f86e731e77c2666aee.tar.gz";
  }) {};

  # isabelle2022 = pkgs.isabelle.overrideAttrs (prev: {
  #   version = "2022-RC0";
  #   dirname = "Isabelle2022-RC0";
  #   sourceRoot = "Isabelle2022-RC0";

  #   src = pkgs.fetchurl {
  #     url = "https://isabelle.sketis.net/website-Isabelle2022-RC0/Isabelle2022-RC0_linux.tar.gz ";
  #     sha256 = "fi+hywGz2CXDMMLtoqAtcVbmx6j4WkYlqQhE/y0FXr0=";
  #   };
  # });

  polyml_test = pkgs.polyml.overrideAttrs (prev: {
    version = "test-15c840d48c9a ";
    src = pkgs.fetchFromGitHub {
      owner = "polyml";
      repo = "polyml";
      rev = "15c840d48c9a3142222aedda44d66554af0bcbb9";
      sha256 = "FnkUM5gUH2xoQuTvSgFwg53VzicaaDGdB7gdjae4r90=";
    };
  });

  inherit (pkgs) haskellPackages;
  haskellDeps = ps: with ps; [
    base
    QuickCheck
  ];

  ghc = haskellPackages.ghcWithPackages haskellDeps;

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
  home.packages = [
    # (pkgs.callPackage ./isabelle {
    #   polyml = pkgs.polyml.overrideAttrs (_: {
    #     pname = "polyml-for-isabelle";
    #     version = "2022";
    #     configureFlags = [ "--enable-intinf-as-int" "--with-gmp" "--disable-shared" ];
    #     buildFlags = [ "compiler" ];
    #     src = pkgs.fetchFromGitHub {
    #       owner = "polyml";
    #       repo = "polyml";
    #       rev = "bafe319bc3a65bf63bd98a4721a6f4dd9e0eabd6";
    #       sha256 = "1ygs09zzq8icq1gc8qf4sb24lxx7sbcyd5hw3vw67a3ryaki0qw2";
    #     };
    #   });
    #   java = newer_isabelle_pkgs.openjdk17;
    #   scala_3 = newer_isabelle_pkgs.scala_3;
    #   coreutils = new_isabelle_pkgs.coreutils;
    #   z3 = new_isabelle_pkgs.z3_4_4_0.overrideAttrs (_: {
    #     src = new_isabelle_pkgs.fetchFromGitHub {
    #       owner = "Z3Prover";
    #       repo = "z3";
    #       rev = "0482e7fe727c75e259ac55a932b28cf1842c530e";
    #       sha256 = "1m53avlljxqd2p8w266ksmjywjycsd23h224yn786qsnf36dr63x";
    #     };
    #   });
    # })
    # newer_isabelle_pkgs.isabelle
    # new_isabelle_pkgs.isabelle
    # unstable.isabelle
    pkgs.rnix-lsp
    # ruststable
    # lldb-mi
    pkgs.z3
    pkgs.vampire
    pkgs.python310
    # pkgs.conda
    # pkgs.python310Packages.conda
    # pkgs.python310Packages.tensorflow
    pkgs.python310Packages.venvShellHook
    pkgs.veriT
    pkgs.iprover
    pkgs.cvc5
    pkgs.leo3-bin
    pkgs.satallax
    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.clippy
    pkgs.texlab
    # pkgs.llvm_12
    # pkgs.lldb
    pkgs.adoptopenjdk-hotspot-bin-15
    pkgs.ant
    pkgs.gdb
    pkgs.libllvm
    pkgs.texlab
    pkgs.nodejs
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
    pkgs.coq
    # pkgs.pythonFull
    # pkgs.pythonPackages.python-language-server marked as broken
    pkgs.ruby
    pkgs.solargraph
    pkgs.rubyPackages.yard
    pkgs.rubocop
  ];
}
