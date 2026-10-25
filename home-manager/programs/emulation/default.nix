{ config, lib, pkgs, osConfig ? null, ... }:

# Console emulation for the COSMIC hosts (thinkpad, bbstation).
#
# Layout (all under ~/Games; add `saves` - and `bios`/`roms` if wanted - as
# Syncthing folders on each host):
#   roms/<es-de system name>/   you provide the games (ES-DE naming: snes
#                               mastersystem megadrive gb gbc gba n64 nds psx
#                               ps2 psp ps3 gc wii xbox xbox360 switch)
#   bios/                       RetroArch system dir (PS1 scph*.bin ...); bios/ps2
#                               is PCSX2's BIOS folder
#   saves/retroarch             SRAM/memory cards of every RetroArch core
#   saves/pcsx2                 PCSX2 memory cards
#   saves/dolphin/{GC,Wii}      Dolphin GC memory cards and the Wii NAND
#   saves/rpcs3/{savedata,trophy}
#   states/retroarch            save states (local, not synced: large and
#                               core-version specific)
#
# Frontend: ES-DE launches everything from one controller UI. Defaults per
# system (the seeded choice), with the alternatives ES-DE lists under
# Other settings > Alternative emulators (only installed ones are offered):
#   snes mastersystem gb gbc gba psx -> RetroArch cores (bsnes, SMS Plus GX,
#     Gambatte, mGBA, Beetle PSX HW): Retro Crisis CRT shaders +
#     RetroAchievements (log in once in RetroArch: Settings > Achievements).
#     Alternatives: the other cores below, plus the standalone mednafen, ares,
#     SameBoy, mGBA, Snes9x and DuckStation.
#   megadrive n64 nds -> RetroArch cores (BlastEm, Mupen64Plus-Next, melonDS),
#     alternatives ParaLLEl N64, DeSmuME and the standalone blastem, simple64,
#     RMG, melonDS, DeSmuME, ares, mednafen.
#   ps2 gc wii psp -> RetroArch cores too (LRPS2, Dolphin, PPSSPP), so one
#     frontend, one input setup and one shader/achievement config cover them;
#     PCSX2, Dolphin and PPSSPP standalone remain as alternatives. The core
#     data they need is linked under bios/ (pcsx2/bios -> ps2, dolphin-emu/Sys
#     and PPSSPP from the cores' own sources). ps3 -> RPCS3: Sony's firmware (PS3UPDAT.PUP
#     4.93, fetched from Sony) is installed into ~/.config/rpcs3 by the
#     activation step below when missing, so nothing is needed in its menu.
#     Disc dumps go in roms/ps3/<Game>.ps3dir/ (the folder holding PS3_GAME/);
#     PSN titles installed from a .pkg are launched through a roms/ps3/
#     <SERIAL>.ps3 text file (ES-DE "RPCS3 Game Serial"). No achievements,
#     trophies only.
#   xbox -> xemu (needs bios/xbox/mcpx_1.0.bin + Complex_4627v1.03.bin from
#     your console; a blank HDD image is provided). xbox360 -> Xenia Canary
#     (native Linux build, early). switch -> Eden, alternative Ryujinx
#     (Ryubing); both need prod.keys + firmware dumped from your console
#     (Eden: ~/.local/share/eden/keys, Ryujinx: ~/.config/Ryujinx/system).
# ES-DE's own config lives in ~/ES-DE; the seeds below are written only when
# absent, since ES-DE rewrites them.
#
# Input: keyboard first, a DualShock 4 as a drop-in. One keyboard layout for
# every emulator, built on RetroArch's defaults:
#   arrows = d-pad AND left stick (what 3D and racing games read)
#   Z X A S = RetroPad B A Y X (PS cross circle square triangle)
#   Q W = L1 R1                 E R = L2 R2
#   C V = L3 R3                 I J K L = right stick
#   Enter = Start, Right Shift (or Backspace) = Select
# PS2 (LRPS2 core override + PCSX2 standalone) and GameCube (Dolphin core
# override), whose pads have a stick and a d-pad that games read apart:
# W A S D = left stick, arrows = d-pad only, Q E = L1 R1, R T = L2 R2,
# 1 2 = L3 R3, I J K L = right stick, Enter = Start, Right Shift = Select.
# PS2 face: Z X C V = cross circle square triangle; PCSX2 only: 3 = the
# Analog mode button (LRPS2 has no RetroPad slot for it). GameCube face:
# Z X C V = B A X Y, E = Z, R T = the L and R triggers (full press), 1 2 =
# their half press (the Dolphin core reads RetroPad L3/R3 as "soft press").
# That is every control of a DualShock 2 and of a GameCube pad.
# N64 only (Mupen64Plus-Next and ParaLLEl N64 overrides): Z = A, X = B,
# C = Z trigger (gas in Road Rash 64, Mupen maps it to RetroPad L2), Q W =
# L R, I J K L = C-buttons, arrows = stick and d-pad, Enter = Start; the
# RetroPad A/X slots (C-right/C-up duplicates) are unbound so X stays B.
# Controller vibration is off everywhere: RetroArch rumble gain 0, no motor
# bindings and zero motor scale in PCSX2, no Rumble/Motor line in Dolphin's
# pad, RPCS3's vibration multipliers forced to 0 in any saved input profile.
# RetroArch leaves L2/R2/L3/R3 and both sticks unbound on the keyboard by
# default and uses letters as hotkeys (R rewind, L fast-forward, E slow
# motion, K frame advance, I netplay), so those binds are added and those
# five hotkeys cleared below (rewind moves to Backspace, and to PS + L2 on
# the pad); the rest (F1 menu, Esc, F-keys, F fullscreen, P
# pause, H reset) stay. RetroArch auto-binds any pad it recognises. The
# standalones (PCSX2, Dolphin) carry every binding twice, keyboard and the
# DS4's SDL name, so plugging the pad in just works and unplugging it falls
# back to the keys. Dolphin has no Wayland input backend at all (its keyboard
# device is XInput2), so it is wrapped to run on XWayland. RPCS3 binds one
# handler per player and never falls back, so `rpcs3` is a launcher
# (rpcs3-launch.py): for --no-gui boots (ES-DE) it enumerates the connected
# pads with RPCS3's own SDL, any model (DualShock, Xbox, ...), writes
# input_configs/global/auto.yml with pad 1..n as players 1..n on the SDL
# handler, or the keyboard profile as player 1 when none is connected, and
# passes --input-config auto. The GUI uses its own active profile; the
# managed keyboard.yml (PS2 layout incl. both sticks) is available there.
#
# Only binary-cached packages (checked against cache.nixos.org 2026-10-21):
# nothing here compiles locally. That is why Snes9x, Genesis Plus GX and
# PicoDrive are absent and RPCS3 is the official AppImage. Re-check with
#   curl -sI https://cache.nixos.org/$(basename $(nix eval --raw .#...outPath) | cut -d- -f1).narinfo
let
  hostName = if osConfig == null then "" else osConfig.networking.hostName or "";
  games = "${config.home.homeDirectory}/Games";
  # ES-DE's ROM root: one folder per system name below. Asserted into
  # es_settings.xml on every activation (not just seeded), so this is the
  # single place to move the library (e.g. onto a mount).
  romsDir = "${games}/roms";
  link = config.lib.file.mkOutOfStoreSymlink;

  es-de = pkgs.callPackage ./es-de.nix { };
  # Dolphin only exposes keyboard/mouse through XInput2, i.e. under X11. With
  # the session's QT_QPA_PLATFORM=wayland;xcb it starts natively on Wayland and
  # lists no input device, so every keyboard binding is dead. Force XWayland.
  dolphin = pkgs.symlinkJoin {
    name = "dolphin-emu-xwayland";
    paths = [ pkgs.dolphin-emu ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/dolphin-emu --set QT_QPA_PLATFORM xcb
    '';
  };

  # DS4 as SDL names it (both the hidapi and the evdev path). Check with
  # Dolphin's controller dialog or PCSX2's binding dialog if a pad shows up
  # under another name and adjust here.
  ds4Dolphin = "SDL/0/PS4 Controller";
  ds4Pcsx2 = "SDL-0";
  # Dolphin GameCube pad: the shared layout above plus the DS4 on every
  # control (`a | b` = either source): X/Z/C/S = A/B/X/Y, W = Z, E/R = L/R
  # triggers (same keys as the RetroArch Dolphin core, where they are L2/R2),
  # arrows = main stick (Shift = walk), IJKL = C-stick, TGFH = d-pad.
  gcPadIni = ''
    [GCPad1]
    Device = XInput2/0/Virtual core pointer
    Buttons/A = `X` | `${ds4Dolphin}:Button A`
    Buttons/B = `Z` | `${ds4Dolphin}:Button B`
    Buttons/X = `C` | `${ds4Dolphin}:Button X`
    Buttons/Y = `S` | `${ds4Dolphin}:Button Y`
    Buttons/Z = `W` | `${ds4Dolphin}:Shoulder R`
    Buttons/Start = `Return` | `${ds4Dolphin}:Start`
    Main Stick/Up = `Up` | `${ds4Dolphin}:Left Y+`
    Main Stick/Down = `Down` | `${ds4Dolphin}:Left Y-`
    Main Stick/Left = `Left` | `${ds4Dolphin}:Left X-`
    Main Stick/Right = `Right` | `${ds4Dolphin}:Left X+`
    Main Stick/Modifier = `Shift`
    Main Stick/Calibration = 100.00 141.42 100.00 141.42 100.00 141.42 100.00 141.42
    C-Stick/Up = `I` | `${ds4Dolphin}:Right Y+`
    C-Stick/Down = `K` | `${ds4Dolphin}:Right Y-`
    C-Stick/Left = `J` | `${ds4Dolphin}:Right X-`
    C-Stick/Right = `L` | `${ds4Dolphin}:Right X+`
    C-Stick/Modifier = `Ctrl`
    C-Stick/Calibration = 100.00 141.42 100.00 141.42 100.00 141.42 100.00 141.42
    Triggers/L = `E` | `${ds4Dolphin}:Trigger L`
    Triggers/R = `R` | `${ds4Dolphin}:Trigger R`
    Triggers/L-Analog = `${ds4Dolphin}:Trigger L`
    Triggers/R-Analog = `${ds4Dolphin}:Trigger R`
    D-Pad/Up = `T` | `${ds4Dolphin}:Pad N`
    D-Pad/Down = `G` | `${ds4Dolphin}:Pad S`
    D-Pad/Left = `F` | `${ds4Dolphin}:Pad W`
    D-Pad/Right = `H` | `${ds4Dolphin}:Pad E`
    [GCPad2]
    Device = XInput2/0/Virtual core pointer
    [GCPad3]
    Device = XInput2/0/Virtual core pointer
    [GCPad4]
    Device = XInput2/0/Virtual core pointer
  '';
  # PCSX2 pad 1 (DualShock 2). A binding with several sources is stored as
  # the key repeated once per source. Keyboard = the PS2 layout from the
  # Input note (WASD stick, arrows d-pad, ZXCV face, QE/RT shoulders, 1/2
  # stick clicks, 3 Analog mode, IJKL right stick, Enter/Backspace or Shift
  # Start/Select). The pad's PS button doubles as Analog.
  pcsx2Binds = {
    Up = [ "Keyboard/Up" "${ds4Pcsx2}/DPadUp" ];
    Down = [ "Keyboard/Down" "${ds4Pcsx2}/DPadDown" ];
    Left = [ "Keyboard/Left" "${ds4Pcsx2}/DPadLeft" ];
    Right = [ "Keyboard/Right" "${ds4Pcsx2}/DPadRight" ];
    Cross = [ "Keyboard/Z" "${ds4Pcsx2}/FaceSouth" ];
    Circle = [ "Keyboard/X" "${ds4Pcsx2}/FaceEast" ];
    Square = [ "Keyboard/C" "${ds4Pcsx2}/FaceWest" ];
    Triangle = [ "Keyboard/V" "${ds4Pcsx2}/FaceNorth" ];
    L1 = [ "Keyboard/Q" "${ds4Pcsx2}/LeftShoulder" ];
    R1 = [ "Keyboard/E" "${ds4Pcsx2}/RightShoulder" ];
    L2 = [ "Keyboard/R" "${ds4Pcsx2}/+LeftTrigger" ];
    R2 = [ "Keyboard/T" "${ds4Pcsx2}/+RightTrigger" ];
    L3 = [ "Keyboard/1" "${ds4Pcsx2}/LeftStick" ];
    R3 = [ "Keyboard/2" "${ds4Pcsx2}/RightStick" ];
    Start = [ "Keyboard/Return" "${ds4Pcsx2}/Start" ];
    Select = [ "Keyboard/Backspace" "Keyboard/Shift" "${ds4Pcsx2}/Back" ];
    Analog = [ "Keyboard/3" "${ds4Pcsx2}/Guide" ];
    LUp = [ "Keyboard/W" "${ds4Pcsx2}/-LeftY" ];
    LDown = [ "Keyboard/S" "${ds4Pcsx2}/+LeftY" ];
    LLeft = [ "Keyboard/A" "${ds4Pcsx2}/-LeftX" ];
    LRight = [ "Keyboard/D" "${ds4Pcsx2}/+LeftX" ];
    RUp = [ "Keyboard/I" "${ds4Pcsx2}/-RightY" ];
    RDown = [ "Keyboard/K" "${ds4Pcsx2}/+RightY" ];
    RLeft = [ "Keyboard/J" "${ds4Pcsx2}/-RightX" ];
    RRight = [ "Keyboard/L" "${ds4Pcsx2}/+RightX" ];
  };
  pcsx2PadBlock = pkgs.writeText "pcsx2-pad.ini" (''
    [InputSources]
    Keyboard = true
    Mouse = true
    SDL = true
    SDLControllerEnhancedMode = true
    SDLPS5PlayerLED = true


    [Pad1]
    Type = DualShock2
    InvertL = 0
    InvertR = 0
    Deadzone = 0
    AxisScale = 1.33
    LargeMotorScale = 0
    SmallMotorScale = 0
    ButtonDeadzone = 0
    PressureModifier = 0.5
  '' + lib.concatStringsSep "\n" (lib.concatLists (lib.mapAttrsToList
    (k: vs: map (v: "${k} = ${v}") vs) pcsx2Binds)) + "\n");
  pcsx2Pad = pkgs.writers.writePython3Bin "pcsx2-pad" { } (builtins.readFile ./pcsx2-pad.py);
  # RPCS3 global settings (config.yml, RPCS3's own file: it rewrites it on
  # exit but keeps these values; asserted on activation while RPCS3 is not
  # running). Key names are unique at their indentation. Tekken 6 on the
  # thinkpad's Vega 7 is GPU-bound (resolution scale 50 % fixed its 45 fps
  # stages, 2026-10-25), so: lighter GPU work (no MSAA, low shader
  # precision, relaxed ZCULL, 75 % scale of the 720p framebuffer; the game
  # renders 1024x576 anyway), the RSX work split over two threads, SPU
  # block size Mega and RPCS3's own scheduler. (A Demon's Souls hang on
  # 2026-10-25 was first blamed on these; it was a broken savestate: the
  # game deadlocked on the audio mixer's mutexes with defaults too.) Frame
  # skip stays off: RPCS3 only has a fixed cadence (draw N, skip M), no
  # automatic one, and it judders on stages that already run full speed.
  # The performance overlay shows CPU/GPU/RSX load and frametime.
  rpcs3Settings = {
    "Exit RPCS3 when process finishes" = "true";   # ES-DE gets the screen back
    "Thread Scheduler Mode" = "RPCS3 Alternative Scheduler";
    "SPU Block Size" = "Mega";
    "MSAA" = "Disabled";
    "Shader Precision" = "Low";
    "Relaxed ZCULL Sync" = "true";
    "Accurate ZCULL stats" = "false";
    "Resolution Scale" = "75";
    "Multithreaded RSX" = "true";
    "Enable Frame Skip" = "false";
  };
  rpcs3OverlaySettings = { "Enabled" = "true"; };   # under "Performance Overlay:"
  rpcs3SettingsSed = pkgs.writeText "rpcs3-settings.sed" (lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "s|^  ${k}: .*$|  ${k}: ${v}|") rpcs3Settings
    ++ lib.mapAttrsToList (k: v:
      "/^  Performance Overlay:$/,/^  [^ ]/ s|^    ${k}: .*$|    ${k}: ${v}|")
      rpcs3OverlaySettings) + "\n");
  # RPCS3 game-window shortcuts, aligned with RetroArch's keys: F2 save
  # state, P pause, Space frame-limit toggle (fast-forward), F fullscreen,
  # Esc stop (ES-DE gets the screen back), F8 screenshot, H restart, F9
  # mute, Tab the Home menu (RPCS3's PS-button overlay: save state, exit).
  # No in-game load shortcut exists; the launcher boots the last state.
  # Stored in GuiConfigs/CurrentSettings.ini [Shortcuts] (Qt key names),
  # replaced as a whole section by the same script as the PCSX2 pad.
  rpcs3ShortcutsBlock = pkgs.writeText "rpcs3-shortcuts.ini" ''
    [Shortcuts]
    game_window_savestate=F2
    game_window_pause_play=P
    game_window_frame_limit=Space
    game_window_toggle_fullscreen=F
    game_window_exit_fullscreen=
    game_window_stop=Esc
    game_window_screenshot=F8
    game_window_restart=H
    gw_mute_unmute=F9
    gw_home_menu=Tab
  '';

  # N64 cores: RetroPad B/Y/L2 are N64 A/B/Z (see the Input note).
  n64Override = ''
    input_player1_b = "z"
    input_player1_y = "x"
    input_player1_l2 = "c"
    input_player1_a = "nul"
    input_player1_x = "nul"
    input_player1_l3 = "nul"
    input_player1_r3 = "nul"
  '';
  # PS2/GC cores: left stick off the arrows onto W A S D, shoulders Q E R T,
  # stick clicks 1 2 (frees C V for the face buttons); see the Input note.
  twoStickOverride = ''
    input_player1_l_y_minus = "w"
    input_player1_l_y_plus = "s"
    input_player1_l_x_minus = "a"
    input_player1_l_x_plus = "d"
    input_player1_l = "q"
    input_player1_r = "e"
    input_player1_l2 = "r"
    input_player1_r2 = "t"
    input_player1_l3 = "1"
    input_player1_r3 = "2"
  '';
  duckstation = pkgs.callPackage ./duckstation.nix { };
  rpcs3Appimage = pkgs.callPackage ./rpcs3.nix { };
  rpcs3Launch = pkgs.writers.writePython3Bin "rpcs3-launch" { } (builtins.readFile ./rpcs3-launch.py);
  rpcs3 = pkgs.symlinkJoin {
    name = "rpcs3-autopad";
    paths = [ rpcs3Appimage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/rpcs3
      makeWrapper ${rpcs3Launch}/bin/rpcs3-launch $out/bin/rpcs3 \
        --set RPCS3_BIN ${rpcs3Appimage}/bin/rpcs3 \
        --set RPCS3_SDL ${rpcs3Appimage.extracted}/usr/lib/libSDL3.so.0 \
        --set RPCS3_KEYBOARD_YML ${pkgs.writeText "rpcs3-keyboard.yml" rpcs3KeyboardProfile}
    '';
  };
  # RPCS3's official game patch list, the same file its "Download latest
  # patches" button fetches (served as JSON by rpcs3.net; the yml is the
  # "patch" field). Pinned by hash, so it is a snapshot: when the team
  # publishes new patches the hash changes and the build fails until updated:
  #   nix store prefetch-file --name rpcs3-patches-api.json \
  #     'https://rpcs3.net/compatibility?patch&api=v1&v=1.2'
  # (v=1.2 is RPCS3's patch engine version; bump if a newer RPCS3 rejects it.)
  rpcs3PatchFeed = pkgs.fetchurl {
    url = "https://rpcs3.net/compatibility?patch&api=v1&v=1.2";
    name = "rpcs3-patches-api.json";
    hash = "sha256-7Vvmw+N6g7fYDGHtFJJgvs2qjdSVBqzKFelX9zZb8oU=";
  };
  rpcs3Patches = pkgs.runCommand "rpcs3-patch.yml" { nativeBuildInputs = [ pkgs.jq ]; } ''
    jq -r .patch ${rpcs3PatchFeed} > $out
    grep -q '^Version: 1.2' $out
  '';
  # Patches switched on, per EBOOT hash / title / serial / app version, in
  # RPCS3's own patch_config.yml layout. Demon's Souls US 01.00: the official
  # "Unlock FPS" patch (60 FPS cap; needs default clock scale and vblank
  # rate, which the global config has) and "Disable Motion Blur".
  rpcs3PatchConfig = ''
    PPU-83681f6110d33442329073b72b8dc88a2f677172:
      Unlock FPS:
        "Demon's Souls":
          BLUS30443:
            "01.00":
              Enabled: true
      Disable Motion Blur:
        "Demon's Souls":
          BLUS30443:
            "01.00":
              Enabled: true
  '';

  # RPCS3 keyboard profile (keys are Qt key names), also installed as a
  # selectable profile for the GUI. Vibration off.
  rpcs3KeyboardProfile = ''
    Player 1 Input:
      Handler: Keyboard
      Device: Keyboard
      Config:
        Left Stick Left: A
        Left Stick Down: S
        Left Stick Right: D
        Left Stick Up: W
        Right Stick Left: J
        Right Stick Down: K
        Right Stick Right: L
        Right Stick Up: I
        Start: Return
        Select: Backspace
        PS Button: ""
        Square: C
        Cross: Z
        Circle: X
        Triangle: V
        Left: Left
        Down: Down
        Right: Right
        Up: Up
        R1: E
        R2: T
        R3: "2"
        L1: Q
        L2: R
        L3: "1"
        Large Vibration Motor Multiplier: 0
        Small Vibration Motor Multiplier: 0
      Buddy Device: "Null"
  '';
  # PS3 system software, straight from Sony's update server (the same file
  # the console downloads). RPCS3 needs it installed once; the activation
  # step does that headlessly. Update: new URL from
  # https://www.playstation.com/support/hardware/ps3/system-software/ then
  #   nix store prefetch-file <url>
  ps3Firmware = pkgs.fetchurl {
    url = "http://dus01.ps3.update.playstation.net/update/ps3/image/us/2026_0318_a2b60b6ac1d2e49e230144345616927c/PS3UPDAT.PUP";
    hash = "sha256-FYRx/YNPjqgDYTa2qrQ82Gx7pz15yjDgrzwP4AAc82U=";
    name = "PS3UPDAT-4.93.PUP";
  };
  xenia = pkgs.callPackage ./xenia.nix { };
  # PlayStation-X: the ES-DE theme, pinned and patched.
  #
  # The theme ships `resources/customizations.xml` as a TEMPLATE; the custom
  # colour schemes actually read `theme-customizations/customizations.xml`
  # (colors.xml sets customizationsPath to that, and the dir does not exist in
  # the repo). So we copy the template there and flip one flag:
  # characterOverlayVisible, which theme.xml reads in <image name="overlay-arts">
  # — the full-height character render on the system view (Lara Croft on psx,
  # and the equivalent on every other system). Everything else stays on, so the
  # console TV adverts (systemVideoVisible) are untouched.
  #
  # Patched in the store rather than in ~/ES-DE/themes so ES-DE's own theme
  # updater cannot overwrite it. Requires the *-custom colour scheme to take
  # effect, which the es_settings seed below selects.
  playstation-x-theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "playstation-x-es-de";
    version = "0-unstable-2026-10-14";

    src = pkgs.fetchFromGitHub {
      owner = "RobZombie9043";
      repo = "playstation-x-es-de";
      rev = "78a6517bc75502951182442b136e0dc50b0ec432";
      hash = "sha256-pDz9YOvcshtF9cGn7KM7iPDfj00sPFO5Zgx52Cd0LKg=";
    };

    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r ./* "$out"/
      mkdir -p "$out/theme-customizations"
      sed 's|<characterOverlayVisible>true</characterOverlayVisible>|<characterOverlayVisible>false</characterOverlayVisible>|' \
        resources/customizations.xml > "$out/theme-customizations/customizations.xml"
      # Fail loudly if upstream renames the flag instead of silently shipping
      # a theme that still has the characters.
      grep -q '<characterOverlayVisible>false</characterOverlayVisible>' \
        "$out/theme-customizations/customizations.xml"
      runHook postInstall
    '';

    meta = {
      description = "PlayStation-X ES-DE theme, with the character overlay art disabled";
      homepage = "https://github.com/RobZombie9043/playstation-x-es-de";
      platforms = lib.platforms.all;
    };
  };

  # Blank 8 GB (sparse) Xbox HDD image for xemu, copied into saves/xemu once.
  xemuHdd = pkgs.fetchzip {
    url = "https://github.com/xemu-project/xemu-hdd-image/releases/download/1.0/xbox_hdd.qcow2.zip";
    hash = "sha256-Ia+GW3CqIyYQlQ5yUx5Fs9KWwM5cr+B/0qiMIcJm0EM=";
    stripRoot = false;
  };
  shaders = pkgs.callPackage ./retro-crisis.nix { };

  # Retro Crisis ships per-resolution presets; bbstation drives a 4K panel,
  # the thinkpad is 1080p. "Flat" = no screen curvature.
  rcRes = if hostName == "bbstation" then "4K Flat" else "1080p Flat";
  rcPreset = name: "${shaders}/RetroCrisis/retro crisis/${rcRes}/RC GDV-NTSC - ${name}.slangp";
  # The same look without the NTSC passes (retro-crisis.nix), for a core
  # whose output is too big for the full chain on RetroArch's OpenGL path
  # (at 640x480 the NTSC passes cost ~8 ms a frame there). PS2 uses it
  # (chosen by eye); N64 at native 320x240 affords the full chain.
  rcFastPreset = name: "${shaders}/RetroCrisis/fast/${rcRes}/RC GDV-NTSC - ${name}.slangp";
  fastPresetCores = [ "LRPS2" ];
  # Cores seeded with a preset outside the pack (full path), chosen by eye
  # in RetroArch's menu: N64 on crtsim (libretro slang library).
  corePresetPaths = {
    "Mupen64Plus-Next" = "${shaders}/shaders_slang/crt/crtsim.slangp";
    "ParaLLEl N64" = "${shaders}/shaders_slang/crt/crtsim.slangp";
  };
  # RetroArch auto-loads ~/.config/retroarch/config/<corename>/<corename>.slangp
  # for a core. corename as in the core .info files; value = preset name in
  # the pack (after "RC GDV-NTSC - ").
  corePresets = {
    # SNES
    "bsnes" = "SNES - Clean";
    "bsnes-hd beta" = "SNES - Clean";
    "bsnes-mercury Accuracy" = "SNES - Clean";
    "Beetle Supafaust" = "SNES - Clean";
    "Mesen-S" = "SNES - Clean";
    # Master System / Mega Drive
    "SMS Plus GX" = "Master System - Clean";
    "BlastEm" = "Mega Drive - Clean";
    # Game Boy family: no dedicated Game Boy preset in the pack, GBA is closest
    "Gambatte" = "GBA - Clean";
    "SameBoy" = "GBA - Clean";
    "TGB Dual" = "GBA - Clean";
    "mGBA" = "GBA - Clean";
    "VBA-M" = "GBA - Clean";
    "VBA Next" = "GBA - Clean";
    "gpSP" = "GBA - Clean";
    "Beetle GBA" = "GBA - Clean";
    # N64 / DS
    "Mupen64Plus-Next" = "N64";
    "ParaLLEl N64" = "N64";
    "melonDS" = "DS";
    "DeSmuME" = "DS";
    # PlayStation
    "Beetle PSX HW" = "PlayStation - Clean";
    "Beetle PSX" = "PlayStation - Clean";
    "SwanStation" = "PlayStation - Clean";
    "PCSX-ReARMed" = "PlayStation - Clean";
    # PS2 core; the Dolphin core shares the PS2 (480i era) preset, PPSSPP
    # the pack's handheld DS preset. Library names as the cores report them.
    "LRPS2" = "PS2 - Clean";
    "dolphin-emu" = "PS2 - Clean";
    "PPSSPP" = "DS";
  };
  # Parameter lines appended to the seeded preset for the 3D cores: guest.r's
  # speed advice for crt-guest-advanced-ntsc (fewer NTSC filter taps, "Speedup
  # w. higher Internal Res." 2). On the thinkpad (Vega 7, 1080p integer
  # scale) the full chain gave 72 fps unthrottled on Mario Kart 64 and the
  # trimmed one 76, with no visible difference in a side-by-side montage.
  rcTrim = ''
    ntsc_taps = "19.000000"
    speedup = "2.000000"
  '';
  # 3D cores only: the 2D cores run the full chain at ~95 fps unthrottled
  # here, so they keep it.
  presetParams = {
    "Beetle PSX HW" = rcTrim;
    "Beetle PSX" = rcTrim;
    "SwanStation" = rcTrim;
    "PCSX-ReARMed" = rcTrim;
    "dolphin-emu" = rcTrim;
    "PPSSPP" = rcTrim;
  };
  # Core options asserted into config/<core>/<core>.opt on activation
  # (RetroArch rewrites those files, so they cannot be managed files).
  # Mupen64Plus-Next: GLideN64, which makes RetroArch switch to its OpenGL
  # driver for N64 (the core demands a GL context). ParaLLEl-RDP (Vulkan)
  # needs the low-level RSP on the CPU and left Road Rash 64 at exactly 60
  # fps unthrottled on the thinkpad, whatever the shader; GLideN64 with the
  # high-level RSP reaches 129 without a shader. Measured 2026-10-25 from
  # a save state.
  # melonDS: threaded software renderer, idle cores otherwise.
  coreOptionAsserts = {
    "Mupen64Plus-Next" = {
      "mupen64plus-rdp-plugin" = "gliden64";
      # GLideN64 renders 640x480 by default: the CRT shader then draws two
      # scanlines per N64 row and the GPU fills four times the pixels.
      # Native 320x240 took Road Rash 64 from 109 to 145 fps unthrottled.
      "mupen64plus-43screensize" = "320x240";
    };
    "melonDS" = { "melonds_threaded_renderer" = "enabled"; };
    # Loading times and slowdowns (2026-10-25). Boot logos stay on
    # everywhere: Rafael likes them. Rewind stays off for PS2, GameCube and
    # PSP (core overrides below): the per-frame state of those cores is
    # tens of MB and users report the cores only run with rewind disabled.
    "SwanStation" = {
      # 4x read/seek and a 150 % CPU overclock were tried and brought
      # freezes and frame drops; back to the safe tier.
      "swanstation_CDROM_ReadSpeedup" = "2";
      "swanstation_CDROM_SeekSpeedup" = "2";
      "swanstation_CDROM_LoadImageToRAM" = "true";
      "swanstation_BIOS_PatchFastBoot" = "false"; # PlayStation logo
      "swanstation_CPU_Overclock" = "100";
    };
    "Beetle PSX HW" = {
      "beetle_psx_hw_cd_fastload" = "2x(native)";
      "beetle_psx_hw_cd_access_method" = "precache";
      "beetle_psx_hw_skip_bios" = "disabled";
    };
    "Beetle PSX" = {
      "beetle_psx_cd_fastload" = "2x(native)";
      "beetle_psx_cd_access_method" = "precache";
      "beetle_psx_skip_bios" = "disabled";
    };
    "PCSX-ReARMed" = { "pcsx_rearmed_show_bios_bootlogo" = "enabled"; };
    # LRPS2: the core picked the first BIOS file alphabetically, a Japanese
    # v1.00 from 2000, whose full boot never reached the game (black screen,
    # and the exit-time auto state captured it). Latest USA BIOS instead.
    "LRPS2" = {
      "pcsx2_bios" = "ps2-0230a-20080220.bin";
      "pcsx2_fastboot" = "disabled";  # full boot: Sony logo, PS2 towers, then the game
    };
    # Dolphin: dolphin_skip_gc_bios stays enabled, the GameCube animation
    # needs a dumped IPL.bin under bios/dolphin-emu/Sys/GC/ that is absent.
    # PAL60: European games with a 60 Hz mode use it (native, no speed
    # change); PAL games on the other cores stay at their 50 Hz.
    "dolphin-emu" = { "dolphin_pal60" = "enabled"; };
    "mGBA" = {
      "mgba_frameskip" = "auto";   # skips only when behind (33 % threshold)
      "mgba_skip_bios" = "OFF";    # GBA boot logo (BIOS in use)
    };
    "PPSSPP" = {
      "ppsspp_auto_frameskip" = "enabled";
      "ppsspp_frameskip" = "1";    # auto needs a non-zero maximum
      "ppsspp_cache_iso" = "enabled";
    };
  };
  presetMarker = "# seeded by nix-configs (home-manager/programs/emulation); delete this line to keep your own";

  esSystems = [
    "snes" "mastersystem" "megadrive" "gb" "gbc" "gba" "n64" "nds"
    "psx" "ps2" "psp" "ps3" "gc" "wii" "xbox" "xbox360" "switch"
  ];
  # Default emulator per system, asserted into the top of each gamelist on
  # every activation (ES-DE stores the choice there; labels as in its
  # es_systems.xml and our es-systems.xml override). RetroArch cores wherever
  # one exists; standalones only where there is no core.
  esAltEmulators = {
    snes = "bsnes";
    mastersystem = "SMS Plus GX";
    megadrive = "BlastEm";
    gb = "Gambatte";
    gbc = "Gambatte";
    gba = "mGBA";
    n64 = "Mupen64Plus-Next";
    nds = "melonDS";
    psx = "Beetle PSX HW";  # accuracy reference; SwanStation froze and dropped frames (2026-10-25)
    ps2 = "LRPS2";
    psp = "PPSSPP";
    gc = "Dolphin";
    wii = "Dolphin";
    ps3 = "RPCS3 Directory (Standalone)"; # games as roms/ps3/<name>.ps3dir/ folders
    xbox = "xemu (Standalone)";
    xbox360 = "xenia (Standalone)";
    switch = "Eden (Standalone)";
  };
  esAltEmulator = pkgs.writers.writePython3Bin "es-alt-emulator" { } (builtins.readFile ./es-alt-emulator.py);
in
{
  home.packages = [
    es-de
    pkgs.pcsx2       # PS2 (pcsx2-qt)
    dolphin          # GameCube / Wii (pkgs.dolphin-emu forced onto XWayland)
    rpcs3            # PS3 (AppImage behind the pad-picking launcher)
    pkgs.ppsspp      # PSP: "PPSSPP (Standalone)"
    pkgs.xemu        # Xbox
    xenia            # Xbox 360: "xenia (Standalone)"
    pkgs.eden        # Switch: "Eden (Standalone)"
    pkgs.ryubing     # Switch: "Ryujinx (Standalone)"
    # Standalone alternatives ES-DE knows by binary name:
    duckstation      # psx: "DuckStation (Standalone)"
    pkgs.blastem     # megadrive: "BlastEm (Standalone)"
    pkgs.simple64    # n64: "simple64 (Standalone)"
    pkgs.rmg         # n64: "Rosalie's Mupen GUI (Standalone)"
    pkgs.melonDS     # nds: "melonDS (Standalone)"
    pkgs.desmume     # nds: "DeSmuME (Standalone)"
    pkgs.mednafen    # gb gbc gba snes mastersystem psx: "Mednafen (Standalone)"
    pkgs.ares        # gb gbc gba snes mastersystem psx: "ares (Standalone)"
    pkgs.sameboy     # gb gbc: "SameBoy (Standalone)"
    pkgs.mgba        # gba gb gbc: "mGBA (Standalone)"
    # pkgs.snes9x-gtk fails to build in nixpkgs 26.05 (missing unzip.h); the
    # SNES cores above are plenty.
  ];

  programs.retroarch = {
    enable = true;
    # First of each group is the one ES-DE uses by default (its own default
    # or the seed below); the rest show up as alternatives in ES-DE.
    cores = {
      # SNES
      bsnes.enable = true;             # accuracy (ES-DE default via seed)
      bsnes-hd.enable = true;          # widescreen / HD mode 7
      bsnes-mercury.enable = true;
      beetle-supafaust.enable = true;
      mesen-s.enable = true;
      # Master System (also Game Gear)
      smsplus-gx.enable = true;
      # Mega Drive
      blastem.enable = true;
      # Nintendo 64
      mupen64plus.enable = true;       # Mupen64Plus-Next (ES-DE default)
      parallel-n64.enable = true;
      # Nintendo DS
      melonds.enable = true;
      desmume.enable = true;
      # PSP (standalone PPSSPP is the default)
      ppsspp.enable = true;
      # Game Boy / Color
      gambatte.enable = true;
      sameboy.enable = true;           # accuracy
      tgbdual.enable = true;           # link cable
      # Game Boy Advance
      mgba.enable = true;
      vba-m.enable = true;
      vba-next.enable = true;
      gpsp.enable = true;              # lightest
      beetle-gba.enable = true;
      # PlayStation
      beetle-psx-hw.enable = true;     # accurate, GPU renderer
      beetle-psx.enable = true;        # accurate, software renderer
      swanstation.enable = true;       # DuckStation-based: fast, upscaling
      pcsx-rearmed.enable = true;      # lightest
      # PS2 and GameCube/Wii inside RetroArch (standalones are the default)
      pcsx2.enable = true;             # LRPS2
      dolphin.enable = true;
    };
    # Appended to retroarch.cfg on every start, so these always win; keep it
    # to paths and infrastructure so everything else stays tweakable in-menu.
    settings = {
      video_driver = "vulkan";
      video_threaded = "false"; # slow-driver fallback, costs time on Vulkan
      # Pixel-exact scaling that fills the screen: "Smart" rounds up to the
      # next integer when that only crops overscan (1080p: 224/240-line
      # content x5 instead of x4, GBA x7, PSP x4), otherwise rounds down
      # (480-line PS2/GC x2, Game Boy x7).
      video_scale_integer = "true";
      video_scale_integer_scaling = "2";
      video_fullscreen = "true";
      audio_driver = "pulse"; # pipewire-pulse
      audio_sync = "true";    # paces the game (vsync is off); Space fast-forwards
      fps_show = "true";
      video_font_enable = "true"; # the OSD: fps counter, notifications
      # Resume where you left off: a state is written on exit (<game>.state.auto)
      # and loaded on the next launch. Manual slots are untouched.
      savestate_auto_save = "true";
      savestate_auto_load = "true";
      # Pad hotkeys (button numbers from RetroArch's DualShock 4 udev
      # profile: 10 PS, 4 L1, 5 R1, 9 Options, L2 = axis +2): hold the PS
      # button, press R1 = save state, L1 = load state, L2 = rewind,
      # Options = quit. The profile also binds PS alone to the menu, which
      # RetroArch keeps for a lone press (hotkeys fire only with a second
      # button). Every save goes to a new slot and load takes the newest
      # one (auto index); nothing is deleted (max_keep 0).
      input_enable_hotkey_btn = "10";
      input_save_state_btn = "5";
      input_load_state_btn = "4";
      input_exit_emulator_btn = "9";  # PS + Options = quit (back to ES-DE), like Esc
      savestate_auto_index = "true";
      savestate_max_keep = "0";
      # Rewind: hold Backspace, or PS + L2 (an axis on the DualShock 4
      # profile), to go back in time. 256 MB buffer; off for the cores
      # whose states are tens of MB (PS2, GameCube, PSP) in their overrides.
      rewind_enable = "true";
      rewind_granularity = "1";
      rewind_buffer_size = "268435456";
      input_rewind = "backspace";
      input_rewind_axis = "+2";
      menu_driver = "ozone";
      system_directory = "${games}/bios";
      savefile_directory = "${games}/saves/retroarch";
      savestate_directory = "${games}/states/retroarch";
      screenshot_directory = "${games}/screenshots";
      video_shader_dir = "${shaders}";
      video_shader_enable = "true";
      cheevos_enable = "true"; # credentials entered once in the menu
      quit_press_twice = "false";
      # Keyboard: the shared layout (see the Input note at the top). RetroArch
      # binds nothing to these by default, which left the Dolphin core's GC
      # triggers (L2/R2) and main stick without keys.
      input_player1_l2 = "e";
      input_player1_r2 = "r";
      input_player1_l3 = "c";
      input_player1_r3 = "v";
      input_player1_l_x_minus = "left";
      input_player1_l_x_plus = "right";
      input_player1_l_y_minus = "up";
      input_player1_l_y_plus = "down";
      input_player1_r_x_minus = "j";
      input_player1_r_x_plus = "l";
      input_player1_r_y_minus = "i";
      input_player1_r_y_plus = "k";
      # Letter hotkeys that would fire on those pad keys.
      input_hold_fast_forward = "nul";
      input_hold_slowmotion = "nul";
      input_toggle_slowmotion = "nul";
      input_frame_advance = "nul";
      input_netplay_game_watch = "nul";
      input_cheat_index_minus = "nul"; # t
      input_cheat_index_plus = "nul";  # y
      input_cheat_toggle = "nul";      # u
      input_rumble_gain = "0";         # no vibration in any core
    };
  };

  # ES-DE finds RetroArch cores in ~/.config/retroarch/cores.
  xdg.configFile."retroarch/cores".source =
    "${config.programs.retroarch.finalPackage}/lib/retroarch/cores";

  # Core overrides (Input note). RetroArch loads config/<library name>/<library
  # name>.cfg on top of the main config when that core starts. Managed files,
  # so "Save Core Overrides" in the menu cannot replace them; edit here.
  # LRPS2 and the Dolphin core ("dolphin-emu") share the two-stick layout and
  # differ only in the face buttons: PS2 Z X C V = cross circle square
  # triangle (RetroPad B A Y X), GC Z X C V = B A X Y (RetroPad B A X Y, the
  # core maps them by name; Z is RetroPad R, L/R are L2/R2, soft L/R L3/R3).
  xdg.configFile."retroarch/config/Mupen64Plus-Next/Mupen64Plus-Next.cfg".text = n64Override;
  xdg.configFile."retroarch/config/ParaLLEl N64/ParaLLEl N64.cfg".text = n64Override;
  xdg.configFile."retroarch/config/LRPS2/LRPS2.cfg".text = twoStickOverride + ''
    input_player1_b = "z"
    input_player1_a = "x"
    input_player1_y = "c"
    input_player1_x = "v"
    rewind_enable = "false"
    # LRPS2 hangs on quit while writing the exit-time state (reproduced
    # 2026-10-25: 120 s timeout with it on, clean exit in 12 s without).
    savestate_auto_save = "false"
    savestate_auto_load = "false"
  '';
  xdg.configFile."retroarch/config/dolphin-emu/dolphin-emu.cfg".text = twoStickOverride + ''
    input_player1_b = "z"
    input_player1_a = "x"
    input_player1_x = "c"
    input_player1_y = "v"
    rewind_enable = "false"
  '';
  xdg.configFile."retroarch/config/PPSSPP/PPSSPP.cfg".text = ''
    rewind_enable = "false"
  '';

  # psx/ps2 without .bin in the extension list (see the file): a bin/cue dump
  # is listed once. For a game that is a folder of files, name the folder
  # after the file to launch, e.g. roms/psx/Game.cue/Game.cue + Game.bin:
  # ES-DE then shows the folder as that single game. Multi-disc: Game.m3u/
  # with the .m3u and all discs inside.
  home.file."ES-DE/custom_systems/es_systems.xml".source = ./es-systems.xml;

  # The theme itself is read-only in the store; ES-DE only reads from here.
  # A hand-downloaded copy at this path is moved aside by the activation step
  # below, since home-manager will not replace a real directory.
  home.file."ES-DE/themes/playstation-x-es-de".source = playstation-x-theme;

  # Dolphin GameCube pad: fully managed (Dolphin cannot save over it, so
  # mapping changes belong here).
  home.file.".config/dolphin-emu/GCPadNew.ini" = { text = gcPadIni; force = true; };

  # Data the RetroArch cores look for under the system dir (bios/): LRPS2
  # reads pcsx2/bios (same files as PCSX2's bios/ps2), the Dolphin core needs
  # Dolphin's Sys tree, PPSSPP its assets; both come from the cores' sources.
  home.file."Games/bios/pcsx2/bios".source = link "${games}/bios/ps2";
  # LRPS2 game database (per-game fixes), looked up as pcsx2/resources/GameIndex.yaml
  home.file."Games/bios/pcsx2/resources".source = "${pkgs.libretro.pcsx2.src}/bin/resources";
  home.file."Games/bios/dolphin-emu/Sys".source = "${pkgs.libretro.dolphin.src}/Data/Sys";
  home.file."Games/bios/PPSSPP".source = "${pkgs.libretro.ppsspp.src}/assets";

  # RPCS3 per-game settings (custom_configs/config_<serial>.yml): only the
  # keys listed are overridden, the rest comes from the global config. RPCS3
  # applies them automatically when that serial boots. Managed files, so
  # "Create Custom Configuration" in the GUI cannot save over them.
  #   BLUS30443 Demon's Souls (US): the game draws the world into off-screen
  #   colour buffers that the CPU reads back; without Write Color Buffers
  #   only the HUD renders over black (RPCS3 names this game in the option's
  #   own tooltip).
  home.file.".config/rpcs3/input_configs/global/keyboard.yml" = { text = rpcs3KeyboardProfile; force = true; };
  # Official patch list + which patches are on (managed: the GUI's patch
  # downloader and toggles cannot write over them; change them here).
  home.file.".config/rpcs3/patches/patch.yml" = { source = rpcs3Patches; force = true; };
  home.file.".config/rpcs3/patch_config.yml" = { text = rpcs3PatchConfig; force = true; };

  home.file.".config/rpcs3/custom_configs/config_BLUS30443.yml" = {
    force = true;
    text = ''
      Video:
        Write Color Buffers: true
    '';
  };

  # Standalone emulators keep their saves where Syncthing sees them.
  home.file = {
    ".config/PCSX2/memcards".source = link "${games}/saves/pcsx2";
    ".config/PCSX2/bios".source = link "${games}/bios/ps2";
    ".local/share/dolphin-emu/GC".source = link "${games}/saves/dolphin/GC";
    ".local/share/dolphin-emu/Wii".source = link "${games}/saves/dolphin/Wii";
    ".config/rpcs3/dev_hdd0/home/00000001/savedata".source = link "${games}/saves/rpcs3/savedata";
    ".config/rpcs3/dev_hdd0/home/00000001/trophy".source = link "${games}/saves/rpcs3/trophy";
    ".local/share/duckstation/memcards".source = link "${games}/saves/duckstation";
    ".local/share/duckstation/bios".source = link "${games}/bios"; # finds the scph*.bin there
    ".mednafen/sav".source = link "${games}/saves/mednafen";
    ".config/ppsspp/PSP/SAVEDATA".source = link "${games}/saves/ppsspp";
    ".local/share/xemu/xemu/xbox_hdd.qcow2".source = link "${games}/saves/xemu/xbox_hdd.qcow2";
    ".local/share/xemu/xemu/eeprom.bin".source = link "${games}/saves/xemu/eeprom.bin";
    ".local/share/xenia/content".source = link "${games}/saves/xenia";
    ".local/share/eden/nand/user/save".source = link "${games}/saves/eden";
    ".config/Ryujinx/bis/user/save".source = link "${games}/saves/ryujinx";
    # ares, SameBoy, mGBA and Snes9x standalone save next to the ROM.
  };

  # home-manager refuses to replace a real directory with its symlink, and the
  # theme downloader leaves a git clone at exactly this path. Move it aside
  # once, before the link check runs, so switching to the packaged theme does
  # not need a manual rm.
  home.activation.emulationThemeTakeover =
    lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      t="${config.home.homeDirectory}/ES-DE/themes/playstation-x-es-de"
      if [ -d "$t" ] && [ ! -L "$t" ]; then
        run mv "$t" "$t.downloaded-backup-$(date +%Y%m%d%H%M%S)"
      fi
    '';

  home.activation.emulationSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # File writes go through this helper so that `run` sees one command:
    # in a dry run `run` only echoes its arguments, and an outer shell
    # redirection would capture that echo as the file's content (which is
    # exactly what happened to the preset files once).
    write_file() { printf '%s' "$2" > "$1"; }
    games="${games}"
    run mkdir -p \
      ${lib.concatMapStringsSep " " (s: ''"${romsDir}/${s}"'') esSystems} \
      "$games/bios/ps2" "$games/saves/retroarch" "$games/saves/pcsx2" \
      "$games/saves/dolphin/GC" "$games/saves/dolphin/Wii" \
      "$games/saves/rpcs3/savedata" "$games/saves/rpcs3/trophy" \
      "$games/saves/duckstation" "$games/saves/mednafen" "$games/saves/ppsspp" \
      "$games/saves/xemu" "$games/saves/xenia" "$games/saves/eden" "$games/saves/ryujinx" \
      "$games/bios/xbox" "$games/bios/nds" \
      "$games/states/retroarch" "$games/screenshots"

    # Retro Crisis preset per core, re-seeded while it still carries our
    # marker; a preset saved from RetroArch's menu (no marker) is left alone.
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (core: system: ''
      f="${config.xdg.configHome}/retroarch/config/${core}/${core}.slangp"
      # Also re-seed a file whose first line is the echoed printf command
      # left behind by the old redirect-in-dry-run bug.
      if [ ! -e "$f" ] || [ "$(head -n1 "$f")" = "${presetMarker}" ] || head -n1 "$f" | grep -q '^printf '; then
        run mkdir -p "$(dirname "$f")"
        run write_file "$f" ${lib.escapeShellArg (presetMarker + "\n#reference \""
          + (corePresetPaths.${core} or (if builtins.elem core fastPresetCores then rcFastPreset system else rcPreset system))
          + "\"\n" + (presetParams.${core} or ""))}
      fi
    '') corePresets)}

    # Core options (coreOptionAsserts): add or replace the key in the .opt.
    ${lib.concatStringsSep "\n" (lib.concatLists (lib.mapAttrsToList (core: opts: lib.mapAttrsToList (k: v: let
      line = ''${k} = "${v}"'';
    in ''
      o="${config.xdg.configHome}/retroarch/config/${core}/${core}.opt"
      if [ ! -e "$o" ]; then
        run mkdir -p "$(dirname "$o")"
        run write_file "$o" ${lib.escapeShellArg (line + "\n")}
      elif ! grep -qxF ${lib.escapeShellArg line} "$o"; then
        run sed -i -e ${lib.escapeShellArg ("/^" + k + " = /d")} -e ${lib.escapeShellArg ("$a " + line)} "$o"
      fi
    '') opts) coreOptionAsserts))}

    # xemu: blank HDD image once, and a config pointing at the bios/saves
    # tree (xemu rewrites the file, so only when absent).
    if [ ! -e "$games/saves/xemu/xbox_hdd.qcow2" ]; then
      run install -Dm644 "${xemuHdd}/xbox_hdd.qcow2" "$games/saves/xemu/xbox_hdd.qcow2"
    fi
    xemu_cfg="${config.home.homeDirectory}/.local/share/xemu/xemu/xemu.toml"
    if [ ! -e "$xemu_cfg" ]; then
      run mkdir -p "$(dirname "$xemu_cfg")"
      run printf '%s\n' '[sys.files]' \
        "bootrom_path = '$games/bios/xbox/mcpx_1.0.bin'" \
        "flashrom_path = '$games/bios/xbox/Complex_4627v1.03.bin'" \
        "eeprom_path = '$games/saves/xemu/eeprom.bin'" \
        "hdd_path = '$games/saves/xemu/xbox_hdd.qcow2'" > "$xemu_cfg"
    fi

    # PCSX2 pad 1 + input sources: asserted on every activation while PCSX2 is
    # not running (it rewrites the ini on exit). Other sections are untouched.
    pcsx2_ini="${config.xdg.configHome}/PCSX2/inis/PCSX2.ini"
    if ! ${pkgs.procps}/bin/pgrep -x pcsx2-qt >/dev/null 2>&1; then
      run mkdir -p "$(dirname "$pcsx2_ini")"
      run ${pcsx2Pad}/bin/pcsx2-pad "$pcsx2_ini" ${pcsx2PadBlock}
    fi

    # RPCS3 shortcuts (see rpcs3ShortcutsBlock); only while it is not running.
    rpcs3_gui="${config.xdg.configHome}/rpcs3/GuiConfigs/CurrentSettings.ini"
    if ! ${pkgs.procps}/bin/pgrep -f 'rpcs3[^ ]*/AppRun.wrapped' >/dev/null 2>&1; then
      run mkdir -p "$(dirname "$rpcs3_gui")"
      [ -e "$rpcs3_gui" ] || run write_file "$rpcs3_gui" ""
      run ${pcsx2Pad}/bin/pcsx2-pad "$rpcs3_gui" ${rpcs3ShortcutsBlock}
    fi

    # RPCS3: install the PS3 firmware once (headless, ~30 s), then assert
    # rpcs3Settings in config.yml, which appears with the firmware install.
    rpcs3_cfg="${config.xdg.configHome}/rpcs3"
    if [ ! -e "$rpcs3_cfg/dev_flash/vsh/module/vsh.self" ]; then
      run ${rpcs3}/bin/rpcs3 --headless --installfw ${ps3Firmware} >/dev/null 2>&1 \
        || echo "emulation: PS3 firmware install failed; run: rpcs3 --installfw ${ps3Firmware}"
    fi
    if [ -e "$rpcs3_cfg/config.yml" ] && ! ${pkgs.procps}/bin/pgrep -f 'rpcs3[^ ]*/AppRun.wrapped' >/dev/null 2>&1; then
      run ${pkgs.gnused}/bin/sed -i -f ${rpcs3SettingsSed} "$rpcs3_cfg/config.yml"
      # Input profiles only exist once a pad handler was picked in the GUI;
      # whatever they contain, vibration stays off.
      for f in "$rpcs3_cfg"/input_configs/*/*.yml; do
        [ -e "$f" ] && [ ! -L "$f" ] || continue   # managed ones are symlinks
        run ${pkgs.gnused}/bin/sed -i -E \
          's|^(\s*(Large\|Small) Vibration Motor Multiplier:) [0-9]+$|\1 0|' "$f"
      done
    fi

    # ES-DE seeds (only when absent: ES-DE owns these files afterwards).
    es="${config.home.homeDirectory}/ES-DE"
    if [ ! -e "$es/settings/es_settings.xml" ]; then
      run mkdir -p "$es/settings"
      run printf '%s\n' '<?xml version="1.0"?>' \
        '<string name="ROMDirectory" value="${romsDir}" />' > "$es/settings/es_settings.xml"
    fi

    # Theme selection. Unlike the seeds above these are re-asserted on every
    # activation, so the theme stays the default: ES-DE rewrites
    # es_settings.xml wholesale when it exits, so an edit made while it runs is
    # lost — hence the guard. ps5-custom (not ps5) is what makes ES-DE read
    # theme-customizations/customizations.xml, i.e. what actually drops the
    # character art; selecting the theme without it would bring Lara back.
    if ! ${pkgs.procps}/bin/pgrep -x es-de >/dev/null 2>&1; then
      set_es_setting() {
        if ${pkgs.gnugrep}/bin/grep -q "<string name=\"$1\" " "$es/settings/es_settings.xml"; then
          run ${pkgs.gnused}/bin/sed -i \
            "s|<string name=\"$1\" value=\"[^\"]*\" />|<string name=\"$1\" value=\"$2\" />|" \
            "$es/settings/es_settings.xml"
        else
          run ${pkgs.gnused}/bin/sed -i \
            "\$a<string name=\"$1\" value=\"$2\" />" "$es/settings/es_settings.xml"
        fi
      }
      set_es_setting Theme playstation-x-es-de
      set_es_setting ThemeColorScheme ps5-custom
      set_es_setting ROMDirectory "${romsDir}"
    fi
    # Default emulator per system (see esAltEmulators). ES-DE rewrites the
    # gamelists itself, so only while it is not running.
    if ! ${pkgs.procps}/bin/pgrep -x es-de >/dev/null 2>&1; then
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (system: label: ''
      run ${esAltEmulator}/bin/es-alt-emulator "$es/gamelists/${system}/gamelist.xml" ${lib.escapeShellArg label}
    '') esAltEmulators)}
    fi
  '';
}
