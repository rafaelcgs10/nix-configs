{ pkgs, lib, config, pkgsUnstable, pkgsLmstudio, spektrafilmPackages, ...}:

let
  # `darktable-spektrafilm-ai` is a symlinkJoin wrapper (it runtime-links the
  # spektrafilm data pack and AI models) around the real darktable build, which
  # it exposes through passthru as `.basePackage`. We patch that base to add a
  # headless `--sync-xmp` mode that reconciles updated XMP sidecars into the
  # library database without launching the GUI (darktable-headless-xmp-sync.patch).
  # The data pack and AI models are already linked declaratively via home.file
  # below, so the runtime wrapper is redundant here and we use the patched base
  # package directly — one build, used for both the GUI and the sync timer.
  darktable-xmp-sync =
    spektrafilmPackages.darktable-spektrafilm-ai.basePackage.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./darktable-headless-xmp-sync.patch
        # native Adobe DNG camera profile (.dcp) support in the input color
        # profile module: put .dcp files in ~/.config/darktable/color/dcp/
        # and pick them like any input profile. The profile tone curve is
        # deliberately not applied, so agx/sigmoid keep owning tone, and the
        # white balance / color calibration modules are untouched.
        ./darktable-dcp-support.patch
      ];
    });

  # DT Pro theme pack from darktable.info (DT-Pro-orange and its siblings).
  # Not in nixpkgs and there is no upstream git repo — the author distributes a
  # single archive from the site, so fetch that and expose the CSS + SVG tree
  # for linking into ~/.config/darktable/themes.
  #
  # Despite being advertised as a ZIP it is really a 7z archive, hence p7zip and
  # the explicit unpackPhase. DT-Pro-orange.css @imports darktable.css, and
  # icon.css pulls the SVG/ directory, so the whole tree has to be installed —
  # not just the one file.
  #
  # The download URL carries a per-file key; if the author rotates it the fetch
  # fails loudly with a hash/404 error rather than silently going stale.
  dt-pro-themes = pkgs.stdenvNoCC.mkDerivation {
    pname = "darktable-dt-pro-themes";
    version = "0-unstable-2026-08-20";

    src = pkgs.fetchurl {
      name = "DT-Pro-Theme-Pack.7z";
      url = "https://darktable.info/sdc_download/13401/?key=5mm66ed41kvuaj5dagt5zaprkgvx31";
      hash = "sha256-UGqb3MRugNZfivEMlj3JLhtSiJe5HUOzYcLFvtkVaRQ=";
    };

    nativeBuildInputs = [ pkgs.p7zip ];
    unpackPhase = ''
      runHook preUnpack
      7z x "$src"
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r ./*.css SVG "$out"/
      runHook postInstall
    '';

    meta = {
      description = "DT Pro theme pack for darktable";
      homepage = "https://darktable.info/en/system-ui-2/darktable-themes-overview/darktable-themes-overview-2/";
      platforms = lib.platforms.all;
    };
  };

  # `dt-sync` — start the headless XMP -> library sync and show LIVE per-file
  # progress. The service logs "[crawler] synced XMP -> DB for `<file>'" per
  # image (via -d control on the unit); we count those against the number of
  # images in darktable's library for a running [n/total %] bar with the current
  # filename. For the big post-tagging sync (all sidecars changed) that total is
  # exact; for routine incremental runs only a few files change, so the % is a
  # loose upper bound — but those finish in seconds anyway. Ctrl-C stops watching;
  # the sync keeps running in the background (it's a systemd service).
  dtSync = pkgs.writeShellScriptBin "dt-sync" ''
    export XDG_RUNTIME_DIR="/run/user/$(${pkgs.coreutils}/bin/id -u)"
    svc="darktable-xmp-sync.service"
    lib="$HOME/.config/darktable/library.db"
    total=$(${pkgs.sqlite}/bin/sqlite3 "file:$lib?immutable=1" \
              "SELECT count(*) FROM images;" 2>/dev/null || echo 0)
    echo "darktable XMP -> DB sync: reconciling updated sidecars (~$total images)…"
    # Start following the log FIRST so a fast (few-file) sync's "done" line is
    # never missed, then trigger the service and wait for the follower to end.
    { ${pkgs.systemd}/bin/journalctl --user -u "$svc" -f -n 0 -o cat 2>/dev/null \
        | ${pkgs.gawk}/bin/awk -v total="$total" '
            /synced XMP -> DB/ {
              n++; f = $0; sub(/.*for `/, "", f); sub(/.$/, "", f);
              p = (total > 0) ? (100.0 * n / total) : 0;
              printf "\r[%d/%d %3.0f%%] %s\033[K", n, total, p, f; fflush(); next
            }
            /headless XMP -> DB sync done/ { printf "\n%s\n", $0; fflush(); exit }
            /FAILED to sync/               { printf "\n%s\n", $0; fflush() }
          '; } &
    follower=$!
    ${pkgs.systemd}/bin/systemctl --user start --no-block "$svc"
    wait "$follower"
  '';
in
{
  home.packages = [
    pkgs.gimp3-with-plugins
    pkgs.scribus
    pkgs.inkscape
    pkgs.krita
    # Affinity v3 (unified Photo/Designer/Publisher app) via Wine, from the
    # affinity-nix overlay. v2 apps also exist as affinity-photo/-designer/
    # -publisher if ever needed.
    pkgs.affinity-v3
    pkgs.lutris
    pkgs.gamescope
    pkgs.mangohud
    pkgs.hydralauncher
    pkgs.ludusavi
    pkgs.protonup-qt
    pkgs.calibre
    pkgs.sc-controller
    pkgsUnstable.zulip
    pkgs.pgadmin4-desktopmode
    pkgs.handbrake # ghb
    pkgs.upscayl
    pkgsLmstudio.lmstudio

    # darktable built from the spektrafilm PR branch (native C spektrafilm
    # module), patched to add the headless `--sync-xmp` mode driven by the
    # systemd timer below. Replaces the stock pkgsDarktable.darktable; the
    # runtime data pack and AI models are linked in via home.file below.
    darktable-xmp-sync
    dtSync # `dt-sync` command: run the sync with a live progress bar
    spektrafilmPackages.spektrafilm
    spektrafilmPackages.spektrafilm-art
    pkgs.vkdt
    pkgs.digikam
    pkgs.rapidraw
    pkgs.focus-stack
    pkgs.hugin
    pkgs.exiftool
    pkgs.deluge

    # Parabolic (Nickvision Tube Converter) — a GTK GUI over yt-dlp. Unlike the
    # integrated YouTube-streaming apps (Spotube/Bloomee), which each ship their
    # own extractor that YouTube keeps breaking, this rides yt-dlp — the one
    # extractor that is patched within hours of any YouTube change — so it stays
    # reliable. Paste a track/playlist/album URL; it downloads audio with tags
    # and cover art to ~/Music, to be played by any local player.
    pkgs.parabolic
    pkgs.yt-dlp

    # Elisa — clean, modern KDE/Kirigami music player for the beets-managed
    # ~/Music (library browser, reads embedded tags/art/synced lyrics). Set as
    # the default audio handler on these (COSMIC) hosts via xdg.mimeApps below.
    pkgs.kdePackages.elisa
  ];

  # Parabolic's binary/desktop id is `org.nickvision.tubeconverter`; alias the
  # short name so `parabolic` works in a terminal (the launcher shows "Parabolic").
  home.shellAliases.parabolic = "org.nickvision.tubeconverter";

  # Make Elisa the default music player. This lives in extras.nix (the default
  # profile = the COSMIC desktop hosts) rather than the shared home.nix, so the
  # tablet — which doesn't get Elisa — isn't pointed at a missing handler. The
  # attrset merges with the (empty) defaultApplications in home.nix. COSMIC reads
  # the standard XDG mimeapps.list, so this is what its "Default Applications"
  # resolves to as well.
  xdg.mimeApps.defaultApplications =
    let elisa = "org.kde.elisa.desktop";
    in lib.genAttrs [
      "audio/mpeg"
      "audio/mp4"
      "audio/aac"
      "audio/flac"
      "audio/x-flac"
      "audio/ogg"
      "audio/x-vorbis+ogg"
      "audio/opus"
      "audio/x-opus+ogg"
      "audio/x-m4a"
      "audio/wav"
      "audio/x-wav"
      "audio/webm"
      "audio/x-ms-wma"
      "application/ogg"
    ] (_: elisa);

  # Film & print data pack for the darktable spektrafilm module. Newer builds
  # can download this pack from within the UI into
  # ~/.local/share/darktable/spektrafilm/packs/<lut_hash>/; we pre-install the
  # pinned pack at that same hashed path so it works offline with no download,
  # while leaving spektrafilm/ itself writable so the in-UI downloader still
  # works for other tables. The resolver (src/common/spektra_fetch.c) picks this
  # up for both fresh edits and edits recorded with this LUT hash. The hash
  # comes from the pack derivation so it tracks pack bumps automatically.
  # (Moved from ~/.config/darktable in the 2026-08 module update: packs now
  # resolve via g_get_user_data_dir(), next to the AI models below.)
  home.file.".local/share/darktable/spektrafilm/packs/${spektrafilmPackages.spektrafilm-data-pack.lutHash}".source =
    spektrafilmPackages.spektrafilm-data-pack;

  # Offline AI models for darktable's AI modules (denoise / upscale / object
  # masking). The fork reports version 5.8.0, which has no auto-download match,
  # so we bundle them here and link them into darktable's models dir (read-only;
  # darktable only scans it). Not used by spektrafilm itself.
  home.file.".local/share/darktable/models".source =
    spektrafilmPackages.darktable-ai-models;

  home.file.".local/share/darktable/raster-masks/.keep".text = "";

  # darktable stores the raster-mask export directory in darktablerc. Keep the
  # generated PNG masks out of $HOME without taking ownership of the full file.
  home.activation.setDarktableRasterMaskPath = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_file="${config.home.homeDirectory}/.config/darktable/darktablerc"
    mask_dir="${config.home.homeDirectory}/.local/share/darktable/raster-masks"

    ${pkgs.coreutils}/bin/mkdir -p "$mask_dir" "$(${pkgs.coreutils}/bin/dirname "$config_file")"
    ${pkgs.coreutils}/bin/touch "$config_file"

    if ${pkgs.gnugrep}/bin/grep -q '^plugins/darkroom/segments/def_path=' "$config_file"; then
      ${pkgs.gnused}/bin/sed -i \
        "s|^plugins/darkroom/segments/def_path=.*|plugins/darkroom/segments/def_path=$mask_dir|" \
        "$config_file"
    else
      printf '\nplugins/darkroom/segments/def_path=%s\n' "$mask_dir" >> "$config_file"
    fi
  '';

  # ── Why Affinity's scratch folder has to live outside your home ──────────
  # Affinity is installed read-only in the Nix store. So that it can still
  # save things (its Wine prefix, settings, activation), affinity-nix stacks
  # a *writable* folder on top of that read-only install using an "overlay"
  # mount. By default that writable folder goes in your home:
  #   ~/.local/share/affinity-v3   (the changes)  = overlay "upperdir"
  #   ~/.local/state/affinity-v3   (its scratch)  = overlay "workdir"
  #
  # The catch: your home is encrypted with ecryptfs, and an overlay mount is
  # not allowed to keep its writable layer on ecryptfs (that filesystem is
  # missing features overlayfs needs — trusted xattrs, whiteouts). The kernel
  # rejects the mount and Affinity dies at launch with a misleading
  # "Cannot allocate memory (os error 12)". (A machine with an unencrypted
  # home has no problem — that's why it "just works" elsewhere.)
  #
  # Fix: move ONLY those two folders onto the normal, unencrypted btrfs disk
  # (/var/lib/affinity-nix, created by the tmpfiles rule in
  # nixos/configuration.nix) and leave a symlink where Affinity looks for
  # them. What moves out is just a throwaway scratch layer that rebuilds in
  # seconds — your Affinity *preferences* ($XDG_DATA_HOME/affinity/) and your
  # saved .afdesign documents still live in your encrypted home. It is the
  # *filesystem*, not the path, that has to be non-ecryptfs; the symlinks
  # themselves still sit in ~. If you ever disable home encryption, delete
  # these two lines (and the tmpfiles rule) to return to the default.
  home.file.".local/share/affinity-v3".source =
    config.lib.file.mkOutOfStoreSymlink "/var/lib/affinity-nix/data";
  home.file.".local/state/affinity-v3".source =
    config.lib.file.mkOutOfStoreSymlink "/var/lib/affinity-nix/state";

  # Affinity/Wine HiDPI: COSMIC (descale_xwayland=fractional) hands XWayland
  # clients unscaled pixels and expects them to scale themselves, but Wine only
  # does that when its registry DPI (LogPixels) is set — default 96 leaves the
  # UI tiny on a 4K/150% display. Derive the DPI from the largest enabled
  # output scale in cosmic-comp's state (150% -> 144) and patch it into the
  # writable Affinity prefix. Runs only when the prefix already exists (first
  # launch creates it) and Affinity is closed (wineserver rewrites user.reg on
  # exit, undoing external edits). Re-applies on every switch, so a changed
  # COSMIC scale is picked up at the next rebuild.
  home.activation.setAffinityWineDpi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    outputs_ron="$HOME/.local/state/cosmic-comp/outputs.ron"
    user_reg="/var/lib/affinity-nix/data/user.reg"

    if [ -f "$outputs_ron" ] && [ -f "$user_reg" ] \
        && ! ${pkgs.procps}/bin/pgrep -f 'affinity-nix-prefi[x]' >/dev/null; then
      dpi=$(${pkgs.gawk}/bin/gawk '
        match($0, /scale: ([0-9.]+)/, m) { if (m[1] + 0 > s) s = m[1] + 0 }
        END { if (s == 0) s = 1; printf "%d", 96 * s + 0.5 }' "$outputs_ron")
      hex=$(printf 'dword:%08x' "$dpi")

      if ! ${pkgs.gnugrep}/bin/grep -q "\"LogPixels\"=$hex" "$user_reg"; then
        # Set LogPixels in both sections wine consults: the canonical
        # Control Panel\Desktop (what winecfg writes) and the legacy
        # Software\Wine\Fonts one the base prefix ships with 96 in.
        ${pkgs.gawk}/bin/gawk -v h1='[Control Panel\\\\Desktop]' \
          -v h2='[Software\\\\Wine\\\\Fonts]' \
          -v kv="\"LogPixels\"=$hex" '
          /^\[/ {
            if (insec && !seen) print kv
            insec = (index($0, h1) == 1 || index($0, h2) == 1)
            seen = 0
            print; next
          }
          insec && /^"LogPixels"=/ { print kv; seen = 1; next }
          { print }
          END { if (insec && !seen) print kv }
        ' "$user_reg" > "$user_reg.hm-tmp"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$user_reg.hm-tmp" "$user_reg"
        ${pkgs.coreutils}/bin/rm -f "$user_reg.hm-tmp"
      fi
    fi
  '';

  # Expose the raw-crop fields in the "raw black/white point" module. The
  # sensor holds more pixels than the official camera output (EOS RP:
  # 6264x4180 active area vs 6240x4160 JPEG); with this set the crop is
  # editable per image. The matching "EOS RP camera JPEG crop" auto-preset
  # (crop module, 6240x4160) lives in data.db, not here — data.db is synced
  # user data. Only run while darktable is closed: it rewrites darktablerc
  # from memory on exit, undoing external edits.
  home.activation.setDarktableRawCropEditing = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_file="${config.home.homeDirectory}/.config/darktable/darktablerc"
    # NB: the nix wrapper names the process ".darktable-wrap", match the
    # command line instead of the process name
    if [ -f "$config_file" ] && ! ${pkgs.procps}/bin/pgrep -f 'bin/darktable$' >/dev/null; then
      if ${pkgs.gnugrep}/bin/grep -q '^plugins/darkroom/rawprepare/allow_editing_crop=' "$config_file"; then
        ${pkgs.gnused}/bin/sed -i \
          's|^plugins/darkroom/rawprepare/allow_editing_crop=.*|plugins/darkroom/rawprepare/allow_editing_crop=true|' \
          "$config_file"
      else
        printf '\nplugins/darkroom/rawprepare/allow_editing_crop=true\n' >> "$config_file"
      fi
    fi
  '';

  # darktable performance: use the GPU, and stop tiling the pixelpipe.
  #
  # Neither setting changes the rendered result — same kernels, same maths — they
  # only decide *where* and *in how many pieces* the pipeline runs:
  #
  #   opencl           darktable ships its own ICD loader but finds zero
  #                    platforms unless a vendor ICD is installed, and then
  #                    silently runs everything on the CPU. rusticl (this
  #                    laptop's iGPU) is additionally gated behind its own
  #                    clplatform_ key because darktable disables it by default.
  #   resourcelevel    "large" raises the share of RAM darktable may use
  #                    (700/16/128/900 vs default 512/8/128/700). More memory
  #                    means fewer tiles, and upstream measures tiling as up to
  #                    10x slower. Safe here because this file is only imported
  #                    by the default profile (thinkpad-e14, bbstation) —
  #                    bbtablet takes everyday.nix and keeps darktable's default.
  #
  # opencl is only switched on if darktable's own darktable-cltest reports the
  # device as usable on this machine, so a host without a working runtime keeps
  # its CPU pipeline instead of failing at every darkroom interaction. Guarded
  # on darktable being closed: it rewrites darktablerc from memory on exit.
  home.activation.setDarktablePerformance = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_file="${config.home.homeDirectory}/.config/darktable/darktablerc"

    set_key() {
      if ${pkgs.gnugrep}/bin/grep -q "^$1=" "$config_file"; then
        ${pkgs.gnused}/bin/sed -i "s|^$1=.*|$1=$2|" "$config_file"
      else
        printf '%s=%s\n' "$1" "$2" >> "$config_file"
      fi
    }

    if [ -f "$config_file" ] && ! ${pkgs.procps}/bin/pgrep -f 'bin/darktable$' >/dev/null; then
      # OpenCL disabled 2026-09-05: rusticl on this AMD iGPU hard-resets the
      # GPU mid-render ("amdgpu: context lost", SIGABRT in darktable:cs0) —
      # confirmed with a gdb backtrace while opening a duplicate in darkroom.
      # The old cltest probe passed and still crashed in real use, so force
      # it off rather than probing.
      set_key opencl FALSE
      set_key resourcelevel large
      # Rafael's chosen darkroom defaults (2026-09): the AgX workflow is what
      # the native-DCP validation and all the RP styles assume as tone mapper.
      set_key 'plugins/darkroom/workflow' 'scene-referred (AgX)'
    fi
  '';

  # DT-Pro-orange theme. The pack is linked read-only into darktable's user
  # theme directory (darktable only ever reads from there; its own built-in
  # themes live in the package's share/ tree, so nothing is shadowed), and the
  # selection itself is a darktablerc key. The value is the CSS filename without
  # its extension. Same closed-darktable guard as the settings above.
  xdg.configFile."darktable/themes".source = dt-pro-themes;

  home.activation.setDarktableTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_file="${config.home.homeDirectory}/.config/darktable/darktablerc"
    if [ -f "$config_file" ] && ! ${pkgs.procps}/bin/pgrep -f 'bin/darktable$' >/dev/null; then
      if ${pkgs.gnugrep}/bin/grep -q '^ui_last/theme=' "$config_file"; then
        ${pkgs.gnused}/bin/sed -i 's|^ui_last/theme=.*|ui_last/theme=DT-Pro-orange|' "$config_file"
      else
        printf 'ui_last/theme=%s\n' "DT-Pro-orange" >> "$config_file"
      fi
    fi
  '';

  # digiKam metadata settings for darktable interoperability. digiKam does the
  # local AI auto-tagging and must write those tags into the XMP *sidecar* that
  # darktable already owns — never into the RAW — using the tag namespaces
  # darktable reads. digiKam 9.x already writes both Xmp.dc.subject and
  # Xmp.lr.hierarchicalSubject by default (the two darktable imports), so we only
  # overlay the handful of keys that differ from digiKam's defaults, via
  # kwriteconfig6 so digiKam's own state in digikamrc (collections, DB paths, UI)
  # is preserved. Guarded on digiKam being closed: it rewrites digikamrc from
  # memory on exit, which would undo an external edit.
  #
  #   Save Tags=true                  default is FALSE — digiKam writes no tags
  #                                   to metadata at all until this is enabled.
  #                                   This alone already covers face *names*:
  #                                   People/<Name> are ordinary tags in the tag
  #                                   tree, so they land in Xmp.dc.subject and
  #                                   Xmp.lr.hierarchicalSubject (as
  #                                   "People|<Name>"), the two keys darktable
  #                                   imports (src/common/exif.cc, FIND_XMP_TAG).
  #   Save FaceTags=true              NOTE: no space in the key name, unlike the
  #                                   others. Writes the face *rectangles* to
  #                                   Xmp.mwg-rs.Regions; default is FALSE. Not
  #                                   needed for tags (see above) — darktable
  #                                   never imports regions as tags. Its only
  #                                   mwg-rs code is _transform_face_tags(),
  #                                   called on *export* to re-map the boxes
  #                                   through the pixelpipe so they stay aligned
  #                                   after crop/rotate. So this keeps face boxes
  #                                   correct in exported files for other
  #                                   face-aware tools (incl. re-import here).
  #   Metadata Writing Mode=1         WRITE_TO_SIDECAR_ONLY: only ever touches
  #                                   IMG.CR3.xmp, never the original image file.
  #   Use XMP Sidecar For Reading     read the same sidecars back in digiKam.
  #   Use Lazy Synchronization=false  write tags to the sidecar immediately, so
  #                                   the flush is predictable and the "Write
  #                                   Metadata" action is never greyed by a queue.
  #
  # The reverse direction (sidecar -> darktable library.db) is the
  # darktable-xmp-sync service below, run on demand with the `dt-sync` alias.
  home.activation.setDigikamMetadata = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_file="${config.home.homeDirectory}/.config/digikamrc"
    kwriteconfig="${pkgs.kdePackages.kconfig}/bin/kwriteconfig6"
    # digiKam is a nix-wrapped binary (comm is ".digikam-wrappe"), so `pgrep -x
    # digikam` never matches a running instance — match the cmdline instead, or
    # we'd rewrite digikamrc while it's open and it would clobber these keys
    # again on exit.
    if ! ${pkgs.procps}/bin/pgrep -f digikam >/dev/null; then
      set_meta_key() {
        "$kwriteconfig" --file "$config_file" --group "Metadata Settings" --key "$1" "$2"
      }
      set_meta_key "Save Tags"                   "true"
      set_meta_key "Save FaceTags"               "true"
      # Ratings (0-5 stars) go to Xmp.xmp.Rating — the key darktable reads. Off
      # by default, which is why AI *tags* synced to darktable but *ratings*
      # never did: they stayed in digiKam's DB and were never written to the
      # sidecar. Pick/Color labels likewise (Xmp.digiKam.PickLabel /
      # Xmp.xmp.Label) so the quality-sort flags also persist in the XMP.
      set_meta_key "Save Rating"                 "true"
      set_meta_key "Save Pick Label"             "true"
      set_meta_key "Save Color Label"            "true"
      set_meta_key "Metadata Writing Mode"       "1"
      set_meta_key "Use XMP Sidecar For Reading" "true"
      set_meta_key "Use Lazy Synchronization"    "false"

      # Keep the digiKam databases on the NVMe SSD (~/.local/share/digikam),
      # NOT on the HDD alongside the 41k RAW files. With both on the spinning
      # disk, SQLite writes (especially the ~1.2 GB thumbnails DB) thrash the
      # drive head against the photo reads, dragging scans out for hours.
      # Only repoint where the photo library actually lives (i.e. bbstation);
      # the DB files themselves were copied over once by hand.
      if [ -d /hdd/raw_photos ]; then
        db_dir="${config.home.homeDirectory}/.local/share/digikam/"
        for key in "Database Name" "Database Name Face" \
                   "Database Name Similarity" "Database Name Thumbnails"; do
          "$kwriteconfig" --file "$config_file" --group "Database Settings" --key "$key" "$db_dir"
        done
      fi
    fi
  '';

  # Point Parabolic (the yt-dlp GUI) at ~/Music/inbox — the staging folder beets
  # imports from (keeping downloads separate from the organized library so beets
  # never re-scans its own output; see programs/music/beets.nix).
  # Parabolic (.NET/Nickvision) remembers the last-used save folder in
  # ~/.config/<AppName>/config.json under the "PreviousSaveFolder" key (default
  # is ~/Downloads). The config dir name isn't stable across versions, so we find
  # an existing Parabolic config by that telltale key and patch it; if none
  # exists yet we create one at the conventional path (a later launch/switch
  # self-corrects if the name differs). Guarded on Parabolic being closed, since
  # it rewrites its config from memory on exit.
  home.activation.setParabolicSaveFolder = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.procps}/bin/pgrep -f 'nickvision.tubeconverter' >/dev/null; then
      music="${config.home.homeDirectory}/Music/inbox"
      cfg=""
      for c in "${config.home.homeDirectory}/.config"/*/config.json; do
        [ -f "$c" ] || continue
        if ${pkgs.gnugrep}/bin/grep -q PreviousSaveFolder "$c" 2>/dev/null; then cfg="$c"; break; fi
      done
      [ -n "$cfg" ] || cfg="${config.home.homeDirectory}/.config/Nickvision Parabolic/config.json"
      mkdir -p "$(dirname "$cfg")"
      if [ -f "$cfg" ]; then
        tmp="$(mktemp)"
        ${pkgs.jq}/bin/jq --arg f "$music" '.PreviousSaveFolder = $f' "$cfg" > "$tmp" && mv "$tmp" "$cfg"
      else
        printf '{"PreviousSaveFolder":"%s"}\n' "$music" > "$cfg"
      fi
    fi
  '';

  # Every 4 hours, reconcile updated XMP sidecars (edited on another machine and
  # synced in) into darktable's library database, headless — replacing the slow
  # interactive startup crawler (disabled just below). If darktable is open the
  # library lock is held: `darktable --sync-xmp` then aborts cleanly with exit 75
  # (EX_TEMPFAIL) and no GUI, which we mark as success so the timer isn't flagged
  # as failed. The next tick catches everything, so a skipped run is harmless.
  systemd.user.services.darktable-xmp-sync = {
    Unit.Description =
      "Reconcile updated darktable XMP sidecars into the library database";
    Service = {
      Type = "oneshot";
      # -d control makes the crawler log one line per synced image
      # ("[crawler] synced XMP -> DB for `<file>'"), which the `dt-sync` script
      # turns into a live per-file progress bar.
      ExecStart = "${darktable-xmp-sync}/bin/darktable -d control --sync-xmp";
      # 0 = synced; 75 = library locked (darktable open) — both are fine.
      SuccessExitStatus = "0 75";
    };
  };

  systemd.user.timers.darktable-xmp-sync = {
    Unit.Description = "Periodic darktable XMP -> library DB sync (every 4h)";
    Timer = {
      OnBootSec = "15min";
      OnUnitActiveSec = "4h";
    };
    Install.WantedBy = [ "timers.target" ];
  };

}
