#!/usr/bin/env bash
# Jump to terminal and switch to email tmux session

TERMINAL_CLASS="foot"
SESSION_TARGET="neomd:reading"  # Change this if your session name is different

# Get the address of the first terminal window
TERMINAL_ADDR=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$TERMINAL_CLASS\") | .address" | head -n1)

if [ -n "$TERMINAL_ADDR" ]; then
    # Focus the terminal window
    hyprctl dispatch focuswindow "address:$TERMINAL_ADDR"

    # sleep 0.0000000000000000001

    # Switch to the target tmux session directly
    tmux switch-client -t "$SESSION_TARGET" 2>/dev/null
else
    notify-send "Terminal not found" "No $TERMINAL_CLASS window is currently open" -t 3000
fi
