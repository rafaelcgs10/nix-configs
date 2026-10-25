# RetroArch shader directory: the libretro slang shader library plus the
# Retro Crisis GDV-NTSC CRT presets (built on crt-guest-advanced-ntsc).
# The Retro Crisis presets reference the base shaders as
# "../../../shaders_slang/...", i.e. three levels up from
# "<res> Flat/", so the pack must sit exactly one directory below the shader
# root next to shaders_slang/. Layout produced here:
#   $out/shaders_slang/            (nixpkgs libretro-shaders-slang)
#   $out/RetroCrisis/retro crisis/<720p Steam Deck|1080p|1440p|4K> <Flat|Curved>/*.slangp
#   $out/RetroCrisis/fast/<same>/*.slangp   (generated, see below)
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

  # "fast" variants: the same presets' parameters (mask, scanlines, bloom,
  # geometry, colour) on crt-guest-advanced-fast, the 9-pass chain without
  # the NTSC passes. Each resolution preset is a few parameter lines over a
  # 4K full preset, so: reference the fast chain, then the 4K preset's
  # parameter lines (pass/texture/scale lines dropped; names the fast chain
  # lacks are ignored by RetroArch), then the resolution preset's own lines.
  # Used for cores on the OpenGL path, where the NTSC chain costs ~8 ms.
  fast="$out/shaders_slang/crt/crt-guest-advanced-fast.slangp"
  skip='^(#|$|shaders|shader[0-9]|scale|filter_linear|float_framebuffer|srgb_framebuffer|wrap_mode|mipmap|alias|textures|SamplerLUT|frame_count_mod)'
  for dir in "$out/RetroCrisis/retro crisis"/*/; do
    res=$(basename "$dir")
    mkdir -p "$out/RetroCrisis/fast/$res"
    for f in "$dir"*.slangp; do
      # Follow the #reference chain (Curved -> Flat -> 4K); base first.
      chain=(); cur="$f"; ok=1
      while :; do
        chain=("$cur" "''${chain[@]}")
        ref=$(sed -n 's/^#reference "\(.*\)"$/\1/p' "$cur" | head -n1)
        [ -z "$ref" ] && break
        cur="$(dirname "$cur")/$ref"
        if [ ! -e "$cur" ]; then echo "fast variant skipped, broken reference: $f -> $ref" >&2; ok=0; break; fi
      done
      [ "$ok" = 1 ] || continue
      {
        echo "#reference \"$fast\""
        for c in "''${chain[@]}"; do grep -vE "$skip" "$c" || true; done
      } > "$out/RetroCrisis/fast/$res/$(basename "$f")"
    done
  done
''
