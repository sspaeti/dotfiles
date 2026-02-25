#!/bin/bash

# Touch workspaces to force monitor assignment
hyprctl dispatch workspace 1
hyprctl dispatch workspace 2
hyprctl dispatch workspace 3

# Determine default terminal class for window detection
TERM_CLASS=$(grep -v '^#' ~/.config/xdg-terminals.list 2>/dev/null | grep -v '^$' | head -1 | sed 's/\.desktop$//')
TERM_CLASS=${TERM_CLASS:-foot}

# Launch default terminal with tmux → workspace 1
uwsm app -- xdg-terminal-exec tmux &
while [ -z "$term_addr" ]; do
    sleep 0.2
    term_addr=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$TERM_CLASS\") | .address")
done
hyprctl dispatch movetoworkspace "1,address:$term_addr"

# Launch Brave → workspace 2
# Wait for gnome-keyring-daemon to be ready (fixes keyring race condition and multiple keyring files at ~/.local/share/keyrings)
while ! systemctl --user is-active --quiet gnome-keyring-daemon.service; do
    sleep 0.2
done

# Fix Ente Auth keyring integration (prevents duplicate keyring creation)
# ~/.config/hypr/sspaeti/fix-ente-keyring.sh > /tmp/keyring-fix-startup.log 2>&1

# brave --password-store=basic --new-window --ozone-platform=wayland --force-device-scale-factor=1.0 &
brave --new-window --ozone-platform=wayland --force-device-scale-factor=1.0 &
while [ -z "$brave_addr" ]; do
    sleep 0.5
    brave_addr=$(hyprctl clients -j | jq -r '.[] | select(.class == "brave-browser") | .address')
done
hyprctl dispatch movetoworkspace "2,address:$brave_addr"

# Launch Obsidian → workspace 3
obsidian &
# obsidian --disable-gpu &
while [ -z "$obsidian_addr" ]; do
    sleep 0.5
    obsidian_addr=$(hyprctl clients -j | jq -r '.[] | select(.class == "obsidian") | .address')
done
hyprctl dispatch movetoworkspace "3,address:$obsidian_addr"

# Optional: Switch to workspace 1 when done
hyprctl dispatch workspace 1
