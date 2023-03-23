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
tmux_switch_to_session "$choice"
