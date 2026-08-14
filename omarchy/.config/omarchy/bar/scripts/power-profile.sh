#!/usr/bin/env bash
# Power profile indicator for the omarchy bar (Waybar-style JSON on stdout).
#
#   power-profile.sh          print the current profile
#   power-profile.sh --cycle  advance performance -> power-saver -> balanced
set -euo pipefail

command -v powerprofilesctl >/dev/null || exit 0

current=$(powerprofilesctl get)

if [[ ${1:-} == "--cycle" ]]; then
  case "$current" in
    balanced) next=performance ;;
    performance) next=power-saver ;;
    *) next=balanced ;;
  esac
  powerprofilesctl set "$next"
  exit 0
fi

case "$current" in
  performance) icon="󰓅"; label="Performance" ;;
  balanced) icon="󰾅"; label="Balanced" ;;
  power-saver) icon="󰾆"; label="Power saver" ;;
  *) icon="󰋗"; label="$current" ;;
esac

printf '{"text":"%s","tooltip":"Power profile: %s\\nClick to cycle"}\n' "$icon" "$label"
