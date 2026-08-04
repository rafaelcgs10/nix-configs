#!/usr/bin/env python3
"""Make clangd understand darktable's introspection-wrapped modules.

darktable compiles its IOP/lib modules (e.g. src/iop/colorin.c) indirectly:
CMake generates an `introspection_<name>.c` wrapper that #includes the real
source, and only the wrapper gets a compile_commands.json entry. When you open
the *real* source in Emacs/clangd there is no matching command, clangd guesses
flags, misses `-I src` / `-DHAVE_CONFIG_H`, and reports bogus errors such as
`unknown type name 'dt_colormatrix_t'`.

This script reads build/compile_commands.json and, for every
`introspection_<name>.<ext>` entry, appends an identical entry pointing at the
real `src/**/<name>.<ext>` source (same flags, generated file swapped out).

Run it from the repo root after every `cmake` (re)configure:
    python3 fix-compile-commands.py            # uses ./build
    python3 fix-compile-commands.py path/to/build
"""
import json
import os
import sys
import glob

build = sys.argv[1] if len(sys.argv) > 1 else "build"
db_path = os.path.join(build, "compile_commands.json")
db = json.load(open(db_path))

# basename -> real source path (first match wins)
srcs = {}
for pat in ("src/**/*.c", "src/**/*.cc", "src/**/*.cpp"):
    for f in glob.glob(pat, recursive=True):
        srcs.setdefault(os.path.basename(f), os.path.abspath(f))

existing = {e["file"] for e in db}
added = 0
new_entries = []
for e in db:
    base = os.path.basename(e["file"])
    if not base.startswith("introspection_"):
        continue
    real_name = base[len("introspection_"):]
    real = srcs.get(real_name)
    if not real or real in existing:
        continue
    gen = e["file"]  # absolute path of the generated wrapper
    clone = dict(e)
    clone["file"] = real
    if "arguments" in e:
        clone["arguments"] = [real if a == gen else a for a in e["arguments"]]
    if "command" in e:
        clone["command"] = e["command"].replace(gen, real)
    new_entries.append(clone)
    existing.add(real)
    added += 1

db.extend(new_entries)
json.dump(db, open(db_path, "w"), indent=1)
print(f"added {added} real-source entries to {db_path}")
