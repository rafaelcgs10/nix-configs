{ lib, options, config, specialArgs, modulesPath }:

let
  emacs-overlay = builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/e00f171142307b3c9bb962beeaaf09d0254f9e31.tar.gz;};
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/33064319607745856f488a998ca3db8ffcede865.tar.gz;
  }) {
    # bundledPackages = false;
    # emacsPackages = pkgs.emacsPackagesFor pkgs.emacsGcc;
    # Directory containing your config.el init.el and packages.el files
    doomPrivateDir = ./doom.d;
    emacsPackagesOverlay = self: super:
      let
        mkGitPkg = { host, user, name, rev ? null }:
          self.trivialBuild {
            pname = name;
            version = rev;
            src = builtins.fetchGit {
              url = "https://${host}.com/${user}/${name}.git";
              rev = rev;
            };
          };
      in {
        isar-mode = self.trivialBuild {
          pname = "isar-mode";
          ename = "isar-mode";
          version = "2020-11-20";
          src = builtins.fetchTarball {
            url = "https://github.com/m-fleury/isar-mode/archive/f29e28e5f73c36f2a05b19e8afcff63f5e1ccabf.tar.gz";
          };
        };
        lsp-isar-parse-args = self.trivialBuild {
          pname = "lsp-isar-parse-args";
          ename = "lsp-isar-parse-args";
          version = "2020-11-20";
          src = builtins.fetchTarball {
            url = "https://github.com/m-fleury/isabelle-emacs/archive/767a5a69c175557e4ed32347b42c9197091061af.tar.gz";
          };
          buildPhase = ''
            cd src/Tools/emacs-lsp/lsp-isar
          '';
        };
        lsp-isar = self.trivialBuild {
          pname = "lsp-isar";
          ename = "lsp-isar";
          version = "2020-11-20";
          src = builtins.fetchTarball {
            url = "https://github.com/m-fleury/isabelle-emacs/archive/767a5a69c175557e4ed32347b42c9197091061af.tar.gz";
          };
          buildPhase = ''
            cd src/Tools/emacs-lsp/lsp-isar
          '';
        };
        isar-goal-mode = self.trivialBuild {
          pname = "isar-goal-mode";
          ename = "isar-goal-mode";
          version = "2020-11-20";
          src = builtins.fetchTarball {
            url = "https://github.com/m-fleury/isar-mode/archive/f29e28e5f73c36f2a05b19e8afcff63f5e1ccabf.tar.gz";
          };
        };
      };
  };
in {
  home.packages = [ doom-emacs ];
  home.file.".emacs.d/init.el".text = ''
      (load "default.el")
  '';
}
