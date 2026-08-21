#!/bin/bash

# Background management script
# Usage: bg-mode-toggle.sh [switch|next|restore]
#   switch: Toggle between Omarchy and personal images (default)
#   next: Cycle to next personal image (auto-switches to personal mode if needed)
#   restore: Restore personal background on startup (if in personal mode)

STATE_FILE="$HOME/.config/hypr/sspaeti/.bg_mode_state"
CURRENT_IMAGE_FILE="$HOME/.config/hypr/sspaeti/.current_personal_image"
ASIA_PICS_DIR="/home/sspaeti/Simon/Sync/Pics/Desktop/Asia 2017"

# Initialize state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "omarchy" > "$STATE_FILE"
fi

# Function to set a personal background image
#
# Omarchy Quattro no longer uses swaybg -- the Omarchy shell (Quickshell) draws
# the background itself from the ~/.local/state/omarchy/current/background
# symlink. omarchy-theme-bg-set repoints that symlink and pushes the change to
# the running shell over IPC, so the old "start swaybg, sleep, kill the previous
# one" dance is gone.
set_personal_image() {
    local image_path="$1"
    local message="$2"

    if ! omarchy-theme-bg-set "$image_path"; then
        notify-send "Background Error" "Could not set $(basename "$image_path")"
        return 1
    fi

    echo "$image_path" > "$CURRENT_IMAGE_FILE"
    # Success is visible on screen; only errors notify.
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
        # Auto-switch to personal mode first if still in omarchy mode
        if [ "$current_mode" != "personal" ]; then
            echo "personal" > "$STATE_FILE"
        fi
        get_next_personal_image
        ;;
    "restore")
        # Restore personal background on startup if in personal mode
        if [ "$current_mode" = "personal" ] && [ -f "$CURRENT_IMAGE_FILE" ]; then
            image_path=$(cat "$CURRENT_IMAGE_FILE")
            if [ -f "$image_path" ]; then
                # Give the Omarchy shell a moment to come up so the IPC push
                # lands. Even if it isn't up yet the symlink is still written and
                # the background plugin picks it up when it starts.
                sleep 1
                omarchy-theme-bg-set "$image_path"
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
            omarchy-theme-bg-next
            notify-send "Background Mode" "Switched to Omarchy backgrounds"
        fi
        ;;
esac
