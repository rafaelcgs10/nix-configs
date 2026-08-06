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
    pkgs.inkscape
    pkgs.krita
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

  # Film & print data pack for the darktable spektrafilm module. The module
  # reads pack.json + spectra_lut.f32 + profiles/ from this exact path
  # (dt_loc_get_user_config_dir()/spektrafilm), so link the pinned pack in.
  home.file.".config/darktable/spektrafilm".source =
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
