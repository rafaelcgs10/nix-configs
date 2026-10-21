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
# Frontend: ES-DE launches everything from one controller UI. Per system:
#   snes mastersystem gb gbc gba psx -> RetroArch cores (Snes9x, Genesis Plus
#     GX, Gambatte, mGBA, Beetle PSX HW): Retro Crisis CRT shaders +
#     RetroAchievements (log in once in RetroArch: Settings > Achievements).
#   ps2 gc wii -> PCSX2 / Dolphin standalone (achievements: log in once in
#     each emulator's settings); ps3 -> RPCS3 (firmware PS3UPDAT.PUP installed
#     once via its menu; no achievements, trophies only).
# ES-DE's own config lives in ~/ES-DE; the seeds below are written only when
# absent, since ES-DE rewrites them.
let
  hostName = if osConfig == null then "" else osConfig.networking.hostName or "";
  games = "${config.home.homeDirectory}/Games";
  link = config.lib.file.mkOutOfStoreSymlink;

  es-de = pkgs.callPackage ./es-de.nix { };
  shaders = pkgs.callPackage ./retro-crisis.nix { };

  # Retro Crisis ships per-resolution presets; bbstation drives a 4K panel,
  # the thinkpad is 1080p. "Flat" = no screen curvature.
  rcRes = if hostName == "bbstation" then "4K Flat" else "1080p Flat";
  rcPreset = system: "${shaders}/RetroCrisis/retro crisis/${rcRes}/RC GDV-NTSC - ${system} - Clean.slangp";
  # RetroArch auto-loads ~/.config/retroarch/config/<corename>/<corename>.slangp
  # for a core. corename as in the core .info files.
  corePresets = {
    "Snes9x" = "SNES";
    "Genesis Plus GX" = "Master System";
    "mGBA" = "GBA";
    "Gambatte" = "GBA"; # no dedicated Game Boy preset in the pack
    "Beetle PSX HW" = "PlayStation";
    "SwanStation" = "PlayStation";
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
  ];

  programs.retroarch = {
    enable = true;
    cores = {
      snes9x.enable = true;          # SNES
      genesis-plus-gx.enable = true; # Master System (also Game Gear/Mega Drive)
      gambatte.enable = true;        # Game Boy / Color
      mgba.enable = true;            # Game Boy Advance
      beetle-psx-hw.enable = true;   # PlayStation (accurate; default in ES-DE seed)
      swanstation.enable = true;     # PlayStation (DuckStation-based: faster,
                                     # upscaling; pick it in ES-DE under
                                     # Other settings > Alternative emulators > psx)
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
  };

  home.activation.emulationSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    games="${games}"
    run mkdir -p \
      ${lib.concatMapStringsSep " " (s: ''"$games/roms/${s}"'') esSystems} \
      "$games/bios/ps2" "$games/saves/retroarch" "$games/saves/pcsx2" \
      "$games/saves/dolphin/GC" "$games/saves/dolphin/Wii" \
      "$games/saves/rpcs3/savedata" "$games/saves/rpcs3/trophy" \
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
