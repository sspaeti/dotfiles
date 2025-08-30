#!/bin/bash

# Docker Compose Windows VM Launcher
# Starts Windows VM via Docker and connects with RDP
# When RDP closes, docker-compose will also stop

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
RDP_COMMAND="rdesktop -g 1440x900 -P -z -x l -r sound:off -u docker 127.0.0.1:3389 -p admin"

echo "Starting Windows VM..."

# Change to script directory where docker-compose.yml is located
cd "$SCRIPT_DIR" || {
    echo "Error: Could not change to $SCRIPT_DIR"
    exit 1
}

# Function to handle cleanup
cleanup() {
    echo "Shutting down Windows VM..."
    docker-compose down
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Start docker-compose in foreground with a background process
docker-compose up &
COMPOSE_PID=$!

# Wait for RDP port to be available and RDP service to be ready
echo "Waiting for RDP port to open..."
while ! nc -z 127.0.0.1 3389; do
    echo "  Port 3389 not ready yet..."
    sleep 10
    
    # Check if docker-compose process is still running
    if ! kill -0 $COMPOSE_PID 2>/dev/null; then
        echo "Docker Compose process died unexpectedly"
        exit 1
    fi
done

echo "Port 3389 is open, waiting for Windows VM to fully initialize..."
echo "This can take 2-3 minutes for Windows to boot completely..."

# Additional wait for Windows to fully boot and RDP service to be ready
sleep 60

# Test RDP connection availability
echo "Testing RDP connection..."
timeout 10 rdesktop -g 640x480 -u docker 127.0.0.1:3389 -p admin 2>/dev/null
if [ $? -ne 0 ]; then
    echo "RDP not fully ready yet, waiting another 30 seconds..."
    sleep 30
fi

echo "Starting RDP connection..."
echo "When you close RDP, the Windows VM will automatically shut down."

# Start RDP in foreground - when it exits, cleanup will run
$RDP_COMMAND

# If RDP exits, cleanup
cleanup