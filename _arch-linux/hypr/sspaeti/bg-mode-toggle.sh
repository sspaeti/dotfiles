#!/bin/bash

# Toggle between Omarchy backgrounds and personal Asia 2017 images
STATE_FILE="$HOME/.config/hypr/sspaeti/.bg_mode_state"
ASIA_PICS_DIR="/home/sspaeti/Simon/Sync/Pics/Desktop/Asia 2017"

# Initialize state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "omarchy" > "$STATE_FILE"
fi

# Read current state
current_mode=$(cat "$STATE_FILE")

if [ "$current_mode" = "omarchy" ]; then
    # Switch to personal Asia images
    echo "personal" > "$STATE_FILE"
    
    # Get a random image from Asia 2017 folder
    if [ -d "$ASIA_PICS_DIR" ]; then
        random_image=$(find "$ASIA_PICS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
        if [ -n "$random_image" ]; then
            swaybg -i "$random_image" &
            # Kill any existing swaybg processes except the new one
            sleep 0.5
            pkill -o swaybg
            notify-send "Background Mode" "Switched to Asia 2017 images"
        else
            notify-send "Background Error" "No images found in Asia 2017 folder"
        fi
    else
        notify-send "Background Error" "Asia 2017 folder not found"
    fi
else
    # Switch to Omarchy backgrounds
    echo "omarchy" > "$STATE_FILE"
    ~/.local/share/omarchy/bin/omarchy-theme-bg-next
    notify-send "Background Mode" "Switched to Omarchy backgrounds"
fi