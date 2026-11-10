#!/usr/bin/env bash
# Data source 1 of the Agent-IDE bar indicator: the status files written by Neovim.
#
# Prints one line per `status-<pid>.json`:   <pid> TAB <alive 0|1> TAB <file content on one line>
# A missing directory prints nothing. Only the pure logic in Model.js interprets the content.
# Test knob: AGENT_IDE_STATUS_DIR overrides the directory.
set -u

dir="${AGENT_IDE_STATUS_DIR:-${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/agent-ide}"
[ -d "$dir" ] || exit 0

n=0
for f in "$dir"/status-*.json; do
  [ -f "$f" ] || continue
  base=${f##*/}
  pid=${base#status-}
  pid=${pid%.json}
  case "$pid" in '' | *[!0-9]*) continue ;; esac
  n=$((n + 1))
  [ "$n" -gt 200 ] && break # a runaway directory must not stall the bar
  if [ -d "/proc/$pid" ]; then
    # newlines and tabs would break the one-line format; JSON strings never hold raw ones
    body=$(head -c 1048576 -- "$f" 2>/dev/null | tr '\n\t\r' '   ') || continue
    printf '%s\t1\t%s\n' "$pid" "$body"
  else
    printf '%s\t0\t{}\n' "$pid"
  fi
done
exit 0
