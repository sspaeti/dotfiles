#!/bin/bash
# Micro Journal Complete Sync Script
# Handles network connection, time sync, and file synchronization

set -e  # Exit on error

# Path definitions
# Pi paths
PI_WRITING_DIR="$HOME/microjournal/writing"
PI_CONFIG_DIR="$HOME/microjournal/config" #path to shell scripts and utilities
PI_NVIM_CONFIG_DIR="$HOME/config/nvim" #wordprocessor config (Nvim)
PI_SECONDBRAIN_DIR="$HOME/microjournal/SecondBrain"

# Mac paths
MAC_NVIM_CONFIG="$HOME/Documents/git/general/dotfiles/nvim-wp/"
MAC_TYPEWRITER_CONFIG="$HOME/Documents/git/general/dotfiles/nvim-wp/micro-journal-scripts"
MAC_WRITING_DIR="$HOME/Simon/SecondBrain/⚛️ Areas/✍🏻 Writing/micro-journal"
MAC_SECONDBRAIN_DIR="$HOME/Simon/SecondBrain"

# Determine if we're running on the Pi or Mac
if [[ "$(uname)" == "Darwin" ]]; then
    IS_MAC=true
    echo "Running on MacBook"
else
    IS_MAC=false
    echo "Running on Raspberry Pi"
fi

# Function to start network on Pi
start_network() {
    if [ "$IS_MAC" = false ]; then
        echo "Starting network connection..."
        ./startnetwork.sh
        # Wait for network to be ready
        echo "Waiting for network connection..."
        for i in {1..15}; do
            if ping -c 1 google.com &> /dev/null; then
                echo "Network is ready."
                return 0
            fi
            sleep 1
        done
        echo "WARNING: Network may not be fully ready, but continuing..."
    else
        echo "Network management skipped on MacBook."
    fi
}

# Function to sync time on Pi
sync_time() {
    if [ "$IS_MAC" = false ]; then
        echo "Synchronizing system time..."
        sudo ./time.sh
    else
        echo "Time synchronization skipped on MacBook."
    fi
}

# Function to stop network on Pi
stop_network() {
    if [ "$IS_MAC" = false ]; then
        echo "Stopping network connection..."
        ./stopnetwork.sh
    else
        echo "Network management skipped on MacBook."
    fi
}

# Function to sync writing files from Pi to Mac
sync_writing_to_mac() {
    if [ "$IS_MAC" = true ]; then
        # Running on Mac, so we're pulling from Pi
        echo "ERROR: This script should be run on the Pi when syncing to Mac."
        exit 1
    else
        echo "Syncing writing files from Pi to Mac..."
        rsync -avz --delete "$PI_WRITING_DIR/" "$MAC_WRITING_DIR/"
        echo "Writing files sync completed!"
    fi
}

# Function to sync Neovim config from Mac to Pi
sync_nvim_config() {
    if [ "$IS_MAC" = true ]; then
        # Running on Mac, so we're pushing to Pi
        echo "ERROR: This script should be run on the Pi when syncing Neovim config."
        exit 1
    else
        echo "Syncing Neovim config from Mac to Pi..."
        rsync -avz "$MAC_NVIM_CONFIG/" "$PI_NVIM_CONFIG_DIR/"
        echo "Neovim config sync completed!"
    fi
}

# Function to sync typewriter utility scripts from Mac to Pi
sync_typewriter_config() {
    if [ "$IS_MAC" = true ]; then
        # Running on Mac, so we're pushing to Pi
        echo "ERROR: This script should be run on the Pi when syncing typewriter configs."
        exit 1
    else
        echo "Syncing typewriter utility scripts from Mac to Pi..."
        rsync -avz "$MAC_TYPEWRITER_CONFIG/" "$PI_CONFIG_DIR/"
        echo "Typewriter utility scripts sync completed!"
    fi
}

# Function to sync SecondBrain from Mac to Pi
sync_secondbrain_from_mac() {
    if [ "$IS_MAC" = true ]; then
        # Running on Mac, so we're pushing to Pi
        echo "ERROR: This script should be run on the Pi when syncing SecondBrain."
        exit 1
    else
        echo "Syncing SecondBrain from Mac to Pi..."
        rsync -avz "$MAC_SECONDBRAIN_DIR/" "$PI_SECONDBRAIN_DIR/"
        echo "SecondBrain sync completed!"
    fi
}

# Main function to run everything in sequence
main() {
    echo "Starting Micro Journal sync process..."
    
    # 1. Open network
    start_network
    
    # 2. Sync time
    sync_time
    
    # 3. Sync writing from Pi to Mac
    sync_writing_to_mac
    
    # 4. Sync Neovim config from Mac to Pi
    sync_nvim_config
    
    # 5. Sync typewriter utility scripts from Mac to Pi
    sync_typewriter_config
    
    # 6. Sync SecondBrain from Mac to Pi
    sync_secondbrain_from_mac
    
    # 7. Close network
    stop_network
    
    echo "Micro Journal sync process completed successfully!"
}

# Run the main function
main
