#!/bin/bash

# Get all directories excluding _archive, _backup, and hidden folders
# Limit depth to 2 levels (main folder and immediate subdirectories)
folders=$(find "$git" -maxdepth 2 -type d \( ! -name ".*" ! -path "*/_*" ! -path "*/\.*" \) | sort)

# Get current tmux sessions
tmuxsessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

tmux_switch_or_create_session() {
    local folder="$1"
    # Extract the base folder name to use as session name
    local session_name=$(basename "$folder" | tr '.' '_')
    
    # Check if session exists
    if tmux has-session -t="$session_name" 2>/dev/null; then
        # Session exists, switch to it
        tmux switch-client -t "$session_name"
    else
        # Create new session and switch to it
        # If we're already in tmux
        if [ -n "$TMUX" ]; then
            # Create session in background and switch to it
            tmux new-session -d -s "$session_name" -c "$folder"
            tmux switch-client -t "$session_name"
        else
            # Not in tmux, create and attach to new session
            tmux new-session -A -s "$session_name" -c "$folder"
        fi
    fi
}

# Use fzf-tmux to select folder
choice=$(echo "$folders" | fzf-tmux -p --reverse --header="Select Git Directory" --preview-window=hidden | tr -d '\n')
    --preview 'ls -la {}' \
    --preview-window=right:50% \
    | tr -d '\n')

# If a choice was made (not cancelled)
if [[ -n "$choice" ]]; then
    tmux_switch_or_create_session "$choice"
fi
