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

# The no-op omarchy-notification-send shim silences the saved/copied toast.
# OCR happens in the sspaeti.clipboard plugin when the image hits the
# clipboard — the old screenshot-indexer script stays retired.
PATH="$SSP_DIR/no-notification-shim:$PATH" omasnap "$@"
