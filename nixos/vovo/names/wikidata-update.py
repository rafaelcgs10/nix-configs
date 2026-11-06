"""Refresh the vendored Wikidata snapshot used by vovo's name correction.

    nix run .#vovo-names-update            # from the repo root, then commit

Writes, into nixos/vovo/names (or the directory given as argument):

  wikidata-artists.csv  name, aliases ("|"-separated), sitelinks
  wikidata-works.csv    title, by (performer or composer), sitelinks

Well-known = many Wikipedia language editions (sitelinks), which keeps the
lists to the names people actually ask for. Composers carry their English
aliases, so "Tchaikovsky" finds "Pyotr Ilyich Tchaikovsky". Output is sorted,
so a refresh shows up as a readable diff.

Query results change over time, so this is a vendored snapshot rather than a
fixed-output fetch (whose hash would break the build after every change).
"""

import csv
import io
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

UA = "vovo-names/1.0 (personal voice music box; https://github.com/rafaelcgs10/nix-configs)"
ENDPOINT = "https://query.wikidata.org/sparql"

# (pattern binding ?a, minimum sitelinks, fetch aliases). Aliases are fetched
# for composers only (people say "Tchaikovsky", not "Pyotr Ilyich ..."), and
# their surname is added too: Wikidata rarely lists it as an alias.
ARTIST_CLASSES = [
    ("?a wdt:P31 wd:Q215380", 20, False),    # band
    ("?a wdt:P31 wd:Q2088357", 20, False),   # musical group
    ("?a wdt:P106 wd:Q177220", 25, False),   # singer
    ("?a wdt:P106 wd:Q639669", 30, False),   # musician
    ("?a wdt:P106 wd:Q2252262", 20, False),  # rapper
    ("?a wdt:P106 wd:Q36834", 25, True),     # composer
]
ARTISTS = """
SELECT ?l (GROUP_CONCAT(DISTINCT ?alt; SEPARATOR="|") AS ?alts) (MAX(?s) AS ?sl) WHERE {
  %s . ?a wikibase:sitelinks ?s . FILTER(?s >= %d)
  ?a rdfs:label ?l FILTER(lang(?l) = "en")
  %s
} GROUP BY ?l
"""
ALIASES = 'OPTIONAL { ?a skos:altLabel ?alt FILTER(lang(?alt) = "en") }'

# (class, minimum sitelinks); only works with a performer or composer, which
# keeps out films and books that share a title.
WORK_CLASSES = [
    ("Q105543609", 12),  # musical work/composition
    ("Q7366", 12),       # song
    ("Q134556", 12),     # single
    ("Q15079786", 10),   # ballet
    ("Q58483088", 10),   # choreographic work (The Nutcracker)
]
WORKS = """
SELECT ?l ?by (MAX(?s) AS ?sl) WHERE {
  ?w wdt:P31 wd:%s . ?w wikibase:sitelinks ?s . FILTER(?s >= %d)
  ?w wdt:P175|wdt:P86 ?p . ?p rdfs:label ?by FILTER(lang(?by) = "en")
  ?w rdfs:label ?l FILTER(lang(?l) = "en")
} GROUP BY ?l ?by
"""


def sparql(query):
    url = ENDPOINT + "?" + urllib.parse.urlencode({"query": query})
    req = urllib.request.Request(url, headers={"Accept": "text/csv", "User-Agent": UA})
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=180) as r:
                return list(csv.DictReader(io.StringIO(r.read().decode())))
        except (urllib.error.URLError, TimeoutError) as e:
            print(f"  attempt {attempt + 1} failed: {e}", file=sys.stderr)
            time.sleep(10 * (attempt + 1))
    sys.exit("Wikidata query kept failing; nothing written")


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "nixos/vovo/names"
    if not os.path.isdir(out):
        sys.exit(f"{out}: not a directory (run from the nix-configs repo root)")

    artists = {}
    for pattern, minimum, aliases in ARTIST_CLASSES:
        rows = sparql(ARTISTS % (pattern, minimum, ALIASES if aliases else ""))
        print(f"{pattern}: {len(rows)}", file=sys.stderr)
        for r in rows:
            name, sl = r["l"].strip(), int(r["sl"])
            alts = {a.strip() for a in r["alts"].split("|") if a.strip() and a.strip() != name}
            if aliases and " " in name:
                alts.add(name.split()[-1])
            old = artists.get(name)
            if old:
                alts |= old[0]
                sl = max(sl, old[1])
            artists[name] = (alts, sl)
        time.sleep(2)

    works = {}
    for cls, minimum in WORK_CLASSES:
        rows = sparql(WORKS % (cls, minimum))
        print(f"{cls}: {len(rows)}", file=sys.stderr)
        for r in rows:
            key = (r["l"].strip(), r["by"].strip())
            works[key] = max(works.get(key, 0), int(r["sl"]))
        time.sleep(2)

    with open(os.path.join(out, "wikidata-artists.csv"), "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["name", "aliases", "sitelinks"])
        for name in sorted(artists, key=str.casefold):
            alts, sl = artists[name]
            w.writerow([name, "|".join(sorted(alts, key=str.casefold)), sl])
    with open(os.path.join(out, "wikidata-works.csv"), "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["title", "by", "sitelinks"])
        for (title, by) in sorted(works, key=lambda k: (k[0].casefold(), k[1].casefold())):
            w.writerow([title, by, works[(title, by)]])
    print(f"wrote {len(artists)} artists, {len(works)} works to {out}", file=sys.stderr)


main()
