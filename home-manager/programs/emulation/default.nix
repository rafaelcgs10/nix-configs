{ config, lib, pkgs, osConfig ? null, ... }:

# Console emulation for the COSMIC hosts (thinkpad, bbstation).
#
# Layout (all under ~/Games; add `saves` - and `bios`/`roms` if wanted - as
# Syncthing folders on each host):
#   roms/<es-de system name>/   you provide the games (ES-DE naming:
#                               snes mastersystem gb gbc gba psx ps2 ps3 gc wii)
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
#   snes mastersystem gb gbc gba psx -> RetroArch cores (Snes9x, Genesis Plus
#     GX, Gambatte, mGBA, Beetle PSX HW): Retro Crisis CRT shaders +
#     RetroAchievements (log in once in RetroArch: Settings > Achievements).
#     Alternatives: the other cores below, plus the standalone mednafen, ares,
#     SameBoy, mGBA, Snes9x and DuckStation.
#   ps2 gc wii -> PCSX2 / Dolphin standalone (achievements: log in once in
#     each emulator's settings); alternatives: the LRPS2 and Dolphin RetroArch
#     cores. ps3 -> RPCS3 (firmware PS3UPDAT.PUP installed once via its menu;
#     no achievements, trophies only), no alternative exists.
# ES-DE's own config lives in ~/ES-DE; the seeds below are written only when
# absent, since ES-DE rewrites them.
let
  hostName = if osConfig == null then "" else osConfig.networking.hostName or "";
  games = "${config.home.homeDirectory}/Games";
  link = config.lib.file.mkOutOfStoreSymlink;

  es-de = pkgs.callPackage ./es-de.nix { };
  duckstation = pkgs.callPackage ./duckstation.nix { };
  shaders = pkgs.callPackage ./retro-crisis.nix { };

  # Retro Crisis ships per-resolution presets; bbstation drives a 4K panel,
  # the thinkpad is 1080p. "Flat" = no screen curvature.
  rcRes = if hostName == "bbstation" then "4K Flat" else "1080p Flat";
  rcPreset = system: "${shaders}/RetroCrisis/retro crisis/${rcRes}/RC GDV-NTSC - ${system} - Clean.slangp";
  # RetroArch auto-loads ~/.config/retroarch/config/<corename>/<corename>.slangp
  # for a core. corename as in the core .info files.
  corePresets = {
    # SNES
    "Snes9x" = "SNES";
    "Snes9x 2010" = "SNES";
    "bsnes" = "SNES";
    "bsnes-hd beta" = "SNES";
    "bsnes-mercury Accuracy" = "SNES";
    "Beetle Supafaust" = "SNES";
    "Mesen-S" = "SNES";
    # Master System (PicoDrive/Genesis Plus GX also run Mega Drive)
    "Genesis Plus GX" = "Master System";
    "SMS Plus GX" = "Master System";
    "PicoDrive" = "Master System";
    # Game Boy family: no dedicated Game Boy preset in the pack, GBA is closest
    "Gambatte" = "GBA";
    "SameBoy" = "GBA";
    "TGB Dual" = "GBA";
    "mGBA" = "GBA";
    "VBA-M" = "GBA";
    "VBA Next" = "GBA";
    "gpSP" = "GBA";
    "Beetle GBA" = "GBA";
    # PlayStation
    "Beetle PSX HW" = "PlayStation";
    "Beetle PSX" = "PlayStation";
    "SwanStation" = "PlayStation";
    "PCSX-ReARMed" = "PlayStation";
    # PS2 core; the Dolphin core gets none (no GameCube preset in the pack)
    "LRPS2" = "PS2";
  };
  presetMarker = "# seeded by nix-configs (home-manager/programs/emulation); delete this line to keep your own";

  esSystems = [ "snes" "mastersystem" "gb" "gbc" "gba" "psx" "ps2" "ps3" "gc" "wii" ];
  # ES-DE defaults that point at cores/emulators we do not install; pin the
  # installed ones instead (ES-DE stores this at the top of each gamelist).
  esAltEmulators = {
    psx = "Beetle PSX HW";
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
    pkgs.rpcs3       # PS3
    # Standalone alternatives ES-DE knows by binary name:
    duckstation      # psx: "DuckStation (Standalone)"
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
      snes9x.enable = true;
      snes9x2010.enable = true;        # lighter
      bsnes.enable = true;             # accuracy
      bsnes-hd.enable = true;          # widescreen / HD mode 7
      bsnes-mercury.enable = true;
      beetle-supafaust.enable = true;
      mesen-s.enable = true;
      # Master System (Genesis Plus GX / PicoDrive also cover Game Gear, Mega Drive)
      genesis-plus-gx.enable = true;
      smsplus-gx.enable = true;
      picodrive.enable = true;
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
    # ares, SameBoy, mGBA and Snes9x standalone save next to the ROM.
  };

  home.activation.emulationSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    games="${games}"
    run mkdir -p \
      ${lib.concatMapStringsSep " " (s: ''"$games/roms/${s}"'') esSystems} \
      "$games/bios/ps2" "$games/saves/retroarch" "$games/saves/pcsx2" \
      "$games/saves/dolphin/GC" "$games/saves/dolphin/Wii" \
      "$games/saves/rpcs3/savedata" "$games/saves/rpcs3/trophy" \
      "$games/saves/duckstation" "$games/saves/mednafen" \
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
