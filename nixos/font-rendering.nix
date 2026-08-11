# macOS-leaning font rendering for the COSMIC desktops (bbstation,
# thinkpad-e14). Imported per-host from flake.nix, like io-performance.nix —
# intentionally NOT in the shared configuration.nix so bbtablet (GNOME) keeps
# its defaults.
#
# The approach mirrors what makes macOS text look good on Linux-reachable
# hardware: grayscale antialiasing (no RGB subpixel — macOS dropped it in
# Mojave, and it fringes under COSMIC's fractional scaling), slight hinting
# that preserves the typeface's true shapes instead of snapping stems to the
# pixel grid, and FreeType stem darkening so light text doesn't look spindly
# the way un-darkened linear-alpha rendering does.
{ pkgs, ... }:

{
  fonts = {
    # DejaVu & friends as a sane fallback baseline.
    enableDefaultPackages = true;

    packages = [
      pkgs.inter # UI font: designed for screens, the closest FOSS analog to SF
      pkgs.noto-fonts # broad Unicode coverage fallback
      pkgs.noto-fonts-color-emoji
    ];

    fontconfig = {
      antialias = true;

      # Slight hinting = keep the designed glyph shapes (macOS philosophy);
      # full hinting would distort them for sharpness we don't need at these
      # pixel densities (4K@150% on bbstation, 157ppi panel on thinkpad-e14).
      hinting = {
        enable = true;
        style = "slight";
      };

      # Grayscale AA, like modern macOS (and GTK4, which ignores subpixel
      # anyway). RGB subpixel would fringe under fractional scaling and on
      # anything that rotates or screenshots text.
      subpixel = {
        rgba = "none";
        lcdfilter = "none";
      };

      defaultFonts = {
        sansSerif = [ "Inter" "Noto Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
        # monospace ("Hack Nerd Font Mono") stays in configuration.nix — it
        # applies to every host, including bbtablet.
      };
    };
  };

  # FreeType stem darkening: emulates macOS "font smoothing", thickening thin
  # stems so grayscale-AA text at these densities reads even instead of faint.
  # (FreeType leaves it off by default everywhere except the CFF engine.)
  environment.variables.FREETYPE_PROPERTIES =
    "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0 type1:no-stem-darkening=0 t1cid:no-stem-darkening=0";
}
