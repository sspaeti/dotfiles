#!/bin/bash
# Pin / reset the monitor scales used by ~/.config/hypr/monitors.lua.
#
#   up     step the FOCUSED monitor's scale one preset up, then apply
#   down   ... and down
#   pin    read the CURRENT live scales, write them into monitors.lua, reload
#   reset  put both scales back to the default (no reload -- the caller does it)
#
# WHY up/down INSTEAD OF `omarchy-hyprland-monitor-scaling up`?
# Because that command applies the new scale with `position = "auto"`:
#   hyprctl eval 'hl.monitor({ output = <focused>, ... position = "auto", scale = N })'
# `auto` makes Hyprland RE-PLACE the monitor, which shoves the external to the
# right of the laptop -- so the laptop lands on the LEFT and the office/home
# arrangement is destroyed on every scale step. Pinning afterwards only repairs
# it; the next scale change breaks it again.
# Stepping the literal here instead means monitors.lua recomputes every position
# from the new scale on reload, so the arrangement survives. One file write, one
# reload, no broken intermediate state, `position = auto` never happens.
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

# Hyprland only accepts scales where the mode divides into whole logical pixels
# (in 1/120 steps). Every preset below is clean for both our panels -- 4K
# (3840x2160, gcd 86400) and the Tuxedo (2880x1800, gcd 43200) -- so no
# clean_scale rounding is needed. Re-check with omarchy-hyprland-monitor-scaling's
# clean_scale() if a monitor with a different mode is ever added here.
SCALES=(1 1.25 1.6 2 3 4)

# Sticky target for repeated presses.
# Scaling the external changes its LOGICAL width (2400 -> 1920 at 1.6 -> 2), so
# the laptop slides left to stay flush and the cursor can end up on the laptop.
# Hyprland then reports the laptop as focused, and the next press would scale the
# wrong monitor. Within this window, keep adjusting whatever we adjusted last.
STICKY="${XDG_RUNTIME_DIR:-/tmp}/monitor-scale-target"
STICKY_WINDOW=5

sticky_target() {
  [[ -f $STICKY ]] || return 1
  local age=$(($(date +%s) - $(stat -c %Y "$STICKY" 2>/dev/null || echo 0)))
  ((age >= 0 && age <= STICKY_WINDOW)) || return 1
  local t
  t=$(<"$STICKY")
  [[ $t == ext_scale || $t == laptop_scale ]] || return 1
  printf '%s\n' "$t"
}

# Which literal governs the focused monitor: laptop_scale, ext_scale, or neither.
# "neither" means an unknown external (a projector, a colleague's screen) -- it
# is driven by the catch-all rule, has no profile geometry to protect, so we let
# Omarchy handle it live instead.
focused_target() {
  local focused desc
  focused=$(hyprctl monitors -j | jq -r '[.[] | select(.focused == true)][0] | .name // empty')
  [[ -n $focused ]] || return 1

  if [[ $focused =~ ^(eDP|LVDS|DSI)- ]]; then
    echo laptop_scale
    return 0
  fi

  desc=$(hyprctl monitors -j | jq -r --arg n "$focused" '.[] | select(.name == $n) | .description')
  # The two Dells are the only externals the profiles lay out.
  if grep -qE 'S2722QC|S2725QC' <<<"$desc"; then
    echo ext_scale
    return 0
  fi

  return 2
}

# Nearest preset to $1, stepped by $2 (up|down), clamped at both ends.
step_scale() {
  awk -v cur="$1" -v dir="$2" -v list="${SCALES[*]}" '
    BEGIN {
      n = split(list, s, " ")
      best = 1; bd = 1e9
      for (i = 1; i <= n; i++) {
        d = cur - s[i]; if (d < 0) d = -d
        if (d < bd) { bd = d; best = i }
      }
      i = (dir == "up") ? best + 1 : best - 1
      if (i < 1) i = 1
      if (i > n) i = n
      print s[i]
    }'
}

case "${1:-}" in
up | down)
  # `set -e` would abort on a non-zero return, and `if ! f` would clobber the
  # exit code with the negation -- so capture it explicitly.
  rc=0
  if target=$(sticky_target); then
    rc=0
  else
    target=$(focused_target) || rc=$?
  fi

  if ((rc == 2)); then
    # Unknown external: no profile geometry at stake, use Omarchy's live path.
    exec omarchy-hyprland-monitor-scaling "$1"
  fi
  if ((rc != 0)) || [[ -z $target ]]; then
    notify-send "Monitor Setup" "No focused monitor"
    exit 1
  fi

  current=$(read_scale "$target")
  new=$(step_scale "$current" "$1")

  if [[ $new == "$current" ]]; then
    notify-send "Monitor Setup" "Scale already at the $([[ $1 == up ]] && echo max || echo min) ($current)"
    exit 0
  fi

  set_scale "$target" "$new"
  printf '%s' "$target" >"$STICKY"
  hyprctl reload >/dev/null
  notify-send "Monitor Setup" "Scale $([[ $target == laptop_scale ]] && echo laptop || echo external): $current -> $new"
  ;;

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
  rm -f "$STICKY"
  ;;

show | "")
  printf 'ext_scale    %s\nlaptop_scale %s\n' "$(read_scale ext_scale)" "$(read_scale laptop_scale)"
  ;;

*)
  echo "Usage: $(basename "$0") {up|down|pin|reset|show}" >&2
  exit 1
  ;;
esac
