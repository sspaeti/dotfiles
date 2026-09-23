#!/bin/bash

# Wrapper for `omarchy-system-lid-close` (Omarchy 4.0.4+) that locks through
# our lock wrapper instead of stock `omarchy-system-lock`, so closing the lid
# does not run `1password --lock`. That is the ONLY delta -- everything else
# mirrors the shipped command. After an Omarchy update, diff and re-sync:
#   diff <(cat "$(which omarchy-system-lid-close)") ~/.config/hypr/sspaeti/omarchy-system-lid-close-wrapper.sh
#
# Bound to `switch:on:Lid Switch` in bindings.lua (stock bind unbound there).

# Locking here rather than waiting for PrepareForSleep is what keeps the lock
# off the critical path. logind's delay inhibitor is a timer that expires
# whether or not the session is secure, so starting the lock the moment the lid
# closes gives Quickshell a head start before logind even decides to suspend.
# omarchy-system-sleep-lock then usually finds the session already secure.
#
# A docked lid close does not suspend (HandleLidSwitchDocked defaults to
# ignore), so it must not lock either: that is clamshell mode, still in use on
# the external display.
if omarchy-hw-laptop-closed && ! omarchy-hw-external-monitors; then
  "$HOME/.config/hypr/sspaeti/omarchy-system-lock-wrapper.sh" >/dev/null 2>&1 || true
fi

omarchy-hyprland-monitor-clamshell
