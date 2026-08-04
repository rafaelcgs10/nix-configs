{ pkgs, inputs, ... }:

let
  # Third-party CLI speaking COSMIC's zcosmic_toplevel_manager protocol.
  # cosmic-comp exposes neither wlr-foreign-toplevel nor a first-party window
  # CLI, so this is the only way to script activate/minimize/sticky.
  cos-cli = inputs.cos-cli.defaultPackage.${pkgs.stdenv.hostPlatform.system};
  jq = "${pkgs.jq}/bin/jq";

  # --- Clipboard history (cliphist) -----------------------------------------

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

  # --- Scratchpad chats (Super+Shift+<key>) ---------------------------------

  # Toggle a chat app like a scratchpad: launch it if not running, minimize it
  # if it is focused, and otherwise bring it to the current workspace and
  # focus it - so the same key shows and hides it from any workspace. The
  # current workspace is inferred from the focused window, since cos-cli does
  # not expose workspace focus. Sticky windows would be an alternative, but
  # cosmic-comp neither minimizes them reliably nor reports their state.
  mkChatToggle = chat: pkgs.writeShellScriptBin "toggle-${chat.name}" ''
    info=$(${cos-cli}/bin/cos-cli info --json)
    app=$(printf '%s' "$info" | ${jq} -c --arg re "${chat.pattern}" \
      '[.apps[] | select(.app_id | test($re; "i"))][0] // empty')
    if [ -z "$app" ]; then
      exec ${pkgs.util-linux}/bin/setsid -f ${chat.launch}
    fi
    idx=$(printf '%s' "$app" | ${jq} .index)
    if printf '%s' "$app" | ${jq} -e '.state | index("activated")' > /dev/null; then
      ${cos-cli}/bin/cos-cli state -i "$idx" --minimize
    else
      cur_ws=$(printf '%s' "$info" | ${jq} -r \
        'first(.apps[] | select(.state | index("activated"))).workspaces[0].index // empty')
      ${cos-cli}/bin/cos-cli state -i "$idx" --unminimize
      if [ -n "$cur_ws" ]; then
        ${cos-cli}/bin/cos-cli move -i "$idx" -w "$cur_ws"
      fi
      ${cos-cli}/bin/cos-cli activate -i "$idx"
    fi
  '';

  chats = map (chat: chat // { toggle = mkChatToggle chat; }) [
    { name = "telegram"; key = "t"; pattern = "telegram"; launch = "Telegram"; }
    { name = "signal";   key = "s"; pattern = "signal";   launch = "signal-desktop"; }
    { name = "zulip";    key = "z"; pattern = "zulip";    launch = "zulip"; }
    { name = "element";  key = "e"; pattern = "element";  launch = "element-desktop"; }
    { name = "discord";  key = "d"; pattern = "discord";  launch = "discord"; }
    { name = "caprine";  key = "c"; pattern = "caprine";  launch = "caprine"; }
  ];

  chatShortcut = chat: ''
    (
        modifiers: [
            Super,
            Shift,
        ],
        key: "${chat.key}",
    ): Spawn("${chat.toggle}/bin/toggle-${chat.name}"),'';

  # Windows that should never tile: the chats above plus small utilities.
  # cosmic-comp matches these as unanchored regexes against the app_id.
  floatingAppIds = map (chat: chat.pattern) chats ++ [
    "kalk"
    "qalculate"
    "dialect"
  ];

  floatingException = appid: ''(appid: "(?i)${appid}", title: "", enabled: true),'';
in
{
  home.packages = [ pkgs.cliphist clipboard-picker clipboard-forget cos-cli ]
    ++ map (chat: chat.toggle) chats;

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

  # Float-by-default rules ("floating window exceptions"). cosmic-comp watches
  # this file and applies changes live. COSMIC Settings writes the same file
  # from its Windows page; keep new exceptions here instead, or the read-only
  # symlink will block the GUI editor.
  xdg.configFile."cosmic/com.system76.CosmicSettings.WindowRules/v1/tiling_exception_custom".text = ''
    [
        ${builtins.concatStringsSep "\n    " (map floatingException floatingAppIds)}
    ]
  '';

  # COSMIC custom shortcuts: Super+V opens the clipboard history picker,
  # Super+Shift+V opens the forget picker (deletes the chosen entry), and
  # Super+Shift+<letter> toggles each scratchpad chat. COSMIC Settings writes
  # this same file when editing custom shortcuts in the GUI; keep new custom
  # shortcuts here instead, or the read-only symlink will block the GUI
  # editor.
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
        ${builtins.concatStringsSep "\n    " (map chatShortcut chats)}
    }
  '';
}
