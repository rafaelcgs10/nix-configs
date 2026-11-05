"""YouTube fallback for vovo: download from YouTube Music, then play it.

Runs as rafael, one instance per request (socket-activated, see youtube.nix).
Reads one line from stdin: "<kind> <option> <base64 query>", kind being one
of song | artist | album | playlist, option one of replace | add | next.
Downloads into ~/Music/Youtube, makes Music
Assistant pick the files up and plays them on the vovo player: the first song
as soon as it is there, the rest queued behind it. On failure, vovo says so.
"""

import base64
import json
import os
import subprocess
import sys
import time
import urllib.parse
import urllib.request

MUSIC_ROOT = "/home/rafael/Music"
YT_DIR = MUSIC_ROOT + "/Youtube"
MA_API = "http://127.0.0.1:8095/api"
HA_API = "http://127.0.0.1:8123/api"
PLAYER_NAME = "vovo"
SATELLITE = "assist_satellite.vovo"
MAX_SONG_SECONDS = 15 * 60   # singles only, no hour-long mixes
MAX_ITEMS = {"song": 1, "artist": 10, "album": 20, "playlist": 20}
SEARCH_FILTER = {"song": "songs", "artist": "songs", "album": "albums", "playlist": "community playlists"}


def log(*a):
    print(*a, file=sys.stderr, flush=True)


def token(env):
    with open(os.environ[env]) as f:
        return f.read().strip()


def post(url, payload, tok):
    req = urllib.request.Request(
        url, data=json.dumps(payload).encode(), method="POST",
        headers={"Authorization": "Bearer " + tok, "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as r:
        body = r.read()
    return json.loads(body) if body else None


def ma(command, **args):
    return post(MA_API, {"message_id": "1", "command": command, "args": args}, token("MA_TOKEN_FILE"))


def say(message):
    try:
        post(HA_API + "/services/assist_satellite/announce",
             {"entity_id": SATELLITE, "message": message}, token("HA_TOKEN_FILE"))
    except Exception as e:  # never let a failed announcement hide the real error
        log("announce failed:", e)


def ytdlp(args):
    cmd = ["yt-dlp", "--no-warnings", "--ignore-errors", "--no-overwrites"] + args
    log("+", " ".join(cmd))
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.stderr.strip():
        log(p.stderr.strip()[-2000:])
    return [line for line in p.stdout.splitlines() if line.strip()]


def search_url(kind, query):
    q = urllib.parse.quote_plus(query)
    return "https://music.youtube.com/search?q=%s#%s" % (q, urllib.parse.quote(SEARCH_FILTER[kind]))


def download(url, items, numbered, single):
    template = "%(artist,uploader|Unknown artist)s/%(album,playlist_title,title)s/"
    template += "%(playlist_index)02d - %(track,title)s.%(ext)s" if numbered else "%(track,title)s.%(ext)s"
    args = [
        "--playlist-items", items,
        "-f", "bestaudio[ext=m4a]/bestaudio",
        "--embed-metadata", "--embed-thumbnail", "--convert-thumbnails", "jpg",
        "-o", YT_DIR + "/" + template,
        "--print", "after_move:filepath",
    ]
    if single:
        args += ["--match-filter", "duration <= %d" % MAX_SONG_SECONDS]
    return [p for p in ytdlp(args + [url]) if os.path.exists(p)]


def ma_uri(path):
    instance = next(p["instance_id"] for p in ma("config/providers") if p["domain"] == "filesystem_local")
    return "%s://track/%s" % (instance, os.path.relpath(path, MUSIC_ROOT))


def ma_track(path):
    """Resolve a downloaded file to a playable Music Assistant item."""
    uri = ma_uri(path)
    for _ in range(10):
        try:
            item = ma("music/item_by_uri", uri=uri)
            if item:
                return item.get("uri") or uri
        except Exception as e:
            log("not resolvable yet:", e)
        time.sleep(2)
    return uri


def queue_id():
    for q in ma("player_queues/all"):
        if q.get("display_name") == PLAYER_NAME:
            return q["queue_id"]
    raise RuntimeError("no Music Assistant queue named " + PLAYER_NAME)


def play(paths, option):
    if paths:
        ma("player_queues/play_media", queue_id=queue_id(), media=[ma_track(p) for p in paths], option=option)


def main():
    line = sys.stdin.readline().strip()
    kind, option, b64 = line.split(" ", 2)
    query = base64.b64decode(b64).decode().strip()
    if kind not in MAX_ITEMS or option not in ("replace", "add", "next") or not query:
        raise SystemExit("bad request: %r" % line)
    log("request:", kind, repr(query))
    os.makedirs(YT_DIR, exist_ok=True)

    if kind == "song":
        url = search_url(kind, query)
    else:
        # The search result is itself an album/playlist (or, for an artist,
        # the list of songs): resolve the top hit first, so the item cap
        # applies to its tracks and not to the search results.
        hits = ytdlp(["--flat-playlist", "--playlist-items", "1", "--print", "url", search_url(kind, query)])
        url = hits[0] if hits and kind != "artist" else search_url(kind, query)

    numbered = kind in ("album", "playlist")
    first = download(url, "1", numbered, single=True)
    if not first:
        say("Sorry, I couldn't get %s from YouTube." % query)
        raise SystemExit("nothing downloaded for %r" % query)
    play(first, option)
    log("playing", first)

    total = MAX_ITEMS[kind]
    if total > 1:
        rest = download(url, "2-%d" % total, numbered, single=True)
        play(rest, "add")
        log("queued", len(rest), "more")

    try:  # index everything properly (artist/album pages, search next time)
        instance = next(p["instance_id"] for p in ma("config/providers") if p["domain"] == "filesystem_local")
        ma("music/sync", media_types=["track"], providers=[instance])
    except Exception as e:
        log("library sync failed:", e)


if __name__ == "__main__":
    main()
