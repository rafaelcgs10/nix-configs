{ src , lib , stdenv , fetchFromGitHub , cmake , qmake , qtquicktimeline , qtsvg , wrapQtAppsHook }:

stdenv.mkDerivation {
  pname = "gpt4all-chat";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "nomic-ai";
    repo = "gpt4all-chat";
    rev = "440bf49d1290ba737f24f83972b1627664169b92";
    hash = "sha256-hA/GF101UXwB8D/SKt5O2Du4e6QmcI+sRJWKUXSBg88=";

    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX ''${CMAKE_BINARY_DIR}/install)' ""
  '';

  nativeBuildInputs = [
    wrapQtAppsHook
    cmake
  ];

  buildInputs = [
    qtquicktimeline
    qtsvg
  ];

  meta = with lib; {
    description = "Gpt4all-j chat";
    homepage = "https://github.com/nomic-ai/gpt4all-chat";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
