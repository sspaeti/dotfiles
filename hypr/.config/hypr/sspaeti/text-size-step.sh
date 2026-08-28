#!/bin/bash
# Step omarchy-display-text-size up/down. That command only takes an absolute
# px value (9-20), so this reads the current one and nudges it.
#
# This is the knob for "make it readable in a screenshot/recording" WITHOUT
# touching geometry: it drives the omarchy shell font, GTK's text-scaling-factor
# and the terminal font size together, and moves no windows. Monitor scaling
# (SUPER+CTRL+SLASH) is the other, geometry-changing knob.

set -euo pipefail

MIN=9
MAX=20
DEFAULT=12

current() {
  # `omarchy-display-text-size` with no args prints e.g. "text size: 14 px" or
  # "text size: 12 (default) px" when nothing is set yet.
  local line
  line=$(omarchy-display-text-size 2>/dev/null | sed -n 's/^text size: *//p' | head -1)
  local n
  n=$(grep -oE '^[0-9]+' <<<"$line" || true)
  [[ -n $n ]] && echo "$n" || echo "$DEFAULT"
}

case "${1:-}" in
up) target=$(($(current) + 1)) ;;
down) target=$(($(current) - 1)) ;;
reset)
  omarchy-display-text-size reset
  notify-send "Text Size" "Reset to default (${DEFAULT}px)"
  exit 0
  ;;
*)
  echo "Usage: $(basename "$0") {up|down|reset}" >&2
  exit 1
  ;;
esac

if ((target < MIN)); then
  target=$MIN
elif ((target > MAX)); then
  target=$MAX
fi

omarchy-display-text-size "$target"
notify-send "Text Size" "${target}px"
