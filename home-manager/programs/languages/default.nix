{ pkgs, lib, options, stdenv, fetchhg, config, specialArgs, modulesPath }:
let
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
    # isabelle2022
    # (pkgs.callPackage ./isabelle { java = pkgs.jdk; polyml = polyml_test ; } )
    new_isabelle_pkgs.isabelle
    pkgs.rnix-lsp
    # ruststable
    lldb-mi
    pkgs.z3
    pkgs.vampire
    pkgs.python310
    # pkgs.conda
    # pkgs.python310Packages.conda
    # pkgs.python310Packages.tensorflow
    pkgs.python310Packages.venvShellHook
    pkgs.veriT
    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.clippy
    pkgs.texlab
    # pkgs.llvm_12
    pkgs.lldb
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
