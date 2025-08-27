#!/bin/bash

# Screenshot Browser with Gum TUI - A beautiful Snagit-like interface for Linux

PICTURES_DIR="/home/sspaeti/Pictures"
PRINTSCREEN_DIR="$PICTURES_DIR/Printscreen"
INDEX_FILE="$PRINTSCREEN_DIR/.screenshot_index.txt"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    for dep in yazi fzf tesseract gum; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        gum style --foreground 196 --bold "Missing dependencies: ${missing_deps[*]}"
        gum style --foreground 214 "Please install them using your package manager"
        gum style --foreground 51 "For Arch Linux: sudo pacman -S yazi-git fzf tesseract gum"
        exit 1
    fi
}

# Function to display header
show_header() {
    clear
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 60 --margin "1 2" --padding "2 4" \
        '📸 SCREENSHOT BROWSER' \
        '' \
        'A beautiful Snagit-like library for Linux'
        
    gum style --foreground 8 --italic "Organized • Searchable • Fast"
    echo
}

# Function to show statistics in a nice format
show_stats() {
    show_header
    
    if [[ -d "$PRINTSCREEN_DIR" ]]; then
        # Calculate stats
        local total_screenshots=$(find "$PRINTSCREEN_DIR" -name "*.png" | wc -l)
        local total_size=$(find "$PRINTSCREEN_DIR" -name "*.png" -exec stat -c%s {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
        local total_size_mb=$((total_size / 1024 / 1024))
        
        # Show main stats
        gum join --vertical \
            "$(gum style --foreground 51 --bold 'LIBRARY STATISTICS')" \
            "" \
            "$(gum join --horizontal \
                "$(gum style --foreground 119 '📷 Total Screenshots: ')" \
                "$(gum style --foreground 15 --bold "$total_screenshots")")" \
            "$(gum join --horizontal \
                "$(gum style --foreground 119 '💾 Total Size: ')" \
                "$(gum style --foreground 15 --bold "${total_size_mb} MB")")"
        
        echo
        
        # Show monthly breakdown
        gum style --foreground 51 --bold "📅 BY MONTH"
        echo
        
        for month_dir in $(ls -1 "$PRINTSCREEN_DIR" | grep -E '^[0-9]{4}-[0-9]{2}$' | sort -r | head -6); do
            local month_count=$(find "$PRINTSCREEN_DIR/$month_dir" -name "*.png" | wc -l)
            local month_size=$(find "$PRINTSCREEN_DIR/$month_dir" -name "*.png" -exec stat -c%s {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
            local month_size_mb=$((month_size / 1024 / 1024))
            
            gum join --horizontal \
                "$(gum style --foreground 81 "  $month_dir:")" \
                "$(gum style --foreground 15 --bold "$month_count files")" \
                "$(gum style --foreground 8 "($month_size_mb MB)")"
        done
        
        echo
        
        # OCR index status
        if [[ -f "$INDEX_FILE" ]]; then
            local indexed_count=$(grep -v '^#' "$INDEX_FILE" | wc -l)
            gum style --foreground 119 "🔍 OCR Indexed: $(gum style --foreground 15 --bold "$indexed_count screenshots")"
        else
            gum style --foreground 214 "⚠️  OCR Index not built yet"
        fi
    else
        gum style --foreground 196 --bold "❌ Printscreen directory not found"
    fi
}

# Function to search screenshots with OCR
search_screenshots() {
    show_header
    
    # Check if index exists
    if [[ ! -f "$INDEX_FILE" ]]; then
        gum style --foreground 214 "⚠️  OCR index not found. Building index..."
        echo
        
        if gum confirm "Build OCR search index now? This may take a few minutes."; then
            gum spin --spinner dot --title "Building OCR index..." -- "$SCRIPT_DIR/screenshot-indexer-parallel.sh" --rebuild
        else
            return
        fi
    fi
    
    gum style --foreground 51 --bold "🔍 SEARCH BY TEXT CONTENT"
    echo
    
    # Get search term from user
    local search_term=$(gum input \
        --placeholder "Enter text to search for (e.g., 'Bestell', 'extract')..." \
        --prompt "🔍 " \
        --prompt.foreground="119")
    
    if [[ -z "$search_term" ]]; then
        gum style --foreground 214 "No search term provided"
        return
    fi
    
    gum style --foreground 8 "Searching for: $(gum style --foreground 15 --bold "$search_term")"
    echo
    
    # Search through OCR content
    local search_results=$(grep -v '^#' "$INDEX_FILE" | grep -i "$search_term")
    
    if [[ -z "$search_results" ]]; then
        gum style --foreground 214 "❌ No screenshots found containing: $search_term"
        gum style --foreground 8 "Try different keywords or rebuild the index"
        return
    fi
    
    # Count results
    local result_count=$(echo "$search_results" | wc -l)
    gum style --foreground 119 "✅ Found $result_count screenshot(s)"
    echo
    
    # Use fzf for selection with better preview
    local selected_line=$(echo "$search_results" | \
        fzf --preview='echo "📁 File: {1}"; echo; echo "📝 OCR Text:"; echo {2} | fold -w 50' \
            --preview-window=right:50% \
            --header="📸 Select screenshot to view (Enter to open in yazi)" \
            --prompt="🔍 " \
            --delimiter="|" \
            --with-nth=1)
    
    if [[ -n "$selected_line" ]]; then
        local selected_file=$(echo "$selected_line" | cut -d'|' -f1)
        local selected_dir=$(dirname "$selected_file")
        
        gum style --foreground 119 "Opening: $(basename "$selected_file")"
        
        # Open yazi in the directory with the file selected
        cd "$selected_dir" && yazi "$(basename "$selected_file")"
    fi
}

# Function to browse screenshots
browse_screenshots() {
    show_header
    gum style --foreground 119 "🗂️  Opening screenshot browser..."
    yazi "$PRINTSCREEN_DIR"
}

# Function to show recent screenshots
show_recent() {
    show_header
    gum style --foreground 51 --bold "⏰ RECENT SCREENSHOTS"
    echo
    
    # Find and show recent screenshots
    local recent_files=$(find "$PRINTSCREEN_DIR" -name "*.png" -printf "%T@ %p\n" | \
        sort -nr | head -20 | cut -d' ' -f2-)
    
    if [[ -z "$recent_files" ]]; then
        gum style --foreground 214 "No screenshots found"
        return
    fi
    
    local selected_recent=$(echo "$recent_files" | \
        fzf --preview='echo "📁 File: {}"; echo; stat -c "📊 Size: %s bytes" "{}"; echo "🕐 Modified: %y" "{}"' \
            --preview-window=right:50% \
            --header="📸 Recent Screenshots (Last 20)" \
            --prompt="📅 ")
    
    if [[ -n "$selected_recent" ]]; then
        local selected_dir=$(dirname "$selected_recent")
        gum style --foreground 119 "Opening: $(basename "$selected_recent")"
        cd "$selected_dir" && yazi "$(basename "$selected_recent")"
    fi
}

# Function to browse by month
browse_by_month() {
    show_header
    gum style --foreground 51 --bold "📅 BROWSE BY MONTH"
    echo
    
    # Get available months
    local months=$(ls -1 "$PRINTSCREEN_DIR" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}$' | sort -r)
    
    if [[ -z "$months" ]]; then
        gum style --foreground 214 "No monthly folders found"
        return
    fi
    
    # Let user select month
    local selected_month=$(echo "$months" | gum choose \
        --height 8 \
        --header="📅 Select month to browse (j/k to navigate, Enter to select):" \
        --header.foreground="8" \
        --selected.foreground="15" \
        --selected.background="57" \
        --cursor="→ " \
        --cursor.foreground="119")
    
    if [[ -n "$selected_month" ]]; then
        local month_path="$PRINTSCREEN_DIR/$selected_month"
        local count=$(find "$month_path" -name "*.png" | wc -l)
        
        gum style --foreground 119 "Opening $selected_month ($(gum style --bold "$count screenshots"))"
        yazi "$month_path"
    fi
}

# Function to rebuild index with options
rebuild_index() {
    show_header
    gum style --foreground 51 --bold "🔧 OCR INDEX MANAGEMENT"
    echo
    
    local choice=$(gum choose \
        --height 6 \
        --header="Choose indexing mode (j/k to navigate, Enter to select):" \
        --header.foreground="8" \
        --selected.foreground="15" \
        --selected.background="57" \
        --cursor="→ " \
        --cursor.foreground="119" \
        "🚀 Smart Update (recommended - only new/modified files)" \
        "🔄 Full Rebuild (all files)" \
        "❌ Cancel")
    
    case "$choice" in
        *"Smart Update"*)
            gum style --foreground 119 "🚀 Starting smart incremental update..."
            gum spin --spinner dot --title "Smart indexing in progress..." -- "$SCRIPT_DIR/screenshot-indexer-parallel.sh" --smart
            gum style --foreground 119 "✅ Smart update completed!"
            ;;
        *"Full Rebuild"*)
            if gum confirm "This will rebuild the entire OCR index. Continue?"; then
                gum style --foreground 214 "🔄 Starting full rebuild with parallel processing..."
                gum spin --spinner dot --title "Full rebuild in progress..." -- "$SCRIPT_DIR/screenshot-indexer-parallel.sh" --rebuild
                gum style --foreground 119 "✅ Full rebuild completed!"
            fi
            ;;
        *) 
            gum style --foreground 8 "Cancelled"
            ;;
    esac
}

# Main menu
show_main_menu() {
    while true; do
        show_header
        
        local choice=$(gum choose \
            --height 10 \
            --header="Use j/k or ↑/↓ to navigate, Enter to select, q to quit:" \
            --header.foreground="8" \
            --selected.foreground="15" \
            --selected.background="57" \
            --cursor="→ " \
            --cursor.foreground="119" \
            "🔍 Search by text content (OCR)" \
            "📁 Browse all screenshots" \
            "⏰ Show recent screenshots" \
            "📅 Browse by month" \
            "🔧 Rebuild search index" \
            "📊 Show statistics" \
            "❌ Exit")
        
        # Handle vim-style quit or empty choice (Escape/Ctrl+C)
        if [[ -z "$choice" ]]; then
            gum style --foreground 119 "👋 Thanks for using Screenshot Browser!"
            exit 0
        fi
        
        case "$choice" in
            *"Search by text"*) search_screenshots ;;
            *"Browse all"*) browse_screenshots ;;
            *"recent"*) show_recent ;;
            *"by month"*) browse_by_month ;;
            *"Rebuild"*) rebuild_index ;;
            *"statistics"*) show_stats ;;
            *"Exit"*) 
                gum style --foreground 119 "👋 Thanks for using Screenshot Browser!"
                exit 0 
                ;;
        esac
        
        echo
        gum style --foreground 8 "Press Enter to continue..."
        read -r
    done
}

# Main function
main() {
    check_dependencies
    
    # Ensure directory exists
    mkdir -p "$PRINTSCREEN_DIR"
    
    # Handle command line arguments
    case "${1:-menu}" in
        "search") search_screenshots ;;
        "browse") browse_screenshots ;;
        "recent") show_recent ;;
        "month") browse_by_month ;;
        "rebuild") rebuild_index ;;
        "stats") show_stats ;;
        *) show_main_menu ;;
    esac
}

# Run
main "$@"