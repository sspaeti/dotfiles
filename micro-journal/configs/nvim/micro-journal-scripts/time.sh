#!/bin/bash

# Script to sync system time with internet time (Eastern US timezone)
# No additional software required

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

echo "Fetching current internet time..."

# Get the HTTP date header from Google
RAW_DATE=$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | sed 's/Date: //')

# Remove carriage return if present
RAW_DATE=$(echo "$RAW_DATE" | tr -d '\r')

if [ -z "$RAW_DATE" ]; then
    echo "Failed to retrieve time from internet. Check your connection."
    exit 1
fi

echo "Internet time (GMT): $RAW_DATE"

# Set the system time to GMT first
echo "Setting system clock to GMT time..."
date -s "$RAW_DATE"

# Now set the timezone to Eastern
echo "Setting timezone to Eastern US..."
export TZ="America/New_York"

echo "System time is now set to: $(date)"

echo "Time synchronization complete!"
