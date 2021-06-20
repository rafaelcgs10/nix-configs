{ pkgs, ...}:

let
  mypolybar = (pkgs.polybar.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [
      pkgs.python38Packages.sphinx
    ];
    src = pkgs.fetchFromGitHub {
      owner = old.pname;
      repo = old.pname;
      rev    = "10bbec44515d2479c0dd606ae48a2e0721ad94c0";
      sha256 = "0kzv6crszs0yx70v0n89jvv40155chraw3scqdybibk4n1pmbkzn";
      fetchSubmodules = true;
    };
  })).override {
    i3Support = false;
    i3GapsSupport = false;
    alsaSupport = true;
    iwSupport = false;
    githubSupport = true;
    mpdSupport = true;
    nlSupport = true;
    pulseSupport = true;
  };


in
{
  services.polybar = {
    enable = true;
    package = mypolybar;
    config = ./config.ini;
    script = ''
    '';
  };
}
