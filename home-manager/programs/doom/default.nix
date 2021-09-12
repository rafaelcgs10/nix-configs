let
  emacs-overlay = builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/e00f171142307b3c9bb962beeaaf09d0254f9e31.tar.gz;};
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/33064319607745856f488a998ca3db8ffcede865.tar.gz;
    # url = https://github.com/vlaci/nix-doom-emacs/archive/f2848e51a557b78214ab19bb504fb936d8d513d4.tar.gz;
    # url = https://github.com/vlaci/nix-doom-emacs/archive/3893c50877a9d2d5d4aeee524ba1539f22115f1f.tar.gz;
  }) {
    # bundledPackages = false;
    emacsPackages = pkgs.emacsPackagesFor pkgs.emacsGcc;
    # Directory containing your config.el init.el and packages.el files
    doomPrivateDir = ./doom.d;
  };
in {
  home.packages = [ doom-emacs pkgs.python3 ];
  home.file.".emacs.d/init.el".text = ''
      (load "default.el")
  '';
}
