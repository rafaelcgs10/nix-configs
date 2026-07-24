{ config, pkgs, lib, ... }:

{
  imports = [
    # ../../programs/xmonad/default.nix
    # ../../programs/hyprland/default.nix
    ../../programs/languages/default.nix
    # ../../programs/plasma5/default.nix
    ../../programs/doom/default.nix
    ../../programs/zsh/default.nix
    ../../programs/nvim/default.nix
    ../../programs/copyq/default.nix
    # ../../programs/jedit/default.nix
    ../../programs/alacritty/default.nix
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
      exec ART "$@"
    '';
  };

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
        "$art_options"
    fi
  '';
}
