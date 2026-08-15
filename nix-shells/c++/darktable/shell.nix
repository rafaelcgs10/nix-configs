# Dev shell for hacking on https://github.com/darktable-org/darktable
#
# Exposed as a flake devShell: `nix develop ~/nix-configs#darktable`.
# Still usable standalone via `nix-shell` thanks to the default pkgs arg below.
#
# Setup once, in your darktable checkout (e.g. ~/Documents/darktable):
#   echo 'use flake ~/nix-configs#darktable' > .envrc   # or symlink this dir's .envrc
#   cp ~/nix-configs/nix-shells/c++/darktable/dot-clangd .clangd
#   direnv allow
#
# Build (inside the shell / once direnv has activated it):
#   git submodule update --init --recursive
#   cmake -B build -G Ninja \
#         -DCMAKE_BUILD_TYPE=RelWithDebInfo \
#         -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
#         -DCMAKE_INSTALL_PREFIX=$PWD/opt
#   cmake --build build -j$(nproc)
#   cmake --install build           # -> ./opt/bin/darktable
#
# IMPORTANT for clangd: darktable's IOP/lib modules are compiled through
# generated `introspection_*.c` wrappers, so the real sources (src/iop/*.c)
# get no compile_commands.json entry and clangd reports bogus errors like
# `unknown type name 'dt_colormatrix_t'`. Run this once after every (re)configure:
#   python3 fix-compile-commands.py
# then reconnect clangd in Emacs (M-x eglot-reconnect).
#
# clangd then reads build/compile_commands.json (via .clangd) and Emacs/eglot
# gets completion, hover types, cross-file goto-definition and diagnostics.
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  name = "darktable-dev";

  # Pull in every build/runtime dependency of the nixpkgs darktable derivation:
  # cmake, ninja, pkg-config, intltool, gtk3, exiv2, lensfun, libraw, lcms2,
  # OpenEXR, libheif, libjxl, lua, sqlite, ... (see `darktable.buildInputs`).
  inputsFrom = [ pkgs.darktable ];

  # Extra tooling for the Emacs/clangd workflow and general C/C++ hacking.
  packages = with pkgs; [
    clang-tools # clangd + clang-format + clang-tidy
    bear # fallback compile_commands.json generator for non-cmake builds
    gdb
    ccache # speeds up rebuilds
  ];

  # Libraries darktable git (master) needs on top of the packaged 5.4.1.
  # These go in buildInputs (not packages/nativeBuildInputs) so their headers
  # land in NIX_CFLAGS_COMPILE and gcc finds them — darktable's CMake links
  # potrace by absolute path but forgets to add its include dir to the target.
  buildInputs = with pkgs; [
    potrace # src/common/ras2vect.c -> #include <potracelib.h>
  ];

  # Belt-and-suspenders: emit compile_commands.json even if you forget the flag.
  CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
}
