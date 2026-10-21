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
#   ps2 gc wii psp -> PCSX2 / Dolphin / PPSSPP standalone (achievements: log
#     in once in each emulator's settings); alternatives: the LRPS2, Dolphin
#     and PPSSPP RetroArch cores. ps3 -> RPCS3 (firmware PS3UPDAT.PUP
#     installed once via its menu; no achievements, trophies only).
#   xbox -> xemu (needs bios/xbox/mcpx_1.0.bin + Complex_4627v1.03.bin from
#     your console; a blank HDD image is provided). xbox360 -> Xenia Canary
#     (native Linux build, early). switch -> Eden, alternative Ryujinx
#     (Ryubing); both need prod.keys + firmware dumped from your console
#     (Eden: ~/.local/share/eden/keys, Ryujinx: ~/.config/Ryujinx/system).
# ES-DE's own config lives in ~/ES-DE; the seeds below are written only when
# absent, since ES-DE rewrites them.
#
# Only binary-cached packages (checked against cache.nixos.org 2026-10-21):
# nothing here compiles locally. That is why Snes9x, Genesis Plus GX and
# PicoDrive are absent and RPCS3 is the official AppImage. Re-check with
#   curl -sI https://cache.nixos.org/$(basename $(nix eval --raw .#...outPath) | cut -d- -f1).narinfo
let
  hostName = if osConfig == null then "" else osConfig.networking.hostName or "";
  games = "${config.home.homeDirectory}/Games";
  link = config.lib.file.mkOutOfStoreSymlink;

  es-de = pkgs.callPackage ./es-de.nix { };
  duckstation = pkgs.callPackage ./duckstation.nix { };
  rpcs3 = pkgs.callPackage ./rpcs3.nix { };
  xenia = pkgs.callPackage ./xenia.nix { };
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
    # PS2 core; Dolphin and PPSSPP cores get none (no preset in the pack)
    "LRPS2" = "PS2 - Clean";
  };
  presetMarker = "# seeded by nix-configs (home-manager/programs/emulation); delete this line to keep your own";

  esSystems = [
    "snes" "mastersystem" "megadrive" "gb" "gbc" "gba" "n64" "nds"
    "psx" "ps2" "psp" "ps3" "gc" "wii" "xbox" "xbox360" "switch"
  ];
  # ES-DE defaults that point at cores/emulators we do not install; pin the
  # installed ones instead (ES-DE stores this at the top of each gamelist).
  esAltEmulators = {
    snes = "bsnes";
    mastersystem = "SMS Plus GX";
    megadrive = "BlastEm";
    nds = "melonDS";
    psx = "Beetle PSX HW";
    psp = "PPSSPP (Standalone)";
    ps2 = "PCSX2 (Standalone)";
    gc = "Dolphin (Standalone)";
    wii = "Dolphin (Standalone)";
    ps3 = "RPCS3 Directory (Standalone)"; # games as roms/ps3/<name>.ps3dir/ folders
  };
in
{
  home.packages = [
    es-de
    pkgs.pcsx2       # PS2 (pcsx2-qt)
    pkgs.dolphin-emu # GameCube / Wii
    rpcs3            # PS3 (AppImage)
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
      video_fullscreen = "true";
      audio_driver = "pulse"; # pipewire-pulse
      menu_driver = "ozone";
      system_directory = "${games}/bios";
      savefile_directory = "${games}/saves/retroarch";
      savestate_directory = "${games}/states/retroarch";
      screenshot_directory = "${games}/screenshots";
      video_shader_dir = "${shaders}";
      video_shader_enable = "true";
      cheevos_enable = "true"; # credentials entered once in the menu
      quit_press_twice = "false";
    };
  };

  # ES-DE finds RetroArch cores in ~/.config/retroarch/cores.
  xdg.configFile."retroarch/cores".source =
    "${config.programs.retroarch.finalPackage}/lib/retroarch/cores";

  # psx/ps2 without .bin in the extension list (see the file): a bin/cue dump
  # is listed once. For a game that is a folder of files, name the folder
  # after the file to launch, e.g. roms/psx/Game.cue/Game.cue + Game.bin:
  # ES-DE then shows the folder as that single game. Multi-disc: Game.m3u/
  # with the .m3u and all discs inside.
  home.file."ES-DE/custom_systems/es_systems.xml".source = ./es-systems.xml;

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

  home.activation.emulationSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    games="${games}"
    run mkdir -p \
      ${lib.concatMapStringsSep " " (s: ''"$games/roms/${s}"'') esSystems} \
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
      if [ ! -e "$f" ] || [ "$(head -n1 "$f")" = "${presetMarker}" ]; then
        run mkdir -p "$(dirname "$f")"
        run printf '%s\n#reference "%s"\n' "${presetMarker}" ${lib.escapeShellArg (rcPreset system)} > "$f"
      fi
    '') corePresets)}

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

    # ES-DE seeds (only when absent: ES-DE owns these files afterwards).
    es="${config.home.homeDirectory}/ES-DE"
    if [ ! -e "$es/settings/es_settings.xml" ]; then
      run mkdir -p "$es/settings"
      run printf '%s\n' '<?xml version="1.0"?>' \
        '<string name="ROMDirectory" value="~/Games/roms" />' > "$es/settings/es_settings.xml"
    fi
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (system: label: ''
      g="$es/gamelists/${system}/gamelist.xml"
      if [ ! -e "$g" ]; then
        run mkdir -p "$(dirname "$g")"
        run printf '%s\n' '<?xml version="1.0"?>' '<alternativeEmulator>' \
          '	<label>${label}</label>' '</alternativeEmulator>' '<gameList />' > "$g"
      fi
    '') esAltEmulators)}
  '';
}
