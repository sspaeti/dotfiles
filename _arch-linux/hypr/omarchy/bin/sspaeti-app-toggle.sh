#!/bin/bash
# Generic app toggle script
# Usage: sspaeti-app-toggle.sh <app_class> <launch_command>
# Example: sspaeti-app-toggle.sh obsidian "obsidian --disable-gpu"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <app_class> <launch_command>"
    echo "Example: $0 obsidian \"obsidian --disable-gpu\""
    exit 1
fi

APP_CLASS="$1"
LAUNCH_COMMAND="$2"

# Check if app is running
APP_INFO=$(hyprctl clients | grep -A 10 "class: $APP_CLASS")

if [ -n "$APP_INFO" ]; then
    # Get workspace of app window
    WORKSPACE=$(echo "$APP_INFO" | grep "workspace:" | head -1 | awk '{print $2}')
    
    # Switch to workspace and focus window
    hyprctl dispatch workspace "$WORKSPACE"
    hyprctl dispatch focuswindow "class:$APP_CLASS"
else
    # App is not running, start it
    eval "$LAUNCH_COMMAND"
fi