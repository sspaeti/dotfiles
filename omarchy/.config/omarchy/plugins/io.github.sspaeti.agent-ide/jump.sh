#!/usr/bin/env bash
# Focus the tmux pane that runs one of the given processes: jump.sh <pid> [<pid>...]
# The first pid that sits on a tty owned by a tmux pane wins. Same steps as lua/agent-ide/tmux.lua.
# Under Hyprland the terminal window of a tmux client is focused first, then that client is
# switched to the pane's session, window and pane. Only window focus and tmux's selection are
# changed; no process is touched. Exits 1 when no pane matched.
set -u
command -v tmux >/dev/null 2>&1 || exit 1
panes=$(tmux list-panes -a -F '#{pane_tty} #{pane_id} #{session_name}' 2>/dev/null) || exit 1

# The pane running one of the pids: "<pane_id> <session_name>".
find_pane() {
  local pid tty pane_tty pane_id session
  for pid in "$@"; do
    case "$pid" in '' | *[!0-9]*) continue ;; esac
    tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    case "$tty" in '' | '?' | '??') continue ;; esac
    tty=${tty#/dev/}
    while read -r pane_tty pane_id session; do
      if [ "${pane_tty#/dev/}" = "$tty" ]; then
        printf '%s %s\n' "$pane_id" "$session"
        return 0
      fi
    done <<<"$panes"
  done
  return 1
}

target=$(find_pane "$@") || exit 1
pane_id=${target%% *}
session=${target#* }

# Hyprland: the window of a process, walking up its parents (tmux client -> shell -> terminal).
clients=""
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  clients=$(hyprctl clients -j 2>/dev/null) || clients=""
fi

window_for_pid() {
  local pid=$1 addr
  [ -n "$clients" ] || return 1
  while [ -n "$pid" ] && [ "$pid" -gt 1 ] 2>/dev/null; do
    addr=$(jq -r --argjson p "$pid" '.[] | select(.pid == $p) | .address' <<<"$clients" 2>/dev/null | head -n1)
    if [ -n "$addr" ]; then
      printf '%s\n' "$addr"
      return 0
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  return 1
}

# Newer Hyprland parses dispatch arguments as Lua; older ones take the classic syntax.
# The Lua focus does not leave the current workspace, so the window's workspace comes first
# (the classic focuswindow switches on its own).
focus_window() {
  local addr=$1 ws out
  ws=$(jq -r --arg a "$addr" '.[] | select(.address == $a) | .workspace.id' <<<"$clients" 2>/dev/null | head -n1)
  case "$ws" in '' | null | -*) ws="" ;; esac
  [ -n "$ws" ] && hyprctl dispatch "hl.dsp.focus({ workspace = \"$ws\" })" >/dev/null 2>&1
  out=$(hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" 2>&1)
  [ "$out" = "ok" ] && return 0
  hyprctl dispatch focuswindow "address:$addr" >/dev/null 2>&1
}

# A tmux client with a visible window, preferring one already on the pane's session.
client_tty=""
client_addr=""
while read -r c_pid c_tty c_session; do
  [ -n "$c_pid" ] || continue
  addr=$(window_for_pid "$c_pid") || continue
  if [ -z "$client_tty" ] || [ "$c_session" = "$session" ]; then
    client_tty=$c_tty
    client_addr=$addr
    [ "$c_session" = "$session" ] && break
  fi
done < <(tmux list-clients -F '#{client_pid} #{client_tty} #{client_session}' 2>/dev/null)

[ -n "$client_addr" ] && focus_window "$client_addr"

# from outside tmux the target must be selected first, then the client follows
tmux select-window -t "$pane_id" 2>/dev/null
tmux select-pane -t "$pane_id" 2>/dev/null
if [ -n "$client_tty" ]; then
  tmux switch-client -c "$client_tty" -t "$pane_id" 2>/dev/null
else
  tmux switch-client -t "$pane_id" 2>/dev/null
fi
exit 0
