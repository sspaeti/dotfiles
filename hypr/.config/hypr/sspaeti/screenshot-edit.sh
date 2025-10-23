#!/bin/bash

# Screenshot workflow: hyprshot -> Satty -> Editt
# Simple and focused - no extra processing

# Generate timestamped filename
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
TEMP_FILE="/tmp/satty-$TIMESTAMP.png"

# Take screenshot with Satty for quick annotations
pkill slurp || hyprshot -m region --raw | \
  satty --filename - \
    --output-filename "$TEMP_FILE" \
    --early-exit

# Check if user saved the screenshot (file exists)
if [[ -f "$TEMP_FILE" ]]; then
    # Copy to clipboard
    wl-copy < "$TEMP_FILE"

    # Always open in Editt for advanced editing
    editt "$TEMP_FILE"

    # Clean up temp file after Editt closes
    rm -f "$TEMP_FILE"
else
    notify-send "Screenshot cancelled" -t 1000
fi
