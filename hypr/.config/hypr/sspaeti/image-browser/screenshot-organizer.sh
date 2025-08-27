#!/bin/bash

# Screenshot organizer - moves screenshots into monthly folders

PICTURES_DIR="/home/sspaeti/Pictures"
PRINTSCREEN_DIR="$PICTURES_DIR/Printscreen"

cd "$PICTURES_DIR" || exit 1

# Create Printscreen directory if it doesn't exist
mkdir -p "$PRINTSCREEN_DIR"

# Function to extract year-month from filename
get_year_month() {
    local filename="$1"
    
    # Handle hyprshot format: 2025-07-05-110532_hyprshot.png
    if [[ "$filename" =~ ^([0-9]{4}-[0-9]{2})-[0-9]{2}-.+_hyprshot\.png$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    
    # Handle screenshot format: screenshot-2025-08-01_22-09-47.png
    if [[ "$filename" =~ ^screenshot-([0-9]{4}-[0-9]{2})-[0-9]{2}_.+\.png$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    
    # Handle flame screen format: flame screen-2025-07-10_12-10.png
    if [[ "$filename" =~ ^flame\ screen-([0-9]{4}-[0-9]{2})-[0-9]{2}_.+\.png$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    
    return 1
}

# Organize screenshots
for file in *.png; do
    # Skip if no PNG files found or if file is in subdirectory
    [[ "$file" == "*.png" ]] && continue
    [[ -d "$file" ]] && continue
    
    year_month=$(get_year_month "$file")
    
    if [[ -n "$year_month" ]]; then
        # Create monthly directory if it doesn't exist
        mkdir -p "$PRINTSCREEN_DIR/$year_month"
        
        # Move file to monthly directory
        echo "Moving $file to $PRINTSCREEN_DIR/$year_month/"
        mv "$file" "$PRINTSCREEN_DIR/$year_month/"
    else
        echo "Could not parse date from: $file"
    fi
done

echo "Screenshot organization complete!"