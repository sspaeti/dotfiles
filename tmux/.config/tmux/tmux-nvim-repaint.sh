#!/bin/bash
# Workaround for tmux zoom grid corruption (tmux#2677 / #2260): after zoom
# transitions and session switches, stale cells from other panes can survive
# in tmux's server-side grid inside nvim panes (foot AND kitty affected — the
# corruption is in tmux, not the terminal).
#
# nvim's :redraw! does NOT fix it: the nvim 0.12 TUI diffs against its own
# screen model and skips cells it believes are already correct. :mode resets
# the terminal and repaints unconditionally, overwriting the corrupted grid.
#
# This sends :mode to every nvim in the current window via its --embed server
# socket (mode-safe: works mid-insert, no keys injected). Run async via
# `run-shell -b` so zoom/switch stays instant.

uid=$(id -u)

repaint() { # $1 = nvim server pid
  local sock
  for sock in "/run/user/$uid/nvim.$1."*; do
    [[ -S $sock ]] || continue
    timeout 2 nvim --server "$sock" --remote-expr 'execute("mode")' >/dev/null 2>&1
    return 0
  done
  return 1
}

tmux list-panes -F '#{pane_pid} #{pane_current_command}' | while read -r pane_pid cmd; do
  [[ $cmd == nvim ]] || continue
  tui=$(pgrep -P "$pane_pid" -x nvim | head -1)
  [[ -z $tui ]] && continue
  # socket lives on the embedded server (child of the TUI); fall back to TUI pid
  srv=$(pgrep -P "$tui" -x nvim | head -1)
  { [[ -n $srv ]] && repaint "$srv"; } || repaint "$tui" &
done
wait
