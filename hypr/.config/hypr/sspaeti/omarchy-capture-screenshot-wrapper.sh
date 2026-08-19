#!/bin/bash

# Wrapper for omarchy-capture-screenshot with post-processing
# Calls the original omarchy script, then always opens the annotation editor
# and organizes screenshots into monthly folders.
#
# Usage: omarchy-capture-screenshot-wrapper.sh [smart|region|windows|fullscreen] [slurp|copy|save]
#
# QUATTRO notes:
#  - The editor is now Tensaku (satty's replacement). `tensaku-edit` takes the
#    exact same flags satty did and saves in place, so it is a drop-in. Override
#    with OMARCHY_SCREENSHOT_EDITOR=satty if you prefer the old one.
#  - omarchy-capture-screenshot now PRINTS the saved file path on stdout, so the
#    old "ls -t before / ls -t after and diff them" guess is gone. That guess
#    could grab the wrong file if two screenshots landed in the same second.
#  - Quattro no longer opens the editor by itself; it only offers it as a click
#    action on the notification. This wrapper opens it every time, as before.

set -o pipefail

EDITOR_CMD="${OMARCHY_SCREENSHOT_EDITOR:-tensaku-edit}"
ORGANIZER="$HOME/.config/hypr/sspaeti/image-browser/auto-organize-screenshot.sh"

MODE="${1:-smart}"
PROCESSING="${2:-slurp}"

# The old CLI took "clipboard" for copy-only; Quattro calls that mode "copy".
[[ $PROCESSING == "clipboard" ]] && PROCESSING="copy"

# Copy-only never writes a file, so there is nothing to edit or organize.
if [[ $PROCESSING == "copy" ]]; then
  exec omarchy-capture-screenshot "$MODE" copy
fi

# Suppress Quattro's own "click to edit" action: this wrapper opens the editor
# itself, and by the time the notification is clicked the file has already been
# moved into its monthly folder, so the path in that action would be stale.
#
# Also silence the "Screenshot saved to clipboard and file" notification by
# shimming a no-op omarchy-notification-send onto PATH for the capture call.
SHIM_DIR="$(cd "$(dirname "$0")" && pwd)/no-notification-shim"
FILEPATH=$(PATH="$SHIM_DIR:$PATH" OMARCHY_SCREENSHOT_EDITOR=true omarchy-capture-screenshot "$MODE" "$PROCESSING")

# Cancelled selection (Esc) prints nothing.
[[ -z $FILEPATH || ! -f $FILEPATH ]] && exit 0

# Annotate. Tensaku/satty write back over the same path.
"$EDITOR_CMD" "$FILEPATH"

# Post-processing: auto-organize into the year-month folder. Pass the exact path
# instead of letting the organizer re-discover it with `find -mmin -1`.
"$ORGANIZER" "$FILEPATH" >/dev/null 2>&1 &
