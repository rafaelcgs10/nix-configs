# RetroArch shader directory: the libretro slang shader library plus the
# Retro Crisis GDV-NTSC CRT presets (built on crt-guest-advanced-ntsc).
# The Retro Crisis presets reference the base shaders as
# "../../../shaders_slang/...", i.e. three levels up from
# "<res> Flat/", so the pack must sit exactly one directory below the shader
# root next to shaders_slang/. Layout produced here:
#   $out/shaders_slang/            (nixpkgs libretro-shaders-slang)
#   $out/RetroCrisis/retro crisis/<720p Steam Deck|1080p|1440p|4K> <Flat|Curved>/*.slangp
#
# Update: new zip from https://github.com/RetroCrisis/Retro-Crisis-GDV-NTSC/releases,
# then `nix hash file <zip>`.
{ runCommand, fetchurl, unzip, libretro-shaders-slang }:
let
  version = "2026.09.27";
  pack = fetchurl {
    url = "https://github.com/RetroCrisis/Retro-Crisis-GDV-NTSC/releases/download/20260927/Retro.Crisis.GDV-NTSC.${version}.zip";
    hash = "sha256-l/isWwRu/L1jMjqVRMAyVcwEQ2B7Cw2A58kE3JSfM+c=";
  };
in
runCommand "retroarch-shaders-retro-crisis-${version}" { nativeBuildInputs = [ unzip ]; } ''
  mkdir -p "$out/RetroCrisis"
  ln -s ${libretro-shaders-slang}/share/libretro/shaders/shaders_slang "$out/shaders_slang"
  unzip -q ${pack} -d tmp -x '__MACOSX/*' '*/.DS_Store'
  mv "tmp/retro crisis" "$out/RetroCrisis/retro crisis"
''
