#!/bin/bash

# Copies the full path of the most recently stored screenshot to the
# clipboard (Super+Alt+Ctrl+C). Complements the omasnap capture flow, which
# leaves the image itself on the clipboard: paste the image as usual, hit
# this bind when a tool (e.g. Claude Code) needs the file path instead.

PRINTSCREEN_DIR="$HOME/Pictures/Printscreen"

LAST=$(find "$PRINTSCREEN_DIR" -maxdepth 2 -type f \
  \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) \
  -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)

if [[ -z $LAST ]]; then
  omarchy-notification-send "No screenshot found" -t 2000
  exit 1
fi

printf '%s' "$LAST" | wl-copy
omarchy-notification-send "Path copied" "$LAST" -t 2000
