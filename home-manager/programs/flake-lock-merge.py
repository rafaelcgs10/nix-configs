import json
import shutil
import sys

# git calls merge drivers as: driver %O %A %B  (base, ours, theirs);
# the result must be written to %A.
_base, ours, theirs = sys.argv[1:4]


def newest(path):
    with open(path) as f:
        lock = json.load(f)
    stamps = [
        n.get("locked", {}).get("lastModified", 0)
        for n in lock.get("nodes", {}).values()
    ]
    return max(stamps, default=0)


try:
    keep_theirs = newest(theirs) >= newest(ours)
except (OSError, ValueError):
    sys.exit(1)  # not JSON on one side: leave the conflict to a human

if keep_theirs:
    shutil.copyfile(theirs, ours)
print(
    "flake.lock: kept the newer side ("
    + ("theirs" if keep_theirs else "ours")
    + ")",
    file=sys.stderr,
)
