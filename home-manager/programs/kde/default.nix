{ config, pkgs, pkgsUnstable, lib, osConfig ? null, ... }:

# KDE Plasma desktop settings for the default profile (thinkpad, bbstation),
# through plasma-manager. Only the keys declared here are written, at every
# home-manager activation; everything else stays Plasma's: monitor layout,
# scaling and refresh rate (KScreen, ~/.local/share/kscreen, remembered per
# set of connected screens), screen brightness, and anything changed in System
# Settings that is not declared below. A declared key changed in the GUI is
# put back at the next switch. (overrideConfig, which regenerates every KDE
# config file, is deliberately off.)
let
  hostName = if osConfig == null then "" else osConfig.networking.hostName or "";

  # Catppuccin's official KDE theme: global themes (look-and-feel packages)
  # and colour schemes for Latte (day) and Mocha (night), Mauve accent. From
  # unstable, matching Plasma (see plasmaUnstableModule in flake.nix).
  catppuccinKde = pkgsUnstable.catppuccin-kde.override {
    flavour = [ "latte" "mocha" ];
    accents = [ "mauve" ];
  };
  lightTheme = "Catppuccin-Latte-Mauve";
  darkTheme = "Catppuccin-Mocha-Mauve";

  kdotool = "${pkgs.kdotool}/bin/kdotool";

  # --- Theme toggle (Meta+Alt+T) ---------------------------------------------

  # Flip between Latte and Mocha by hand. --keep-auto leaves the automatic
  # day/night switching on, so (as on COSMIC) a manual flip lasts until the
  # next sunrise/sunset.
  theme-toggle = pkgs.writeShellScriptBin "theme-toggle" ''
    current=$(${pkgs.kdePackages.kconfig}/bin/kreadconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage)
    if [ "$current" = "${darkTheme}" ]; then next=${lightTheme}; else next=${darkTheme}; fi
    exec ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-lookandfeel --keep-auto -a "$next"
  '';

  # --- Scratchpad windows (Meta+Shift+<key>) ---------------------------------

  # Toggle a scratchpad window (chats, the notes Emacs): launch it if it is not
  # running, minimize it if it is focused, otherwise bring it up and focus it.
  # The window rules below put these windows on all desktops, so they always
  # come back on the current one. kdotool drives KWin over its scripting API
  # (xdotool's commands, for Wayland). Matched by window class, or by caption
  # for the notes Emacs (every Emacs frame shares the class).
  mkToggle = w: pkgs.writeShellScriptBin "toggle-${w.name}" ''
    win=$(${kdotool} search ${if (w.field or "class") == "title" then "--name" else "--class"} '${w.pattern}' 2>/dev/null | head -n1)
    if [ -z "$win" ]; then
      exec ${pkgs.util-linux}/bin/setsid -f ${w.launch}
    fi
    if [ "$(${kdotool} getactivewindow 2>/dev/null)" = "$win" ]; then
      ${kdotool} windowminimize "$win"
    else
      ${kdotool} windowactivate "$win"
    fi
  '';

  chats = [
    { name = "telegram"; key = "T"; pattern = "telegram"; launch = "Telegram"; }
    { name = "signal";   key = "S"; pattern = "signal";   launch = "signal-desktop"; }
    { name = "zulip";    key = "Z"; pattern = "zulip";    launch = "zulip"; }
    { name = "element";  key = "E"; pattern = "element";  launch = "element-desktop"; }
    { name = "discord";  key = "D"; pattern = "discord";  launch = "discord"; }
    { name = "caprine";  key = "C"; pattern = "caprine";  launch = "caprine"; }
  ];

  # Floating "Notes & Grammar" Emacs (Meta+Shift+G): a second Emacs daemon
  # named "grammar", started on first use by `emacsclient -a ""`, independent
  # of the main daemon's clients. Its frame title is set in the Grammar section
  # of doom config.el. The launcher creates the note file first: visiting a
  # non-existent file whose buffer Doom's file template already modified makes
  # a later `emacsclient -c <file>` stop the daemon at "File no longer exists,
  # write buffer to file? (y or n)" until answered.
  grammarWindow = {
    name = "grammar";
    key = "G";
    field = "title";
    pattern = "^Notes & Grammar";
    launch = "${pkgs.writeShellScriptBin "notes-emacs" ''
      note=/home/rafael/Documents/notes/scratch.org
      [ -e "$note" ] || printf '#+title: Scratch\n\n' > "$note"
      exec emacsclient -s grammar -a "" -c "$note"
    ''}/bin/notes-emacs";
  };

  scratchpads = map (w: w // { toggle = mkToggle w; }) (chats ++ [ grammarWindow ]);
in
{
  programs.plasma = {
    enable = true;

    # Day/night: Plasma switches between the two global themes on its own
    # (sunrise/sunset from Night Light's location schedule), applied once the
    # session is idle for a few seconds. Set as plain kdeglobals keys rather
    # than workspace.lookAndFeel: that option runs plasma-apply-lookandfeel
    # at every activation, which turns the automatic switching off.
    configFile.kdeglobals.KDE = {
      AutomaticLookAndFeel = true;
      DefaultLightLookAndFeel = lightTheme;
      DefaultDarkLookAndFeel = darkTheme;
    };

    # Inter for the interface (installed system-wide by nixos/font-rendering.nix),
    # the terminal's Nerd Font for monospace.
    fonts = {
      general = { family = "Inter"; pointSize = 10; };
      menu = { family = "Inter"; pointSize = 10; };
      toolbar = { family = "Inter"; pointSize = 10; };
      small = { family = "Inter"; pointSize = 8; };
      windowTitle = { family = "Inter"; pointSize = 10; };
      fixedWidth = { family = "Hack Nerd Font Mono"; pointSize = 10; };
    };

    # Clipboard history: Plasma's Klipper replaces cliphist + fuzzel; its
    # history popup is Meta+V (Plasma's default), entries can be deleted from
    # it, and images are kept. 2048 is Klipper's maximum.
    configFile.klipperrc.General = {
      MaxClipItems = 2048;
      KeepClipboardContents = true;
      IgnoreImages = false;
    };

    # Shortcuts carried over from COSMIC:
    # - Meta+T Konsole, Meta+F Dolphin: launch shortcuts on the apps' desktop
    #   entries (how System Settings stores application shortcuts). KWin's
    #   tile editor had Meta+T; it is left without a key.
    # - Meta+Q close (besides Alt+F4 and Meta+Shift+Q; Meta+Q was the activity
    #   switcher), Meta+M maximize (besides Meta+PgUp), Meta+Escape lock
    #   (besides Meta+L and Meta+O).
    # - Meta+1..9, 0: go to desktop N (instead of the Nth task-manager entry).
    #   Meta+Shift+N, moving the window there, is declared for the thinkpad
    #   below: KDE stores it as the shifted symbol, which depends on the
    #   keyboard layout.
    shortcuts = {
      "services/org.kde.konsole.desktop"._launch = "Meta+T";
      "services/org.kde.dolphin.desktop"._launch = "Meta+F";
      kwin = {
        "Edit Tiles" = [ ];
        "Window Close" = [ "Alt+F4" "Meta+Shift+Q" "Meta+Q" ];
        "Window Maximize" = [ "Meta+PgUp" "Meta+M" ];
      }
      // lib.listToAttrs (lib.imap1 (n: key: lib.nameValuePair "Switch to Desktop ${toString n}" "Meta+${key}")
        [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" ])
      // lib.optionalAttrs (hostName == "thinkpad")
        (lib.listToAttrs (lib.imap1 (n: sym: lib.nameValuePair "Window to Desktop ${toString n}" "Meta+${sym}")
          # Brazilian ABNT (thinkpad): Shift+1..0
          [ "!" "@" "#" "$" "%" "¨" "&" "*" "(" ")" ]));
      ksmserver."Lock Session" = [ "Screensaver" "Meta+O" "Meta+L" "Meta+Escape" ];
      plasmashell = {
        "manage activities" = [ ];
      }
      // lib.listToAttrs (map (n: lib.nameValuePair "activate task manager entry ${toString n}" [ ])
        (lib.range 1 10));
    };

    # Ten virtual desktops in two rows, as already set in System Settings.
    kwin.virtualDesktops = {
      number = 10;
      rows = 2;
    };

    hotkeys.commands = {
      theme-toggle = {
        name = "Toggle Catppuccin Latte/Mocha";
        key = "Meta+Alt+T";
        command = "${theme-toggle}/bin/theme-toggle";
      };
    } // lib.listToAttrs (map (w: lib.nameValuePair "toggle-${w.name}" {
      name = "Toggle ${w.name}";
      key = "Meta+Shift+${w.key}";
      command = "${w.toggle}/bin/toggle-${w.name}";
    }) scratchpads);

    # The panel, as on COSMIC: one thin bar on top of every screen. Left:
    # launcher, workspaces and the open windows; centre: clock; right: the
    # system monitors, then the system tray (audio, network, Bluetooth,
    # battery, notifications, keyboard layout). Plasma redraws the panels from
    # this whenever it changes; edits made in panel edit mode are replaced at
    # the next switch. COSMIC's container-manager applet has no Plasma
    # equivalent and is left out.
    panels = [
      {
        location = "top";
        height = 32;
        floating = false;
        screen = "all";
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.panelspacer"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.panelspacer"
          # CPU and memory as rings (COSMIC's minimon), colours from
          # Catppuccin (mauve, blue).
          {
            systemMonitor = {
              title = "CPU";
              displayStyle = "org.kde.ksysguard.piechart";
              sensors = [ { name = "cpu/all/usage"; color = "203,166,247"; label = "CPU"; } ];
              totalSensors = [ "cpu/all/usage" ];
            };
          }
          {
            systemMonitor = {
              title = "Memory";
              displayStyle = "org.kde.ksysguard.piechart";
              sensors = [ { name = "memory/physical/usedPercent"; color = "137,180,250"; label = "Memory"; } ];
              totalSensors = [ "memory/physical/usedPercent" ];
            };
          }
          # Free disk space over all local disks, as text.
          {
            systemMonitor = {
              title = "Disk free";
              displayStyle = "org.kde.ksysguard.textonly";
              sensors = [ { name = "disk/all/free"; color = "250,179,135"; label = "Disk free"; } ];
            };
          }
          # Download and upload over all interfaces, as line charts (green,
          # peach).
          {
            systemMonitor = {
              title = "Network";
              displayStyle = "org.kde.ksysguard.linechart";
              sensors = [
                { name = "network/all/download"; color = "166,227,161"; label = "Down"; }
                { name = "network/all/upload"; color = "250,179,135"; label = "Up"; }
              ];
            };
          }
          "org.kde.plasma.systemtray"
        ];
      }
    ];

    # Scratchpad windows live on every virtual desktop (KWin: an empty desktop
    # list with a Force rule means all desktops).
    window-rules = map (w: {
      description = "Scratchpad: ${w.name}";
      match = if (w.field or "class") == "title" then {
        window-class = { value = "emacs"; type = "exact"; };
        title = { value = w.pattern; type = "regex"; };
      } else {
        window-class = { value = w.pattern; type = "substring"; };
      };
      apply.desktops = { value = ""; apply = "force"; };
    }) scratchpads;
  }
  # The thinkpad's keyboard and touchpad, as they were set in COSMIC: Brazilian
  # ThinkPad layout, and the Elantech PS/2 touchpad with flat acceleration
  # (smoother on its ~100 Hz reports), two-finger scrolling, tap and drag.
  # bbstation's input stays whatever System Settings holds.
  // lib.optionalAttrs (hostName == "thinkpad") {
    input.keyboard = {
      model = "pc104";
      layouts = [ { layout = "br"; variant = "thinkpad"; } ];
      options = [ "terminate:ctrl_alt_bksp" ];
      repeatDelay = 600;
      repeatRate = 25;
    };
    input.touchpads = [
      {
        name = "ETPS/2 Elantech Touchpad";
        vendorId = "0002";
        productId = "000e";
        accelerationProfile = "none";
        pointerSpeed = 0;
        naturalScroll = false;
        scrollMethod = "twoFingers";
        tapToClick = true;
        tapAndDrag = true;
        tapDragLock = false;
        rightClickMethod = "twoFingers";
      }
    ];
  };

  # Konsole, KDE's terminal (Plasma's default, so Dolphin's "Open terminal"
  # and the like use it). Catppuccin Mocha, the official scheme from
  # catppuccin/konsole. Konsole can't follow Plasma's light/dark switch
  # (a long-open KDE wish), so it stays Mocha by day; zsh's colours use the
  # terminal palette and follow it.
  programs.konsole = {
    enable = true;
    defaultProfile = "Catppuccin";
    profiles.Catppuccin = {
      colorScheme = "Catppuccin-Mocha";
      font = { name = "Hack Nerd Font Mono"; size = 11; };
    };
  };
  # The scheme file itself (Konsole reads schemes from ~/.local/share/konsole).
  # plasma-manager's customColorSchemes only takes a file in this repo or an
  # INI attrset, so the fetched upstream file is installed directly.
  xdg.dataFile."konsole/Catppuccin-Mocha.colorscheme".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/konsole/a4e18c1c8bba6c283ed3b539100050c3d9a80bee/themes/catppuccin-mocha.colorscheme";
    hash = "sha256-uHuVaYipMcR1qnR2nedrlXUNVlUQ2Ok5jGnq80sEvj8=";
  };

  home.packages = [ catppuccinKde theme-toggle pkgs.kdotool ]
    ++ map (w: w.toggle) scratchpads;

  # Plasma themes Qt and GTK itself, and kde-gtk-config syncs the Catppuccin
  # colour scheme into GTK apps, so they follow the day/night switch too.
  # Stylix's KDE, Qt and GTK targets (one fixed scheme, and Qt through qtct,
  # which makes KDE apps ignore Plasma's colours) and home-manager's GTK/Qt
  # settings files (read-only symlinks kde-gtk-config could not update) are
  # turned off on these hosts; bbtablet's GNOME keeps them.
  stylix.targets.kde.enable = false;
  stylix.targets.qt.enable = false;
  stylix.targets.gtk.enable = false;
  qt.enable = lib.mkForce false;
  gtk.enable = lib.mkForce false;

  # Match GTK apps to the interface font where Stylix still sets fonts.
  stylix.fonts.sansSerif = {
    package = pkgs.inter;
    name = "Inter";
  };

  # Default applications: KDE's own (installed by the plasma6 module) for
  # photos, PDFs, archives, folders and music; Emacs (through the daemon) for
  # text, VLC for video, LibreWolf for the web. RAW files are left out, so the
  # photo editors keep handling them. Plasma's "Default Applications" settings
  # read this same mimeapps.list.
  xdg.mimeApps.defaultApplications =
    let
      for = app: types: lib.genAttrs types (_: [ app ]);
    in
    for "org.kde.gwenview.desktop" [
      "image/jpeg" "image/png" "image/gif" "image/webp" "image/bmp"
      "image/tiff" "image/svg+xml" "image/heic" "image/heif" "image/avif"
      "image/jxl" "image/x-icon"
    ]
    // for "emacsclient.desktop" [
      "text/plain" "text/markdown" "text/x-markdown" "text/x-org" "text/csv"
      "text/x-log" "text/x-python" "text/x-csrc" "text/x-chdr" "text/x-c++src"
      "text/x-c++hdr" "text/x-java" "text/x-tex" "text/x-shellscript"
      "application/x-shellscript" "application/json" "application/xml"
      "application/toml" "application/x-yaml" "text/x-nix"
    ]
    // for "vlc.desktop" [
      "video/mp4" "video/x-matroska" "video/webm" "video/quicktime"
      "video/x-msvideo" "video/mpeg" "video/ogg" "video/x-flv" "video/3gpp"
      "video/x-ms-wmv" "video/mp2t"
    ]
    // for "okularApplication_pdf.desktop" [ "application/pdf" ]
    // for "org.kde.ark.desktop" [
      "application/zip" "application/x-tar" "application/gzip"
      "application/x-compressed-tar" "application/x-bzip2-compressed-tar"
      "application/x-xz-compressed-tar" "application/zstd"
      "application/x-zstd-compressed-tar" "application/x-7z-compressed"
      "application/vnd.rar" "application/x-rar"
    ]
    // for "org.kde.dolphin.desktop" [ "inode/directory" ]
    // for "org.kde.elisa.desktop" [
      "audio/mpeg" "audio/mp4" "audio/aac" "audio/flac" "audio/x-flac"
      "audio/ogg" "audio/x-vorbis+ogg" "audio/opus" "audio/x-opus+ogg"
      "audio/x-m4a" "audio/wav" "audio/x-wav" "audio/webm" "audio/x-ms-wma"
      "application/ogg"
    ]
    // for "librewolf.desktop" [
      "text/html" "application/xhtml+xml" "x-scheme-handler/http"
      "x-scheme-handler/https" "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ];

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
}
