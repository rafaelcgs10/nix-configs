{
  pkgs ? import <nixpkgs> {},
}:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "pyfftw";
  version = "0.15.1";
  pyproject = true;
  pythonRuntimeDepsCheck = false;

  src = pkgs.python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-u83m1A0WXhy68S3eBi6/6+nkM5TKyMFm5pm6LJpLBGE=";
  };

  build-system = with pkgs.python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with pkgs; [
    python3Packages.numpy
    python3Packages.cython
    python3Packages.scipy
    fftw
  ];

  nativeBuildInputs = with pkgs; [
    fftw
  ];
}
