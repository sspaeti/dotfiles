#!/bin/bash
# Whenever a monitor is PHYSICALLY plugged/unplugged, clear the stored monitor
# profile and reload Hyprland so monitors.lua re-runs auto-detection
# (home/office/laptop). Manual profile choices (SUPER+ALT+7/8/...) persist
# across ordinary reloads (e.g. theme changes).
#
# Hyprland also fires monitoradded/monitorremoved when a profile merely
# DISABLES a monitor (laptop-only, ext-only) -- those must NOT reset the
# profile. So on every event we fingerprint the physically connected
# connectors via sysfs (cable-level, unaffected by hyprctl disable) and only
# reset when the fingerprint actually changed.

STATE="$HOME/.local/state/omarchy/monitor-profile"
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

[[ -S $SOCKET ]] || exit 0

# single instance per session
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/monitor-hotplug-watcher.lock"
flock -n 9 || exit 0

fingerprint() {
  local d
  for d in /sys/class/drm/card*-*; do
    [[ -f $d/status ]] || continue
    if [[ $(<"$d/status") == connected ]]; then
      printf '%s %s\n' "$d" "$(md5sum "$d/edid" 2>/dev/null | cut -d' ' -f1)"
    fi
  done
}

last=$(fingerprint)

socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
  case "$line" in
  monitoradded* | monitorremoved*)
    sleep 1 # let a burst of hotplug events settle
    now=$(fingerprint)
    if [[ $now != "$last" ]]; then
      last=$now
      rm -f "$STATE"
      hyprctl reload >/dev/null 2>&1
      notify-send "Monitor Setup" "Monitor change detected: auto-detect"
    fi
    ;;
  esac
done
