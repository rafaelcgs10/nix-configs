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

    def handle(p):
        fn = os.path.basename(p)
        if not fn.lower().endswith(EXTS):
            return
        stem = os.path.splitext(fn)[0]
        name = clean(stem)
        base = re.sub(r"\s{2,}", " ", stem).strip()
        had_junk = name != base
        if " - " in name:
            artist, title = (x.strip() for x in name.split(" - ", 1))
        elif had_junk:
            artist, title = None, name
        else:
            return                              # nothing to fix; leave as-is
        try:
            f = File(p, easy=True)
            if f is None:
                return
            if title:
                f["title"] = [title]
            if artist:
                f["artist"] = [artist]
            f.save()
            print("cleaned: %s -> %s / %s" % (fn, artist, title))
        except Exception as e:                  # noqa: BLE001
            sys.stderr.write("skip %s: %s\n" % (fn, e))

    # Accept any mix of files and directories: import-one passes ONE file as each
    # download finishes; the batch path passes the whole inbox directory.
    for arg in sys.argv[1:]:
        if os.path.isfile(arg):
            handle(arg)
        elif os.path.isdir(arg):
            for dp, _, fns in os.walk(arg):
                for fn in fns:
                    handle(os.path.join(dp, fn))
  '';
  # mutagen ships with beets, but expose a small env so the cleaner runs
  # standalone from the import script and the timer's service.
  tagCleanerEnv = pkgs.python3.withPackages (ps: [ ps.mutagen ]);

  # beets embeds synced lyrics INTO each file (USLT/LYRICS tag), which Elisa
  # reads directly — but phones and other players often want a portable ".lrc"
  # sidecar next to the audio. This exporter reads the embedded lyrics and, when
  # they're SYNCED (contain [mm:ss] timestamps), writes "<track>.lrc" beside the
  # file. Idempotent: it skips any track that already has a .lrc, so re-running
  # over the whole library only touches new/changed tracks. Plain (un-timestamped)
  # lyrics are left embedded-only — a sidecar without timings adds nothing.
  lrcSyncPy = pkgs.writeText "lrc-sync.py" ''
    import sys, os, re
    from mutagen import File

    EXTS = (".mp3", ".m4a", ".mp4", ".aac", ".opus", ".flac", ".ogg", ".oga")
    TS = re.compile(r"\[\d{1,2}:\d{2}(?:[.:]\d{1,3})?\]")   # an LRC timestamp

    def lyrics_of(f):
        tags = getattr(f, "tags", None)
        if not tags:
            return None
        keys = list(tags.keys())
        for k in keys:                       # ID3 (un)synced lyrics frame
            if str(k).upper().startswith("USLT"):
                fr = tags[k]
                return str(getattr(fr, "text", fr))
        for k in keys:                       # vorbis LYRICS, mp4 \xa9lyr, etc.
            if "LYR" in str(k).upper():
                v = tags[k]
                if isinstance(v, list):
                    v = v[0] if v else ""
                return str(v)
        return None

    def handle(p):
        if os.path.splitext(p)[1].lower() not in EXTS:
            return
        lrc = os.path.splitext(p)[0] + ".lrc"
        if os.path.exists(lrc):
            return
        try:
            f = File(p)
        except Exception:
            return
        lyr = lyrics_of(f)
        if not lyr or not TS.search(lyr):
            return                           # no synced lyrics -> no sidecar
        try:
            with open(lrc, "w", encoding="utf-8") as out:
                out.write(lyr.strip() + "\n")
            print("lrc: %s" % os.path.basename(lrc))
        except Exception as e:               # noqa: BLE001
            sys.stderr.write("skip %s: %s\n" % (lrc, e))

    for arg in sys.argv[1:] or ["."]:
        if os.path.isfile(arg):
            handle(arg)
        elif os.path.isdir(arg):
            for dp, _, fns in os.walk(arg):
                for fn in fns:
                    handle(os.path.join(dp, fn))
  '';

  # `music-lrc-sync [path]` — export .lrc sidecars for a file/dir (default: the
  # whole library). Wired into both import paths so new tracks get a sidecar.
  lrcSync = pkgs.writeShellScriptBin "music-lrc-sync" ''
    set -eu
    root="''${1:-${musicDir}}"
    [ -e "$root" ] || exit 0
    ${tagCleanerEnv}/bin/python ${lrcSyncPy} "$root"
  '';

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
    # Export .lrc lyric sidecars for anything newly organized.
    ${lrcSync}/bin/music-lrc-sync "${musicDir}" || true
  '';

  # `music-import-one <file>` — import a SINGLE just-downloaded track. music-dl
  # wires this into yt-dlp's --exec hook so each track is cleaned, matched and
  # moved into the library the moment its download finishes, rather than waiting
  # for the whole playlist. Best-effort (|| true): a track beets can't handle is
  # left in the inbox for the final `music-import -q` sweep to mop up. PATH is set
  # explicitly because yt-dlp's --exec environment may lack fpcalc/ffmpeg.
  musicImportOne = pkgs.writeShellScriptBin "music-import-one" ''
    set -eu
    export PATH=${lib.makeBinPath [ pkgs.beets pkgs.chromaprint pkgs.ffmpeg ]}:$PATH
    f="''${1:-}"
    [ -f "$f" ] || exit 0
    ${tagCleanerEnv}/bin/python ${tagCleanerPy} "$f" || true
    ${pkgs.beets}/bin/beet import -q -s "$f" || true
    # Export a .lrc lyric sidecar for the track just organized.
    ${lrcSync}/bin/music-lrc-sync "${musicDir}" || true
  '';

  # `music-dl <url>...` — ONE command that downloads AND organizes. It fetches
  # audio with yt-dlp into ~/Music/inbox and, via yt-dlp's --exec hook, imports
  # each track (tag-clean → MusicBrainz match → art/lyrics/replaygain → move into
  # the library) THE MOMENT its download finishes — so on a long playlist tracks
  # land in ~/Music/… incrementally instead of all at the end. A final sweep mops
  # up. Handles single videos, playlists and albums (yt-dlp recurses).
  #
  # It replaces the flaky Parabolic GUI, which freezes/crashes and aborts a whole
  # PLAYLIST on one dead entry. Robustness knobs: --ignore-errors/--no-abort-on-
  # error (skip a dead entry, keep going), --download-archive (re-run to resume a
  # partial playlist and skip what's already organized), --continue/--retries. It
  # also skips items longer than MUSIC_DL_MAX_SECS (default 2 h; --no-limit or
  # MUSIC_DL_MAX_SECS=0 disables it) and collapses endless YouTube radio mixes
  # (list=RD…) to just their seed track — see below.
  #
  # YouTube now 403s ANONYMOUS media requests (the mid-2026 "PO token" wall), so
  # yt-dlp authenticates using the logged-in LibreWolf profile's cookies — the
  # one reliable user-side bypass (a newer yt-dlp does NOT help; even the current
  # release 403s without cookies). YouTube also ROTATES those cookies mid-batch,
  # invalidating yt-dlp's snapshot; the download loop handles that by re-reading
  # the browser's fresh cookies and resuming (see below). This is BEST-EFFORT: if
  # no browser profile is found we still attempt the download anonymously (and say
  # so) rather than failing outright — plenty of non-YouTube sources need no auth.
  # Override with MUSIC_DL_COOKIES = a cookies.txt path OR a --cookies-from-browser
  # spec (e.g. MUSIC_DL_COOKIES=chromium or firefox:/path/to/profile).
  musicDl = pkgs.writeShellScriptBin "music-dl" ''
    set -eu
    inbox="${inboxDir}"
    data="${beetsData}"
    mkdir -p "$inbox" "$data"

    # Pull music-dl's own flags out of the argument list; everything else is a URL
    # for yt-dlp. --no-limit (aliases -A / --full) drops the max-duration filter
    # for this run, so items of ANY length download.
    no_limit=0
    urls=()
    for a in "$@"; do
      case "$a" in
        --no-limit|--full|-A) no_limit=1 ;;
        *) urls+=("$a") ;;
      esac
    done
    set -- "''${urls[@]}"

    if [ "$#" -lt 1 ]; then
      echo "usage: music-dl [--no-limit] <url> [url...]   # download + organize into ~/Music" >&2
      echo "       --no-limit (-A, --full)   download items of any length (ignore the max-duration filter)" >&2
      exit 2
    fi

    # Choose a cookie source so authenticated requests clear YouTube's 403 wall.
    # Preference: explicit override > an exported cookies.txt > LibreWolf profile
    # > anonymous. A cookies.txt is the ROBUST option: YouTube ROTATES and
    # invalidates cookies read live from a logged-in browser (yt-dlp then 403s
    # partway through a batch, warning "cookies are no longer valid"), whereas a
    # file exported from a PRIVATE window that is then closed stays valid. See the
    # yt-dlp wiki "Exporting YouTube cookies" and drop the file at $cookie_file.
    # MUSIC_DL_COOKIES may be a cookies.txt path OR a --cookies-from-browser spec.
    cookie_args=()
    cookie_file="${config.home.homeDirectory}/.config/yt-dlp/cookies.txt"
    librewolf="${config.home.homeDirectory}/.librewolf"
    if [ -n "''${MUSIC_DL_COOKIES:-}" ]; then
      if [ -f "''${MUSIC_DL_COOKIES}" ]; then
        cookie_args=(--cookies "''${MUSIC_DL_COOKIES}")
      else
        cookie_args=(--cookies-from-browser "''${MUSIC_DL_COOKIES}")
      fi
      echo "music-dl: using cookies from ''${MUSIC_DL_COOKIES}"
    elif [ -f "$cookie_file" ]; then
      cookie_args=(--cookies "$cookie_file")
      echo "music-dl: using exported cookies file ($cookie_file)"
    elif [ -d "$librewolf" ]; then
      cookie_args=(--cookies-from-browser "firefox:$librewolf")
      echo "music-dl: authenticating with LibreWolf cookies ($librewolf). If YouTube rotates them mid-batch, the download loop below re-reads fresh cookies and resumes automatically — keep LibreWolf open and logged in. (For a hands-off setup, drop a cookies.txt at $cookie_file.)"
    else
      echo "music-dl: WARNING no cookies — downloading anonymously; YouTube may return HTTP 403. Provide $cookie_file or set MUSIC_DL_COOKIES." >&2
    fi

    # Skip over-long items — 10-hour lofi streams / endless DJ sets aren't what
    # this tool is for and each eats hundreds of MB. Default ceiling 2 hours,
    # overridable with MUSIC_DL_MAX_SECS (0 disables it); --no-limit disables it
    # for a single run.
    max_secs="''${MUSIC_DL_MAX_SECS:-7200}"
    case "$max_secs" in ""|*[!0-9]*) max_secs=7200 ;; esac
    if [ "$no_limit" -eq 1 ]; then
      max_secs=0
      echo "music-dl: --no-limit set — downloading items of any length."
    fi
    filter_args=()
    if [ "$max_secs" -gt 0 ]; then
      filter_args=(--match-filter "duration < $max_secs")
    fi

    # YouTube "radio" mixes (list=RD…, start_radio=1) are auto-generated and
    # effectively endless — this one expanded to 2065 items. Grab only the seed
    # track from those. Real playlists (list=PL…, albums, channels) download full.
    pl_args=()
    case " $* " in
      *"list=RD"*|*"start_radio=1"*)
        pl_args=(--no-playlist)
        echo "music-dl: YouTube radio/mix detected — downloading only the seed track, not the endless mix." >&2
        ;;
    esac

    # Download with automatic recovery from cookie rotation. YouTube periodically
    # rotates the account cookies in the browser as a security measure, which
    # invalidates the snapshot yt-dlp read at startup — the rest of a long batch
    # then 403s. But the BROWSER now holds the fresh, valid cookies, so we just
    # re-run: --cookies-from-browser re-reads them, and --download-archive makes
    # the rerun skip everything already fetched and resume where it stopped. Loop
    # until a clean run, or until a whole attempt downloads NOTHING new (genuinely
    # dead cookies / network / all-unavailable — no point spinning). "$@" and the
    # arg arrays expand to zero words when empty (bash [@] rule).
    archive="$data/yt-dlp-archive.txt"
    attempt=0
    max_attempts=8
    while :; do
      attempt=$((attempt + 1))
      before=$(${pkgs.coreutils}/bin/wc -l < "$archive" 2>/dev/null || echo 0)

      set +e
      ${pkgs.yt-dlp}/bin/yt-dlp \
        "''${cookie_args[@]}" \
        "''${filter_args[@]}" \
        "''${pl_args[@]}" \
        --ignore-errors \
        --no-abort-on-error \
        --continue \
        --retries 10 \
        --fragment-retries 10 \
        --concurrent-fragments 4 \
        --download-archive "$archive" \
        --ffmpeg-location ${pkgs.ffmpeg}/bin \
        --extract-audio \
        --audio-quality 0 \
        --embed-thumbnail \
        --embed-metadata \
        --paths "$inbox" \
        --output "%(title)s.%(ext)s" \
        --exec "after_move:${musicImportOne}/bin/music-import-one %(filepath)q" \
        "$@"
      rc=$?
      set -e

      # rc 0 = yt-dlp finished with no errors → done.
      if [ "$rc" -eq 0 ]; then
        break
      fi

      after=$(${pkgs.coreutils}/bin/wc -l < "$archive" 2>/dev/null || echo 0)
      if [ "$attempt" -ge "$max_attempts" ]; then
        echo "music-dl: still failing after $attempt attempts — stopping (already-downloaded tracks are kept; rerun later to resume)." >&2
        break
      fi
      if [ "$after" -gt "$before" ]; then
        # Progress was made, then it broke → classic mid-batch cookie rotation.
        # Pause a moment for the browser to settle, then resume with fresh cookies.
        got=$((after - before))
        echo "music-dl: attempt $attempt downloaded $got track(s) then failed (likely YouTube rotated the cookies). Re-reading fresh cookies and resuming…" >&2
        ${pkgs.coreutils}/bin/sleep 5
        continue
      fi
      # No progress at all this attempt.
      if [ "$attempt" -ge 2 ]; then
        echo "music-dl: no tracks downloaded across $attempt attempts — the cookies are probably invalid. Log into YouTube in LibreWolf, or provide $cookie_file (see the cookies.txt note above)." >&2
        break
      fi
      echo "music-dl: first attempt failed with no downloads; re-reading cookies and retrying once…" >&2
      ${pkgs.coreutils}/bin/sleep 5
    done

    # Each track was already imported as it finished (the --exec hook above), so
    # this final pass just mops up: import any straggler beets couldn't take
    # mid-download and drain leftover thumbnails/cruft from failed entries.
    exec ${musicImport}/bin/music-import -q
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
  home.packages = [ pkgs.beets pkgs.chromaprint pkgs.ffmpeg pkgs.yt-dlp musicImport musicImportOne musicDl lrcSync ];

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
