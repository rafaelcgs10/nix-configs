{ config, pkgs, inputs, lib, ... }:

let
  # Rosé Pine theme for COSMIC (rose-pine/cosmic-desktop). Stylix has no COSMIC
  # target, so we apply it declaratively through cosmic-manager: parse the
  # upstream ThemeBuilder .ron with cosmic-manager's own RON parser and feed it
  # to appearance.theme. Using fromRON avoids hand-transcribing the palette and
  # stays faithful to upstream. main = dark (night), dawn = light (day).
  cosmicLib = import "${inputs.cosmic-manager}/lib/extend-lib.nix" { inherit lib; };
  rosePineCosmicDark = cosmicLib.cosmic.ron.fromRON
    (builtins.readFile ./rose-pine-cosmic.ron);
  rosePineCosmicLight = cosmicLib.cosmic.ron.fromRON
    (builtins.readFile ./rose-pine-cosmic-light.ron);

  # Third-party CLI speaking COSMIC's zcosmic_toplevel_manager protocol.
  # cosmic-comp exposes neither wlr-foreign-toplevel nor a first-party window
  # CLI, so this is the only way to script activate/minimize/sticky.
  cos-cli = inputs.cos-cli.defaultPackage.${pkgs.stdenv.hostPlatform.system};

  # Docker/Podman container manager applet for the panel (see the file).
  container-manager-applet = pkgs.callPackage ./container-manager-applet.nix { };
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

  # --- Theme toggle (Super+Alt+T) --------------------------------------------

  # Flip COSMIC between dark (Rosé Pine) and light (Dawn) by rewriting is_dark;
  # cosmic watches the file and applies it live. is_dark is intentionally NOT
  # managed declaratively (see the CosmicTheme.Mode comment below), so it stays
  # writable. Note: with the day/night auto-switch enabled, a manual toggle
  # lasts until the next sunrise/sunset boundary, when auto takes over again.
  cosmic-theme-toggle = pkgs.writeShellScriptBin "cosmic-theme-toggle" ''
    mode_file="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"
    if [ -f "$mode_file" ] && ${pkgs.gnugrep}/bin/grep -q true "$mode_file"; then
      printf 'false' > "$mode_file"
    else
      printf 'true' > "$mode_file"
    fi
  '';

  # --- Scratchpad chats (Super+Shift+<key>) ---------------------------------

  # Toggle a scratchpad window (chats, the notes Emacs): launch it if not
  # running, minimize it if it is focused, otherwise unminimize and focus it.
  # The window is made *sticky* (shown on every workspace), so it always
  # comes back on the workspace you are on. Moving it instead is not an
  # option: cosmic-comp's move_to_workspace maps a window into the tiling
  # layer whenever the target workspace tiles, so it came back tiled
  # (verified with screenshots 2026-10-20); activating a non-sticky window
  # on another workspace switches to that workspace instead.
  # Order matters: set_sticky is a no-op on a minimized window, so unminimize
  # first; activate on a sticky window focuses it without a workspace switch.
  # cos-cli does not report the sticky/minimized state of sticky windows, so
  # the hide/show decision is based on "activated" (focused) only: a visible
  # but unfocused scratchpad gets focused on the first press, hidden on the
  # second.
  mkChatToggle = chat: pkgs.writeShellScriptBin "toggle-${chat.name}" ''
    find_app() {
      ${cos-cli}/bin/cos-cli info --json | ${jq} -c --arg re "${chat.pattern}" \
        '[.apps[] | select(.${chat.field or "app_id"} | test($re; "i"))][0] // empty'
    }
    app=$(find_app)
    if [ -z "$app" ]; then
      ${pkgs.util-linux}/bin/setsid -f ${chat.launch}
      # Wait for the window, then pin it to every workspace.
      for _ in $(seq 1 60); do
        sleep 0.5
        app=$(find_app)
        [ -n "$app" ] && break
      done
      [ -n "$app" ] && ${cos-cli}/bin/cos-cli state -i "$(printf '%s' "$app" | ${jq} .index)" --sticky
      exit 0
    fi
    idx=$(printf '%s' "$app" | ${jq} .index)
    if printf '%s' "$app" | ${jq} -e '.state | index("activated")' > /dev/null; then
      ${cos-cli}/bin/cos-cli state -i "$idx" --minimize
    else
      ${cos-cli}/bin/cos-cli state -i "$idx" --unminimize
      ${cos-cli}/bin/cos-cli state -i "$idx" --sticky   # no-op if already sticky
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

  # Floating "Notes & Grammar" Emacs (Super+Shift+G): a second Emacs daemon
  # named "grammar", started on first use by `emacsclient -a ""`, so it is
  # independent of the main daemon's clients. It opens
  # ~/Documents/notes/scratch.org, a writable note in the notes project.
  # Matched by frame title, since every Emacs frame shares the app_id
  # "emacs"; the title is set for that daemon in the Grammar section of doom
  # config.el. Unlike the chats this is NOT minimized/stickied: a pgtk Emacs
  # frame comes back black after cosmic-comp re-maps it into the sticky layer
  # (verified 2026-10-20; cosmic-term and GTK4 apps render fine). Instead
  # hide = delete the frame(s), show = open a new frame, which always lands
  # floating on the current workspace via the window rule below. Buffers
  # live in the daemon, so nothing is lost. A minimized pgtk frame stops
  # Emacs' event loop entirely (no frame callbacks from the compositor), and
  # a hidden-by-minimize frame would hang the emacsclient below, so the
  # window is unminimized first in case it was minimized by hand.
  grammarWindow = rec {
    name = "grammar";
    key = "g";
    pattern = "^Notes & Grammar";
    note = "/home/rafael/Documents/notes/scratch.org";
    launch = "emacsclient -s grammar -a \"\" -c ${note}";
    toggle = pkgs.writeShellScriptBin "toggle-grammar" ''
      idx=$(${cos-cli}/bin/cos-cli info --json | ${jq} --arg re "${pattern}" \
        '[.apps[] | select(.title | test($re))][0].index // empty')
      if [ -n "$idx" ]; then
        ${cos-cli}/bin/cos-cli state -i "$idx" --unminimize > /dev/null 2>&1
        ${pkgs.coreutils}/bin/timeout 10 emacsclient -s grammar -e \
          '(dolist (f (frame-list)) (when (window-system f) (delete-frame f t)))' > /dev/null
      else
        # The note must exist on disk: visiting a non-existent file whose
        # buffer Doom's file template already modified makes the next
        # `emacsclient -c <file>` stop at "File no longer exists, write
        # buffer to file? (y or n)" and the daemon ignores clients until
        # answered.
        [ -e "${note}" ] || printf '#+title: Scratch\n\n' > "${note}"
        exec ${pkgs.util-linux}/bin/setsid -f ${launch}
      fi
    '';
  };

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
  # Declarative COSMIC config via cosmic-manager. Apply Rosé Pine to the desktop
  # and COSMIC apps: Main (dark) at night, Dawn (light) during the day.
  wayland.desktopManager.cosmic = {
    enable = true;
    appearance.theme = {
      # `mode` is intentionally left unset: setting it would hard-write a
      # static is_dark. Instead we enable COSMIC's native day/night auto
      # switch below, which flips between these two themes at sunrise/sunset.
      # window_hint (border/hint around the active window) is set to Love
      # (#eb6f92) directly in rose-pine-cosmic.ron.
      dark = rosePineCosmicDark;    # Rosé Pine (night)
      light = rosePineCosmicLight;  # Rosé Pine Dawn (day)
    };

    # UI fonts (com.system76.CosmicTk). Inter is designed for screens (the
    # closest FOSS analog to Apple's SF) and is installed system-wide by
    # nixos/font-rendering.nix; pin it explicitly rather than relying on
    # COSMIC's compiled-in default. Monospace matches the terminal font so
    # cosmic-edit/-term agree.
    appearance.toolkit = let
      normal = { __type = "enum"; variant = "Normal"; };
      font = family: {
        inherit family;
        stretch = normal;
        style = normal;
        weight = normal;
      };
    in {
      interface_font = font "Inter";
      monospace_font = font "Hack Nerd Font Mono";
    };

    # Enable COSMIC's "Auto" appearance mode (follows the day/night cycle).
    # cosmic-manager only exposes a static dark/light `mode`, so set
    # `auto_switch` directly on com.system76.CosmicTheme.Mode via its generic
    # configFile escape hatch.
    # Only set auto_switch; leave is_dark for COSMIC to compute from the time
    # of day, so a rebuild doesn't momentarily force one mode.
    configFile."com.system76.CosmicTheme.Mode" = {
      version = 1;
      entries.auto_switch = true;
    };

    # COSMIC Terminal: font + Rosé Pine colour schemes. syntax_theme_dark /
    # _light follow the system dark/light mode, so the terminal tracks the
    # day/night auto switch too (Dawn by day, Main by night). The colour scheme
    # maps are keyed by an integer ColorSchemeId, which a Nix attrset can't
    # express, so build them via fromRON on the upstream scheme files.
    configFile."com.system76.CosmicTerm" = {
      version = 1;
      entries = {
        font_name = "Hack Nerd Font Mono";
        syntax_theme_dark = "Rosé Pine";
        syntax_theme_light = "Rosé Pine Dawn";
        color_schemes_dark = cosmicLib.cosmic.ron.fromRON
          "{0: ${builtins.readFile ./rose-pine-term-main.ron}}";
        color_schemes_light = cosmicLib.cosmic.ron.fromRON
          "{0: ${builtins.readFile ./rose-pine-term-dawn.ron}}";
      };
    };
  };

  home.packages = [ pkgs.cliphist clipboard-picker clipboard-forget cosmic-theme-toggle cos-cli container-manager-applet ]
    ++ map (chat: chat.toggle) chats;

  # Pin the Container Manager applet in the panel's right wing, next to the
  # status area, without taking over the whole applet list: panel layouts
  # differ per host and are otherwise left to Settings > Panel. The RON file
  # is `Some(([left...], [right...]))`; insert the applet id as the first entry
  # of the right list if it is not present anywhere yet. cosmic-panel watches
  # the file and reloads live. Skipped when the panel has never written its
  # config (fresh host): add it once via Settings > Panel > Applets then.
  home.activation.pinContainerManagerApplet = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    wings="$HOME/.config/cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings"
    applet="org.cosmic_utils.CosmicExtAppletContainerManager"
    if [ -f "$wings" ] && ! ${pkgs.gnugrep}/bin/grep -q "$applet" "$wings" \
       && ${pkgs.gnugrep}/bin/grep -q '^\], \[$' "$wings"; then
      $DRY_RUN_CMD ${pkgs.gnused}/bin/sed -i "/^\], \[\$/a\\    \"$applet\"," "$wings"
    fi
  '';

  # Match GTK apps to the COSMIC interface font. Set here (not in home.nix)
  # deliberately: this module is only imported by the COSMIC profile, so
  # bbtablet's GNOME setup keeps Stylix's default sans-serif.
  stylix.fonts.sansSerif = {
    package = pkgs.inter;
    name = "Inter";
  };

  xdg.configFile."autostart/synology-drive.desktop".text = ''
    [Desktop Entry]
    Name=Synology Drive Client
    Comment=Synology Drive Client
    Exec=synology-drive autostart
    Icon=synology-drive
    Terminal=false
    Type=Application
    Categories=Network;FileTransfer;
  '';

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

  # `wl-paste --watch` runs `cliphist store` synchronously per clipboard
  # change and waits for it. If the selection owner never answers the
  # compositor's receive request (seen 2026-10-19 with an Xwayland-proxied
  # source: cosmic-comp kept the pipe open and never wrote), that one store
  # blocks forever and every later copy is silently dropped. Wrap the store
  # in a timeout so a hung receive costs 10 s, not the rest of the session.
  # The text watcher also gets --type text so binary offers (raw BMP was
  # stored as text right before the hang) never reach it.
  systemd.user.services = let
    store = "${pkgs.coreutils}/bin/timeout 10 ${config.services.cliphist.package}/bin/cliphist "
      + "${lib.escapeShellArgs config.services.cliphist.extraOptions} store";
    wlPaste = "${pkgs.wl-clipboard}/bin/wl-paste";
  in {
    cliphist.Service.ExecStart = lib.mkForce "${wlPaste} --type text --watch ${store}";
    cliphist-images.Service.ExecStart = lib.mkForce "${wlPaste} --type image --watch ${store}";
  };

  # The clipboard-picker / clipboard-forget scripts above display cliphist
  # through fuzzel (--dmenu). Enable programs.fuzzel so home-manager writes
  # fuzzel.ini, which Stylix's fuzzel target themes (Rosé Pine); the pickers
  # read that default config since they pass no --config.
  programs.fuzzel.enable = true;

  # Float-by-default rules ("floating window exceptions"). cosmic-comp watches
  # this file and applies changes live. COSMIC Settings writes the same file
  # from its Windows page; keep new exceptions here instead, or the read-only
  # symlink will block the GUI editor.
  xdg.configFile."cosmic/com.system76.CosmicSettings.WindowRules/v1/tiling_exception_custom".text = ''
    [
        ${builtins.concatStringsSep "\n    " (map floatingException floatingAppIds)}
        (appid: "(?i)^emacs$", title: "${grammarWindow.pattern}", enabled: true),
    ]
  '';

  # (COSMIC Terminal font + colour schemes are managed via cosmic-manager in
  # the wayland.desktopManager.cosmic block above.)

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
        (
            modifiers: [
                Super,
                Alt,
            ],
            key: "t",
        ): Spawn("${cosmic-theme-toggle}/bin/cosmic-theme-toggle"),
        ${builtins.concatStringsSep "\n    " (map chatShortcut (chats ++ [ grammarWindow ]))}
    }
  '';
}
