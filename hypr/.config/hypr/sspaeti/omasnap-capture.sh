#!/bin/bash

# Omasnap capture wrapper: save straight into the monthly Printscreen folder.
#
# Omasnap captures, edits, and outputs on its own (Enter = copy + save); this
# wrapper only points its save target at the current YYYY-MM folder so no
# post-hoc move is needed, silences the save/copy notification, seeds the
# clipboard history with the saved file's path (image stays the active entry),
# and refreshes the OCR index when a capture landed.
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

NEW_FILE=$(find "$MONTH_DIR" -maxdepth 1 -name '*.png' -newer "$MARKER" \
  -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)

if [[ -n $NEW_FILE ]]; then
  # Clipboard history ends up: [.., path, image] — image active for pasting,
  # full file path one entry behind it (for Claude Code and friends).
  printf '%s' "$NEW_FILE" | wl-copy
  wl-copy --type image/png <"$NEW_FILE"

  # Same background OCR-index hook auto-organize-screenshot.sh uses.
  INDEXER="$SSP_DIR/image-browser/screenshot-indexer-parallel.sh"
  [[ -x $INDEXER ]] && nohup "$INDEXER" --smart >/dev/null 2>&1 &
fi
