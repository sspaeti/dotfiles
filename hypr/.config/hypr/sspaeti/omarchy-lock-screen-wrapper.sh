#!/bin/bash

# Wrapper for omarchy-lock-screen that skips locking 1Password.
# Calls the original behavior except the "1password --lock" step.

# Lock the screen
pidof hyprlock || hyprlock &

# Set keyboard layout to default (first layout)
hyprctl switchxkblayout all 0 > /dev/null 2>&1

# Avoid running screensaver when locked
pkill -f org.omarchy.screensaver
