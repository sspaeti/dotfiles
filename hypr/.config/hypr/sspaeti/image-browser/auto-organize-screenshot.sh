#!/bin/bash

# Auto-organizer for new screenshots - call this after taking screenshots

PICTURES_DIR="/home/sspaeti/Pictures"
PRINTSCREEN_DIR="$PICTURES_DIR/Printscreen"

# Get current year-month
CURRENT_MONTH=$(date +%Y-%m)
MONTH_DIR="$PRINTSCREEN_DIR/$CURRENT_MONTH"

# Create monthly directory if it doesn't exist
mkdir -p "$MONTH_DIR"

# Function to move screenshot to monthly folder
organize_screenshot() {
    local screenshot_path="$1"
    local filename=$(basename "$screenshot_path")
    local destination="$MONTH_DIR/$filename"
    
    # Move to monthly folder
    mv "$screenshot_path" "$destination"
    echo "Screenshot organized: $destination"
    
    # Optional: Add to OCR index immediately (background smart update)
    nohup "$PICTURES_DIR/screenshot-indexer-parallel.sh" --smart >/dev/null 2>&1 &
}

# If called with a screenshot path argument
if [[ -n "$1" && -f "$1" ]]; then
    organize_screenshot "$1"
else
    # Look for recent screenshots in Pictures directory
    find "$PICTURES_DIR" -maxdepth 1 -name "*.png" -mmin -1 | while read -r screenshot; do
        organize_screenshot "$screenshot"
    done
fi