#!/usr/bin/env bash
# Jump to terminal and switch to email tmux session

SESSION_TARGET="neomd:reading"  # Change this if your session name is different

# Match foot launched via omarchy (org.omarchy.zsh / org.omarchy.bash) or vanilla foot
TERMINAL_CLASS_REGEX='^(org\.omarchy\.(zsh|bash)|foot|org\.codeberg\.dnkl\.foot)$'
TERMINAL_ADDR=$(hyprctl clients -j | jq -r --arg re "$TERMINAL_CLASS_REGEX" '.[] | select(.class | test($re)) | .address' | head -n1)

if [ -n "$TERMINAL_ADDR" ]; then
    # Focus the terminal window
    hyprctl dispatch focuswindow "address:$TERMINAL_ADDR"

    # sleep 0.0000000000000000001

    # Switch to the target tmux session directly
    tmux switch-client -t "$SESSION_TARGET" 2>/dev/null
else
    notify-send "Terminal not found" "No foot/omarchy terminal window is currently open" -t 3000
fi
