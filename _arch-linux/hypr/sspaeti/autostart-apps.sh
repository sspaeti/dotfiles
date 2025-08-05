#!/bin/bash

# Touch workspaces to force monitor assignment
hyprctl dispatch workspace 1
hyprctl dispatch workspace 2
hyprctl dispatch workspace 3

# Launch Alacritty with tmux → workspace 1
alacritty -e tmux &
while [ -z "$alacritty_addr" ]; do
    sleep 0.2
    alacritty_addr=$(hyprctl clients -j | jq -r '.[] | select(.class == "Alacritty") | .address')
done
hyprctl dispatch movetoworkspace "1,address:$alacritty_addr"

# Launch Brave → workspace 2
brave --new-window --ozone-platform=wayland --force-device-scale-factor=1.0 &
while [ -z "$brave_addr" ]; do
    sleep 0.5
    brave_addr=$(hyprctl clients -j | jq -r '.[] | select(.class == "brave-browser") | .address')
done
hyprctl dispatch movetoworkspace "2,address:$brave_addr"

# Launch Obsidian → workspace 3
obsidian --disable-gpu &
while [ -z "$obsidian_addr" ]; do
    sleep 0.5
    obsidian_addr=$(hyprctl clients -j | jq -r '.[] | select(.class == "obsidian") | .address')
done
hyprctl dispatch movetoworkspace "3,address:$obsidian_addr"

# Optional: Switch to workspace 1 when done
hyprctl dispatch workspace 1
