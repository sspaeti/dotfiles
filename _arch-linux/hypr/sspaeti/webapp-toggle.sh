#!/bin/bash
# Web app toggle script for browser-based applications
# Usage: sspaeti-webapp-toggle.sh <url> <browser_command>
# Example: sspaeti-webapp-toggle.sh "https://web.whatsapp.com/" "brave --new-window"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <url> <browser_command>"
    echo "Example: $0 \"https://web.whatsapp.com/\" \"brave --new-window\""
    exit 1
fi

URL="$1"
BROWSER="$2"

# Extract domain from URL for pattern matching
DOMAIN=$(echo "$URL" | sed 's|https\?://||' | sed 's|/.*||')

# Check if webapp is running by looking for browser windows with matching domain
WEBAPP_INFO=$(hyprctl clients | grep -A 15 -B 5 -i "$DOMAIN")

if [ -n "$WEBAPP_INFO" ]; then
    # Get workspace of webapp window
    WORKSPACE=$(echo "$WEBAPP_INFO" | grep "workspace:" | head -1 | awk '{print $2}')
    
    # Get the window address to focus on the specific window
    ADDRESS=$(echo "$WEBAPP_INFO" | grep "Window" | head -1 | awk '{print $2}' | sed 's/://')
    
    # Switch to workspace and focus window
    hyprctl dispatch workspace "$WORKSPACE"
    hyprctl dispatch focuswindow "address:0x$ADDRESS"
else
    # Webapp is not running, start it using passed browser command
    eval "$BROWSER --app=\"$URL\""
fi
