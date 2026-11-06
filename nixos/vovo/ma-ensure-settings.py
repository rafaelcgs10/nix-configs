"""Run before Music Assistant starts: make sure settings.json is valid and has
the providers vovo needs, with fixed instance ids.

A forced power-off while Music Assistant was writing settings.json once left
it with factory defaults: no music library, no squeezelite player. The music
library's instance id matters: the library database maps every track to it.

Usage: ma-ensure-settings /var/lib/private/music-assistant/settings.json
"""

import json
import os
import shutil
import sys

REQUIRED_PROVIDERS = {
    "squeezelite": {
        "values": {},
        "type": "player",
        "domain": "squeezelite",
        "instance_id": "squeezelite",
        "enabled": True,
        "name": None,
        "default_name": "Squeezelite",
        "last_error": None,
    },
    "filesystem_local--cd62YU9B": {
        "values": {"path": "/srv/music", "content_type": "music"},
        "type": "music",
        "domain": "filesystem_local",
        "instance_id": "filesystem_local--cd62YU9B",
        "enabled": True,
        "name": None,
        "default_name": "Filesystem (local disk)",
        "last_error": None,
    },
}


def load(path):
    try:
        with open(path) as f:
            data = json.load(f)
        return data if isinstance(data, dict) else None
    except (OSError, ValueError):
        return None


def main():
    path = sys.argv[1]
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data = load(path)
    if data is None:
        print("settings.json missing or corrupt, trying the backup")
        data = load(path + ".backup")
    if data is None:
        print("no usable settings; Music Assistant starts fresh, providers added")
        data = {}

    changed = False
    providers = data.setdefault("providers", {})
    # A second filesystem_local with another id would duplicate the library.
    for key in [k for k, v in providers.items()
                if isinstance(v, dict) and v.get("domain") == "filesystem_local" and k not in REQUIRED_PROVIDERS]:
        print("removing extra music library provider", key)
        del providers[key]
        changed = True
    for key, entry in REQUIRED_PROVIDERS.items():
        cur = providers.get(key)
        if not isinstance(cur, dict) or not cur.get("enabled") or cur.get("values", {}).get("path", entry["values"].get("path")) != entry["values"].get("path"):
            print("restoring provider", key)
            merged = dict(entry)
            if isinstance(cur, dict):
                merged["values"] = {**cur.get("values", {}), **entry["values"]}
            providers[key] = merged
            changed = True

    if changed:
        if os.path.exists(path):
            shutil.copy2(path, path + ".before-ensure")
        tmp = path + ".tmp"
        with open(tmp, "w") as f:
            json.dump(data, f, indent=2)
            f.flush()
            os.fsync(f.fileno())
        # Music Assistant runs as a dynamic user that owns its state dir; this
        # runs as root, so hand the file back.
        st = os.stat(os.path.dirname(path))
        os.chown(tmp, st.st_uid, st.st_gid)
        os.chmod(tmp, 0o600)
        os.replace(tmp, path)  # atomic: a power cut leaves old or new, never half
        print("settings.json repaired")
    else:
        print("settings.json ok")


if __name__ == "__main__":
    main()
