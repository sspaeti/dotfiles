#!/bin/bash
# Open omapic on the most-recent screenshot for a quick cut-out.

[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
PICS="${XDG_PICTURES_DIR:-$HOME/Pictures}"

# Newest screenshot-*.png anywhere under Pictures (root + monthly folders).
latest="$(find "$PICS" -type f -name 'screenshot-*.png' -printf '%T@ %p\n' 2>/dev/null \
          | sort -nr | head -1 | cut -d' ' -f2-)"

if [[ -n "$latest" ]]; then
    exec omapic "$latest"
else
    exec omapic --clipboard
fi
