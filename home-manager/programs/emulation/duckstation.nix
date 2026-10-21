# DuckStation (PS1) standalone. nixpkgs dropped it at upstream's request
# (and its licence is now CC-BY-NC-ND), so this wraps the official AppImage,
# pinned to a dated release tag (the "latest"/"preview" tags move).
# Update: pick a tag from https://github.com/stenzek/duckstation/releases, then
#   nix store prefetch-file https://github.com/stenzek/duckstation/releases/download/<tag>/DuckStation-x64.AppImage
{ lib, appimageTools, fetchurl }:
let
  pname = "duckstation";
  version = "0.1-11894";
  src = fetchurl {
    url = "https://github.com/stenzek/duckstation/releases/download/v${version}/DuckStation-x64.AppImage";
    hash = "sha256-wv0mJXrFz+/k93thsEuP4pn5xODPa4UfxSWcgVl5Rmo=";
  };
  extracted = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs = pkgs: [ pkgs.libGL pkgs.alsa-lib pkgs.libpulseaudio ];
  extraInstallCommands = ''
    for d in ${extracted}/*.desktop; do
      [ -e "$d" ] || continue
      install -Dm644 "$d" "$out/share/applications/$(basename "$d")"
      sed -i -E 's|^Exec=[^ ]*|Exec=${pname}|' "$out/share/applications/$(basename "$d")"
    done
    for i in ${extracted}/*.png ${extracted}/*.svg; do
      [ -e "$i" ] || continue
      install -Dm644 "$i" "$out/share/icons/hicolor/scalable/apps/$(basename "$i")"
    done
  '';
  meta = {
    description = "PlayStation 1 emulator";
    homepage = "https://www.duckstation.org";
    license = lib.licenses.cc-by-nc-nd-40;
    mainProgram = "duckstation";
    platforms = [ "x86_64-linux" ];
  };
}
