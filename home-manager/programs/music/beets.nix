{ config, lib, pkgs, osConfig ? null, ... }:

# beets — the music library manager that keeps ~/Music organized and tagged.
# Parabolic (yt-dlp) downloads land as loose files directly in ~/Music; beets
# fingerprints them (AcoustID/chroma), matches against MusicBrainz, fetches
# cover art, and MOVES each into ~/Music/<AlbumArtist>/<Album>/… . Only the
# loose top-level files are imported each run, so the already-organized subtree
# is never needlessly re-scanned.
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
  beetsData = "${config.home.homeDirectory}/.local/share/beets";

  # The automated importer. Parabolic drops loose files into ~/Music, then yt-dlp
  # post-processes them (extract audio, embed tags/art). So: (1) if anything at
  # the top level changed in the last 5 min a download is still in flight — wait
  # for the next tick; (2) otherwise singleton-import ONLY the loose top-level
  # audio files (organized tracks already live in subfolders and stay put).
  autoImport = pkgs.writeShellScript "beets-autoimport" ''
    set -eu
    music="${musicDir}"
    [ -d "$music" ] || exit 0
    # A download may still be writing — bail if the top level changed recently.
    if ${pkgs.findutils}/bin/find "$music" -maxdepth 1 -type f -mmin -5 | ${pkgs.gnugrep}/bin/grep -q .; then
      exit 0
    fi
    # Import just the loose top-level audio files (--no-run-if-empty = no-op when none).
    ${pkgs.findutils}/bin/find "$music" -maxdepth 1 -type f \
      \( -iname '*.mp3' -o -iname '*.m4a' -o -iname '*.opus' -o -iname '*.flac' \
         -o -iname '*.ogg' -o -iname '*.webm' -o -iname '*.aac' -o -iname '*.wav' \) \
      -print0 | ${pkgs.findutils}/bin/xargs -0 --no-run-if-empty ${pkgs.beets}/bin/beet import -qs
  '';
in
{
  # fpcalc (from chromaprint) is the fingerprinter the `chroma` plugin shells out
  # to, and ffmpeg is the `replaygain` loudness backend — both must be on PATH
  # for interactive and automated import.
  home.packages = [ pkgs.beets pkgs.chromaprint pkgs.ffmpeg ];

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
        move = true;        # move the loose file into the organized tree
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
      #   strong_rec_thresh 0.10  auto-accept looser matches in -q (default 0.04)
      #   track_length 0.3        a padded duration shouldn't sink a clear match
      match = {
        strong_rec_thresh = 0.10;
        medium_rec_thresh = 0.30;
        distance_weights.track_length = 0.3;
      };

      plugins = "musicbrainz chroma fetchart embedart lyrics lastgenre scrub replaygain duplicates";

      # Everything below is written INTO the file tags (import.write = true above),
      # so Strawberry and any other player read it directly — nothing is locked in
      # a beets-only store. Cover art is additionally saved as a per-album cover
      # file, which players also use for folder thumbnails.
      fetchart = {
        auto = true;
        maxwidth = 1200;                     # fetch large art, then embed/store
        cover_names = "cover front folder album";
      };
      embedart.auto = true;                  # embed the art into each track

      lastgenre = {
        auto = true;
        count = 3;                           # up to 3 genres
      };

      lyrics = {
        auto = true;
        synced = true;                       # prefer time-synced (LRC) lyrics from
                                             # LRCLIB — Strawberry shows these as a
                                             # scrolling/karaoke view. Embedded in
                                             # the file's lyrics tag on write.
        # LRCLIB only: free, no API key, no rate limits, and the source that
        # actually provides synced lyrics. Genius was dropped — without a paid
        # API key it throttles every request with HTTP 429.
        sources = "lrclib";
      };

      # Loudness normalization tags (ReplayGain), computed via ffmpeg's ebur128.
      # Strawberry (and most players) use these to even out volume across tracks.
      replaygain = {
        auto = true;
        backend = "ffmpeg";
      };
    };
  };

  home.shellAliases = {
    # Manual imports of ~/Music. Downloads are mostly loose singles, so the
    # default is SINGLETON mode (-s). `music-import` reviews each match
    # interactively; `-auto` is the hands-off variant the timer runs;
    # `music-import-album` groups a folder as one album for a full-album drop.
    music-import = "beet import -s ${musicDir}";
    music-import-auto = "beet import -qs ${musicDir}";
    music-import-album = "beet import ${musicDir}";
  };

  # Make sure ~/Music exists so Parabolic can write downloads into it.
  home.activation.ensureMusicDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${musicDir}
  '';

  # bbstation owns automatic import: a timer ticks every 10 minutes and the
  # service imports only settled loose downloads (nothing touched for 5 min).
  systemd.user.services.beets-autoimport = lib.mkIf isBbstation {
    Unit.Description = "Import & organize settled downloads in ~/Music via beets";
    Service = {
      Type = "oneshot";
      # beet shells out to fpcalc (chromaprint) and ffmpeg (replaygain).
      Environment = [ "PATH=${lib.makeBinPath [ pkgs.beets pkgs.chromaprint pkgs.ffmpeg ]}" ];
      ExecStart = "${autoImport}";
    };
  };

  systemd.user.timers.beets-autoimport = lib.mkIf isBbstation {
    Unit.Description = "Periodically import settled ~/Music downloads";
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "10min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
