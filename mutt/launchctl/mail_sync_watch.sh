#!/bin/bash

# mail_sync_watch.sh - Script to sync and process emails

# Configure log file
LOG_DIR="$HOME/.config/mutt/logs"
LOG_FILE="$LOG_DIR/mail_sync.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}

sync_mail() {
    log "=== Starting mail sync cycle ==="
    
    log "1. Downloading emails..."
    offlineimap -a sspaeti.com
    if [ $? -ne 0 ]; then
        log "Error: Download failed"
        return 1
    fi
    
    log "2. Screening emails..."
    ~/.config/mutt/initial_screening.sh
    if [ $? -ne 0 ]; then
        log "Error: Screening failed"
        return 1
    fi
    
    log "3. Syncing back to IMAP..."
    offlineimap -a sspaeti.com
    if [ $? -ne 0 ]; then
        log "Error: Upload sync failed"
        return 1
    fi
    
    log "Sync cycle completed successfully"
    echo
}

# Check if running in loop mode
if [ "$1" = "--loop" ]; then
    log "Starting mail sync in loop mode (30 minute intervals)"
    while true; do
        sync_mail
        log "Sleeping for 30 minutes..."
        sleep 3600
    done
else
    # Run once
    sync_mail
fi
