"""Keep ~/Music/Youtube small: delete songs older than 2 days, then the oldest
ones until the folder is under 1 GB. Songs being played (open files) are
kept. Music Assistant then resyncs, so deleted songs leave the library.

    youtube-cleanup [--dry-run]

Age is the file's change time (when it was downloaded/written), not its
modification time, which yt-dlp may set to the video's upload date. The
cached playlists in ~/Music/Playlists are not touched (they have their own
cap, see youtube-fetch).
"""

import json
import os
import sys
import time
import urllib.request

ROOT = "/home/rafael/Music/Youtube"
MAX_AGE = 2 * 86400
MAX_BYTES = 1024 ** 3
MA_API = "http://127.0.0.1:8095/api"


def open_files():
    """Paths currently open by any process we can see (rafael's and MA's)."""
    paths = set()
    for pid in filter(str.isdigit, os.listdir("/proc")):
        fd_dir = "/proc/%s/fd" % pid
        try:
            for fd in os.listdir(fd_dir):
                try:
                    paths.add(os.readlink(os.path.join(fd_dir, fd)))
                except OSError:
                    pass
        except OSError:
            pass
    return paths


def ma_sync():
    try:
        with open(os.environ["MA_TOKEN_FILE"]) as f:
            tok = f.read().strip()

        def ma(command, **args):
            req = urllib.request.Request(MA_API, method="POST", headers={
                "Authorization": "Bearer " + tok, "Content-Type": "application/json"},
                data=json.dumps({"message_id": "1", "command": command, "args": args}).encode())
            with urllib.request.urlopen(req, timeout=60) as r:
                return json.loads(r.read())

        instance = next(p["instance_id"] for p in ma("config/providers") if p["domain"] == "filesystem_local")
        ma("music/sync", media_types=["track"], providers=[instance])
        print("Music Assistant library sync started")
    except Exception as e:
        print("library sync failed:", e)


def main():
    dry = "--dry-run" in sys.argv
    if not os.path.isdir(ROOT):
        return
    files = []
    for d, _, names in os.walk(ROOT):
        for n in names:
            p = os.path.join(d, n)
            try:
                st = os.stat(p)
            except OSError:
                continue
            files.append((st.st_ctime, st.st_size, p))
    files.sort(reverse=True)  # newest first
    busy = open_files()
    now = time.time()
    keep_bytes = 0
    doomed = []
    for ctime, size, p in files:
        if p in busy:
            keep_bytes += size
            continue
        if now - ctime > MAX_AGE:
            doomed.append((p, size, "older than 2 days"))
        elif keep_bytes + size > MAX_BYTES:
            doomed.append((p, size, "over the 1 GB cap"))
        else:
            keep_bytes += size
    freed = 0
    for p, size, why in doomed:
        print(("would delete" if dry else "deleting"), "%s (%.1f MB, %s)" % (os.path.relpath(p, ROOT), size / 1e6, why))
        if not dry:
            try:
                os.remove(p)
                freed += size
            except OSError as e:
                print("  failed:", e)
    if not dry:
        for d, _, _ in sorted(os.walk(ROOT), key=lambda w: -len(w[0])):  # deepest first
            if d != ROOT and not os.listdir(d):
                os.rmdir(d)
    gone = sum(s for _, s, _ in doomed) if dry else freed
    print("%d files, kept %.0f MB, %s %.0f MB" % (len(files), keep_bytes / 1e6, "would free" if dry else "freed", gone / 1e6))
    if doomed and not dry:
        ma_sync()


main()
