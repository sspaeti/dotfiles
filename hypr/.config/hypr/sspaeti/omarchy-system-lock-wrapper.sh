#!/bin/bash

# Wrapper for `omarchy system lock` that skips locking 1Password.
# That skip is the ONLY reason this file exists -- everything else mirrors the
# shipped command. After an Omarchy update, diff against it and re-sync:
#   diff <(cat "$(which omarchy-system-lock)") ~/.config/hypr/sspaeti/omarchy-system-lock-wrapper.sh
#
# QUATTRO: hyprlock is uninstalled. The old wrapper called `hyprlock` behind an
# `if ! pidof hyprlock` guard, so after the upgrade it failed silently and the
# screen never locked at all. Locking is now the Quickshell `lock` plugin.
#
# Also gone from this wrapper, on purpose:
#   - the `omarchy-brightness-{keyboard,display} off` block and its `sleep 3`
#     guard. The lock plugin runs both itself once the lock is actually up
#     (shell/plugins/lock/Service.qml), and owns the `omarchy-system-wake` call
#     on unlock -- duplicating it here would turn the display off with nothing
#     left to turn it back on.
#   - the OMARCHY_LOCK_ONLY escape hatch, which only ever came from
#     hypridle.conf's before_sleep_cmd. hypridle is uninstalled; idle and
#     pre-sleep locking now live in ~/.config/omarchy/shell.json ("idle").

omarchy-shell lock lock >/dev/null

# Set keyboard layout to default (first layout)
hyprctl switchxkblayout all 0 >/dev/null 2>&1

# NOTE: the stock command locks 1Password here. Deliberately not doing that.

# Avoid running screensaver when locked
pkill -x ttfx 2>/dev/null || true
# ttfx handles SIGTERM asynchronously, so keep its terminal alive until it exits.
timeout 1s pidwait -x ttfx 2>/dev/null || true
pkill -f '[o]rg.omarchy.screensaver' 2>/dev/null || true
