{
  pkgs ? import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/25.05.tar.gz";
}) {},
}:

pkgs.python312Packages.buildPythonPackage rec {
  pname = "colour-science";
  version = "0.4.7";
  pyproject = true;
  pythonRuntimeDepsCheck = false;

  src = pkgs.fetchFromGitHub {
	  owner = "colour-science";
	  repo = "colour";
	  rev = "a3bfe349685f528100672e5c8ca2dfeeef64a273";
	  hash = "sha256-yu0mmXnCZD1gEuTeo31mRjl+CaMdnaDlltIHf2v57pU=";
  };

  dependencies = with pkgs; [
	  python312Packages.numpy
  ];

  build-system = with pkgs.python312Packages; [
	  setuptools
	  setuptools-scm
	  hatchling
  ];
}
