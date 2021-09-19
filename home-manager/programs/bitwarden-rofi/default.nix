  # source: https://github.com/nix-community/nur-combined/blob/master/repos/reedrw/pkgs/bitwarden-rofi/default.nix#L68

{ stdenv , lib , fetchFromGitHub , makeWrapper , unixtools , xsel , xclip , wl-clipboard , xdotool , bitwarden-cli , rofi , jq , keyutils , libnotify }:
let
  bins = [
    jq
    bitwarden-cli
    unixtools.getopt
    rofi
    xsel
    xclip
    xdotool
    keyutils
    libnotify
  ];
in
stdenv.mkDerivation {
  pname = "bitwarden-rofi";
  name = "bitwarden-rofi";

  src = fetchFromGitHub {
    owner = "mattydebie";
    repo = "bitwarden-rofi";
    rev = "62c95afd5634234bac75855dc705d4da5f4fab69";
    sha256 = "0cwpc3am9kqn9pxqq8kaqg8150y3bln8a6gzm5nfh61357m55xba";
  };

  buildInputs = [
    makeWrapper
  ];


  installPhase = ''
    mkdir -p "$out/bin"
    install -Dm755 "bwmenu" "$out/bin/bwmenu"
    install -Dm755 "lib-bwmenu" "$out/bin/lib-bwmenu" # TODO don't put this in bin
    install -Dm755 -d "$out/usr/share/doc/bitwarden-rofi"
    install -Dm755 -d "$out/usr/share/doc/bitwarden-rofi/img"
    install -Dm644 "README.md" "$out/usr/share/doc/bitwarden-rofi/README.md"
    install -Dm644 img/* "$out/usr/share/doc/bitwarden-rofi/img/"
    wrapProgram "$out/bin/bwmenu" --prefix PATH : ${lib.makeBinPath bins}
    # run bw login and keyctl link @u @s after
  '';

  meta = with lib; {
    description = "Wrapper for Bitwarden and Rofi";
    homepage = "https://github.com/mattydebie/bitwarden-rofi";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
