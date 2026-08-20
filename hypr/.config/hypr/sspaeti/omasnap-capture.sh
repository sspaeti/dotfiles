#!/bin/bash

# Omasnap capture wrapper: save straight into the monthly Printscreen folder.
#
# Omasnap captures, edits, and outputs on its own (Enter = copy + save; the
# image lands on the clipboard instantly). This wrapper only points the save
# target at the current YYYY-MM folder, silences the save/copy notification,
# and refreshes the OCR index when a capture landed. The clipboard is left
# entirely to omasnap — copy-last-screenshot-path.sh (Super+Alt+Ctrl+C) grabs
# the saved file's path on demand.
#
# Usage: omasnap-capture.sh [omasnap args, e.g. --copy | fullscreen | windows]
#
# Toggle behavior: omasnap is single-instance — invoking it while an overlay
# is open dismisses that overlay and exits without capturing, so a second
# hotkey press closes the picker and the new-file check below finds nothing.

# Hyprland's session PATH puts /usr/bin before ~/.local/bin, which would
# resolve the pacman omasnap instead of the locally installed fork build.
export PATH="$HOME/.local/bin:$PATH"

SSP_DIR="$HOME/.config/hypr/sspaeti"
MONTH_DIR="$HOME/Pictures/Printscreen/$(date +%Y-%m)"
mkdir -p "$MONTH_DIR"
export OMASNAP_SCREENSHOT_DIR="$MONTH_DIR"

# Anything saved after this marker was produced by this invocation.
MARKER=$(mktemp -t omasnap-capture.XXXXXX)
trap 'rm -f "$MARKER"' EXIT

# The no-op omarchy-notification-send shim silences the saved/copied toast.
PATH="$SSP_DIR/no-notification-shim:$PATH" omasnap "$@"

# Same background OCR-index hook auto-organize-screenshot.sh uses.
INDEXER="$SSP_DIR/image-browser/screenshot-indexer-parallel.sh"
if [[ -x $INDEXER ]] &&
  find "$MONTH_DIR" -maxdepth 1 -name '*.png' -newer "$MARKER" | grep -q .; then
  nohup "$INDEXER" --smart >/dev/null 2>&1 &
fi
