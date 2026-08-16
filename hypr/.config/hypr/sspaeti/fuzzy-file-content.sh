#!/bin/bash
set -euo pipefail

# Fuzzy file *content* search (ripgrep).
#
# QUATTRO: see the header of fuzzy-file-names.sh -- walker/elephant are gone, so
# every `walker --dmenu` prompt became omarchy-menu-select / omarchy-menu-input.

ICON_FILE="󰈔" # nf-md-file
ICON_DIR="󰉋"  # nf-md-folder

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
SELECTED_DIR=$(
    for dir in "${AVAILABLE_DIRS[@]}"; do
        printf '%s\t%s\t%s\n' "$ICON_DIR" "$(basename "$dir")" "$dir"
    done | omarchy-menu-select "Select search directory"
) || exit 0

# The selection comes back as "<basename>\t<path>"
SEARCH_DIR=$(printf '%s' "$SELECTED_DIR" | cut -f2)
[ -d "$SEARCH_DIR" ] || exit 0

# Get search term from user
SEARCH_TERM=$(omarchy-menu-input "Search contents in $(basename "$SEARCH_DIR")") || exit 0
[ -n "$SEARCH_TERM" ] || exit 0

# Convert search term to a fuzzy regex: 'test' -> 't.*e.*s.*t.*'
FUZZY_REGEX=$(printf '%s' "$SEARCH_TERM" | sed 's/./&.*/g')

notify-send "Fuzzy Content Search" "Searching for '$SEARCH_TERM'..."

mapfile -t MATCHES < <(
    rg --line-number \
        --no-heading \
        --color=never \
        --max-columns=300 \
        --ignore-case \
        --hidden \
        --glob '!.zip/**' \
        --glob '!.git/**' \
        --glob '!node_modules/**' \
        --glob '!.cache/**' \
        "$FUZZY_REGEX" "$SEARCH_DIR" 2>/dev/null |
        awk -F: '{print $1}' | sort -u | head -n 200
)

if [ "${#MATCHES[@]}" -eq 0 ]; then
    notify-send "Fuzzy Content Search" "No matches for '$SEARCH_TERM'"
    exit 0
fi

SELECTED=$(
    for path in "${MATCHES[@]}"; do
        printf '%s\t%s\t%s\n' "$ICON_FILE" "$(basename "$path")" "$path"
    done | omarchy-menu-select "Results (${#MATCHES[@]})"
) || exit 0

FILE_PATH=$(printf '%s' "$SELECTED" | cut -f2)
[ -f "$FILE_PATH" ] || exit 0
DIR_PATH=$(dirname "$FILE_PATH")

ACTION=$(omarchy-menu-select "Action" \
    "Open file" "Copy path to clipboard" "Open folder in Nautilus" "Open folder in terminal") || exit 0

case "$ACTION" in
"Copy path to clipboard")
    printf '%s\n' "$FILE_PATH" | wl-copy
    notify-send "Path Copied" "$FILE_PATH"
    ;;
"Open file")
    if command -v code >/dev/null; then
        code "$FILE_PATH"
    elif command -v nvim >/dev/null; then
        omarchy-launch-tui nvim "$FILE_PATH"
    else
        xdg-open "$FILE_PATH"
    fi
    ;;
"Open folder in Nautilus")
    nautilus "$DIR_PATH"
    ;;
"Open folder in terminal")
    if command -v ghostty >/dev/null; then
        ghostty --working-directory="$DIR_PATH"
    elif command -v alacritty >/dev/null; then
        alacritty --working-directory "$DIR_PATH"
    else
        xdg-open "$DIR_PATH"
    fi
    ;;
esac
