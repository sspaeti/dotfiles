#!/usr/bin/env bash
# Jump to the terminal window hosting tmux and switch to the email session.

SESSION_TARGET="neomd:reading" # Change this if your session name is different

# QUATTRO NOTE: with the Lua config, `hyprctl dispatch` parses its argument as
# Lua, not the old conf syntax. `hyprctl dispatch focuswindow "address:0x.."`
# now fails with `error: ')' expected near 'address'` (but still exits 0, so the
# breakage is silent). Use the hl.* dispatcher instead:
#   focus a window -> hl.dsp.focus({ window = "address:0x.." })
# Same convention as omarchy-launch-or-focus and sspaeti/autostart-apps.sh.
focus_window() { hyprctl dispatch "hl.dsp.focus({ window = \"address:$1\" })" >/dev/null; }

CLIENTS=$(hyprctl clients -j)

# Walk up the process tree from $1 until a pid owns a Hyprland window.
window_for_pid() {
    local pid=$1 addr
    while [[ -n $pid && $pid -gt 1 ]]; do
        addr=$(jq -r --argjson p "$pid" '.[] | select(.pid == $p) | .address' <<<"$CLIENTS" | head -n1)
        [[ -n $addr ]] && {
            echo "$addr"
            return 0
        }
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    done
    return 1
}

# Preferred: resolve the window from the live tmux client, so this works with
# any terminal (foot, kitty, alacritty, ghostty, ...) instead of a class allowlist.
TERMINAL_ADDR=""
TMUX_CLIENT=""
while read -r client_pid client_tty; do
    [[ -z $client_pid ]] && continue
    if addr=$(window_for_pid "$client_pid"); then
        TERMINAL_ADDR=$addr
        TMUX_CLIENT=$client_tty
        break
    fi
done < <(tmux list-clients -F '#{client_pid} #{client_tty}' 2>/dev/null)

# Fallback: no tmux client attached yet -- match a terminal window by class.
if [[ -z $TERMINAL_ADDR ]]; then
    TERMINAL_CLASS_REGEX='^(org\.omarchy\.(zsh|bash)|foot|org\.codeberg\.dnkl\.foot|kitty|[Aa]lacritty|com\.mitchellh\.ghostty)$'
    TERMINAL_ADDR=$(jq -r --arg re "$TERMINAL_CLASS_REGEX" '.[] | select(.class | test($re)) | .address' <<<"$CLIENTS" | head -n1)
fi

if [[ -z $TERMINAL_ADDR ]]; then
    notify-send "Terminal not found" "No terminal window is currently open" -t 3000
    exit 1
fi

focus_window "$TERMINAL_ADDR"

if [[ -n $TMUX_CLIENT ]]; then
    tmux switch-client -c "$TMUX_CLIENT" -t "$SESSION_TARGET" 2>/dev/null
else
    tmux switch-client -t "$SESSION_TARGET" 2>/dev/null
fi
