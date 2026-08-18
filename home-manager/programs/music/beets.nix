{ config, lib, pkgs, osConfig ? null, ... }:

# beets — the music library manager that keeps ~/Music organized and tagged.
# Parabolic (yt-dlp) downloads into a dedicated STAGING folder, ~/Music/inbox
# (single tracks land loose; playlists land in per-playlist subfolders). beets
# imports the inbox RECURSIVELY, fingerprints (AcoustID/chroma), matches against
# MusicBrainz, embeds art/lyrics/replaygain, and MOVES each track OUT of the
# inbox into ~/Music/<AlbumArtist>/<Album>/… (singles → ~/Music/Singles/…).
#
# Why a separate inbox rather than importing ~/Music directly: if the download
# folder and the organized library are the same directory, `beet import`
# re-walks its own moved output every run (the move destinations aren't in
# beets' incremental history), re-fingerprinting everything endlessly. Keeping
# the inbox separate means the import source empties as tracks are organized, so
# nothing is ever analyzed twice.
#
# The library database lives OUTSIDE ~/Music (in ~/.local/share/beets) on
# purpose: it is a SQLite DB and must never be Syncthing-shared — only the
# organized audio files under ~/Music are. Each machine keeps its own beets DB.
#
# Auto-import (the systemd timer+service below) runs on bbstation only, so a
# single machine owns the "move/rename" side and Syncthing just propagates the
# result; other machines can still run `beet import` by hand via the aliases.
let
  hostName = if osConfig == null then "" else osConfig.networking.hostName or "";
  isBbstation = hostName == "bbstation";
  musicDir = "${config.home.homeDirectory}/Music";
  inboxDir = "${musicDir}/inbox";
  beetsData = "${config.home.homeDirectory}/.local/share/beets";

  # yt-dlp writes the whole YouTube video title into the file's title tag
  # ("New Slang [OFFICIAL VIDEO]", "Ghost Town [Official HD Remastered Video]"),
  # and the uploader/channel into the artist tag ("SubPopRecords", "… - Topic").
  # That promo junk inflates beets' string distance so a CORRECT MusicBrainz
  # match scores "medium" instead of "strong" — and quiet mode only auto-applies
  # STRONG matches, so the track is silently dumped as `asis` (untagged). This
  # pre-import pass rewrites title/artist from the (cleaned) filename so matching
  # sees "The Shins" / "New Slang", not the video title. It runs over the inbox
  # right before `beet import`. Conservative: it only rewrites a file when the
  # name has a clear "Artist - Title" split or when it actually stripped junk —
  # otherwise the file is left untouched, so already-clean tags aren't clobbered.
  tagCleanerPy = pkgs.writeText "clean-inbox-tags.py" ''
    import sys, os, re
    from mutagen import File

    # Bracketed/parenthesised promo noise that never helps a catalog match.
    JUNK = re.compile(
        r"\s*[\(\[]\s*("
        r"official(\s+(music\s+)?video|\s+audio|\s+lyrics?(\s+video)?)?"
        r"|lyrics?(\s+video)?|audio|visuali[sz]er|video|hd|4k|hq"
        r"|remaster(ed)?(\s+\d{4})?|\d{4}\s+remaster|explicit|clean"
        r"|full\s+album|enhanced[^)\]]*|promo[^)\]]*|colou?r\s+coded[^)\]]*"
        r")\s*[\)\]]", re.I)

    EXTS = (".mp3", ".m4a", ".opus", ".flac", ".ogg", ".oga", ".webm")

    def clean(stem):
        n = JUNK.sub("", stem)
        n = re.sub(r"\s*\|\s*.*$", "", n)      # drop "| Stages"-style tails
        n = re.sub(r"\s{2,}", " ", n).strip(" -_")
        return n

    root = sys.argv[1]
    for dp, _, fns in os.walk(root):
        for fn in fns:
            if not fn.lower().endswith(EXTS):
                continue
            stem = os.path.splitext(fn)[0]
            name = clean(stem)
            base = re.sub(r"\s{2,}", " ", stem).strip()
            had_junk = name != base
            if " - " in name:
                artist, title = (x.strip() for x in name.split(" - ", 1))
            elif had_junk:
                artist, title = None, name
            else:
                continue                        # nothing to fix; leave as-is
            p = os.path.join(dp, fn)
            try:
                f = File(p, easy=True)
                if f is None:
                    continue
                if title:
                    f["title"] = [title]
                if artist:
                    f["artist"] = [artist]
                f.save()
                print("cleaned: %s -> %s / %s" % (fn, artist, title))
            except Exception as e:                # noqa: BLE001
                sys.stderr.write("skip %s: %s\n" % (fn, e))
  '';
  # mutagen ships with beets, but expose a small env so the cleaner runs
  # standalone from the import script and the timer's service.
  tagCleanerEnv = pkgs.python3.withPackages (ps: [ ps.mutagen ]);

  # The `music-import` command (also used by the timer).
  #   music-import        interactive: review each match, no cleanup.
  #   music-import -q      hands-off: auto-accept / import-as-is, then DELETE
  #                        whatever remains in the inbox. After a quiet import
  #                        with quiet_fallback=asis, beets has imported+moved
  #                        every track it could — so anything left is a track
  #                        already in the library (a re-downloaded duplicate) or
  #                        non-audio cruft (thumbnails, .json). Clearing it drains
  #                        the inbox so duplicates aren't re-examined next run.
  # Cleanup runs ONLY in -q mode and ONLY if the import exited 0 (set -e), so a
  # Ctrl-C or error never deletes anything, and interactively-skipped tracks
  # (which may be deliberate) are preserved.
  musicImport = pkgs.writeShellScriptBin "music-import" ''
    set -eu
    inbox="${inboxDir}"
    [ -d "$inbox" ] || exit 0
    quiet=""
    [ "''${1:-}" = "-q" ] && quiet="-q"
    # Clean yt-dlp's polluted title/artist tags so beets can actually match.
    ${tagCleanerEnv}/bin/python ${tagCleanerPy} "$inbox" || true
    ${pkgs.beets}/bin/beet import $quiet -s "$inbox"
    if [ -n "$quiet" ]; then
      ${pkgs.findutils}/bin/find "$inbox" -mindepth 1 -type f -delete
      ${pkgs.findutils}/bin/find "$inbox" -mindepth 1 -type d -empty -delete
    fi
  '';

  # `music-dl <url>...` — a robust, headless replacement for the Parabolic GUI.
  # Parabolic (a GTK front-end over this same yt-dlp) tends to freeze/crash and,
  # worst of all, aborts a whole PLAYLIST when one entry is deleted/geo-blocked/
  # private — so you silently lose the rest. This wrapper drives yt-dlp directly
  # into the SAME ~/Music/inbox staging folder beets watches, so the downstream
  # pipeline is identical; only the front-end changes. The robustness knobs:
  #   --ignore-errors / --no-abort-on-error  a dead entry is skipped, not fatal —
  #                        the rest of the playlist still downloads.
  #   --download-archive   records every completed video id; re-running the same
  #                        playlist URL grabs only what's still missing (resume a
  #                        flaky download) and never re-fetches what beets already
  #                        organized. Delete a line to force a re-download.
  #   --continue / --retries / --fragment-retries  survive dropped connections.
  # Audio is extracted WITHOUT re-encoding (native opus/m4a → best quality), with
  # the thumbnail and source metadata embedded as a fallback for beets. Files land
  # flat in the inbox named "%(title)s.ext"; the tag-cleaner + beets do the rest.
  musicDl = pkgs.writeShellScriptBin "music-dl" ''
    set -eu
    inbox="${inboxDir}"
    data="${beetsData}"
    mkdir -p "$inbox" "$data"
    if [ "$#" -lt 1 ]; then
      echo "usage: music-dl <url> [url...]   # downloads audio into ${inboxDir}" >&2
      exit 2
    fi
    exec ${pkgs.yt-dlp}/bin/yt-dlp \
      --ignore-errors \
      --no-abort-on-error \
      --continue \
      --retries 10 \
      --fragment-retries 10 \
      --concurrent-fragments 4 \
      --download-archive "$data/yt-dlp-archive.txt" \
      --ffmpeg-location ${pkgs.ffmpeg}/bin \
      --extract-audio \
      --audio-quality 0 \
      --embed-thumbnail \
      --embed-metadata \
      --paths "$inbox" \
      --output "%(title)s.%(ext)s" \
      "$@"
  '';

  # The timer's entry point: import only once the inbox has settled (nothing
  # touched for 5 min = no download in flight), then run the hands-off
  # import+cleanup. Playlist subfolders are handled (beet imports recursively).
  autoImport = pkgs.writeShellScript "beets-autoimport" ''
    set -eu
    inbox="${inboxDir}"
    [ -d "$inbox" ] || exit 0
    [ -n "$(${pkgs.coreutils}/bin/ls -A "$inbox" 2>/dev/null)" ] || exit 0
    if ${pkgs.findutils}/bin/find "$inbox" -type f -mmin -5 | ${pkgs.gnugrep}/bin/grep -q .; then
      exit 0
    fi
    exec ${musicImport}/bin/music-import -q
  '';
in
{
  # fpcalc (from chromaprint) is the fingerprinter the `chroma` plugin shells out
  # to, and ffmpeg is the `replaygain` loudness backend — both must be on PATH
  # for interactive and automated import.
  home.packages = [ pkgs.beets pkgs.chromaprint pkgs.ffmpeg pkgs.yt-dlp musicImport musicDl ];

  programs.beets = {
    enable = true;
    package = pkgs.beets;
    settings = {
      directory = musicDir;
      library = "${beetsData}/library.db";

      # Organize into a clean, player-friendly tree. %aunique{} disambiguates
      # same-named albums; singles/compilations get their own top-level folders.
      paths = {
        default = "$albumartist/$album%aunique{}/$track $title";
        singleton = "Singles/$artist/$title";
        comp = "Compilations/$album%aunique{}/$track $title";
      };

      import = {
        move = true;        # move out of the inbox into the organized tree
        write = true;       # write corrected tags back into the file
        resume = true;
        incremental = true; # remember imported dirs, skip them next run
        # Fully hands-off in -q (quiet) mode: auto-accept strong MusicBrainz/
        # AcoustID matches, and for anything without a strong match, import it
        # "as-is" (keep yt-dlp's tags) and still organize it — never skip.
        quiet_fallback = "asis";
        log = "${beetsData}/import.log";
      };

      # Since beets 2.0 MusicBrainz is an opt-in plugin, not always-on core — it
      # MUST be listed or nothing matches. `chroma` (AcoustID fingerprinting)
      # only produces candidates when `musicbrainz` is on, and rescues rips
      # whose durations differ from the release. Matching is tuned to accept:
      #   strong_rec_thresh 0.20  auto-accept medium-strength matches in -q
      #                           (default 0.04). Raised from 0.10: yt-dlp rips
      #                           of a slightly different edit/remaster land in
      #                           the 0.10-0.20 band, and with the tag cleaner
      #                           feeding clean artist/title + AcoustID backing,
      #                           these are almost always the right recording —
      #                           so auto-apply them instead of dumping to asis.
      #   track_length 0.3        a padded duration shouldn't sink a clear match
      match = {
        strong_rec_thresh = 0.20;
        medium_rec_thresh = 0.30;
        distance_weights.track_length = 0.3;
      };

      plugins = "musicbrainz chroma fetchart embedart lyrics lastgenre scrub replaygain duplicates";

      # Everything below is written INTO the file tags (import.write = true), so
      # Strawberry/Elisa and any other player read it directly — nothing is
      # locked in a beets-only store. Cover art is also saved as a per-album file
      # for folder thumbnails.
      fetchart = {
        auto = true;
        maxwidth = 1200;
        cover_names = "cover front folder album";
      };
      embedart.auto = true;

      lastgenre = {
        auto = true;
        count = 3;
      };

      lyrics = {
        auto = true;
        synced = true;
        # LRCLIB only: free, no API key, no rate limits, and the source that
        # provides synced lyrics. Genius throttles every request with HTTP 429.
        sources = "lrclib";
      };

      replaygain = {
        auto = true;
        backend = "ffmpeg";
      };
    };
  };

  home.shellAliases = {
    # `music-dl <url>...` (installed above) is the robust downloader that replaces
    # the Parabolic GUI — it writes into the same inbox beets watches.
    # `music-import` (interactive, no delete) is the command installed above.
    # `music-import-auto` is the hands-off variant: import + drain the inbox
    # (delete already-in-library duplicates and cruft). `music-inbox` lists it.
    music-import-auto = "music-import -q";
    music-inbox = "ls -la ${inboxDir}";
  };

  # Make sure the inbox exists so Parabolic can write downloads into it.
  home.activation.ensureMusicInbox = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${inboxDir}
  '';

  # bbstation owns automatic import: a timer ticks every 10 minutes and the
  # service imports only a settled inbox (nothing touched for 5 min).
  systemd.user.services.beets-autoimport = lib.mkIf isBbstation {
    Unit.Description = "Import & organize settled downloads from ~/Music/inbox via beets";
    Service = {
      Type = "oneshot";
      # beet shells out to fpcalc (chromaprint) and ffmpeg (replaygain).
      Environment = [ "PATH=${lib.makeBinPath [ pkgs.beets pkgs.chromaprint pkgs.ffmpeg ]}" ];
      ExecStart = "${autoImport}";
    };
  };

  systemd.user.timers.beets-autoimport = lib.mkIf isBbstation {
    Unit.Description = "Periodically import settled ~/Music/inbox downloads";
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "10min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
