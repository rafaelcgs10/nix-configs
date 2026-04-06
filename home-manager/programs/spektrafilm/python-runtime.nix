let
  spektrafilm-pkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/25.05.tar.gz";
  }) {
    config.allowBroken = true;
    overlays = [
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (python-final: python-prev: {
            colour-science = import ./colour-science.nix { pkgs = final; };
            pyfftw = import ./pyfftw.nix { pkgs = final; };
            openimageio = import ./openimageio.nix { pkgs = final; };
            spektrafilm = import ./spektrafilm.nix { pkgs = final; };
          })
        ];
      })
    ];
  };
in
spektrafilm-pkgs.python3.withPackages
  (ps: with ps; [ numpy scipy spektrafilm ])
