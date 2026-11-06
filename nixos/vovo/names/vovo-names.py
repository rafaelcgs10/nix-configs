"""Correct misheard artist and song names in vovo's "play ..." requests.

Speech-to-text gets common words right and names wrong ("Daphne Punk",
"Billy Gene", "radio ahead"). Before the library search, Home Assistant asks
this service to snap the name onto a known artist or song:

  vovo-names build CATALOG.json BILLBOARD.csv WD_ARTISTS.csv WD_WORKS.csv
      (Nix build time) merge the lists, precompute normalised + phonetic keys
  vovo-names serve CATALOG.json
      (socket-activated) HTTP on the socket systemd passes in; POST /correct
      {"mode": "plain"|"artist"|"album"|"genre", "name": "..."} returns
      {"mode", "name", "changed", "score", "source"}; exits when idle.
      A mood word ("lofi", misheard "low fy") from MOODS_FILE (moods.nix)
      returns mode "mood" with the mood's name.

Names are compared twice, by spelling (rapidfuzz ratio of the normalised
text) and by sound (Metaphone codes per word), so "daphne punk" (TFN PNK)
still lands on "daft punk" (TFT PNK). The music library (from Music
Assistant, read at start) is part of the catalog and wins ties. Anything
without a confident match is returned unchanged.
"""

import csv
import json
import os
import re
import socket
import sys
import time
import unicodedata
import urllib.request
from http.server import BaseHTTPRequestHandler, HTTPServer

import jellyfish
from rapidfuzz import fuzz, process

MA_API = "http://127.0.0.1:8095/api"
IDLE_EXIT = 600            # seconds without requests before exiting
LIBRARY_MAX_AGE = 300      # re-read the library if older (new downloads)
# Minimum combined score (0-100) to change a name. Tuned on spoken-command
# mishearings: a bare "play X" must be close ("something nice" must not become
# "Something New"), while a name that is surely an artist ("songs by X", or
# the "by X" part) may be looser, and a title is matched among that artist's
# own songs only.
ACCEPT_BARE = 90
ACCEPT_ARTIST = 75
ACCEPT_TITLE_OF_ARTIST = 70
ACCEPT_TITLE_WITH_BY = 85
ACCEPT_MOOD = 85
LIBRARY_BONUS = 4


def log(*a):
    print(*a, file=sys.stderr, flush=True)


ONES = "zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen".split()
TENS = "_ _ twenty thirty forty fifty sixty seventy eighty ninety".split()


def words(n):
    """Number as spoken: 7 seven, 99 ninety nine, 1812 eighteen twelve,
    2000 two thousand, 2005 two thousand five."""
    if n < 20:
        return ONES[n]
    if n < 100:
        return TENS[n // 10] + ("" if n % 10 == 0 else " " + ONES[n % 10])
    if n < 1000:
        return ONES[n // 100] + " hundred" + ("" if n % 100 == 0 else " " + words(n % 100))
    if n < 10000 and not (2000 <= n < 2010) and n % 100 != 0:
        return words(n // 100) + " " + (words(n % 100) if n % 100 >= 10 else "oh " + ONES[n % 100])
    if n < 10000:
        return words(n // 1000) + " thousand" + ("" if n % 1000 == 0 else " " + words(n % 1000))
    return str(n)


def norm(s):
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode().lower()
    s = s.replace("&", " and ").replace("-", " ")
    s = re.sub(r"\s*[\(\[][^\)\]]*[\)\]]", " ", s)               # "(Remastered)", "[Live]"
    s = re.sub(r"\s+(feat\.?|featuring|ft\.?|with|x)\s+.*$", "", s)  # "Drake Featuring Rihanna"
    # Digits as words: the speech-to-text says "seven years", lists say "7 Years"
    s = re.sub(r"\d+", lambda m: " " + words(int(m.group())) + " ", s)
    return " ".join(re.sub(r"[^a-z0-9 ]", "", s).split())


def phon(n):
    return " ".join(jellyfish.metaphone(w) or w for w in n.split())


# --- build (Nix) --------------------------------------------------------------

def build(out, billboard, wd_artists, wd_works):
    artists = {}   # norm key -> [display, popularity]  (aliases point at display)
    titles = {}    # (norm title, display artist) -> [display title, popularity]

    def add_artist(key, display, pop):
        k = norm(key)
        if k and (k not in artists or artists[k][1] < pop):
            artists[k] = [display, pop]

    def add_title(title, artist, pop):
        k = (norm(title), artist)
        if k[0]:
            old = titles.get(k)
            titles[k] = [title, (old[1] if old else 0) + pop]

    # Billboard Hot 100: one row per song per chart week; weeks = popularity.
    with open(billboard, newline="") as f:
        for r in csv.DictReader(f):
            main = re.split(r"\s+(?:featuring|feat\.?|ft\.?|with|x|&|and)\s+", r["performer"], maxsplit=1, flags=re.I)[0]
            add_artist(r["performer"], r["performer"], 1)
            add_artist(main, main.strip(), 1)
            add_title(r["title"].title() if r["title"].isupper() else r["title"], main.strip(), 1)
    # Wikidata: sitelinks = popularity (scaled to be comparable to chart weeks)
    with open(wd_artists, newline="") as f:
        for r in csv.DictReader(f):
            pop = int(r["sitelinks"]) * 5
            add_artist(r["name"], r["name"], pop)
            for alias in filter(None, r["aliases"].split("|")):
                add_artist(alias, r["name"], pop)
    with open(wd_works, newline="") as f:
        for r in csv.DictReader(f):
            add_title(r["title"], r["by"], int(r["sitelinks"]) * 5)

    cat = {
        "artists": [[k, phon(k), d, p] for k, (d, p) in sorted(artists.items())],
        "titles": [[k, phon(k), d, a, p] for (k, a), (d, p) in sorted(titles.items())],
    }
    with open(out, "w") as f:
        json.dump(cat, f, separators=(",", ":"))
    log(f"catalog: {len(cat['artists'])} artist keys, {len(cat['titles'])} titles")


# --- matching -----------------------------------------------------------------

class Index:
    """Parallel lists so rapidfuzz can scan them at C speed."""

    def __init__(self):
        self.keys, self.phons, self.items = [], [], []

    def add(self, key, ph, item):
        self.keys.append(key)
        self.phons.append(ph)
        self.items.append(item)

    def best(self, q, cutoff, only=None):
        """(score, item) of the best match for normalised q, or None."""
        qp = phon(q)
        cands = {}
        keys, phons = self.keys, self.phons
        if only is not None:
            keys = [self.keys[i] for i in only]
            phons = [self.phons[i] for i in only]
        for _, _, i in process.extract(q, keys, scorer=fuzz.ratio, limit=8, score_cutoff=cutoff - 15):
            cands[i] = True
        for _, _, i in process.extract(qp, phons, scorer=fuzz.ratio, limit=8, score_cutoff=cutoff):
            cands[i] = True
        best = None
        for i in cands:
            spell = fuzz.ratio(q, keys[i])
            sound = fuzz.ratio(qp, phons[i])
            # Sound alone is too loose for short names; it needs some spelling
            # agreement to count (TFN PNK ~ TFT PNK, but not every "BL" name).
            score = max(spell, sound - 5 if spell >= 55 else 0)
            item = self.items[only[i] if only is not None else i]
            score = min(100, score + (LIBRARY_BONUS if item["library"] else 0))
            rank = (score, item["library"], item["pop"])
            if score >= cutoff and (best is None or rank > best[0]):
                best = (rank, item)
        return (best[0][0], best[1]) if best else None


def squash(s):
    return s.replace(" ", "")


class Moods:
    """Mood words from moods.nix, compared without spaces ("low fi" ~ "lofi")
    by spelling and by sound."""

    def __init__(self, path):
        self.words = []  # (squashed norm, squashed phonetic, mood)
        if path:
            with open(path) as f:
                for mood, spec in json.load(f).items():
                    for w in [mood] + spec.get("words", []):
                        n = norm(w)
                        self.words.append((squash(n), squash(phon(n)), mood))

    def match(self, q):
        q = re.sub(r"^(some|a bit of|a little|the) ", "", q)
        short = re.sub(r" (music|songs|playlist|please)$", "", q)
        best = None
        for qq in {q, short}:
            m = self._match(squash(qq), squash(phon(qq)))
            if m and (best is None or m > best):
                best = m
        return best

    def _match(self, qs, qp):
        best = None
        for ws, wp, mood in self.words:
            spell = fuzz.ratio(qs, ws)
            # sound counts only with some spelling agreement: "life" (LF) is
            # not "lofi" (LF), "lowfy" is
            score = max(spell, fuzz.ratio(qp, wp) - 5 if spell >= 60 else 0)
            if score >= ACCEPT_MOOD and (best is None or score > best[0]):
                best = (score, mood)
        return best


class Catalog:
    def __init__(self, path):
        t = time.time()
        self.moods = Moods(os.environ.get("MOODS_FILE"))
        with open(path) as f:
            cat = json.load(f)
        self.static_artists = cat["artists"]
        self.static_titles = cat["titles"]
        self.library_at = 0
        self.rebuild()
        log(f"catalog loaded in {time.time() - t:.1f}s")

    def rebuild(self):
        lib_artists, lib_titles, lib_albums = [], [], []
        try:
            for a in ma("music/artists/library_items", limit=5000):
                lib_artists.append(a["name"])
            for t in ma("music/tracks/library_items", limit=5000):
                lib_titles.append((t["name"], ", ".join(a["name"] for a in t.get("artists", []))))
            for a in ma("music/albums/library_items", limit=5000):
                lib_albums.append((a["name"], ", ".join(x["name"] for x in a.get("artists", []))))
        except Exception as e:  # the static catalog still works without MA
            log("library not available:", e)
        self.library_at = time.time()
        self.artists, self.titles, self.albums = Index(), Index(), Index()
        self.titles_by_artist = {}
        for k, ph, d, p in self.static_artists:
            self.artists.add(k, ph, {"name": d, "pop": p, "library": False})
        for k, ph, d, a, p in self.static_titles:
            self.titles.add(k, ph, {"name": d, "artist": a, "pop": p, "library": False})
            self.titles_by_artist.setdefault(norm(a), []).append(len(self.titles.keys) - 1)
        for name in lib_artists:
            k = norm(name)
            self.artists.add(k, phon(k), {"name": name, "pop": 10 ** 6, "library": True})
        for name, artist in lib_titles:
            k = norm(name)
            self.titles.add(k, phon(k), {"name": name, "artist": artist, "pop": 10 ** 6, "library": True})
            for a in artist.split(", "):
                self.titles_by_artist.setdefault(norm(a), []).append(len(self.titles.keys) - 1)
        for name, artist in lib_albums:
            k = norm(name)
            self.albums.add(k, phon(k), {"name": name, "artist": artist, "pop": 10 ** 6, "library": True})
        log(f"index: {len(self.artists.keys)} artists, {len(self.titles.keys)} titles, "
            f"{len(self.albums.keys)} albums ({len(lib_titles)} library tracks)")

    def fresh(self):
        if time.time() - self.library_at > LIBRARY_MAX_AGE:
            self.rebuild()

    def correct(self, mode, name):
        self.fresh()
        q = norm(name)
        same = {"mode": mode, "name": name, "changed": False, "score": 0, "source": ""}
        if not q or mode not in ("plain", "artist", "album", "genre"):
            return same  # random, next song, playlist: not a name
        if mode in ("plain", "genre"):
            m = self.moods.match(q)
            if m:
                return {"mode": "mood", "name": m[1], "changed": True, "score": round(m[0]), "source": "moods"}
            if mode == "genre":
                return same

        def out(new_mode, new_name, score, item):
            return {"mode": new_mode, "name": new_name, "changed": new_name.lower() != name.lower() or new_mode != mode,
                    "score": round(score), "source": "library" if item["library"] else "catalog"}

        if mode == "artist":
            a = self.artists.best(q, ACCEPT_ARTIST)
            return out("artist", a[1]["name"], a[0], a[1]) if a else same
        if mode == "album":
            title, _, by = q.partition(" by ")
            a = self.albums.best(title, ACCEPT_BARE)
            return out("album", "%s by %s" % (a[1]["name"], a[1]["artist"]) if by else a[1]["name"], a[0], a[1]) if a else same

        # plain: "title by artist", or a bare artist or title
        title, sep, by = q.partition(" by ")
        if sep:
            a = self.artists.best(by, ACCEPT_ARTIST)
            if a:
                own = self.titles_by_artist.get(norm(a[1]["name"]), [])
                t = self.titles.best(title, ACCEPT_TITLE_OF_ARTIST, only=own) if own else None
                if t:
                    return out("plain", "%s by %s" % (t[1]["name"], a[1]["name"]), min(a[0], t[0]), t[1])
                return out("plain", "%s by %s" % (name.lower().split(" by ")[0], a[1]["name"]), a[0], a[1])
            t = self.titles.best(title, ACCEPT_TITLE_WITH_BY)
            return out("plain", "%s by %s" % (t[1]["name"], t[1]["artist"]), t[0], t[1]) if t else same
        a = self.artists.best(q, ACCEPT_BARE)
        t = self.titles.best(q, ACCEPT_BARE)
        if a and (not t or (a[0], a[1]["library"]) >= (t[0], t[1]["library"])):
            return out("artist", a[1]["name"], a[0], a[1])
        if t:
            return out("plain", "%s by %s" % (t[1]["name"], t[1]["artist"]), t[0], t[1])
        return same


def ma(command, **args):
    with open(os.environ["MA_TOKEN_FILE"]) as f:
        tok = f.read().strip()
    req = urllib.request.Request(
        MA_API, method="POST",
        data=json.dumps({"message_id": "1", "command": command, "args": args}).encode(),
        headers={"Authorization": "Bearer " + tok, "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read())


# --- serve (systemd socket activation) ----------------------------------------

def serve(path):
    catalog = Catalog(path)

    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            t = time.time()
            req = {}
            try:
                req = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))) or b"{}")
                res = catalog.correct(req.get("mode", "plain"), req.get("name", ""))
                code = 200
            except Exception as e:
                log("error:", repr(e))
                res, code = {"error": str(e)}, 500
            body = json.dumps(res).encode()
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            log(f"{req!r} -> {res!r} ({(time.time() - t) * 1000:.0f} ms)")

        def log_message(self, format, *args):
            pass

    class Server(HTTPServer):
        def server_bind(self):
            pass  # the socket comes bound and listening from systemd

        def server_activate(self):
            pass

    if os.environ.get("LISTEN_FDS") != "1":
        sys.exit("expects one listening socket from systemd (LISTEN_FDS=1)")
    srv = Server(("127.0.0.1", 0), Handler, bind_and_activate=False)
    srv.socket = socket.socket(fileno=3)
    srv.timeout = IDLE_EXIT
    srv.handle_timeout = lambda: sys.exit(0)  # idle: free the RAM, systemd restarts on demand
    while True:
        srv.handle_request()


if __name__ == "__main__":
    if sys.argv[1:2] == ["build"] and len(sys.argv) == 6:
        build(*sys.argv[2:])
    elif sys.argv[1:2] == ["serve"] and len(sys.argv) == 3:
        serve(sys.argv[2])
    elif sys.argv[1:2] == ["test"]:  # vovo-names test CATALOG.json "mode:name" ...
        c = Catalog(sys.argv[2])
        for arg in sys.argv[3:]:
            mode, _, name = arg.partition(":")
            t = time.time()
            r = c.correct(mode, name)
            print(f"{arg!r:45} -> {r['mode']}: {r['name']!r} score {r['score']} {r['source']} ({(time.time() - t) * 1000:.0f} ms)")
    else:
        sys.exit(__doc__)
