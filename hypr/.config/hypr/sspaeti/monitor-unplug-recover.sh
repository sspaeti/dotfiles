#!/bin/bash
# Re-enable the laptop panel when the last REAL external monitor goes away while
# SUPER+ALT+1 (omarchy-hyprland-monitor-internal) had it disabled.
#
# WHY (Omarchy 4.0.4, Hyprland 0.56.2):
#   Upstream omarchy-hyprland-monitor-watch already runs
#   `omarchy-hyprland-monitor-internal recover` on every monitorremoved event,
#   and recover() is supposed to clear the disable toggle when no external is
#   active. It decides that with omarchy-hyprland-monitor-external-active, which
#   treats every enabled output not named eDP-*/LVDS-*/DSI-* as an external.
#   But when Hyprland loses its last enabled output it creates a headless output
#   literally named "FALLBACK" (src/state/FallbackState.cpp) so clients keep
#   running, and `hyprctl monitors all -j` lists it as enabled. external-active
#   therefore says "an external is live", recover() bails, the toggle file
#   ~/.local/state/omarchy/toggles/hypr/internal-monitor-disable.lua survives
#   every reload, and the laptop stays black until an external is plugged back.
#
# This does the same recovery, ignoring FALLBACK/HEADLESS-* outputs. It only
# ever REMOVES the disable toggle (never sets anything), so the worst case is a
# laptop panel that turns on. The mirror toggle is left alone on purpose: the
# external mirrors the laptop there, so nothing goes black when it is unplugged.
#
# Launched from autostart.lua. Drop this when upstream's
# omarchy-hyprland-monitor-external-active excludes FALLBACK (one-line fix:
# add `^FALLBACK$` to its name filter). Registered in ../CLAUDE.md section 3.
#
# Manual test: SUPER+ALT+1 (laptop off), unplug the external -> laptop panel
# must come back within ~2s with a "Laptop display restored" notification.
# Same thing happens for SUPER+ALT+9 (laptop-only profile) while the toggle is on.

TOGGLE="internal-monitor-disable"
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

log() { echo "monitor-unplug-recover: $*" >&2; }

# True when an enabled output exists that is neither the laptop panel nor one of
# Hyprland's synthetic outputs. A failed/empty hyprctl answer (IPC busy mid-reload)
# counts as "unknown" -> true, so a hiccup never clears the toggle at the desk.
real_external_active() {
  local json
  json=$(hyprctl monitors all -j 2>/dev/null) || return 0
  [[ -n $json ]] || return 0
  jq -e '.[] | select(.disabled == false)
           | select((.name | test("^(eDP|LVDS|DSI)-|^FALLBACK$|^HEADLESS-")) | not)' \
    <<<"$json" >/dev/null 2>&1
}

recover() {
  omarchy-hyprland-toggle-enabled "$TOGGLE" || return 0
  real_external_active && return 0

  log "no real external active and $TOGGLE set -> re-enabling laptop panel"
  omarchy-hyprland-toggle "$TOGGLE" off # removes the flag file + hyprctl reload
  hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' >/dev/null 2>&1 || true
  omarchy-notification-send -g 󰍹 "Laptop display restored (no external monitor)"
}

if [[ ! -S $SOCKET ]]; then
  log "no Hyprland event socket at $SOCKET"
  exit 1
fi

# Boot/login with a stale toggle and no external (shut down docked, started on
# the train) is the same black screen, so check once before listening.
recover

while read -r event; do
  case "$event" in
    monitorremoved\>\>* | monitorremovedv2\>\>*)
      log "event: $event"
      # Give Hyprland a moment to settle (FALLBACK creation is deferred), then
      # check twice: the first hyprctl right after a removal can still be busy.
      sleep 1
      recover
      sleep 2
      recover
      ;;
  esac
done < <(socat -U - "UNIX-CONNECT:$SOCKET")
