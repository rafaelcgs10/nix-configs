"""Assert ES-DE's per-system default emulator in a gamelist.xml.

usage: es-alt-emulator.py <gamelist.xml> <label>
ES-DE keeps the choice as an <alternativeEmulator><label>..</label>
</alternativeEmulator> element before <gameList>. Creates the file when
missing, replaces the label when it differs, leaves everything else alone.
"""
import os
import re
import sys

path, label = sys.argv[1], sys.argv[2]
alt = ("<alternativeEmulator>\n\t<label>" + label
       + "</label>\n</alternativeEmulator>")
try:
    with open(path) as f:
        s = f.read()
except FileNotFoundError:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    s = '<?xml version="1.0"?>\n<gameList />\n'

new = re.sub(r"<alternativeEmulator>.*?</alternativeEmulator>", alt, s,
             count=1, flags=re.S)
if new == s and "<alternativeEmulator>" not in s:
    new = re.sub(r"(<\?xml[^>]*\?>\n?)", r"\1" + alt + "\n", s, count=1)
if new != s:
    with open(path, "w") as f:
        f.write(new)
    system = os.path.basename(os.path.dirname(path))
    print(f"es-alt-emulator: {system} -> {label}")
