#!/bin/bash

# Function to run when Ctrl + C (SIGINT) is detected
cleanup() {
    echo "Disabling NetworkManager.service..."
    sudo systemctl stop NetworkManager.service
    echo "NetworkManager.service disabled."
    exit 0
}

# Trap Ctrl + C (SIGINT) and call the cleanup function
trap cleanup SIGINT

sudo systemctl start NetworkManager.service
sleep 10
echo "########################################"
echo "Open http://$(hostname -I | awk '{print $1}'):8080 in your web browser"
echo "Ctrl + C to exit"
echo "########################################"

# Start the file browser, suppressing output
filebrowser -r ~/microjournal/documents -a 0.0.0.0 --noauth -d ~/file.db > /dev/null 2>&1

# Wait indefinitely until Ctrl + C is pressed
while true; do
    sleep 1
done
