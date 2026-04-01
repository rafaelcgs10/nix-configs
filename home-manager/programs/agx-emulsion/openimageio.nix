{
  pkgs ? import <nixpkgs> {},
}:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "OpenImageIO";
  version = "3.1.8.0";
  pyproject = true;

  src = pkgs.python3Packages.fetchPypi {
    pname = "openimageio";   # must be lowercase
    version = "3.1.10.0";    # use a version that actually exists
    sha256 = "sha256-XYA5S5YtwPg8FO/Ov8SBw9HtOr5mABsvYCJhzbHJBYo=";
  };

  build-system = with pkgs.python3Packages; [
    setuptools
    setuptools-scm
    scikit-build-core
  ];

  dependencies = with pkgs; [
	  python3Packages.numpy
	  python3Packages.scipy
  ];

  nativeBuildInputs = with pkgs; [
	  fftw
    cmake
    ninja
    git
  ];
  buildInputs = with pkgs; [
    zlib
    imath
    openexr
    libjpeg 
    libtiff
    libpng
    openimageio
    freetype
    opencolorio
    opencv
    libraw
    libheif
    mesa
    libgbm
    libglvnd
    qt6.qtbase
    qt6.qttools
    giflib
    ffmpeg
    openjph
    libwebp
  ] ++ (with pkgs.python3Packages; [
    pybind11
  ]);

  dontWrapQtApps = true;
cmakeFlags = [
  "-DUSE_Nuke=OFF"
  # "-DUSE_Robinmap=OFF"
    "-DOpenImageIO_BUILD_MISSING_DEPS=required"
];
}
