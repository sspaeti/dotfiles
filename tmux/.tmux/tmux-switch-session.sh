#!/bin/bash

#from: https://jdhao.github.io/2021/11/20/tmux_fuzzy_session_switch/
tmuxsessions=$(tmux list-sessions -F "#{session_name}")

tmux_switch_to_session() {
    session="$1"
    if [[ $tmuxsessions = *"$session"* ]]; then
        tmux switch-client -t "$session"
    fi
}

choice=$(sort -rfu <<< "$tmuxsessions" \
    | fzf-tmux \
    | tr -d '\n')

# Check if $choice has content before trying to switch sessions: e.g. if hitting ESC, it will go back to existing session
if [[ -n "$choice" ]]; then
    tmux_switch_to_session "$choice"
fi
