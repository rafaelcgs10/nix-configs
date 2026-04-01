{ pkgs ? import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/25.05.tar.gz";
}) { 
  overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (python-final: python-prev: {
          colour-science = final.callPackage ./colour-science.nix {};
          pyfftw = final.callPackage ./pyfftw.nix {};
        })
      ];
    })
  ]; 
}
}:

pkgs.python312Packages.buildPythonApplication rec {
  pname = "agx-emulsion";
  version = "0.1.0-alpha";
  pyproject = true;
  doCheck = false;
  doInstallCheck = false;
  pythonRuntimeDepsCheck = false;

  src = pkgs.fetchFromGitHub {
	  owner = "andreavolpato";
	  repo = "agx-emulsion";
	  rev = "0e0baf2e3dd51032e89df92c8bb281f05e3ce977";
	  hash = "sha256-9N9ozvw7/XGHWX1AjblZbR7GI9dbHAwFUuV/C2HGZjI=";
  };

  build-system = with pkgs.python312Packages; [ setuptools ];

  dependencies = with pkgs; [
   python312Packages.napari
   python312Packages.numpy
   python312Packages.matplotlib
   python312Packages.scipy
   python312Packages.scikit-image
   python312Packages.dotmap
   python312Packages.opt-einsum
   python312Packages.magicgui
   python312Packages.lmfit
   python312Packages.pyqt5
   python312Packages.numba
   python312Packages.cython
   python312Packages.colour-science
   python312Packages.pyfftw
   openimageio
  ]; 
  
  nativeBuildInputs = with pkgs; [
    wrapGAppsHook3
  ];

  dontWrapGApps = true;

  preFixup = ''
	qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
    '';
}
