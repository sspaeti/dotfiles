#!/bin/bash

# Log file path
LOG_FILE=~/.config/mutt/logs/sync_status.log

# Function to check if connected to Wi-Fi
check_wifi() {
    wifi_name=$(networksetup -getairportnetwork en0 | awk -F": " '{print $2}')
    if [ -n "$wifi_name" ]; then
        return 0  # Connected to Wi-Fi
    else
        return 1  # Not connected to Wi-Fi
    fi
}

# Log start time
echo "Sync started at $(date)" >> "$LOG_FILE"

# Check if connected to Wi-Fi
if check_wifi; then
    # Run the first sync
    offlineimap -a sspaeti.com
    
    # Wait for 2 seconds
    sleep 2
    
    # Run the screener
    ~/.config/mutt/initial_screening.sh >> ~/.config/mutt/logs/screening.log 2>&1
    
    # Wait for 2 seconds
    sleep 2
    
    # Run the second sync
    offlineimap -a sspaeti.com
    
    echo "Sync completed successfully at $(date)" >> "$LOG_FILE"
else
    echo "Not connected to Wi-Fi. Sync not performed at $(date)" >> "$LOG_FILE"
fi

# Remove log entries older than 7 days
find "$LOG_FILE" -mtime +7 -delete
