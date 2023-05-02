{ lib , stdenv , fetchFromGitHub , cmake , qmake , qtquicktimeline , qtsvg }:

stdenv.mkDerivation {
  pname = "gpt4all-chat";
  version = "unstable-2023-04-30";

  src = fetchFromGitHub {
    owner = "nomic-ai";
    repo = "gpt4all-chat";
    rev = "d3d8229b047939e442db797e1d1de65cdd45f462";
    hash = "sha256-7qhlFQ1IvqnoOKCtMyTz1Z4zD4RDm1259+hflZ29ZmU=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX ''${CMAKE_BINARY_DIR}/install)' ""
  '';

  nativeBuildInputs = [
    cmake
    qmake
  ];

  buildInputs = [
    qtquicktimeline
    qtsvg
  ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Gpt4all-j chat";
    homepage = "https://github.com/nomic-ai/gpt4all-chat";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
