{ lib, pkgs, ... }:

let
  # LanguageTool English n-gram data. `null` disables it (the server then
  # runs without --languageModel). Update: new file name from
  # https://languagetool.org/download/ngram-data/ then
  #   TMPDIR=/var/tmp nix store prefetch-file --name <file> <url>
  # (TMPDIR on disk: the 9 GB download is staged there, not in the 8 GB
  # tmpfs /tmp).
  ngramsEnHash = "sha256-EOVIcx2fWBifw2pVP39oVwO+MNoNm7QtH3tb9fi7Iyw=";
  ngramsEnZip = pkgs.fetchurl {
    url = "https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip";
    name = "ngrams-en-20150817.zip";
    hash = ngramsEnHash;
  };
  # --languageModel expects <dir>/en/{1grams,2grams,3grams}.
  languagetoolNgrams = if ngramsEnHash == null then null else
    pkgs.runCommand "languagetool-ngrams-en-20150817" {
      nativeBuildInputs = [ pkgs.unzip ];
    } ''
      mkdir -p "$out"
      unzip -q ${ngramsEnZip} -d "$out"
      test -d "$out/en/1grams" || { echo "unexpected archive layout:"; ls "$out"; exit 1; }
    '';
in
{
  # Doom Emacs via nix-doom-emacs-unstraightened. The config in ./doom.d and
  # its entire package set are built into the Nix store, so there is no
  # ~/.config/emacs clone, ~/.doom-local, or `doom sync`. Unstraightened stores
  # mutable state under XDG dirs (~/.cache/doom, ~/.local/share/doom, and
  # ~/.local/state/doom), not DOOMLOCALDIR. Its default `nix` profile puts some
  # state in `nix` subdirectories, so old standalone Doom state is not migrated
  # automatically.
  #
  # DOOMDIR is read-only in the store. This config redirects custom-file to the
  # writable Doom cache; persistent declarative changes belong in config.el.
  programs.doom-emacs = {
    enable = true;
    # Flakes only copy Git-tracked files to the store, so every file below this
    # directory must be added to Git before rebuilding.
    doomDir = ./doom.d;
    # pgtk build for native Wayland rendering, matching the rest of the system.
    emacs = pkgs.emacs-pgtk;
    # Nix 2.19+ can fail to fetch pinned Git revisions through fetchGit. Use the
    # fetchTree path recommended by Unstraightened for modern Nix versions.
    experimentalFetchTree = true;
    # Tree-sitter grammars are not pulled in automatically; ship them all so any
    # (lang +tree-sitter) module works out of the box.
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];

    emacsPackageOverrides = _eself: esuper: {
      # The canonical Codeberg Git endpoint has returned 504s during evaluation.
      # Fetch the same commit from its maintained GitHub mirror instead. `commit`
      # is assigned from Doom's package pin by Unstraightened, so this follows
      # future Doom updates without duplicating the revision in packages.el.
      geiser = esuper.geiser.overrideAttrs (old: {
        src = builtins.fetchTree {
          type = "github";
          owner = "emacsmirror";
          repo = "geiser";
          rev = old.commit;
        };
      });

      # Doom works around https://github.com/ProofGeneral/PG/issues/771 by
      # building Proof General without autoloads, then loading proof-site
      # explicitly in its Coq module. See the official Doom workaround at
      # https://github.com/doomemacs/core/issues/8169.
      # Unstraightened ignores Doom's `:build (:not autoloads)` recipe directive,
      # so mirror that official workaround by removing the generated autoload
      # file after installation.
      proof-general = esuper.proof-general.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          rm "$out"/share/emacs/site-lisp/elpa/proof-general-*/proof-general-autoloads.el
        '';
      });
    };
  };

  # Run Emacs as a daemon so Doom's startup cost is paid once at login; frames
  # then open instantly via `emacsclient -c` or the "Emacs (Client)" desktop
  # entry. The unstraightened module already points services.emacs.package at
  # the Doom emacs (provideEmacs = true by default), so we only enable the
  # service here. Home Manager deliberately sets X-RestartIfChanged=false for
  # this unit to avoid killing live editor sessions, so restart it manually
  # after a rebuild that changes Doom or its config.
  services.emacs = {
    enable = true;
    client.enable = true; # adds the "Emacs (Client)" desktop entry
    startWithUserSession = "graphical";
  };

  # Keep spelling data in Home Manager's XDG data tree instead of referring to
  # files in the mutable nix-configs checkout from config.el.
  xdg.dataFile = {
    "doom/american-english-exhaustive.txt".source = ./american-english-exhaustive.txt;
    "doom/ispell.dict".source = ./ispell.dict;
  };

  # wordnet provides the `wn` binary + offline WordNet database used by Doom's
  # (lookup +dictionary +offline) backends: wordnut for definitions and
  # synosaurus-wordnet for synonyms. (The `dyalog` binary for dyalog-mode lives
  # with the other language toolchains in programs/languages.)
  home.packages = [ pkgs.wordnet ];

  # LanguageTool as a warm local HTTP server, so Doom's on-demand checks
  # (langtool.el, Grammar section of config.el) answer instantly instead of
  # paying a JVM start per check. Binds to localhost only (no --public).
  #
  # With LanguageTool's English n-gram data (--languageModel): the 782
  # statistical confusion pairs in resource/en/confusion_sets.txt
  # (there/their, affect/effect, then/than, ...) are only checked when this
  # Lucene index is present. 9 GB download from languagetool.org (the zip
  # lands straight in the store, so the 8 GB tmpfs /tmp is not involved),
  # ~15 GB unpacked; the zip itself is garbage-collected once unpacked. Both
  # COSMIC hosts carry it (SSD required: random reads). word2vec rules were
  # removed from LanguageTool, fastText only does language detection, so
  # this is the only data add-on left. Heap raised for the index.
  systemd.user.services.languagetool = {
    Unit = {
      Description = "LanguageTool HTTP server for Emacs (localhost:8081)";
      After = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.languagetool}/bin/languagetool-http-server --port 8081"
        + lib.optionalString (languagetoolNgrams != null) " --languageModel ${languagetoolNgrams}";
      Environment = [ "JAVA_TOOL_OPTIONS=-Xmx2g" ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Project marker for the floating "Notes & Grammar" Emacs (second daemon,
  # see config.el): makes ~/Documents/notes a projectile project root.
  home.file."Documents/notes/.projectile".text = "";
}
