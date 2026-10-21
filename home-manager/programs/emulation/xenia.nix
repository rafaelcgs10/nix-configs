# Xenia Canary (Xbox 360): upstream's native Linux build, patched to run
# against Nix libraries (no compilation). Early-stage on Linux; expect rough
# edges. ES-DE finds it as `xenia_canary` on PATH and starts it in the
# emulator's directory, so the wrapper moves to a writable data dir first
# (xenia writes its config, log and content there).
# Update: https://github.com/xenia-canary/xenia-canary-releases/releases,
#   nix hash file xenia_canary_linux.tar_.xz
{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, lz4, xorg, fontconfig
, gtk3, zlib, pango, harfbuzz, atk, cairo, gdk-pixbuf, glib, SDL2, alsa-lib
, vulkan-loader }:
stdenv.mkDerivation {
  pname = "xenia-canary";
  version = "02d2cb5";
  src = fetchurl {
    url = "https://github.com/xenia-canary/xenia-canary-releases/releases/download/02d2cb5/xenia_canary_linux.tar_.xz";
    hash = "sha256-WsO801Qw3EBsx5y0A9wyY0FRSl48GeEYo3OG3Eb05sE=";
    name = "xenia-canary-linux.tar.xz"; # upstream's ".tar_.xz" confuses the unpacker
  };
  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [
    lz4 xorg.libX11 xorg.libxcb fontconfig gtk3 zlib pango harfbuzz atk cairo
    gdk-pixbuf glib SDL2 alsa-lib stdenv.cc.cc.lib
  ];
  installPhase = ''
    runHook preInstall
    install -Dm755 build/bin/Linux/Release/xenia_canary $out/libexec/xenia_canary
    makeWrapper $out/libexec/xenia_canary $out/bin/xenia_canary \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]} \
      --run 'mkdir -p "''${XDG_DATA_HOME:-$HOME/.local/share}/xenia" && cd "''${XDG_DATA_HOME:-$HOME/.local/share}/xenia"'
    runHook postInstall
  '';
  meta = {
    description = "Xbox 360 emulator (Canary, Linux build)";
    homepage = "https://xenia.jp";
    license = lib.licenses.bsd3;
    mainProgram = "xenia_canary";
    platforms = [ "x86_64-linux" ];
  };
}
