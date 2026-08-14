#!/bin/bash
#
# Regenerates the Omarchy emoji picker's data from the DATA block at the bottom
# of emoji-fuzzy.sh, which stays the source of truth for the personal keyword set.
#
# Background: emoji-fuzzy.sh used to pipe "<emoji> <keywords...>" lines into
# `walker --dmenu`. Under Omarchy Quattro that renders as a plain text list
# rather than the emoji grid. Omarchy's built-in picker already is that grid and
# reads a simple JSON list, so the data lives there now. The plugin was cloned
# with `omarchy plugin clone omarchy.emojis`, which makes it user-owned and
# survives Omarchy updates.
#
# Usage: emoji-data-sync.sh        # regenerate after editing emoji-fuzzy.sh
#
# Line format expected in the DATA block:
#   <emoji><space><keywords...>

set -euo pipefail

SRC="$HOME/.config/hypr/sspaeti/emoji-fuzzy.sh"
DEST="$HOME/.config/omarchy/plugins/sspaeti.emojis/emojis.json"

[[ -f $SRC ]] || { echo "source not found: $SRC" >&2; exit 1; }
[[ -d ${DEST%/*} ]] || {
  echo "plugin not found: ${DEST%/*}" >&2
  echo "run: omarchy plugin clone omarchy.emojis" >&2
  exit 1
}

python3 - "$SRC" "$DEST" <<'PY'
import json, re, sys

src, dest = sys.argv[1], sys.argv[2]
data = open(src, encoding="utf-8").read().split("### DATA ###\n", 1)[1]

out, skipped = [], []
for line in data.splitlines():
    line = line.strip()
    if not line:
        continue
    emoji, _, keywords = line.partition(" ")
    if not emoji:
        continue
    # A purely ASCII first field means the line isn't "<emoji> <keywords>".
    if re.fullmatch(r"[A-Za-z0-9:;._-]+", emoji):
        skipped.append(line)
        continue
    out.append({"e": emoji, "k": keywords.strip().lower()})

json.dump(out, open(dest, "w", encoding="utf-8"), ensure_ascii=False)
print(f"wrote {len(out)} emojis to {dest}")
for s in skipped:
    print(f"  skipped (no leading emoji): {s}")
PY

# The shell polls its plugin data, but reload immediately so the change is live.
omarchy-shell -q shell reload 2>/dev/null || true
