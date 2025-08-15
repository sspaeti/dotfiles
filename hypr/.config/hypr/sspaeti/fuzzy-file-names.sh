#!/bin/bash
set -euo pipefail

# Define available search directories
AVAILABLE_DIRS=(
    "$HOME/Pictures/"
)

# Add all subdirectories in Simon/Sync to the list
if [ -d "$HOME/Simon/Sync" ]; then
    while IFS= read -r -d '' dir; do
        AVAILABLE_DIRS+=("$dir")
    done < <(find "$HOME/Simon/Sync" -mindepth 1 -maxdepth 1 -type d -print0)
fi

if [ -d "$HOME/git" ]; then
    while IFS= read -r -d '' dir; do
        AVAILABLE_DIRS+=("$dir")
    done < <(find "$HOME/git" -mindepth 1 -maxdepth 1 -type d -print0)
fi

# Let user select which directories to search
DIR_MENU=""
for dir in "${AVAILABLE_DIRS[@]}"; do
    DIR_MENU="$DIR_MENU$(basename "$dir") ($dir)\n"
done

SELECTED_DIR=$(echo -e "$DIR_MENU" | walker --dmenu --placeholder "Select search directory: " --forceprint)

# Exit if no directory selected
if [ -z "$SELECTED_DIR" ]; then
    exit 0
fi

# Extract the actual path from the selection
SEARCH_DIR=$(echo "$SELECTED_DIR" | sed 's/.*(\(.*\))/\1/')

# Get search term from user
SEARCH_TERM=$(walker --dmenu --placeholder "Search file names for: " --forceprint)

# Exit if no search term
if [ -z "$SEARCH_TERM" ]; then
    exit 0
fi

# Notify the user that the search is starting
notify-send "Omarchy File Name Search" "Searching for '$SEARCH_TERM'..."

# Search file names with fd and grep, prioritizing filename matches over path matches
SELECTED=$(fd -t f --hidden --exclude .git --exclude node_modules --exclude .cache --exclude .zip . "$SEARCH_DIR" 2>/dev/null | \
    {
        # First priority: filename contains the search term (case insensitive)
        grep -i "$SEARCH_TERM" | {
            # Show files with search term in basename first
            while IFS= read -r file; do
                if basename "$file" | grep -qi "$SEARCH_TERM"; then
                    echo "$file"
                fi
            done
            # Then show files with search term in path
            while IFS= read -r file; do
                if ! basename "$file" | grep -qi "$SEARCH_TERM" && echo "$file" | grep -qi "$SEARCH_TERM"; then
                    echo "$file"
                fi
            done
        } <<< "$(cat)"
    } | \
    head -n 200 | \
    walker --dmenu --placeholder "Results: " --forceprint)

# Exit if nothing selected
if [ -z "$SELECTED" ]; then
    exit 0
fi

# The selected line is the file path
FILE_PATH="$SELECTED"

# Show options for what to do with the file
ACTION=$(echo -e "Open file\nCopy path to clipboard\nOpen folder in Nautilus\nOpen folder in terminal" | walker --dmenu --placeholder "Action: " --forceprint)

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
