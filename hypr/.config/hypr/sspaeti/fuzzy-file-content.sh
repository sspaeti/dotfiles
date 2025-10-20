#!/bin/bash
set -euo pipefail

# Define available search directories
AVAILABLE_DIRS=(
    "$HOME/Documents"
)

# Add all subdirectories in Simon/Sync to the list
if [ -d "$HOME/Simon/Sync" ]; then
    while IFS= read -r -d '' dir; do
        AVAILABLE_DIRS+=("$dir")
    done < <(find "$HOME/Simon/Sync" -mindepth 1 -maxdepth 1 -type d -print0)
fi

# Let user select which directories to search
DIR_MENU=""
for dir in "${AVAILABLE_DIRS[@]}"; do
    DIR_MENU="$DIR_MENU$(basename "$dir") ($dir)\n"
done

SELECTED_DIR=$(echo -e "$DIR_MENU" | walker --dmenu -p "Select search directory: " 2>/dev/null)

# Exit if no directory selected
if [ -z "$SELECTED_DIR" ]; then
    exit 0
fi

# Extract the actual path from the selection
SEARCH_DIR=$(echo "$SELECTED_DIR" | sed 's/.*(\(.*\))/\1/')
SEARCH_DIRS=("$SEARCH_DIR")

# Get search term from user
SEARCH_TERM=$(walker --dmenu -p "Search for: " 2>/dev/null)

# Exit if no search term
if [ -z "$SEARCH_TERM" ]; then
    exit 0
fi

# Convert search term to a fuzzy regex: 'test' -> 't.*e.*s.*t.*'
FUZZY_REGEX=$(echo "$SEARCH_TERM" | sed 's/./&.*/g')

# Notify the user that the search is starting
notify-send "Omarchy Fuzzy Search" "Searching for '$SEARCH_TERM'..."

# Search with ripgrep, limit results, and display with wofi
# The output from rg is in the format: /path/to/file:line_number:content
SELECTED=$(rg --line-number \
   --no-heading \
   --color=never \
   --max-columns=300 \
   --ignore-case \
   --hidden \
   --glob '!.zip/**' \
   --glob '!.git/**' \
   --glob '!node_modules/**' \
   --glob '!.cache/**' \
   "$FUZZY_REGEX" "${SEARCH_DIRS[@]}" 2>/dev/null | \
   awk -F: '{print $1}' | sort -u | \
   head -n 200 | \
   walker --dmenu -p "Results: " 2>/dev/null)

# Exit if nothing selected
if [ -z "$SELECTED" ]; then
    exit 0
fi

# The selected line is now just the file path
FILE_PATH="$SELECTED"

# Show options for what to do with the file
ACTION=$(echo -e "Open file\nCopy path to clipboard\nOpen folder in Nautilus\nOpen folder in terminal" | walker --dmenu -p "Action: " 2>/dev/null)

if [ "$ACTION" = "Copy path to clipboard" ]; then
    echo "$FILE_PATH" | wl-copy
    notify-send "Path Copied" "File path copied to clipboard: $FILE_PATH"
elif [ "$ACTION" = "Open file" ]; then
    # Open the file in the preferred editor
    if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
        if command -v code >/dev/null; then
            code "$FILE_PATH"
        elif command -v nvim >/dev/null; then
            nvim "$FILE_PATH"
        else
            xdg-open "$FILE_PATH"
        fi
    else
        notify-send "File Not Found" "Could not open the selected file: $FILE_PATH"
    fi
elif [ "$ACTION" = "Open folder in Nautilus" ]; then
    # Get the directory containing the file
    DIR_PATH=$(dirname "$FILE_PATH")
    if [ -d "$DIR_PATH" ]; then
        nautilus "$DIR_PATH"
    else
        notify-send "Directory Not Found" "Could not open directory: $DIR_PATH"
    fi
elif [ "$ACTION" = "Open folder in terminal" ]; then
    # Get the directory containing the file
    DIR_PATH=$(dirname "$FILE_PATH")
    if [ -d "$DIR_PATH" ]; then
        # Use the same terminal variable as in your hypr config
        if command -v ghostty >/dev/null; then
            ghostty --working-directory="$DIR_PATH"
        elif command -v alacritty >/dev/null; then
            alacritty --working-directory "$DIR_PATH"
        else
            xdg-open "$DIR_PATH"
        fi
    else
        notify-send "Directory Not Found" "Could not open directory: $DIR_PATH"
    fi
fi

