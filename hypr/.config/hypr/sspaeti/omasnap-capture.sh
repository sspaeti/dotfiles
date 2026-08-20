#!/bin/bash

# Omasnap capture wrapper: save straight into the monthly Printscreen folder.
#
# Omasnap captures, edits, and outputs on its own (Enter = copy + save); this
# wrapper only points its save target at the current YYYY-MM folder so no
# post-hoc move is needed (keeps the notification's click-to-edit path valid)
# and refreshes the OCR index when a capture landed.
#
# Usage: omasnap-capture.sh [omasnap args, e.g. --copy | fullscreen | windows]
#
# Toggle behavior: omasnap is single-instance — invoking it while an overlay
# is open dismisses that overlay and exits without capturing, so a second
# hotkey press closes the picker and the index check below finds nothing.

# Hyprland's session PATH puts /usr/bin before ~/.local/bin, which would
# resolve the pacman omasnap instead of the locally installed fork build.
export PATH="$HOME/.local/bin:$PATH"

MONTH_DIR="$HOME/Pictures/Printscreen/$(date +%Y-%m)"
mkdir -p "$MONTH_DIR"
export OMASNAP_SCREENSHOT_DIR="$MONTH_DIR"

omasnap "$@"

# Same background OCR-index hook auto-organize-screenshot.sh uses.
INDEXER="$HOME/.config/hypr/sspaeti/image-browser/screenshot-indexer-parallel.sh"
if [[ -x $INDEXER ]] && find "$MONTH_DIR" -maxdepth 1 -name '*.png' -mmin -1 | grep -q .; then
  nohup "$INDEXER" --smart >/dev/null 2>&1 &
fi
