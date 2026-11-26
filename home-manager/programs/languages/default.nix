{ config, lib, pkgs, ... }:
let
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
  # python = import ../spektrafilm/python.nix;

  ghc = haskellPackages.ghcWithPackages haskellDeps;

  # Elixir toolchain, all from one BEAM package set so Elixir, Erlang/OTP,
  # rebar3 and the language server agree on the OTP version (28). Bump the
  # Elixir minor here; elixir-ls is overridden to run on the same Elixir,
  # because it compiles the project with its own runtime and a mismatch
  # gives spurious diagnostics. (elixir-ls only patches its launch script
  # with the Elixir path, so the override is a cheap rebuild.)
  beam = pkgs.beam28Packages;
  elixir = beam.elixir_1_19;
  elixir-ls = beam.elixir-ls.override { inherit elixir; };

  # Darwin requires a different library path prefix
  
in
{
  # programs.opam.enable = true;

  # Persistent IEx/erl shell history across sessions.
  home.sessionVariables.ERL_AFLAGS = "-kernel shell_history enabled";

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
    pkgs.python3
    pkgs.fontconfig
    # (pkgs.buildFHSEnv {
    #   name = "pixi";
    #   runScript = "pixi";
    #   targetPkgs = pkgs: with pkgs; [ pixi ];
    # })
    pkgs.conda
    # pkgs.micromamba
    # pkgs.python310Packages.conda
    # pkgs.python310Packages.tensorflow
    # pkgs.python310Packages.venvShellHook
    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.rust-analyzer
    pkgs.valgrind
    # pkgs.massif-visualizer
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
    # C# / .NET: SDK + csharp-ls language server installed globally so Doom's
    # eglot finds `csharp-ls` even when a project has no flake or its direnv is
    # not (yet) allowed. A project devshell that provides its own versions
    # takes precedence on PATH via envrc.
    pkgs.dotnet-sdk_10
    pkgs.csharp-ls
    # Dyalog APL (`dyalog`, `dyalogscript`), driven from Doom by dyalog-mode
    # over the RIDE protocol. Unfree; the package refuses to
    # build until its licence is accepted (free Basic Licence, non-commercial
    # use only: https://www.dyalog.com/uploads/documents/Developer_Software_Licence.pdf).
    # (pkgs.dyalog.override { acceptLicense = true; })

    # Elixir / Erlang (see `beam` above). Installed globally so Doom's eglot
    # finds `elixir-ls` without a project flake; a project devshell that
    # pins its own Elixir/OTP wins on PATH through direnv. Hex and rebar
    # are fetched per user by `mix local.hex` / `mix local.rebar` into
    # ~/.mix as usual.
    elixir # elixir, elixirc, iex, mix
    beam.erlang # erl, dialyzer, observer, typer
    beam.rebar3
    elixir-ls # LSP for Doom (lang elixir +lsp); also ships elixir-debug-adapter
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # File-change notifications for Elixir's file_system library: elixir-ls,
    # `mix test --stale` watchers and Phoenix live reload use it on Linux.
    pkgs.inotify-tools
  ] ++ [

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

    # Terraform and Kubernetes, for Doom's (terraform +lsp) and (yaml +lsp)
    # (see the Terraform / YAML section of doom.d/config.el). terraform is
    # unfree (BSL); terraform-ls formats through it.
    pkgs.terraform
    pkgs.terraform-ls
    pkgs.tflint
    pkgs.yaml-language-server
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.k9s

    # Python, for Doom's (python +lsp) (see the Python section of
    # doom.d/config.el): basedpyright is the language server (completion,
    # hover docs/types, definitions, inlay hints); ruff lints and formats.
    # A project devshell / uv venv that pins its own ruff or basedpyright
    # wins on PATH through direnv.
    pkgs.basedpyright
    pkgs.ruff
    # TypeScript/React, JSON, CSS: typescript-language-server (needs a
    # tsserver: the project's node_modules/typescript, else this one),
    # vscode-langservers-extracted (json/css/html/eslint servers), prettier
    # as the fallback formatter when a project has none in node_modules.
    pkgs.typescript-language-server
    pkgs.typescript
    pkgs.vscode-langservers-extracted
    pkgs.prettier
    # Dockerfiles: docker-langserver + hadolint (chained lint in config.el).
    pkgs.dockerfile-language-server
    pkgs.hadolint
    # Nix (flakes, these configs): nil language server.
    pkgs.nil
    # Shell scripts: bash-language-server runs shellcheck for diagnostics.
    pkgs.bash-language-server
    pkgs.shellcheck

    # Quint (formal specifications): its language server, for eglot in Doom
    # (Quint section of doom.d/config.el). Not in nixpkgs; packaged here.
    (pkgs.callPackage ./quint-language-server { })

    # pkgs.pythonFull
    # pkgs.pythonPackages.python-language-server marked as broken
    # pkgs.ruby
    # pkgs.solargraph
    # pkgs.rubyPackages.yard
    # pkgs.rubocop
  ];
}
