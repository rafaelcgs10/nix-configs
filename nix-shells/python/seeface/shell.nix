{ pkgs ? (import <nixpkgs> {}).pkgs }:
with pkgs;
mkShell {
  buildInputs = [
    python38Packages.virtualenv # run virtualenv .
    python38Packages.numpy
    python38Packages.opencv3
    python38Packages.pillow
    python38Packages.pillow
    python38Packages.onnx
    python38Packages.pip
  ];
  shellHook = ''
    # https://pastebin.com/t86VmYCc
    # fixes libstdc++ issues and libgl.so issues
    LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib/:/run/opengl-driver/lib/
    virtualenv -p python3 env
    source env/bin/activate
  '';
}
