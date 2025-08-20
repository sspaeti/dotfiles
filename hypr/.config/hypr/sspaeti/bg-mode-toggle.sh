#!/bin/bash

# Background management script
# Usage: bg-mode-toggle.sh [switch|next|restore]
#   switch: Toggle between Omarchy and personal images (default)
#   next: Cycle to next personal image (only works in personal mode)
#   restore: Restore personal background on startup (if in personal mode)

STATE_FILE="$HOME/.config/hypr/sspaeti/.bg_mode_state"
CURRENT_IMAGE_FILE="$HOME/.config/hypr/sspaeti/.current_personal_image"
ASIA_PICS_DIR="/home/sspaeti/Simon/Sync/Pics/Desktop/Asia 2017"

# Initialize state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "omarchy" > "$STATE_FILE"
fi

# Function to set a personal background image
set_personal_image() {
    local image_path="$1"
    local message="$2"
    
    swaybg -i "$image_path" &
    sleep 0.5
    pkill -o swaybg
    echo "$image_path" > "$CURRENT_IMAGE_FILE"
    notify-send "Background" "Next personal image"
}

# Function to get next personal image in sequence
get_next_personal_image() {
    if [ ! -d "$ASIA_PICS_DIR" ]; then
        notify-send "Background Error" "Asia 2017 folder not found"
        return 1
    fi

    # Get all images in sorted order
    mapfile -t images < <(find "$ASIA_PICS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

    if [ ${#images[@]} -eq 0 ]; then
        notify-send "Background Error" "No images found in Asia 2017 folder"
        return 1
    fi

    # Get current image index
    local current_index=0
    if [ -f "$CURRENT_IMAGE_FILE" ]; then
        local current_image=$(cat "$CURRENT_IMAGE_FILE")
        for i in "${!images[@]}"; do
            if [ "${images[$i]}" = "$current_image" ]; then
                current_index=$i
                break
            fi
        done
    fi

    # Get next image (cycle back to 0 if at end)
    local next_index=$(( (current_index + 1) % ${#images[@]} ))
    local next_image="${images[$next_index]}"
    local image_name=$(basename "$next_image")
    
    set_personal_image "$next_image" "$image_name ($(($next_index + 1))/${#images[@]})"
}

# Function to get random personal image
get_random_personal_image() {
    if [ ! -d "$ASIA_PICS_DIR" ]; then
        notify-send "Background Error" "Asia 2017 folder not found"
        return 1
    fi

    local random_image=$(find "$ASIA_PICS_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
    if [ -n "$random_image" ]; then
        set_personal_image "$random_image" "Switched to Asia 2017 images"
    else
        notify-send "Background Error" "No images found in Asia 2017 folder"
        return 1
    fi
}

# Read current state
current_mode=$(cat "$STATE_FILE")

# Handle command line argument
action="${1:-switch}"

case "$action" in
    "next")
        if [ "$current_mode" = "personal" ]; then
            get_next_personal_image
        else
            notify-send "Background Mode" "Switch to personal mode first (use 'switch')"
        fi
        ;;
    "restore")
        # Restore personal background on startup if in personal mode
        if [ "$current_mode" = "personal" ] && [ -f "$CURRENT_IMAGE_FILE" ]; then
            image_path=$(cat "$CURRENT_IMAGE_FILE")
            if [ -f "$image_path" ]; then
                # Wait for Omarchy's swaybg to start first
                sleep 1
                # Start new swaybg with personal image
                swaybg -i "$image_path" &
                sleep 0.5
                # Kill the old swaybg (Omarchy's)
                pkill -o swaybg
            fi
        fi
        ;;
    "switch"|*)
        if [ "$current_mode" = "omarchy" ]; then
            # Switch to personal Asia images
            echo "personal" > "$STATE_FILE"
            get_random_personal_image
        else
            # Switch to Omarchy backgrounds
            echo "omarchy" > "$STATE_FILE"
            ~/.local/share/omarchy/bin/omarchy-theme-bg-next
            notify-send "Background Mode" "Switched to Omarchy backgrounds"
        fi
        ;;
esac
