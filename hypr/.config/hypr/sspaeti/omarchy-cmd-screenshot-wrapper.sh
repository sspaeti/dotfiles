#!/bin/bash

# Wrapper for omarchy-cmd-screenshot with post-processing
# Calls the original omarchy script, then always opens Satty for editing
# and organizes screenshots into monthly folders

[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
OUTPUT_DIR="${OMARCHY_SCREENSHOT_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}}"

# Record newest screenshot before taking a new one
BEFORE=$(ls -t "$OUTPUT_DIR"/screenshot-*.png 2>/dev/null | head -1)

# Call the original omarchy-cmd-screenshot, suppressing its notification
OMARCHY_SCREENSHOT_EDITOR=true ~/.local/share/omarchy/bin/omarchy-cmd-screenshot "$@"

# Find the newly created screenshot
AFTER=$(ls -t "$OUTPUT_DIR"/screenshot-*.png 2>/dev/null | head -1)

# If a new screenshot was taken, open Satty
if [[ -n "$AFTER" && "$AFTER" != "$BEFORE" ]]; then
    satty --filename "$AFTER" \
        --output-filename "$AFTER" \
        --actions-on-enter save-to-clipboard \
        --save-after-copy \
        --copy-command 'wl-copy'

    # Post-processing: Auto-organize screenshots into year-month folders
    ~/.config/hypr/sspaeti/image-browser/auto-organize-screenshot.sh >/dev/null 2>&1 &
fi
