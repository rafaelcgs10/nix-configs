{ lib, options, config, specialArgs, modulesPath }:

let
  emacs-overlay = builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/7673ee506b16d9fa77740b783c779394d722074e.tar.gz;};
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/fee14d217b7a911aad507679dafbeaa8c1ebf5ff.tar.gz;
  }) {
    # bundledPackages = false;
    # emacsPackages = pkgs.emacsPackagesFor pkgs.emacsGcc;
    # Directory containing your config.el init.el and packages.el files
    doomPrivateDir = ./doom.d;
    dependencyOverrides = {
      "emacs-overlay" = (builtins.fetchTarball {
        url = https://github.com/nix-community/emacs-overlay/archive/7673ee506b16d9fa77740b783c779394d722074e.tar.gz;
      });
    };
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
        gitignore-mode = pkgs.emacsPackages.git-modes;
        gitconfig-mode = pkgs.emacsPackages.git-modes;
        isar-mode = self.trivialBuild {
          pname = "isar-mode";
          ename = "isar-mode";
          version = "2020-11-20";
          src = builtins.fetchTarball {
            url = "https://github.com/m-fleury/isar-mode/archive/f29e28e5f73c36f2a05b19e8afcff63f5e1ccabf.tar.gz";
          };
        };
        # twauctex = self.trivialBuild {
        #   pname = "twauctex";
        #   ename = "twauctex";
        #   version = "2021-04-26";
        #   packageRequires = [ pkgs.emacsPackages.auctex pkgs.emacsPackages.latex-extra ];
        #   src = pkgs.fetchFromGitHub {
        #     owner = "jeeger";
        #     repo = "twauctex";
        #     rev = "0984f0c8692694c121b2b7ecb221b2a824794876";
        #     hash = "sha256-lFmdVMXIIXZ9ZohAJw5rhxpTv017qIyzmpuKOWDdeJ4=";
        #   };
        # };
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
