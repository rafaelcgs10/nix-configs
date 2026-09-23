{ pkgs, ... }:

# Freedesktop thumbnailer for camera RAW files.
#
# Why this exists: nothing in nixpkgs ships a .thumbnailer covering CR3, so
# RAW files get a generic icon. `xdg-mime query filetype` reports
# image/x-canon-cr3 and no installed .thumbnailer claims that type — gdk-pixbuf
# lists only ordinary image formats, ffmpegthumbnailer only video/* and
# application/*. (Handed a CR3 manually, ffmpegthumbnailer does read ~5MB and
# then fail with "Video Codec not found", but nothing routes CR3 to it.)
#
# So this is an enhancement, not a hang fix: it buys RAW previews at a cost of
# ~5MB read per file on first sight, once, after which the file manager's
# thumbnail cache serves it. Worth knowing before pointing a file manager at a
# few thousand RAWs over wifi for the first time.
#
# nufraw-thumbnailer is the packaged alternative but its dcraw fork cannot
# decode CR3 (verified: exits 0, produces no output), so it is not a substitute.
#
# Approach: lift the JPEG preview the camera already embedded, rather than
# demosaicing. Measured on a 23MB CR3, bytes read to produce one thumbnail:
#
#   exiftool -b -PreviewImage        28.4 MB   1.47s
#   exiftool -fast2                   8.3 MB   0.53s
#   libraw simple_dcraw -e            4.8 MB   0.02s   <- preferred
#
# That read volume is what crosses the wifi for files on the SMB share, so it
# is the number that matters most here.
let
  rawThumbnailer = pkgs.writeShellApplication {
    name = "raw-thumbnailer";
    runtimeInputs = with pkgs; [ coreutils libraw exiftool imagemagick ];
    text = ''
      size="$1"
      input="$2"
      output="$3"

      tmpd="$(mktemp -d)"
      trap 'rm -rf "$tmpd"' EXIT

      render() {
        magick "$1" -auto-orient -thumbnail "''${size}x''${size}" -strip "png:$output"
      }

      # simple_dcraw always writes beside its input as <input>.thumb.<ext>, with
      # no stdout mode. Feeding it a symlink in a temp dir keeps that write off
      # the source directory — verified it does not follow through to the real
      # path, which matters because these files live on a read-mostly SMB share.
      ln -s "$input" "$tmpd/in.raw"
      if simple_dcraw -e "$tmpd/in.raw" >/dev/null 2>&1; then
        # Extension varies: JPEG-backed previews land as .thumb.jpg, a few
        # bodies embed PPM instead.
        for thumb in "$tmpd"/in.raw.thumb.*; do
          if [ -s "$thumb" ]; then
            render "$thumb"
            exit 0
          fi
        done
      fi

      # Fallback for anything libraw will not open. -fast2 stops exiftool from
      # scanning the whole file to find the tag (28MB -> 8MB on CR3).
      for tag in PreviewImage JpgFromRaw ThumbnailImage; do
        if exiftool -b "-$tag" -fast2 "$input" > "$tmpd/preview" 2>/dev/null \
          && [ -s "$tmpd/preview" ]; then
          render "$tmpd/preview"
          exit 0
        fi
      done

      exit 1
    '';
  };

  # Canon first (CR3/CR2/CRW), then the other bodies' formats so this stays
  # useful for anything that lands in the photo folders.
  mimeTypes = [
    "image/x-canon-cr3"
    "image/x-canon-cr2"
    "image/x-canon-crw"
    "image/x-adobe-dng"
    "image/x-nikon-nef"
    "image/x-nikon-nrw"
    "image/x-sony-arw"
    "image/x-fuji-raf"
    "image/x-panasonic-rw2"
    "image/x-olympus-orf"
    "image/x-pentax-pef"
  ];

  rawThumbnailerEntry = pkgs.writeTextDir "share/thumbnailers/raw.thumbnailer" ''
    [Thumbnailer Entry]
    TryExec=${rawThumbnailer}/bin/raw-thumbnailer
    Exec=${rawThumbnailer}/bin/raw-thumbnailer %s %i %o
    MimeType=${builtins.concatStringsSep ";" mimeTypes};
  '';
in
{
  home.packages = [
    rawThumbnailer
    rawThumbnailerEntry
  ];
}
