# withoutbg GIMP 3 plug-in (Tools > WithoutBG > Remove Background...): sends the
# active layer to a local withoutBG server and attaches the returned alpha
# matte as an *unapplied* layer mask, so the cutout stays reviewable until you
# hit Layer > Mask > Apply Layer Mask.
# https://github.com/withoutbg/withoutbg-gimp
#
# The repo has no LICENSE file; the plug-in source itself carries a
# "GNU General Public License v3 or later" header, which is what is recorded
# below. (Same situation as gimp-path-shape-creator.nix.)
#
# The plug-in is *only* an HTTP client -- all the actual matting happens in
# withoutbg-inference.nix, which extras.nix starts on demand via systemd socket
# activation. Note the plug-in downsizes to 1024px before POSTing and upscales
# the returned matte locally, so the mask is full-resolution regardless; the
# model itself only ever sees 448x448.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
}:

let
  # gi/GTK only; no ML, no requests -- it talks to the server with stdlib
  # urllib. Must be the Python nixpkgs builds GIMP's own plug-ins with, since
  # the shebang below is what interprets the file.
  pythonEnv = python3.withPackages (ps: [
    ps.pygobject3
    ps.pycairo
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "withoutbg-gimp";
  version = "0-unstable-2026-07-24";

  src = fetchFromGitHub {
    owner = "withoutbg";
    repo = "withoutbg-gimp";
    rev = "a0c9a1b86828a4d1ca01d4c71f9b09f00b8530ef";
    hash = "sha256-js/fZI6Q4dAq6TG+cTUJdd7EIW3kn1R4FXbJHMJJbkU=";
  };

  dontBuild = true;
  # The shebang is rewritten explicitly below; the default hook would point it
  # at whatever python is in the build PATH, which has no gi.
  dontPatchShebangs = true;

  # Upstream assumes an always-on Docker container, so five seconds is plenty
  # for it. Here the server is socket-activated, and this health check is
  # literally the connection that starts it: cold, it has to import onnxruntime,
  # read and sha256-verify a 455MB ONNX graph and run a warm-up inference --
  # measured at 4.2s with the model in page cache, and worse without. Five
  # seconds turns that into a spurious "server not reachable" on the first run
  # of the day; thirty covers it with room to spare and costs nothing when the
  # server is already up (the check answers in milliseconds).
  postPatch = ''
    substituteInPlace withoutbg/withoutbg.py \
      --replace-fail 'urlopen(f"{server_url}/health", timeout=5)' \
                     'urlopen(f"{server_url}/health", timeout=30)'
  '';

  # GIMP loads <plug-ins>/<name>/<name>.py, executable; $out is that directory.
  installPhase = ''
    runHook preInstall

    install -Dm755 withoutbg/withoutbg.py $out/withoutbg.py
    substituteInPlace $out/withoutbg.py \
      --replace-fail '#!/usr/bin/env python3' '#!${pythonEnv}/bin/python3'

    runHook postInstall
  '';

  meta = {
    description = "GIMP 3 plug-in that adds a withoutBG alpha matte as a layer mask";
    homepage = "https://github.com/withoutbg/withoutbg-gimp";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
