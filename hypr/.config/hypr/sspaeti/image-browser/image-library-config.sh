#!/bin/bash

# Central Configuration for Image Library System

# Base directories
export PICTURES_DIR="/home/sspaeti/Pictures"
export SHELL_DIR="/home/sspaeti/.config/hypr/sspaeti/image-browser"
export PRINTSCREEN_DIR="$PICTURES_DIR/Printscreen"
export INDEX_FILE="$SHELL_DIR/.image_ocr_index.txt"

# Define all image directories to index
export IMAGE_DIRS=(
    "$PICTURES_DIR/Printscreen"
    "$PICTURES_DIR/Fireshot"
    "$PICTURES_DIR/Ksnip"
    "/home/sspaeti/Simon/Sync/Pics/Design Blogs/Blog Pictures sspaeti"
    "/home/sspaeti/Simon/Sync/Pics/Design Blogs/Design Palette"
    "/home/sspaeti/Simon/Sync/Pics/Design Blogs/Figma"
    "/home/sspaeti/Simon/Sync/Pics/Design Blogs/Generated AI"
    "/home/sspaeti/Simon/Sync/Pics/Design Blogs/Krita"
    "/home/sspaeti/Simon/Sync/Pics/Design Blogs/Miro"
    "/home/sspaeti/Simon/Sync/Pics/Design Blogs/Snagit"
    "/home/sspaeti/Simon/Sync/Pics/Design Blogs/Unsplash"
)

# Supported image extensions (for find command)
export IMAGE_EXTENSIONS="png\|jpg\|jpeg\|webp\|PNG\|JPG\|JPEG\|WEBP"

# Function to find all images across all directories
find_all_images() {
    for dir in "${IMAGE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "Scanning directory: $dir" >&2
            find "$dir" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \)
        else
            echo "Directory not found: $dir" >&2
        fi
    done
}

# Function to count all images
count_all_images() {
    local count=0
    for dir in "${IMAGE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            local dir_count=$(find "$dir" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | wc -l)
            count=$((count + dir_count))
        fi
    done
    echo "$count"
}
