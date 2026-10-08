#!/usr/bin/env python3
"""Regenerate nerdfonts.tsv from the Nerd Fonts project's glyphnames.json.

Source (public, MIT): https://github.com/ryanoasis/nerd-fonts — the file
`glyphnames.json` at a release tag is the official name → codepoint map.
No font data is downloaded; the glyphs render through the Nerd Font that
Omarchy already ships.

Adapted from tools/convert_nerd.py in
https://github.com/farangkao/omarchy-emojis-nerd (MIT, see
THIRD_PARTY_NOTICES.md). Changes: resolves the latest release by default,
tracks the installed version in NERDFONTS_VERSION, and reports the glyphs
added/removed compared to the current nerdfonts.tsv.

Output: one line per unique codepoint, `keywords <TAB> nf-name <TAB> hex`.
Keywords are the nf-prefixed name, the raw name, the dashed name and the
name's words minus the set prefix. Set labels ("material", "fontawesome")
are left out on purpose: they would match thousands of glyphs; narrow by
prefix instead ("md home").

The picker greps the file on every search, so a new dataset applies on the
next search with no shell restart.

Usage:
    ./update-nerdfonts.py            # latest release -> nerdfonts.tsv
    ./update-nerdfonts.py --check    # report only, write nothing
    ./update-nerdfonts.py --version 3.5.0
"""
import argparse
import json
import re
import sys
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
TSV = HERE / "nerdfonts.tsv"
VERSION_FILE = HERE / "NERDFONTS_VERSION"
GLYPHS_URL = "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v{version}/glyphnames.json"
LATEST_URL = "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"


def fetch_json(url):
    req = urllib.request.Request(url, headers={"User-Agent": "sspaeti-emojis-update"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


def latest_version():
    return re.sub(r"^v", "", fetch_json(LATEST_URL)["tag_name"])


def installed_version():
    return VERSION_FILE.read_text().strip() if VERSION_FILE.exists() else "unknown"


def keywords_for(names):
    words = set()
    for n in names:
        words.add("nf-" + n)
        words.add(n)
        words.add(n.replace("_", "-"))
        parts = n.replace("-", " ").replace("_", " ").split()
        for w in parts[1:]:
            if w:
                words.add(w)
    return " ".join(sorted(words))


def build_rows(data):
    by_code = {}  # hex codepoint -> names (aliases share a codepoint)
    for name, meta in data.items():
        if name == "METADATA":
            continue
        by_code.setdefault(meta["code"].lower(), set()).add(name)
    rows = []
    for code, names in by_code.items():
        primary = sorted(names)[0]
        rows.append((f"nf-{primary}", f"{keywords_for(names)}\tnf-{primary}\t{code}"))
    rows.sort(key=lambda r: r[0])
    return rows


def current_codes():
    """hex codepoint -> nf-name from the nerdfonts.tsv on disk."""
    out = {}
    if not TSV.exists():
        return out
    for line in TSV.read_text().splitlines():
        f = line.split("\t")
        if len(f) == 3:
            out[f[2]] = f[1]
    return out


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--version", help="Nerd Fonts release to use (default: latest on GitHub)")
    p.add_argument("--check", action="store_true", help="report changes, write nothing")
    args = p.parse_args()

    version = re.sub(r"^v", "", args.version) if args.version else latest_version()
    print(f"installed: {installed_version()}   target: {version}")

    data = fetch_json(GLYPHS_URL.format(version=version))
    rows = build_rows(data)
    new = {r[1].split("\t")[2]: r[0] for r in rows}
    old = current_codes()
    added = sorted(new[c] for c in new.keys() - old.keys())
    removed = sorted(old[c] for c in old.keys() - new.keys())
    print(f"glyphs: {len(old)} -> {len(new)}   added: {len(added)}   removed: {len(removed)}")
    for n in added[:20]:
        print(f"  + {n}")
    if len(added) > 20:
        print(f"  … {len(added) - 20} more")
    for n in removed[:20]:
        print(f"  - {n}")
    if len(removed) > 20:
        print(f"  … {len(removed) - 20} more")

    if args.check:
        return 1 if (added or removed or installed_version() != version) else 0

    TSV.write_text("\n".join(r[1] for r in rows) + "\n")
    VERSION_FILE.write_text(version + "\n")
    print(f"wrote {TSV.name} ({len(rows)} glyphs) and {VERSION_FILE.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
