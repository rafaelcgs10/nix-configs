let
  emacs-overlay = builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;};
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  spinner-lzip = builtins.fetchurl {
    url = "https://elpa.gnu.org/packages/spinner-1.7.3.el.lz";
    sha256 = "188i2r7ixva78qd99ksyh3jagnijpvzzjvvx37n57x8nkp8jc4i4";
  };
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    # url = https://github.com/vlaci/nix-doom-emacs/archive/master.tar.gz;
    url = https://github.com/vlaci/nix-doom-emacs/archive/f2849e51a557b78214ab19bb504fb936d8d513d4.tar.gz;
    # url = https://github.com/vlaci/nix-doom-emacs/archive/3893c50877a9d2d5d4aeee524ba1539f22115f1f.tar.gz;
  }) {
    # Directory containing your config.el init.el and packages.el files
    doomPrivateDir = ./doom.d;

    # emacsPackagesOverlay = self: super: {
    #   spinner = super.spinner.override {
    #     elpaBuild = args: super.elpaBuild (args // {
    #       src = pkgs.runCommandLocal "spinner-1.7.3.el" {} ''
    #         ${pkgs.lzip}/bin/lzip -d -c ${spinner-lzip} > $out
    #       '';
    #     });
    #   };
    # };
  };
in {
  home.packages = [ doom-emacs pkgs.python3 ];
  home.file.".emacs.d/init.el".text = ''
      (load "default.el")
  '';
}
