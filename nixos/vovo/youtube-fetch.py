"""YouTube fallback for vovo: download from YouTube Music, then play it.

Runs as rafael, one instance per request (socket-activated, see youtube.nix).
Reads one line from stdin: "<kind> <option> <base64 query>", kind being one
of song | artist | album | playlist | related | mood | continue, option one of
replace | add | next. "related" plays songs similar to the query (YouTube
Music radio); "mood" plays random songs from the mood's playlists in
MOODS_FILE (moods.nix); "continue" (query: the last request, "mode|name")
keeps the music going in the same style when the queue has run out;
"ytplaylist" plays a cached local copy of the most-viewed YouTube playlist
for the query (see play_ytplaylist).
Downloads into ~/Music/Youtube, makes Music
Assistant pick the files up and plays them on the vovo player: the first song
as soon as it is there, the rest queued behind it. On failure, vovo says so.
"""

import base64
import collections
import concurrent.futures
import difflib
import hashlib
import json
import os
import random
import re
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
PLAYER_ENTITY = "media_player.vovo"
RESUME_FLAG = "input_boolean.vovo_resume_after_voice"
MAX_SONG_SECONDS = 15 * 60   # singles only, no hour-long mixes
MAX_ITEMS = {"song": 1, "artist": 10, "album": 20, "playlist": 20, "related": 20, "mood": 20, "continue": 20, "ytplaylist": 30}
SEARCH_FILTER = {"song": "songs", "artist": "songs", "album": "albums", "playlist": "community playlists", "related": "songs"}
# After a single song, queue this many songs from its YouTube Music radio, so
# the music goes on and "next" has somewhere to go.
RELATED_AFTER_SONG = 19


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


def phrase(key, **values):
    """A random variant of a phrases.nix message, placeholders filled in."""
    try:
        with open(os.environ["PHRASES_FILE"]) as f:
            variants = json.load(f)[key]
    except (KeyError, OSError, ValueError):
        return ""
    return random.choice(variants).format(**values)


def say(message):
    if not message:
        return
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


def ytdlp_stream(args):
    """Like ytdlp(), but yields printed lines as they appear (one per finished
    download), so each song can be queued while the next one downloads."""
    cmd = ["yt-dlp", "--no-warnings", "--ignore-errors", "--no-overwrites"] + args
    log("+", " ".join(cmd))
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1)
    try:
        for line in p.stdout:
            if line.strip():
                yield line.strip()
    finally:  # also when the caller stops early (music stopped): end yt-dlp
        if p.poll() is None:
            p.kill()
        p.wait()


def search_url(kind, query):
    q = urllib.parse.quote_plus(query)
    return "https://music.youtube.com/search?q=%s#%s" % (q, urllib.parse.quote(SEARCH_FILTER[kind]))


def download_args(url, items, numbered, single):
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
    return args + [url]


def download(url, items, numbered, single):
    return [p for p in ytdlp(download_args(url, items, numbered, single)) if os.path.exists(p)]


def download_and_queue(url, items, numbered, single):
    """Download the rest, adding each song to the queue as soon as it is done."""
    n = 0
    for path in ytdlp_stream(download_args(url, items, numbered, single)):
        if stopped_by_user():
            break
        if os.path.exists(path):
            try:
                ma_sync()
                play([path], "add")
                n += 1
            except Exception as e:
                log("queueing failed:", path, e)
    return n


# Words that make a video something other than the song (unless asked for).
NOT_THE_SONG = ("trailer", "reaction", "karaoke", "tutorial", "lesson", "how to play", "interview", "behind the scenes")
SONG_CANDIDATES = 10


def song_id(query):
    """YouTube video id of the most-viewed matching song: of the top
    YouTube results, those whose title/channel contain the query's words and
    that are 45 s - 15 min long; falls back to YouTube Music's top song."""
    want = [w for w in norm(query).split() if w not in ("the", "a", "by", "of", "and")]
    best = None
    for line in ytdlp(["--flat-playlist", "--print", "%(id)s\t%(view_count|0)s\t%(duration|0)s\t%(channel,uploader|)s\t%(title)s",
                       "ytsearch%d:%s" % (SONG_CANDIDATES, query)]):
        f = line.split("\t")
        if len(f) < 5:
            continue
        vid, views, secs, channel, title = f[0], f[1], f[2], f[3], "\t".join(f[4:])
        try:
            views, secs = int(float(views)), float(secs)
        except ValueError:
            continue
        text = norm(title + " " + channel)
        if not 45 <= secs <= MAX_SONG_SECONDS:
            continue
        if any(w in text and w not in norm(query) for w in NOT_THE_SONG):
            continue
        if want and sum(w in text for w in want) < max(1, round(0.75 * len(want))):
            continue
        if best is None or views > best[0]:
            best = (views, vid, title)
    if best:
        log("most viewed: %s (%d views)" % (best[2], best[0]))
        return best[1]
    ids = ytdlp(["--flat-playlist", "--playlist-items", "1", "--print", "id", search_url("song", query)])
    return ids[0] if ids else None


def radio_url(video_id):
    """YouTube Music radio for a song: the song itself first, then related ones."""
    return "https://music.youtube.com/watch?v=%s&list=RDAMVM%s" % (video_id, video_id)


def ha_state(entity):
    req = urllib.request.Request(HA_API + "/states/" + entity,
                                 headers={"Authorization": "Bearer " + token("HA_TOKEN_FILE")})
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read()).get("state")


def _looks_stopped():
    try:
        player = ha_state(PLAYER_ENTITY)
        flag = ha_state(RESUME_FLAG)
        satellite = ha_state(SATELLITE)
        return player in ("paused", "idle", "off", "unavailable") and flag == "off" and satellite == "idle"
    except Exception as e:
        log("state check failed:", e)
        return False


def stopped_by_user():
    """True once the user has stopped/paused the music by voice. A pause while
    vovo listens sets the resume flag, so it does not count; the check is
    repeated after 5 s to skip the moment between "idle" and the resume."""
    if not _looks_stopped():
        return False
    time.sleep(5)
    if _looks_stopped():
        log("music stopped by the user: not queueing more")
        return True
    return False


# --- before YouTube: is it in the library after all? --------------------------
# Most "not in the library" requests are speech-to-text mishearings of songs
# that ARE in the library ("bohemian rapsody", "the off-string"); YouTube would
# happily return something for them. Fuzzy-match against the whole library
# first; only clear misses go to YouTube. 0.82 separated real mishearings
# (0.89-1.0) from true misses (<= 0.75) on this library.
FUZZY_MIN = 0.82


def norm(text):
    return re.sub(r"[^a-z0-9 ]", "", text.lower().replace("-", " ")).strip()


def similarity(a, b):
    return difflib.SequenceMatcher(None, a, b).ratio()


def library_match(kind, query):
    """Best fuzzy library match as (score, media, label), or None."""
    q = norm(query)
    title, _, by = q.partition(" by ")
    best = None
    if kind in ("song", "artist"):
        for t in ma("music/tracks/library_items", limit=5000):
            artists = ", ".join(a["name"] for a in t.get("artists", []))
            if kind == "song":
                score = similarity(title, norm(t["name"]))
                if by:
                    score = 0.6 * score + 0.4 * similarity(by, norm(artists))
                if not best or score > best[0]:
                    best = (score, t["uri"], "%s by %s" % (t["name"], artists))
        for a in ma("music/artists/library_items", limit=5000):
            score = similarity(q, norm(a["name"]))
            if not best or score > best[0]:
                best = (score, a["uri"], "music by %s" % a["name"])
    elif kind == "album":
        for a in ma("music/albums/library_items", limit=5000):
            score = similarity(title, norm(a["name"]))
            if not best or score > best[0]:
                best = (score, a["uri"], "the album %s" % a["name"])
    log("library match:", best)
    return best if best and best[0] >= FUZZY_MIN else None


def ma_sync():
    """Index new files right away (incremental, fast), so a request for the
    same song later is found in the library instead of downloaded again."""
    try:
        instance = next(p["instance_id"] for p in ma("config/providers") if p["domain"] == "filesystem_local")
        ma("music/sync", media_types=["track"], providers=[instance])
    except Exception as e:
        log("library sync failed:", e)


_library_tracks = None


def clean_title(title, artist=""):
    """Song title without YouTube decorations: "(2012 Remaster)", "[Official
    Video]", "(Audio)", "feat. ..." and a leading "Artist - "."""
    t = re.sub(r"[\(\[][^\)\]]*[\)\]]", " ", title)
    t = re.sub(r"(?i)\b(feat\.?|ft\.?|featuring)\b.*$", " ", t)
    if " - " in t:
        head, tail = t.split(" - ", 1)
        if not artist or similarity(norm(head), norm(artist)) >= 0.6 or norm(head) in norm(artist):
            t = tail
    return norm(t)


def library_copy(title, artist):
    """URI of the library's own copy of a song (strict match), if any."""
    global _library_tracks
    if _library_tracks is None:
        _library_tracks = [
            (clean_title(t["name"]), norm(", ".join(a["name"] for a in t.get("artists", []))), t["uri"])
            for t in ma("music/tracks/library_items", limit=5000)
        ]
    nt, na = clean_title(title, artist), norm(artist)
    for lt, la, uri in _library_tracks:
        # YouTube channels are often "<artist> Official", "<artist> - Topic"
        if similarity(nt, lt) >= 0.9 and la and (la in na or na in la or similarity(na, la) >= 0.8):
            return uri
    return None


def radio_queue(url, items):
    """Queue the songs of a radio/related list one by one: the library copy
    when there is one, otherwise download it. Returns how many were queued."""
    return queue_entries(ytdlp(["--flat-playlist", "--playlist-items", items, "--print",
                                "%(id)s\t%(title)s\t%(artist,channel,uploader|)s", url]))


def queue_entries(entries):
    """Queue "id<TAB>title<TAB>artist" entries in order (library copy first)."""
    n = 0
    for line in entries:
        if stopped_by_user():
            break
        vid, title, artist = (line.split("\t") + ["", ""])[:3]
        uri = library_copy(title, artist)
        try:
            if uri:
                log("in library, not downloading:", title, "-", artist)
                ma("player_queues/play_media", queue_id=queue_id(), media=[uri], option="add")
            else:
                got = download("https://www.youtube.com/watch?v=" + vid, "1", False, single=True)
                if not got:
                    continue
                ma_sync()
                play(got, "add")
            n += 1
        except Exception as e:
            log("queueing failed:", title, e)
    return n


# --- moods ("play some lofi"): random songs from hand-picked playlists --------
MOOD_CACHE = "/home/rafael/.cache/vovo-moods"
MOOD_CACHE_DAYS = 7
MOOD_LIST_MAX = 1000          # entries listed per playlist (8 s per 1000 on a PC)
MOOD_SONG_SECONDS = (45, 480)  # single songs, not mixes


def mood_entries(url):
    """The playlist's songs as "id<TAB>title<TAB>artist" lines, cached a week."""
    os.makedirs(MOOD_CACHE, exist_ok=True)
    path = os.path.join(MOOD_CACHE, hashlib.sha1(url.encode()).hexdigest() + ".json")
    try:
        if time.time() - os.path.getmtime(path) < MOOD_CACHE_DAYS * 86400:
            with open(path) as f:
                return json.load(f)
    except OSError:
        pass
    lines = ytdlp(["--flat-playlist", "--playlist-items", "1-%d" % MOOD_LIST_MAX, "--print",
                   "%(id)s\t%(title)s\t%(artist,channel,uploader|)s\t%(duration|0)s", url])
    entries = []
    for line in lines:
        f = (line.split("\t") + ["", "", "", "0"])[:4]
        try:
            seconds = float(f[3])
        except ValueError:
            seconds = 0
        if not seconds or MOOD_SONG_SECONDS[0] <= seconds <= MOOD_SONG_SECONDS[1]:
            entries.append("\t".join(f[:3]))
    if entries:
        with open(path + ".tmp", "w") as f:
            json.dump(entries, f)
        os.replace(path + ".tmp", path)
    elif os.path.exists(path):  # YouTube hiccup: an old list beats nothing
        with open(path) as f:
            return json.load(f)
    log("mood playlist:", url, len(entries), "songs")
    return entries


MOOD_LIBRARY_SONGS = 5


def mood_library(artists):
    """URIs of up to 5 random library songs by any of the given artists."""
    want = {norm(a) for a in artists}
    if not want:
        return []
    hits = []
    for t in ma("music/tracks/library_items", limit=5000):
        names = {norm(a["name"]) for a in t.get("artists", [])}
        if names & want:
            hits.append(t["uri"])
    return random.sample(hits, min(MOOD_LIBRARY_SONGS, len(hits)))


def play_mood(mood, option, exclude=frozenset()):
    with open(os.environ["MOODS_FILE"]) as f:
        spec = json.load(f).get(mood)
    if not spec:
        raise SystemExit("unknown mood %r" % mood)
    # Library songs by the mood's artists first: they play at once.
    lib = mood_library(spec.get("artists", []))
    if lib:
        ma("player_queues/play_media", queue_id=queue_id(), media=lib, option=option)
        log("mood from library:", len(lib), "songs")
        option = "add"
    pool = [e for url in spec["playlists"] for e in mood_entries(url)]
    fresh = [e for e in pool if entry_key(*(e.split("\t") + ["", ""])[1:3]) not in exclude]
    pool = fresh if len(fresh) >= MAX_ITEMS["mood"] else pool  # small lists: allow repeats
    if not pool:
        if lib:
            return
        say(phrase("youtube_mood_playlist_failed", mood=mood))
        raise SystemExit("empty mood pool for %r" % mood)
    picks = random.sample(pool, min(MAX_ITEMS["mood"] - len(lib), len(pool)))
    recent_add(entry_key(*(e.split("\t") + ["", ""])[1:3]) for e in picks)
    if lib:
        wait_playing()
        log("queued", queue_entries(picks), "more", mood)
        return
    # The first one that downloads starts playing (with the requested queue
    # option); the rest are added behind it as they arrive.
    while picks:
        vid = picks.pop(0).split("\t")[0]
        first = download("https://www.youtube.com/watch?v=" + vid, "1", False, single=True)
        if first:
            ma_sync()
            play(first, option)
            log("playing", first)
            wait_playing()
            break
    else:
        say(phrase("youtube_mood_failed", mood=mood))
        raise SystemExit("nothing downloaded for mood %r" % mood)
    log("queued", queue_entries(picks), "more", mood)


# --- playlist search: skip mixes and off-topic hits ---------------------------
PLAYLIST_CANDIDATES = 4  # from each of YouTube Music and YouTube


def pick_playlist(query):
    """The most-viewed of the top community playlists for a genre/playlist
    name whose title shares a word with the query and whose songs are single
    songs (median under 8 min), not hour-long mixes. Falls back to the first
    YouTube Music hit."""
    q = urllib.parse.quote_plus(query)
    hits = ytdlp(["--flat-playlist", "--playlist-items", "1-%d" % PLAYLIST_CANDIDATES,
                  "--print", "url", search_url("playlist", query)])
    hits += ytdlp(["--flat-playlist", "--playlist-items", "1-%d" % PLAYLIST_CANDIDATES, "--print", "url",
                   "https://www.youtube.com/results?search_query=%s&sp=EgIQAw%%253D%%253D" % q])
    want = {w for w in norm(query).split() if w not in ("music", "playlist", "songs", "some", "the", "a")}
    best = None
    ids = {}
    for url in hits:  # same playlist from both searches: check it once
        m = re.search(r"(?:list=|browse/VL)([A-Za-z0-9_-]+)", url)
        ids.setdefault(m.group(1) if m else url, url)
    for url in ids.values():
        info = ytdlp(["-J", "--flat-playlist", "--playlist-items", "1-10", url])
        try:
            d = json.loads(info[0]) if info else None
        except ValueError:
            d = None
        if not d:
            continue
        title = norm(d.get("title") or "")
        durations = sorted(e.get("duration") or 0 for e in (d.get("entries") or []))
        median = durations[len(durations) // 2] if durations else 0
        views = d.get("view_count") or 0
        ok_title = not want or want & set(title.split()) or any(w in title.replace(" ", "") for w in want)
        ok = ok_title and 0 < median <= 480
        log("playlist candidate:", title, "views %d" % views, "median %ds" % median, "ok" if ok else "skip")
        if ok and (best is None or views > best[0]):
            best = (views, url)
    if best:
        return best[1]
    return hits[0] if hits else None


# --- "play X playlist": cached local copies of YouTube playlists -------------
PLAYLISTS_DIR = MUSIC_ROOT + "/Playlists"
PLAYLISTS_MAX_BYTES = 2 * 1024 ** 3
YTPLAYLIST_CANDIDATES = 4  # from each of YouTube and YouTube Music


def slug(text):
    return norm(text).replace(" ", "-") or "playlist"


def best_summed_playlist(query):
    """The YouTube playlist for the exact search term whose first 30 videos
    have the most views in total (single songs only, no hour-long mixes)."""
    q = urllib.parse.quote_plus(query)
    hits = ytdlp(["--flat-playlist", "--playlist-items", "1-%d" % YTPLAYLIST_CANDIDATES, "--print", "url",
                  "https://www.youtube.com/results?search_query=%s&sp=EgIQAw%%253D%%253D" % q])
    hits += ytdlp(["--flat-playlist", "--playlist-items", "1-%d" % YTPLAYLIST_CANDIDATES,
                   "--print", "url", search_url("playlist", query)])
    ids = {}
    for url in hits:
        m = re.search(r"(?:list=|browse/VL)([A-Za-z0-9_-]+)", url)
        if m:
            ids.setdefault(m.group(1), "https://www.youtube.com/playlist?list=" + m.group(1))
    best = None
    # Read the candidates 4 at a time (each is a few seconds of yt-dlp on the Pi).
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        infos = list(pool.map(lambda u: (u, ytdlp(["-J", "--flat-playlist", "--playlist-items",
                                                   "1-%d" % MAX_ITEMS["ytplaylist"], u])), ids.values()))
    for url, info in infos:
        try:
            d = json.loads(info[0]) if info else None
        except ValueError:
            d = None
        entries = [e for e in ((d or {}).get("entries") or []) if e and e.get("id")]
        if not entries:
            continue
        durations = sorted(e.get("duration") or 0 for e in entries)
        median = durations[len(durations) // 2]
        views = sum(e.get("view_count") or 0 for e in entries)
        ok = 0 < median <= 480
        log("playlist candidate:", d.get("title"), "%d songs" % len(entries), "views %d" % views,
            "median %ds" % median, "ok" if ok else "skip")
        if ok and (best is None or views > best[0]):
            best = (views, d.get("title") or query, url, entries)
    return best


def write_m3u(name, folder, files):
    """A .m3u next to the folder, so Music Assistant lists it as a playlist."""
    path = os.path.join(PLAYLISTS_DIR, name + ".m3u")
    with open(path, "w") as f:
        f.write("#EXTM3U\n")
        for p in files:
            f.write(os.path.relpath(p, PLAYLISTS_DIR) + "\n")


def playlists_cap(keep):
    """Drop the least recently played playlists until under the size cap."""
    sizes = {}
    for name in os.listdir(PLAYLISTS_DIR):
        d = os.path.join(PLAYLISTS_DIR, name)
        if os.path.isdir(d):
            total = sum(os.path.getsize(os.path.join(r, f)) for r, _, fs in os.walk(d) for f in fs)
            index = os.path.join(d, "playlist.json")
            used = os.path.getmtime(index) if os.path.exists(index) else 0
            sizes[name] = (used, total)
    total = sum(t for _, t in sizes.values())
    for name, (used, size) in sorted(sizes.items(), key=lambda kv: kv[1][0]):
        if total <= PLAYLISTS_MAX_BYTES:
            break
        if name == keep:
            continue
        log("playlist cap: removing", name)
        for r, ds, fs in os.walk(os.path.join(PLAYLISTS_DIR, name), topdown=False):
            for f in fs:
                os.remove(os.path.join(r, f))
            os.rmdir(r)
        m3u = os.path.join(PLAYLISTS_DIR, name + ".m3u")
        if os.path.exists(m3u):
            os.remove(m3u)
        total -= size


def download_into(folder, index, vid, title):
    out = os.path.join(folder, "%02d - %%(title)s.%%(ext)s" % index)
    got = ytdlp(["-f", "bestaudio[ext=m4a]/bestaudio", "--embed-metadata", "--embed-thumbnail",
                 "--convert-thumbnails", "jpg", "--match-filter", "duration <= %d" % MAX_SONG_SECONDS,
                 "-o", out, "--print", "after_move:filepath", "https://www.youtube.com/watch?v=" + vid])
    return next((p for p in got if os.path.exists(p)), None)


def play_ytplaylist(query, option):
    name = slug(query)
    folder = os.path.join(PLAYLISTS_DIR, name)
    index = os.path.join(folder, "playlist.json")
    os.makedirs(folder, exist_ok=True)
    data = None
    if os.path.exists(index):
        with open(index) as f:
            data = json.load(f)
        log("cached playlist:", data.get("title"), len(data.get("entries", [])), "songs")
    else:
        best = best_summed_playlist(query)
        if not best:
            say(phrase("youtube_not_found", query=query + " playlist"))
            raise SystemExit("no playlist for %r" % query)
        views, title, url, entries = best
        data = {"query": query, "title": title, "url": url, "views": views,
                "entries": [{"id": e["id"], "title": e.get("title") or ""} for e in entries], "files": {}}
        log("chose playlist:", title, "with %d views over %d songs" % (views, len(entries)))
    files = data.setdefault("files", {})
    started = False
    paths = []
    for i, e in enumerate(data["entries"], 1):
        p = files.get(e["id"])
        if not (p and os.path.exists(p)):
            p = download_into(folder, i, e["id"], e["title"])
            if not p:
                continue
            files[e["id"]] = p
            ma_sync()
        paths.append(p)
        if not started:
            play([p], option)
            log("playing", p)
            started = True
            wait_playing()
        elif not stopped_by_user():
            play([p], "add")
        with open(index + ".tmp", "w") as f:  # save progress (also marks "recently played")
            json.dump(data, f)
        os.replace(index + ".tmp", index)
    if not started:
        say(phrase("youtube_failed", query=query + " playlist"))
        raise SystemExit("nothing downloaded for playlist %r" % query)
    write_m3u(name, folder, paths)
    playlists_cap(keep=name)
    log("playlist ready:", data.get("title"), len(paths), "songs")


# --- recently played: never repeat within the last few hundred songs ---------
RECENT_FILE = "/home/rafael/.cache/vovo-moods/recent.json"
RECENT_MAX = 400


def recent_load():
    try:
        with open(RECENT_FILE) as f:
            return json.load(f)
    except (OSError, ValueError):
        return []


def recent_add(keys):
    keep = (recent_load() + list(keys))[-RECENT_MAX:]
    os.makedirs(os.path.dirname(RECENT_FILE), exist_ok=True)
    with open(RECENT_FILE + ".tmp", "w") as f:
        json.dump(keep, f)
    os.replace(RECENT_FILE + ".tmp", RECENT_FILE)


def entry_key(title, artist=""):
    return clean_title(title, artist)


def wait_playing(timeout=20):
    """Wait until the player is playing (queueing more checks for a stop)."""
    end = time.time() + timeout
    while time.time() < end:
        try:
            if ha_state(PLAYER_ENTITY) == "playing":
                return True
        except Exception:
            pass
        time.sleep(1)
    return False


# --- continue: the queue ran out, more in the same style ----------------------
CONTINUE_SEEDS = 5         # last songs that set the style
CONTINUE_RADIO_SEEDS = 2   # of those, how many get a YouTube radio lookup
CONTINUE_LIBRARY = 8       # library songs (instant start)
GENERIC_GENRES = {"music", "other", "unknown", "misc", "various", "soundtrack"}


def queue_history():
    """Media items (tracks) of the queue that just ended, oldest first."""
    items = ma("player_queues/items", queue_id=queue_id(), limit=500, offset=0) or []
    return [i["media_item"] for i in items if i.get("media_item")]


def continue_music(last, option):
    mode, _, name = last.partition("|")
    history = queue_history()
    seen = {entry_key(t["name"], ", ".join(a["name"] for a in t.get("artists", []))) for t in history}
    seen |= set(recent_load())
    if mode == "mood" and name:
        log("continuing mood", name)
        play_mood(name, option, exclude=seen)
        return

    seeds = history[-CONTINUE_SEEDS:]
    # What was asked for weighs most ("play X by Y" was followed by random
    # library songs); the newest played song adds the current style.
    title, _, by = name.partition(" by ")
    ask = {"artist": name, "album": name, "genre": name + " music"}.get(mode, ("%s %s" % (title, by)).strip())
    if not seeds and not ask:
        log("nothing played or asked before: nothing to continue")
        return
    artists = collections.Counter(a["name"] for t in seeds for a in t.get("artists", []))
    if mode == "artist" or by:
        artists[by or name] += len(seeds) + 1  # the requested artist first
    genre_count = collections.Counter(g.lower() for t in seeds for g in set((t.get("metadata") or {}).get("genres") or []))
    genres = {g for g, n in genre_count.items() if n >= 2 and g not in GENERIC_GENRES}
    log("continuing from", repr(ask), [t["name"] for t in seeds], "artists", dict(artists), "genres", genres)

    # YouTube Music's related songs for the request and the newest song
    queries = [ask] if ask else []
    if seeds:
        t = seeds[-1]
        queries.append("%s %s" % (t["name"], ", ".join(a["name"] for a in t.get("artists", []))))
    related = []
    for q in queries[:CONTINUE_RADIO_SEEDS]:
        vid = song_id(q)
        if vid:
            related += ytdlp(["--flat-playlist", "--playlist-items", "2-26", "--print",
                              "%(id)s\t%(title)s\t%(artist,channel,uploader|)s", radio_url(vid)])
    wanted_artists = {norm(a) for a in artists}
    wanted_artists |= {norm((line.split("\t") + ["", "", ""])[2]) for line in related}
    wanted_artists.discard("")

    # Library songs by the same or related artists, or with the same genre
    lib = []
    for t in ma("music/tracks/library_items", limit=5000):
        names = {norm(a["name"]) for a in t.get("artists", [])}
        tgenres = {g.lower() for g in ((t.get("metadata") or {}).get("genres") or [])}
        key = entry_key(t["name"], ", ".join(a["name"] for a in t.get("artists", [])))
        if key not in seen and (names & wanted_artists or (genres and tgenres & genres)):
            lib.append((t["uri"], key))
    lib = random.sample(lib, min(CONTINUE_LIBRARY, len(lib)))

    # New songs from YouTube: the related ones not played recently
    fresh, keys = [], set()
    for line in related:
        vid, title, artist = (line.split("\t") + ["", "", ""])[:3]
        key = entry_key(title, artist)
        if key and key not in seen and key not in keys and vid not in seen:
            fresh.append(line)
            keys.add(key)
    random.shuffle(fresh)
    fresh = fresh[:MAX_ITEMS["continue"] - len(lib)]
    log("continue: %d library songs, %d from YouTube" % (len(lib), len(fresh)))
    if not lib and not fresh:
        return

    top = artists.most_common(1)[0][0] if artists else ""
    if artists and artists.most_common(1)[0][1] < 2 and seeds and seeds[-1].get("artists"):
        top = seeds[-1]["artists"][0]["name"]  # no clear favourite: the last one
    top = top or (title if ask else "that")
    say(phrase("more_like_this", artist=top))
    recent_add([k for _, k in lib] + list(keys))
    if lib:
        ma("player_queues/play_media", queue_id=queue_id(), media=[u for u, _ in lib], option=option)
        wait_playing()
        log("queued", queue_entries(fresh), "more from YouTube")
        return
    while fresh:
        vid = fresh.pop(0).split("\t")[0]
        first = download("https://www.youtube.com/watch?v=" + vid, "1", False, single=True)
        if first:
            ma_sync()
            play(first, option)
            wait_playing()
            log("queued", queue_entries(fresh), "more from YouTube")
            return


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

    if kind == "mood":
        play_mood(query, option, exclude=set(recent_load()))
        ma_sync()
        return
    if kind == "continue":
        continue_music(query, option)
        ma_sync()
        return
    if kind == "ytplaylist":
        play_ytplaylist(query, option)
        ma_sync()
        return

    match = library_match(kind, query)
    if match:
        _, uri, label = match
        ma("player_queues/play_media", queue_id=queue_id(), media=[uri], option=option)
        say(phrase("youtube_library_instead", label=label))
        log("played from library instead:", label)
        return

    if kind in ("song", "related"):
        vid = song_id(query)
        if not vid:
            say(phrase("youtube_not_found", query=query))
            raise SystemExit("no search result for %r" % query)
        radio = radio_url(vid)
        if kind == "song":
            first = download("https://www.youtube.com/watch?v=" + vid, "1", False, single=True)
            more = "2-%d" % (1 + RELATED_AFTER_SONG)
        else:  # related: skip the seed itself (that is what is playing now)
            first = download(radio, "2", False, single=True)
            more = "3-%d" % (1 + MAX_ITEMS["related"])
        if not first:
            say(phrase("youtube_failed", query=query))
            raise SystemExit("nothing downloaded for %r" % query)
        ma_sync()
        play(first, option)
        log("playing", first)
        log("queued", radio_queue(radio, more), "related")
    else:
        # The search result is itself an album/playlist (or, for an artist,
        # the list of songs): resolve the top hit first, so the item cap
        # applies to its tracks and not to the search results.
        if kind == "playlist":
            hit = pick_playlist(query)
            hits = [hit] if hit else []
        else:
            hits = ytdlp(["--flat-playlist", "--playlist-items", "1", "--print", "url", search_url(kind, query)])
        url = hits[0] if hits and kind != "artist" else search_url(kind, query)

        numbered = kind in ("album", "playlist")
        first = download(url, "1", numbered, single=True)
        if not first:
            say(phrase("youtube_failed", query=query))
            raise SystemExit("nothing downloaded for %r" % query)
        ma_sync()
        play(first, option)
        log("playing", first)
        log("queued", download_and_queue(url, "2-%d" % MAX_ITEMS[kind], numbered, single=True), "more")

    ma_sync()


if __name__ == "__main__":
    main()
