{ pkgs ? import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/25.05.tar.gz";
}) {
  overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (python-final: python-prev: {
          colour-science = final.callPackage ./colour-science.nix {};
          pyfftw = final.callPackage ./pyfftw.nix {};
          openimageio = final.callPackage ./openimageio.nix {};
        })
      ];
    })
  ]; 
}
}:

let
  qt5 = pkgs.libsForQt5.qt5;
in
pkgs.python3Packages.buildPythonPackage rec {
  pname = "spektrafilm";
  version = "0.3.3";
  pyproject = true;
  doCheck = false;
  doInstallCheck = false;
  dontCheckRuntimeDeps = true;

  src = pkgs.fetchFromGitHub {
    owner = "andreavolpato";
    repo = "spektrafilm";
    rev = "500bc429b7e93450ef228305c319dc03d8e185d1";
    hash = "sha256-00000000000000000000000000000000000000000000";
  };

  build-system = with pkgs.python3Packages; [ setuptools ];

  dependencies = with pkgs.python3Packages; [
    napari
    numpy
    matplotlib
    scipy
    scikit-image
    dotmap
    opt-einsum
    magicgui
    lmfit
    pyqt5
    rawpy
    # pyconify
    numba
    cython
    colour-science
    pyfftw
    openimageio
  ]; 

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  postFixup = ''
    wrapProgram $out/bin/spektrafilm \
      --set QT_PLUGIN_PATH "${qt5.qtbase.bin}/${qt5.qtbase.qtPluginPrefix}:${qt5.qtwayland.bin}/${qt5.qtbase.qtPluginPrefix}" \
      --set QT_QPA_PLATFORM xcb \
      --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib" \
      --set LIBGL_DRIVERS_PATH "/run/opengl-driver/lib/dri" \
      --set __EGL_VENDOR_LIBRARY_DIRS "/run/opengl-driver/share/glvnd/egl_vendor.d"
  '';
}
