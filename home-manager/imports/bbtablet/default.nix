{ config, pkgs, lib, ... }:

{
  imports = [
    ../../programs/languages/default.nix
    ../../programs/doom/default.nix
    ../../programs/zsh/default.nix
    ../../programs/nvim/default.nix
    # ../../programs/jedit/default.nix
    # ../../programs/rofi/default.nix
    ../../programs/X-themes/default.nix
    # ../../programs/polybar/default.nix
    # ../../programs/gcloud/default.nix
    ../../programs/graphical-apps/default.nix
    ../../programs/non-arm/default.nix
  ];

  home.file.".config/autostart/synology-drive.desktop" = {
    force = true;
    text = ''
      [Desktop Entry]
      Name=Synology Drive Client
      Comment=Synology Drive Client
      Exec=synology-drive start
      Icon=synology-drive
      Terminal=false
      Type=Application
      Categories=Network;FileTransfer;
    '';
  };

  home.file.".local/bin/art-touch" = {
    executable = true;
    force = true;
    text = ''
      #!${pkgs.runtimeShell}
      export GTK_OVERLAY_SCROLLING=0

      # Perf knobs for the Surface Go 1 (2c/4t Kaby Lake, no AVX2, 8 GB RAM).
      # MALLOC_ARENA_MAX=2 keeps glibc from spawning up to 8 per-thread arenas
      # (RAW pipelines allocate large short-lived buffers — fragmentation hurts
      # more than lock contention on a 2-core CPU).
      export MALLOC_ARENA_MAX=2
      # Return freed memory to the kernel sooner so zram/swap pressure stays low.
      export MALLOC_TRIM_THRESHOLD_=131072
      # Faster locale-independent float parsing for ART's many .arp/.pp3 params.
      export LC_NUMERIC=C
      # Passive OMP wait avoids spinning idle threads on this thermally-limited
      # dual-core: idle worker threads sleep instead of burning a HT sibling.
      export OMP_WAIT_POLICY=PASSIVE
      export OMP_DYNAMIC=FALSE

      exec ART "$@"
    '';
  };

  # ART-only GTK CSS overrides: enlarges scrollbars, slider knobs, buttons and
  # tab targets so the UI is usable with a finger on the 10" Surface Go screen.
  # The theme file is picked up by ART's own theme system (Preferences → Theme
  # dropdown lists any file in ~/.config/ART/themes/ named `<Name>-GTK3-*.css`),
  # so the overrides are scoped to ART and do not leak into the rest of GNOME.
  #
  # The base of the file is the vanilla RawTherapee stylesheet that the stock
  # "Default" theme resolves to — inlined via readFile so the touch theme keeps
  # every layout rule ART needs, and gets regenerated whenever pkgs.art is
  # rebuilt. If art.version diverges from the profile's ART, the CSS still
  # applies cleanly (theme files are just supplementary style).
  home.file.".config/ART/themes/Touch-GTK3-_19.css".text = ''
    ${builtins.readFile "${pkgs.art}/share/ART/themes/RawTherapee-GTK3-_19-DEPRECATED.css"}

    /* ============ Touch overrides for Surface Go tablet ============
       ART loads _ART.css unconditionally at startup, and _ART.css uses
       higher-specificity selectors (e.g. `scrollbar:not(.overlay-indicator).vertical
       slider`) with em-based sizes. To actually override we must:
         (a) match those exact selectors — the plain `scrollbar slider` loses
             to `scrollbar.vertical slider` on CSS specificity;
         (b) use `!important` to defeat later-loaded rules;
         (c) proportionally bump em sizes so the coupled padding/margin math in
             _ART.css doesn't produce misaligned artifacts.
       The FontSize bump in the options sed already scales all em-based
       measurements up by 40%; the rules below add absolute-px minimums so the
       result is finger-friendly regardless of FontSize.
    */

    /* --- Scrollbar container: reserve more width/height for the slider.
           _ART.css puts min-width: 1px on the container as a "stuck workaround",
           so we have to force the container thickness explicitly. --- */
    scrollbar.vertical,
    scrollbar.vertical:hover,
    scrollbar:not(.overlay-indicator).vertical {
        min-width: 72px !important;
    }
    scrollbar.horizontal,
    scrollbar.horizontal:hover,
    scrollbar:not(.overlay-indicator).horizontal {
        min-height: 72px !important;
    }

    /* --- Scrollbars: hovering variant (mouse/finger-over grows the slider). --- */
    scrollbar:not(.overlay-indicator).vertical slider,
    scrollbar.vertical.hovering slider {
        min-height: 120px !important;
        min-width: 64px !important;
        border-width: 2px !important;
        border-radius: 32px !important;
    }
    scrollbar:not(.overlay-indicator).horizontal slider,
    scrollbar.horizontal.hovering slider {
        min-width: 120px !important;
        min-height: 64px !important;
        border-width: 2px !important;
        border-radius: 32px !important;
    }

    /* --- Scrollbars: overlay-indicator (thin, idle) variant.
           This is what you see most of the time; make it fat enough to notice
           and to tap without hunting. --- */
    scrollbar.vertical.overlay-indicator:not(.hovering) slider {
        min-width: 56px !important;
        min-height: 120px !important;
        border-radius: 28px !important;
        margin: 2px !important;
    }
    scrollbar.horizontal.overlay-indicator:not(.hovering) slider {
        min-height: 56px !important;
        min-width: 120px !important;
        border-radius: 28px !important;
        margin: 2px !important;
    }

    /* --- Defeat the "Scrollbar stuck workaround" in _ART.css that shrinks
           the vertical scrollbar container to 1px on hover. --- */
    scrollbar:not(.overlay-indicator):hover {
        min-width: 72px !important;
        min-height: 72px !important;
    }

    /* --- Adjuster knobs — every ART slider gets a bigger drag handle.
           _ART.css sets padding here; the visible size is 2*padding, and the
           negative margin has to match to keep alignment. --- */
    scale slider {
        min-width: 0 !important;
        min-height: 0 !important;
        padding: 12px !important;
        margin: -12px !important;
        border-radius: 24px !important;
    }
    scale trough {
        min-height: 6px !important;
        min-width: 6px !important;
        margin: 12px !important;
    }

    /* --- Buttons: taller and roomier for finger tapping. --- */
    button {
        min-height: 32px !important;
        padding: 6px 10px !important;
    }

    /* --- Checkboxes and radios. --- */
    checkbutton check,
    radiobutton radio,
    check,
    radio {
        min-width: 20px !important;
        min-height: 20px !important;
    }

    /* --- Combobox dropdowns. --- */
    combobox button,
    combobox arrow {
        min-width: 24px !important;
        min-height: 32px !important;
    }

    /* --- Tool-panel notebook tabs. --- */
    notebook > header > tabs > tab {
        padding: 8px 12px !important;
        min-height: 32px !important;
    }

    /* --- Tree/list rows (file browser & history). --- */
    treeview.view row {
        min-height: 32px !important;
    }
  '';

  home.file.".local/share/applications/art-touch.desktop" = {
    force = true;
    text = ''
      [Desktop Entry]
      Name=ART Touch
      Comment=ART raw image processor with always-visible scrollbars
      Exec=/home/rafael/.local/bin/art-touch %F
      Icon=ART
      Terminal=false
      Type=Application
      Categories=Graphics;Photography;
      MimeType=image/x-dcraw;image/tiff;image/jpeg;image/png;
    '';
  };

  # Keep only the ART knobs that matter for this low-power CPU-only tablet under
  # management. The rest of ~/.config/ART/options is intentionally left mutable
  # because ART stores recent folders, geometry, and other UI state there.
  home.activation.tuneArtForBbtablet = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    art_options="$HOME/.config/ART/options"
    if [ -f "$art_options" ]; then
      $DRY_RUN_CMD ${pkgs.gnused}/bin/sed -i \
        -e 's/^AdjusterMinDelay=.*/AdjusterMinDelay=200/' \
        -e 's/^AdjusterMaxDelay=.*/AdjusterMaxDelay=500/' \
        -e 's/^PreviewDemosaicFromSidecar=.*/PreviewDemosaicFromSidecar=0/' \
        -e 's/^DenoiseZoomedOut=.*/DenoiseZoomedOut=false/' \
        -e 's/^HideTPVScrollbar=.*/HideTPVScrollbar=false/' \
        -e 's/^HistogramScopeType=.*/HistogramScopeType=0/' \
        -e 's/^MaxInspectorBuffers=.*/MaxInspectorBuffers=1/' \
        -e 's/^RAWImageIOCacheSize=.*/RAWImageIOCacheSize=4/' \
        -e 's/^ClutCacheSize=.*/ClutCacheSize=2/' \
        -e 's/^PreviewResamplingQuality=.*/PreviewResamplingQuality=0/' \
        -e 's/^WBPreviewMode=.*/WBPreviewMode=0/' \
        -e 's/^CTLScriptsFastPreview=.*/CTLScriptsFastPreview=true/' \
        -e 's/^ThumbLazyCaching=.*/ThumbLazyCaching=true/' \
        -e 's/^ThumbnailInterpolation=.*/ThumbnailInterpolation=0/' \
        -e 's/^MaxPreviewHeight=.*/MaxPreviewHeight=200/' \
        -e 's/^MaxPreviewWidth=.*/MaxPreviewWidth=600/' \
        -e 's/^Theme=.*/Theme=Touch/' \
        -e 's/^FontSize=.*/FontSize=10/' \
        -e 's/^CPFontSize=.*/CPFontSize=8/' \
        "$art_options"
    fi
  '';
}
