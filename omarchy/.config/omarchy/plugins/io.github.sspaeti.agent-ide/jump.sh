#!/usr/bin/env bash
# Focus the tmux pane that runs one of the given processes: jump.sh <pid> [<pid>...]
# The first pid that sits on a tty owned by a tmux pane wins. Same steps as lua/agent-ide/tmux.lua.
# Only tmux's selection is changed; no process is touched. Exits 1 when no pane matched.
set -u
command -v tmux >/dev/null 2>&1 || exit 1
panes=$(tmux list-panes -a -F '#{pane_tty} #{pane_id}' 2>/dev/null) || exit 1

for pid in "$@"; do
  case "$pid" in '' | *[!0-9]*) continue ;; esac
  tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
  case "$tty" in '' | '?' | '??') continue ;; esac
  tty=${tty#/dev/}
  while read -r pane_tty pane_id; do
    if [ "${pane_tty#/dev/}" = "$tty" ]; then
      # from outside tmux the target must be selected first, then the client follows
      tmux select-window -t "$pane_id" 2>/dev/null
      tmux select-pane -t "$pane_id" 2>/dev/null
      tmux switch-client -t "$pane_id" 2>/dev/null
      exit 0
    fi
  done <<<"$panes"
done
exit 1
