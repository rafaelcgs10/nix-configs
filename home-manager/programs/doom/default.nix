{ lib, options, config, specialArgs, modulesPath }:

let
  kodkodi = pkgs.callPackage ./kodkodi { };
  pkgs_old = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/860b56be91fb874d48e23a950815969a7b832fbc.tar.gz) { };
  pkgs_new = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/da6125aceb8351148f1dc94f45fe1c78e4374dc1.tar.gz) { };
  emacs-overlay = builtins.fetchTarball {url = https://github.com/nix-community/emacs-overlay/archive/e00f171142307b3c9bb962beeaaf09d0254f9e31.tar.gz;};
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  java = (pkgs_new.oraclejdk14.overrideAttrs (old: {
    version = "15.0.2+7";
    src = /home/rafael/jdk.tar.gz;
    doInstallCheck = false;
  }));
  scala = (pkgs_old.scala_2_13.overrideAttrs (old: {
    version = "2.13.4-1";
    src = pkgs.fetchurl {
      url = "https://isabelle.sketis.net/components/scala-2.13.4-1.tar.gz";
      sha256 = "1615s1gkklz1zzgj62k1iyvhgvfjhs51x8xv35k8kss3wzwcv034";
    };
    doInstallCheck = false;
  }));
  polyml = (pkgs_old.polyml.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "polyml";
      repo = "polyml";
      rev    = "f86ae3dc168612d51e7a73fbe3b7e02cb3bc1bac";
      sha256 = "020axkl3av8wwrl45zvzs66r7rfazcvl1mw3rqx89k61cv7mnlf2";
      fetchSubmodules = true;
    };
  }));
  isabelle = (pkgs_new.isabelle.overrideAttrs (old: {
    src = /home/rafael/isabelle/Isabelle2021.tar.gz;

    postPatch = ''
    patchShebangs .
    sed -i '4iexport TARGET=x86_64-linux' Admin/bash_process/build
    sed -i '5iecho oi' Admin/bash_process/build
    sed -i '2iecho oi3' lib/scripts/polyml-version
    sed -i '3iexport ML_HOME=${polyml}' lib/scripts/polyml-version
    sed -i '4iML_HOME=${polyml}' lib/scripts/polyml-version
    sed -i '11iexport POLYML_HOME=${polyml}' bin/isabelle
    sed -i '12iexport ML_HOME=${polyml}/bin' bin/isabelle
    sed -i '13iexport TARGET=x86_64-linux' bin/isabelle
    sed -i '14iecho oi4' bin/isabelle
    sed -i '52ipwd' bin/isabelle
    sed -i '35iecho $TOOL' bin/isabelle
    sed -i '6iecho oi5' bin/isabelle_java
    sed -i '9iecho $TARGET' bin/isabelle_java
    sed -i '11iecho oi6' lib/Tools/java
    sed -i '10iecho $CLASSPATH' lib/Tools/java
    # sed -i '12ienv' lib/Tools/java
    sed -i '13iecho $ISABELLE_JAVA_SYSTEM_OPTIONS' lib/Tools/java
    sed -i '28s|\/usr\/bin\/env|${pkgs_old.coreutils}\/bin\/env|' lib/Tools/env

    sed -i '1iexport POLYML_HOME=${polyml}' lib/scripts/getsettings
    sed -i '2iexport ML_HOME=${polyml}' lib/scripts/getsettings
    sed -i '3iML_HOME=${polyml}' lib/scripts/getsettings
    sed -i '4iexport Z3_HOME=${pkgs_old.z3}' lib/scripts/getsettings
    sed -i '5iexport Z3_VERSION=${pkgs_old.z3.version}' lib/scripts/getsettings
    sed -i '6iexport Z3_SOLVER=${pkgs_old.z3}/bin/z3' lib/scripts/getsettings
    sed -i '7iexport Z3_INSTALLED=yes' lib/scripts/getsettings
    sed -i '8iexport ML_SYSTEM_64=true' lib/scripts/getsettings
    sed -i '9iexport ML_SYSTEM=${polyml.name}' lib/scripts/getsettings
    sed -i '10iexport ML_PLATFORM=${pkgs_old.stdenv.system}' lib/scripts/getsettings
    sed -i '11iexport ML_IDENTIFIER=polyml-5.8.1_x86_64-linux' lib/scripts/getsettings
    sed -i '12iexport ML_HOME=${polyml}/bin' lib/scripts/getsettings
    sed -i '13iexport POLYML_HOME=${polyml}' lib/scripts/getsettings
    sed -i '14iexport ISABELLE_JAVA_PLATFORM=${pkgs_old.stdenv.system}' lib/scripts/getsettings
    sed -i '15iexport SCALA_HOME=${scala}' lib/scripts/getsettings
    sed -i '16iexport ISABELLE_JDK_HOME=${java}' lib/scripts/getsettings
    sed -i '17iexport JAVA_HOME=${java}' lib/scripts/getsettings
    sed -i '18iexport ISABELLE_PLATFORM64=x86_64-linux' lib/scripts/getsettings
    sed -i '19iexport ISABELLE_PLATFORM_FAMILY="linux"' lib/scripts/getsettings
    sed -i '20iexport KODKODI_JAVA_LIBRARY_PATH=${kodkodi}' lib/scripts/getsettings

    echo ISABELLE_LINE_EDITOR=${pkgs_old.rlwrap}/bin/rlwrap >>etc/settings

    '';

    buildPhase = ''
    export HOME=/tmp
    rm -rf lib/classes
    ./lib/scripts/getsettings
    env
    ./bin/isabelle build -b HOL
    '';

    installPhase = ''
    # sed -i '47ipwd' .bin/isabelle
    # sed -i '48iecho $ISABELLE_HOME' bin/isabelle
    export HOME=/tmp
    mkdir -p $out/bin
    mv $TMP/$dirname $out
    cd $out/$dirname
    ./bin/isabelle install $out/bin

    wrapProgram $out/$dirname/src/HOL/Tools/ATP/scripts/remote_atp --set PERL5LIB ${pkgs_old.perlPackages.makeFullPerlPath [ pkgs_old.perlPackages.LWP ]}
  '';
  }));
  # wrapProgram $out/$dirname/src/HOL/Tools/ATP/scripts/remote_atp --set PERL5LIB ${pkgs_new.perlPackages.makeFullPerlPath [ pkgs_new.perlPackages.LWP ]}
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/33064319607745856f488a998ca3db8ffcede865.tar.gz;
    # url = https://github.com/vlaci/nix-doom-emacs/archive/f2848e51a557b78214ab19bb504fb936d8d513d4.tar.gz;
    # url = https://github.com/vlaci/nix-doom-emacs/archive/3893c50877a9d2d5d4aeee524ba1539f22115f1f.tar.gz;
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
  home.packages = [ doom-emacs pkgs.python3 kodkodi ];
  home.file.".emacs.d/init.el".text = ''
      (load "default.el")
  '';
}
