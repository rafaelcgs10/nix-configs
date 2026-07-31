{ pkgs, lib, config, pkgsUnstable, pkgsLmstudio, spektrafilmPackages, ...}:

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
    # module). Replaces the stock pkgsDarktable.darktable; the runtime data pack
    # and AI models are linked in via home.file below.
    spektrafilmPackages.darktable-spektrafilm-ai
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
}
