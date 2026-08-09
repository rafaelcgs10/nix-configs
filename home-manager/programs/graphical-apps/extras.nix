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
      patches = (old.patches or [ ]) ++ [ ./darktable-headless-xmp-sync.patch ];
    });
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
    pkgsUnstable.freetube

    # darktable built from the spektrafilm PR branch (native C spektrafilm
    # module), patched to add the headless `--sync-xmp` mode driven by the
    # systemd timer below. Replaces the stock pkgsDarktable.darktable; the
    # runtime data pack and AI models are linked in via home.file below.
    darktable-xmp-sync
    spektrafilmPackages.spektrafilm
    spektrafilmPackages.spektrafilm-art
    pkgs.vkdt
    pkgs.rapidraw
    pkgs.focus-stack
    pkgs.hugin
    pkgs.exiftool
    pkgs.deluge
  ];

  # Film & print data pack for the darktable spektrafilm module. Newer builds
  # can download this pack from within the UI into
  # ~/.config/darktable/spektrafilm/packs/<lut_hash>/; we pre-install the pinned
  # pack at that same hashed path so it works offline with no download, while
  # leaving spektrafilm/ itself writable so the in-UI downloader still works for
  # other tables. The resolver (src/common/spektra_fetch.c) picks this up for
  # both fresh edits and edits recorded with this LUT hash. The hash comes from
  # the pack derivation so it tracks pack bumps automatically.
  home.file.".config/darktable/spektrafilm/packs/${spektrafilmPackages.spektrafilm-data-pack.lutHash}".source =
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
      ExecStart = "${darktable-xmp-sync}/bin/darktable --sync-xmp";
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
