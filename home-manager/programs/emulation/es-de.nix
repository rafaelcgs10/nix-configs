# ES-DE (EmulationStation Desktop Edition): the controller-driven game
# launcher in front of RetroArch and the standalone emulators. nixpkgs dropped
# its native package (freeimage CVEs), so this wraps the official AppImage.
# It runs inside appimageTools' FHS sandbox and launches the emulators from
# there; /nix, /home, /run and /dev are bound, so Nix-installed emulators,
# Vulkan and controllers work from inside it.
#
# Update: pick the x64 AppImage link from
# https://gitlab.com/es-de/emulationstation-de/-/releases, then
#   nix store prefetch-file <url>
{ lib, appimageTools, fetchurl }:
let
  pname = "es-de";
  version = "3.5.0";
  src = fetchurl {
    url = "https://gitlab.com/es-de/emulationstation-de/-/package_files/357718352/download";
    hash = "sha256-q8KZmhI4X4V3W9P5hvqJHHa2nfN5H3wS5MeDzzw2MPU=";
    name = "ES-DE_x64-${version}.AppImage";
  };
  extracted = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs = pkgs: [ pkgs.libGL pkgs.alsa-lib pkgs.libpulseaudio ];
  extraInstallCommands = ''
    install -Dm644 ${extracted}/org.es_de.frontend.desktop \
      $out/share/applications/org.es_de.frontend.desktop
    install -Dm644 ${extracted}/org.es_de.frontend.svg \
      $out/share/icons/hicolor/scalable/apps/org.es_de.frontend.svg
    substituteInPlace $out/share/applications/org.es_de.frontend.desktop \
      --replace-fail 'Exec=es-de' 'Exec=${pname}'
  '';
  meta = {
    description = "EmulationStation Desktop Edition, a frontend for emulators";
    homepage = "https://es-de.org";
    license = lib.licenses.mit;
    mainProgram = "es-de";
    platforms = [ "x86_64-linux" ];
  };
}
