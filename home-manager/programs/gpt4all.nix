{ lib, stdenv, fetchFromGitHub, cmake, vulkan-headers, qt6 }:

let
  rev = "d3d8229b047939e442db797e1d1de65cdd45f462";

  src = fetchFromGitHub {
    owner = "nomic-ai";
    repo = "gpt4all-chat";
    rev = rev;
    sha256 = "sha256-7qhlFQ1IvqnoOKCtMyTz1Z4zD4RDm1259+hflZ29ZmU=";
    fetchSubmodules = true;
  };
in
stdenv.mkDerivation {
  name = "gpt4all-chat-${rev}";
  src = src;

  dontWrapQtApps = true;
  nativeBuildInputs = [ cmake qt6.qmake ];
  buildInputs = [ qt6.qtquicktimeline qt6.qtsvg ];

  buildPhase = ''
    mkdir -p build
    cd build
    cmake ..
    cmake --build .
  '';

  installPhase = ''
    mkdir -p $out/bin/
    cp ./chat $out/bin/chat
  '';

}
