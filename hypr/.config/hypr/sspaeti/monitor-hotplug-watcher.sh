#!/bin/bash
# Whenever a monitor is plugged/unplugged, clear the stored monitor profile and
# reload Hyprland so monitors.lua re-runs auto-detection (home/office/laptop).
# Manual profile choices (SUPER+ALT+7/8/...) persist across ordinary reloads
# (e.g. theme changes) -- only real cable events reset them.

STATE="$HOME/.local/state/omarchy/monitor-profile"
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

[[ -S $SOCKET ]] || exit 0

# single instance per session
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/monitor-hotplug-watcher.lock"
flock -n 9 || exit 0

socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
  case "$line" in
  monitoradded* | monitorremoved*)
    rm -f "$STATE"
    sleep 1 # let a burst of hotplug events settle
    hyprctl reload >/dev/null 2>&1
    notify-send "Monitor Setup" "Monitor change detected: auto-detect"
    ;;
  esac
done
