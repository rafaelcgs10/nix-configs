"""Replace whole sections of PCSX2.ini with the given block, keeping the rest.

usage: pcsx2-pad.py <PCSX2.ini> <block-file>
The block file holds complete [Section] blocks. Every section it contains is
removed from the ini (PCSX2 stores multi-bindings as repeated keys, so a
plain key/value merge would not do) and the block is appended. Writes only
when the result differs.
"""
import re
import sys

ini_path, block_path = sys.argv[1], sys.argv[2]
with open(block_path) as f:
    block = f.read().rstrip("\n") + "\n"
sections = set(re.findall(r"^\[([^\]]+)\]\s*$", block, re.M))

try:
    with open(ini_path) as f:
        lines = f.read().split("\n")
except FileNotFoundError:
    lines = []

out, skip = [], False
for line in lines:
    m = re.match(r"^\[([^\]]+)\]\s*$", line)
    if m:
        skip = m.group(1) in sections
    if not skip:
        out.append(line)
body = "\n".join(out).rstrip("\n")
new = (body + "\n\n\n" if body else "") + block
old = "\n".join(lines)
if new != old:
    with open(ini_path, "w") as f:
        f.write(new)
    print(f"pcsx2-pad: updated {', '.join(sorted(sections))} in {ini_path}")
