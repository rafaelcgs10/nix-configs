# FHS environment for training openWakeWord models (pip wheels with native code + CUDA).
# Usage:
#   nix-shell ~/nix-configs/nix-shells/wakeword/shell.nix          # interactive
#   nix-shell ~/nix-configs/nix-shells/wakeword/shell.nix --run 'wakeword-fhs -c "<cmd>"'
# Inside, venvs live in ~/wakeword-training/venv (training) and ~/wakeword-training/venv-tf (tflite conversion).
{ pkgs ? import <nixpkgs> { } }:
let
  fhs = pkgs.buildFHSEnv {
    name = "wakeword-fhs";
    targetPkgs = p: with p; [
      uv
      git
      git-lfs
      wget
      curl
      gnutar
      zstd
      ffmpeg
      sox
      libsndfile
      portaudio
      espeak-ng
      zlib
      stdenv.cc.cc.lib
      stdenv.cc
      gnumake
      pkg-config
      glib
      libGL
      libx11
      openssl
      bzip2
      xz
      libffi
      ncurses
      readline
      sqlite
    ];
    profile = ''
      export LD_LIBRARY_PATH=/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
      export UV_CACHE_DIR=$HOME/wakeword-training/.uv-cache
      export UV_PYTHON_INSTALL_BIN=0
      export UV_PYTHON_INSTALL_DIR=$HOME/wakeword-training/.uv-python
      export HF_HOME=$HOME/wakeword-training/.hf-cache
      export PIP_CACHE_DIR=$HOME/wakeword-training/.pip-cache
    '';
    runScript = "bash";
  };
in
pkgs.mkShell {
  packages = [ fhs ];
  shellHook = ''
    echo "Run 'wakeword-fhs' to enter the FHS environment."
  '';
}
