#!/bin/bash

# Screenshot workflow: hyprshot -> Satty -> Editt
# Satty saves directly to Printscreen directory, Editt opens and edits that file

# Set up directory structure with year-month
YEAR_MONTH=$(date +'%Y-%m')
OUTPUT_DIR="$HOME/Pictures/Printscreen/$YEAR_MONTH"

# Create directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate timestamped filename - save directly to final location
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
SCREENSHOT_FILE="$OUTPUT_DIR/screenshot-$TIMESTAMP.png"

# Take screenshot with Satty - save directly to Printscreen directory
pkill slurp || hyprshot -m region --raw | \
  satty --filename - \
    --output-filename "$SCREENSHOT_FILE" \
    --early-exit

# Check if user saved the screenshot (file exists)
if [[ -f "$SCREENSHOT_FILE" ]]; then
    # Copy to clipboard
    wl-copy < "$SCREENSHOT_FILE"

    # Open in Editt for advanced editing
    # Editt will open the file from Printscreen directory and save edits there
    editt "$SCREENSHOT_FILE"

    notify-send "Screenshot saved" "$SCREENSHOT_FILE" -t 2000
else
    notify-send "Screenshot cancelled" -t 1000
fi
