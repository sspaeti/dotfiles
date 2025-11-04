#!/bin/bash

# Wrapper for omarchy-cmd-screenshot with post-processing
# Calls the original omarchy script, then organizes screenshots into monthly folders

# Call the original omarchy-cmd-screenshot with all arguments passed through
~/.local/share/omarchy/bin/omarchy-cmd-screenshot "$@"

# Post-processing: Auto-organize screenshots into year-month folders
# Run in background to avoid blocking the screenshot workflow
{
    sleep 0.5  # Wait for file to be fully written
    ~/.config/hypr/sspaeti/image-browser/auto-organize-screenshot.sh >/dev/null 2>&1

    # # Fast OCR indexing - only recent screenshots
    # if [[ -f "/home/sspaeti/.config/hypr/sspaeti/image-browser/screenshot-indexer-parallel.sh" ]]; then
    #     "/home/sspaeti/.config/hypr/sspaeti/image-browser/screenshot-indexer-parallel.sh" --recent >/dev/null 2>&1
    # fi
} &
