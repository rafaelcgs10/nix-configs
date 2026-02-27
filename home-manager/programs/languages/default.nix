{ config, lib, pkgs, ... }:
let
  # unstable = import <nixpkgs-unstable> {};
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/2292d4b35aa854e312ad2e95c4bb5c293656f21a.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
  # ruststable = (nixpkgs.latest.rustChannels.stable.rust.override { extensions = [ "rust-src" "rls-preview" "rust-analysis" "rustfmt-preview" ];});

  # mynixpkgs = import (builtins.fetchTarball {
  #   url = "https://github.com/rafaelcgs10/nixpkgs/archive/4ade716721f543b113bf97857e93972b99c927b8.tar.gz";
  # }) {};

  # new_isabelle_pkgs = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/c100196b085a72aa453bd3f86e731e77c2666aee.tar.gz";
  # }) {};

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
  #

  # We currently take all libraries from systemd and nix as the default
  
  # https://github.com/NixOS/nixpkgs/blob/c339c066b893e5683830ba870b1ccd3bbea88ece/nixos/modules/programs/nix-ld.nix#L44
  
  pythonldlibpath = lib.makeLibraryPath (with pkgs; [
    zlib zstd stdenv.cc.cc curl openssl attr libssh bzip2 libxml2 acl libsodium util-linux xz systemd
    mesa
    fontconfig   
    libgbm
    libGLU
    libGL
    libglibutil
  ]);
  
  # Darwin requires a different library path prefix
  
  wrapPrefix = if (!pkgs.stdenv.isDarwin) then "LD_LIBRARY_PATH" else "DYLD_LIBRARY_PATH";
  
  patchedpython = (pkgs.symlinkJoin {
    
    name = "python";
    
    paths = [ pkgs.python311 ];
    
    buildInputs = [ pkgs.makeWrapper ];
    
    postBuild = ''
      wrapProgram "$out/bin/python3.11" --prefix ${wrapPrefix} : "${pythonldlibpath}"
    '';
    
  }); 
in
{
  # programs.opam.enable = true;

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
    # ruststable
    # lldb-mi
    # pkgs.z3
    # pkgs.vampire
    # patchedpython
    pkgs.python311
    pkgs.fontconfig
    pkgs.python311Packages.pip
    pkgs.python311Packages.pyqt5
    pkgs.conda
    # (pkgs.buildFHSEnv {
    #   name = "pixi";
    #   runScript = "pixi";
    #   targetPkgs = pkgs: with pkgs; [ pixi ];
    # })
    # pkgs.conda
    pkgs.micromamba
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
    ghc
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
