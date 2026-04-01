{
  pkgs ? import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/25.05.tar.gz";
}) {},
}:

pkgs.python312Packages.buildPythonPackage rec {
  pname = "pyfftw";
  version = "0.15.1";
  pyproject = true;
  pythonRuntimeDepsCheck = false;

  src = pkgs.python312Packages.fetchPypi {
	  inherit pname version;
	  hash = "sha256-u83m1A0WXhy68S3eBi6/6+nkM5TKyMFm5pm6LJpLBGE=";
  };

  build-system = with pkgs.python312Packages; [
	  setuptools
	  setuptools-scm
  ];

  dependencies = with pkgs; [
	  python312Packages.numpy
	  python312Packages.cython
	  python312Packages.scipy
	  fftw
  ];

  nativeBuildInputs = with pkgs; [
	  fftw
  ];
}
