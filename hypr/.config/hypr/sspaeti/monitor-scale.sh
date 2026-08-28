#!/bin/bash
# Pin / reset the monitor scales used by ~/.config/hypr/monitors.lua.
#
#   pin    read the CURRENT live scales, write them into monitors.lua, reload
#   reset  put both scales back to the default (no reload -- the caller does it)
#
# WHY REWRITE monitors.lua INSTEAD OF LAYERING AN OVERRIDE ON TOP?
# Because omarchy-hyprland-monitor-clamshell TEXT-PARSES monitors.lua for the
# internal monitor's scale and re-asserts it with `hyprctl eval` after every
# monitor event and on a 2s poll while docked. An override layered somewhere
# else would be silently reverted a couple of seconds later. Writing the literal
# keeps Omarchy's own machinery in agreement with us instead of racing it.
#
# monitors.lua derives every position from these two numbers, so pinning a new
# scale keeps the monitors flush rather than stranding the laptop off to the
# side -- which is what plain `omarchy-hyprland-monitor-scaling` does, since it
# re-places the monitor at `position = auto`.

set -euo pipefail

MONITORS_LUA="$HOME/.config/hypr/monitors.lua"
DEFAULT_SCALE=1.6

[[ -f $MONITORS_LUA ]] || {
  echo "not found: $MONITORS_LUA" >&2
  exit 1
}

# Rewrite `local <name> = <number>` in place. --follow-symlinks matters: these
# dotfiles are stowed, and plain `sed -i` would replace a symlink with a file.
set_scale() {
  local name="$1" value="$2"
  sed -i --follow-symlinks -E \
    "s|^local ${name} = [0-9]+(\.[0-9]+)?$|local ${name} = ${value}|" \
    "$MONITORS_LUA"
}

read_scale() {
  sed -nE "s|^local $1 = ([0-9]+(\.[0-9]+)?)$|\1|p" "$MONITORS_LUA" | head -1
}

case "${1:-}" in
pin)
  # Internal panel -> laptop_scale; first enabled external -> ext_scale.
  # `monitors all` so a disabled panel is still visible; mirrors are excluded by
  # taking only enabled outputs.
  monitors=$(hyprctl monitors all -j)

  laptop_new=$(jq -r '
    [.[] | select((.name | test("^(eDP|LVDS|DSI)-")) and .disabled != true) | .scale][0] // empty
  ' <<<"$monitors")

  ext_new=$(jq -r '
    [.[] | select((.name | test("^(eDP|LVDS|DSI)-") | not) and .disabled != true) | .scale][0] // empty
  ' <<<"$monitors")

  changed=()
  if [[ -n $laptop_new ]]; then
    set_scale laptop_scale "$laptop_new"
    changed+=("laptop $laptop_new")
  fi
  if [[ -n $ext_new ]]; then
    set_scale ext_scale "$ext_new"
    changed+=("external $ext_new")
  fi

  if ((${#changed[@]} == 0)); then
    notify-send "Monitor Setup" "Nothing to pin -- no enabled monitor found"
    exit 1
  fi

  hyprctl reload >/dev/null
  notify-send "Monitor Setup" "PINNED: ${changed[*]}"
  ;;

reset)
  set_scale laptop_scale "$DEFAULT_SCALE"
  set_scale ext_scale "$DEFAULT_SCALE"
  ;;

show | "")
  printf 'ext_scale    %s\nlaptop_scale %s\n' "$(read_scale ext_scale)" "$(read_scale laptop_scale)"
  ;;

*)
  echo "Usage: $(basename "$0") {pin|reset|show}" >&2
  exit 1
  ;;
esac
