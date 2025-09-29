#!/bin/bash

# Docker Compose Windows VM Launcher
# Starts Windows VM via Docker and connects with RDP
# When RDP closes, docker-compose will also stop

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
# RDP_COMMAND="rdesktop -g 1600x1000@144 -P -z -x l -r sound:off -u docker 127.0.0.1:3389 -p admin"
# Note: added `-grab-keyboard` for avoiding terminal interuptions. e.g. ctrl+c is terminating RDC, but can be used for copying
RDP_COMMAND="xfreerdp3 /u:docker /p:admin /v:127.0.0.1:3389 /size:1600x1000 +f /cert:tofu -grab-keyboard /scale:140"

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

# Wait for container to be running
echo "Waiting for Windows container to start..."
while true; do
    CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' windows 2>/dev/null)
    if [ "$CONTAINER_STATUS" = "running" ]; then
        echo "Container is running!"
        break
    fi
    echo "  Container status: $CONTAINER_STATUS"
    sleep 5
    
    # Check if docker-compose process is still running
    if ! kill -0 $COMPOSE_PID 2>/dev/null; then
        echo "Docker Compose process died unexpectedly"
        exit 1
    fi
done

# Check if web interface is responding (faster than waiting for RDP)
echo "Checking if Windows VM web interface is responding..."
while true; do
    if curl -s --connect-timeout 5 http://127.0.0.1:8006 > /dev/null 2>&1; then
        echo "Web interface is responding at http://127.0.0.1:8006"
        break
    fi
    echo "  Web interface not ready yet..."
    sleep 5
done

# Now wait for RDP port specifically
echo "Waiting for RDP service to be ready..."
while ! nc -z 127.0.0.1 3389; do
    echo "  RDP port not ready yet..."
    sleep 5
done

echo "RDP port is open, testing connection..."
# Quick RDP test with shorter timeout
timeout 5 rdesktop -g 320x240 -u docker 127.0.0.1:3389 -p admin 2>/dev/null
if [ $? -ne 0 ]; then
    echo "RDP not fully ready yet, waiting 5 more seconds..."
    sleep 5 
fi

echo "Starting RDP connection..."
echo "When you close RDP, the Windows VM will automatically shut down."

# Start RDP in new session to isolate from terminal signals (otherwise ctrl+c for copying will stop everything) 
setsid $RDP_COMMAND

# If RDP exits, cleanup
cleanup
