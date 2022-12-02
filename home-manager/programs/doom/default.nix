{ lib, options, config, specialArgs, modulesPath }:

let
  emacs-overlay = builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/5c03fb3e6636b7121b8c3b126d2351e78cb54d4f.tar.gz;};
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/3c02175dd06714c15ddd2f73708de9b4dacc6aa9.tar.gz;
  }) {
    # bundledPackages = true;
    # emacsPackages = pkgs.emacsPackagesFor pkgs.emacsGit;
    emacsPackages = pkgs.emacsPackagesFor pkgs.emacsGitNativeComp;
    doomPrivateDir = ./doom.d;
    dependencyOverrides = {
      "emacs-overlay" = emacs-overlay;
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
        academic-phrases = pkgs.emacsPackages.academic-phrases;
        gitignore-mode = pkgs.emacsPackages.git-modes;
        flycheck-grammarly = pkgs.emacsPackages.flycheck-grammarly;
        flycheck-languagetool = pkgs.emacsPackages.flycheck-languagetool;
        company-posframe = pkgs.emacsPackages.company-posframe;

        isar-goal-mode = self.trivialBuild {
          pname = "isar-goal-mode";
          ename = "isar-goal-mode";
          version = "2020-11-20";
          src = builtins.fetchTarball {
            url = "https://github.com/m-fleury/isar-mode/archive/8675631462517a0a2723405177ef86d06dfaa6d5.tar.gz";
          };
        };
        isar-mode = self.trivialBuild {
          pname = "isar-mode";
          ename = "isar-mode";
          version = "2020-11-20";
          src = builtins.fetchTarball {
            url = "https://github.com/m-fleury/isar-mode/archive/8675631462517a0a2723405177ef86d06dfaa6d5.tar.gz";
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
            url = "https://github.com/m-fleury/isabelle-emacs/archive/9f7cd9036714f957c700a91ca909451a4e567539.tar.gz";
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
            url = "https://github.com/m-fleury/isabelle-emacs/archive/9f7cd9036714f957c700a91ca909451a4e567539.tar.gz";
          };
          buildPhase = ''
            cd src/Tools/emacs-lsp/lsp-isar
          '';
        };
      };
  };
in {

  home.packages = [ doom-emacs ];
  home.file.".emacs.d/init.el".text = ''
      (load "default.el")
  '';
}
