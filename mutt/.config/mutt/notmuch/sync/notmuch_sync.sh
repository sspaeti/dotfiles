#!/bin/bash

# Notmuch-based sync script for neomutt (Linux/Arch)
# Syncs email with offlineimap and applies notmuch screening tags

# Log file path
LOG_FILE=~/.config/mutt/logs/notmuch_sync_status.log

# Create log directory if it doesn't exist
mkdir -p ~/.config/mutt/logs

# Function to check if connected to Wi-Fi (Linux)
check_wifi() {
    # Check if any wireless interface is connected
    if command -v nmcli &> /dev/null; then
        # Using NetworkManager
        if nmcli -t -f DEVICE,STATE device | grep -q "wifi:connected"; then
            return 0  # Connected to Wi-Fi
        fi
    elif command -v iwgetid &> /dev/null; then
        # Fallback to iwgetid
        if iwgetid -r &> /dev/null; then
            return 0  # Connected to Wi-Fi
        fi
    fi
    return 1  # Not connected to Wi-Fi
}

# Log start time
echo "Notmuch sync started at $(date)" >> "$LOG_FILE"

# Check if connected to Wi-Fi
if check_wifi; then
    # Run the first sync with offlineimap
    echo "Running offlineimap..." >> "$LOG_FILE"
    offlineimap -a sspaeti.com

    # Wait for 2 seconds
    sleep 2

    # Run the notmuch screener
    echo "Running notmuch screening..." >> "$LOG_FILE"
    ~/.config/mutt/notmuch/notmuch_screening.sh >> ~/.config/mutt/logs/notmuch_screening.log 2>&1

    # Wait for 2 seconds
    sleep 2

    # Run the second sync (to sync any local changes back)
    echo "Running second offlineimap sync..." >> "$LOG_FILE"
    offlineimap -a sspaeti.com

    echo "Notmuch sync completed successfully at $(date)" >> "$LOG_FILE"
else
    echo "Not connected to Wi-Fi. Sync not performed at $(date)" >> "$LOG_FILE"
fi

# Keep only last 100 lines of log
tail -100 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
