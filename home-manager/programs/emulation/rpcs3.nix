# RPCS3 (PS3) standalone from the official AppImage: the nixpkgs package is
# not in the binary cache at this lock (a multi-hour local build), and the
# AppImage is what upstream supports. Pinned to a build tag; ~/.config/rpcs3
# is used either way, so switching back to pkgs.rpcs3 later keeps the data.
# Update: https://github.com/RPCS3/rpcs3-binaries-linux/releases/latest, then
#   nix store prefetch-file <AppImage url>
{ lib, appimageTools, fetchurl, runCommand, dwarfs }:
let
  pname = "rpcs3";
  version = "0.0.43-20366";
  src = fetchurl {
    url = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-4e078e07a847d1b07edcb4dd9657bc6e99eb7e35/rpcs3-v0.0.43-20366-4e078e07_linux64.AppImage";
    hash = "sha256-wYpThUBeQtmBVohdbCTAxIMkWjB3T2Z+qcLgInYrMx8=";
  };
  # RPCS3 ships a DwarFS AppImage: appimageTools.extract (unsquashfs) cannot
  # read it and the runtime's own --appimage-extract needs FUSE, which the
  # build sandbox lacks. dwarfsextract reads the image directly.
  extracted = runCommand "${pname}-${version}-extracted" { nativeBuildInputs = [ dwarfs ]; } ''
    mkdir -p $out
    dwarfsextract -i ${src} --image-offset=auto -o $out
  '';
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = extracted;
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
  # The unpacked AppDir, for the launcher that enumerates pads with RPCS3's
  # own SDL (programs/emulation/rpcs3-launch.py).
  passthru.extracted = extracted;
  meta = {
    description = "PlayStation 3 emulator";
    homepage = "https://rpcs3.net";
    license = lib.licenses.gpl2Only;
    mainProgram = "rpcs3";
    platforms = [ "x86_64-linux" ];
  };
}
