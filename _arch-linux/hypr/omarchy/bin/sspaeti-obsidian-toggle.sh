#!/bin/bash
# Save as ~/.config/hypr/scripts/obsidian-smart-focus.sh

OBSIDIAN_INFO=$(hyprctl clients | grep -A 10 "class: obsidian")

if [ -n "$OBSIDIAN_INFO" ]; then
    # Get workspace of obsidian window
    WORKSPACE=$(echo "$OBSIDIAN_INFO" | grep "workspace:" | head -1 | awk '{print $2}')
    
    # Switch to workspace and focus window
    hyprctl dispatch workspace "$WORKSPACE"
    hyprctl dispatch focuswindow "class:obsidian"
else
    # Obsidian is not running, start it
    obsidian --disable-gpu
fi
