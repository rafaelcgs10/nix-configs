{ pkgs, ... }:

let
  # Fuzzy-searchable clipboard history popup: pick an entry and it becomes the
  # current clipboard content. Bound to Super+V via the COSMIC shortcut below.
  clipboard-picker = pkgs.writeShellScriptBin "clipboard-picker" ''
    ${pkgs.cliphist}/bin/cliphist list \
      | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "clipboard> " --width 50 --lines 8 \
      | ${pkgs.cliphist}/bin/cliphist decode \
      | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  # Pick an entry and it is deleted from the history (e.g. a copied password).
  clipboard-forget = pkgs.writeShellScriptBin "clipboard-forget" ''
    ${pkgs.cliphist}/bin/cliphist list \
      | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "forget> " --width 50 --lines 8 \
      | ${pkgs.cliphist}/bin/cliphist delete
  '';
in
{
  home.packages = [ pkgs.cliphist clipboard-picker clipboard-forget ];

  # cliphist watches the clipboard through the Wayland data-control protocol,
  # which cosmic-comp only exposes when COSMIC_DATA_CONTROL_ENABLED=1 (set in
  # the host hardware-configuration.nix). CopyQ cannot fill this role on
  # COSMIC: it has no data-control support, and cosmic-comp does not mirror
  # the clipboard into XWayland for unfocused windows, so a background CopyQ
  # never sees new copies.
  services.cliphist = {
    enable = true;
    allowImages = true;
    # cliphist has no unlimited mode (-max-items 0 would wipe the history on
    # the next copy), so use a practically-unlimited cap.
    extraOptions = [
      "-max-dedupe-search" "100"
      "-max-items" "1000000"
    ];
  };

  # COSMIC custom shortcuts: Super+V opens the clipboard history picker,
  # Super+Shift+V opens the forget picker (deletes the chosen entry). COSMIC
  # Settings writes this same file when editing custom shortcuts in the GUI;
  # keep new custom shortcuts here instead, or the read-only symlink will
  # block the GUI editor.
  xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".text = ''
    {
        (
            modifiers: [
                Super,
            ],
            key: "v",
        ): Spawn("${clipboard-picker}/bin/clipboard-picker"),
        (
            modifiers: [
                Super,
                Shift,
            ],
            key: "v",
        ): Spawn("${clipboard-forget}/bin/clipboard-forget"),
    }
  '';
}
