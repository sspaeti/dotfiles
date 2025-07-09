#!/bin/bash

# Get network interface (first active interface)
INTERFACE=$(ip route get 1.1.1.1 | awk '{print $5; exit}')

# Get initial values
RX1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

sleep 1

# Get values after 1 second
RX2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Calculate rates
RX_RATE=$((RX2 - RX1))
TX_RATE=$((TX2 - TX1))

# Format output
format_bytes() {
    local bytes=$1
    if [ $bytes -gt 1048576 ]; then
        echo "$(($bytes / 1048576))MB/s"
    elif [ $bytes -gt 1024 ]; then
        echo "$(($bytes / 1024))KB/s"
    else
        echo "${bytes}B/s"
    fi
}

DOWN=$(format_bytes $RX_RATE)
UP=$(format_bytes $TX_RATE)

# Output JSON for waybar
echo "{\"text\": \"⇣$DOWN ⇡$UP\", \"tooltip\": \"Download: $DOWN\\nUpload: $UP\"}"