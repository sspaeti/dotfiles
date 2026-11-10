#!/usr/bin/env bash
# Data source 2 of the Agent-IDE bar indicator: Claude sessions running anywhere (tmux panes, other terminals).
#
# Prints the JSON array of `claude agents --json`. Prints nothing when `claude` is missing, fails or takes too
# long, so the widget can tell "no answer" from "no sessions" (`[]`). Read-only; never touches a session.
set -u

# Quickshell children do not necessarily inherit the login shell's PATH.
for candidate in "$HOME/.local/bin" "$HOME/.claude/local" "$HOME/.npm-global/bin" "$HOME/go/bin"; do
  case ":$PATH:" in
    *":$candidate:"*) ;;
    *) [ -d "$candidate" ] && PATH="$PATH:$candidate" ;;
  esac
done
export PATH

command -v claude >/dev/null 2>&1 || exit 0
out=$(timeout 4 claude agents --json 2>/dev/null) || exit 0
printf '%s\n' "$out"
