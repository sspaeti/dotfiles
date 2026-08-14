#!/bin/bash

# Launch terminal -> ws1, Brave -> ws2, Obsidian -> ws3.
#
# QUATTRO NOTE: with the Lua config, `hyprctl dispatch` parses its argument as
# Lua, not as the old conf syntax. `hyprctl dispatch workspace 1` and
# `hyprctl dispatch movetoworkspace "1,address:0x.."` now fail with
#   error: ')' expected near '1'
# and exit 7. Use the hl.* dispatchers instead:
#   focus workspace  ->  hl.dsp.focus({ workspace = N })
#   move a window    ->  hl.dsp.window.move({ workspace = N, window = "address:0x..", follow = false })
# `hyprctl keyword` is gone entirely ("can't work with non-legacy parsers").

# Check WiFi health and notify if issues detected
~/.config/hypr/sspaeti/wifi/check-wifi-startup.sh &

focus_ws() { hyprctl dispatch "hl.dsp.focus({ workspace = $1 })" >/dev/null; }

move_to_ws() { # move_to_ws <workspace> <address>
    hyprctl dispatch "hl.dsp.window.move({ workspace = $1, window = \"address:$2\", follow = false })" >/dev/null
}

# wait_for_window <class-regex> [timeout-seconds] -> prints address, or nothing on timeout.
# Matches on a regex because app classes drift between releases (Obsidian ships
# as "md.obsidian.Obsidian" now, it used to be plain "obsidian"). A hard timeout
# keeps a class rename from leaving this script spinning forever.
wait_for_window() {
    local re=$1 deadline=$((SECONDS + ${2:-30})) addr=
    while [ -z "$addr" ]; do
        [ "$SECONDS" -ge "$deadline" ] && {
            notify-send "Autostart" "Timed out waiting for window: $re" &
            return 1
        }
        sleep 0.3
        addr=$(hyprctl clients -j | jq -r --arg re "$re" \
            'first(.[] | select(.class | test($re; "i")) | .address) // empty')
    done
    printf '%s\n' "$addr"
}

# Touch workspaces to force monitor assignment
focus_ws 1
focus_ws 2
focus_ws 3
focus_ws 1

# Determine default terminal class for window detection
TERM_CLASS=$(grep -v '^#' ~/.config/xdg-terminals.list 2>/dev/null | grep -v '^$' | head -1 | sed 's/\.desktop$//')
TERM_CLASS=${TERM_CLASS:-foot}

# Launch default terminal with tmux → workspace 1
uwsm app -- xdg-terminal-exec tmux &
term_addr=$(wait_for_window "^${TERM_CLASS}$") && move_to_ws 1 "$term_addr"

# Launch Brave → workspace 2
# Wait for gnome-keyring-daemon to be ready (fixes keyring race condition and multiple keyring files at ~/.local/share/keyrings)
while ! systemctl --user is-active --quiet gnome-keyring-daemon.service; do
    sleep 0.2
done

# Fix Ente Auth keyring integration (prevents duplicate keyring creation)
# ~/.config/hypr/sspaeti/fix-ente-keyring.sh > /tmp/keyring-fix-startup.log 2>&1

# brave --password-store=basic --new-window --ozone-platform=wayland --force-device-scale-factor=1.0 &
brave --new-window --ozone-platform=wayland --force-device-scale-factor=1.0 &
brave_addr=$(wait_for_window "^brave-browser$" 60) && move_to_ws 2 "$brave_addr"

# Launch Obsidian → workspace 3
obsidian &
# obsidian --disable-gpu &
obsidian_addr=$(wait_for_window "obsidian" 60) && move_to_ws 3 "$obsidian_addr"

# Switch to workspace 1 when done
focus_ws 1
