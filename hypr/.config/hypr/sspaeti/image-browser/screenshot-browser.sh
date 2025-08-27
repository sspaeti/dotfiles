#!/bin/bash

# Screenshot Browser TUI - A Snagit-like interface for Linux screenshots with OCR search

PICTURES_DIR="/home/sspaeti/Pictures"
PRINTSCREEN_DIR="$PICTURES_DIR/Printscreen"
INDEX_FILE="$PRINTSCREEN_DIR/.screenshot_index.txt"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v yazi >/dev/null 2>&1; then
        missing_deps+=("yazi")
    fi
    
    if ! command -v fzf >/dev/null 2>&1; then
        missing_deps+=("fzf")
    fi
    
    if ! command -v tesseract >/dev/null 2>&1; then
        missing_deps+=("tesseract")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}Please install them using your package manager${NC}"
        echo -e "${CYAN}For Arch Linux: sudo pacman -S yazi-git fzf tesseract${NC}"
        exit 1
    fi
}

# Function to display help
show_help() {
    echo -e "${WHITE}Screenshot Browser - A Snagit-like TUI for Linux${NC}"
    echo
    echo -e "${CYAN}Usage:${NC}"
    echo "  $0 [command]"
    echo
    echo -e "${CYAN}Commands:${NC}"
    echo -e "  ${GREEN}search${NC}      Search screenshots by OCR text content"
    echo -e "  ${GREEN}browse${NC}      Browse all screenshots with yazi"
    echo -e "  ${GREEN}recent${NC}      Show recent screenshots"
    echo -e "  ${GREEN}month${NC}       Browse screenshots by month"
    echo -e "  ${GREEN}rebuild${NC}     Rebuild OCR search index"
    echo -e "  ${GREEN}stats${NC}       Show screenshot statistics"
    echo -e "  ${GREEN}help${NC}        Show this help message"
    echo
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0 search"
    echo "  $0 browse"
    echo "  $0 month 2025-08"
}

# Function to search screenshots by OCR content
search_screenshots() {
    if [[ ! -f "$INDEX_FILE" ]]; then
        echo -e "${YELLOW}Index not found. Building OCR index with parallel processing...${NC}"
        "$SCRIPT_DIR/screenshot-indexer-parallel.sh" --rebuild
    fi
    
    echo -e "${CYAN}Search screenshots by text content (fuzzy search):${NC}"
    echo -e "${YELLOW}Type your search term and press Enter${NC}"
    
    # Use fzf for fuzzy searching through OCR content
    local selected_line=$(grep -v '^#' "$INDEX_FILE" | \
        fzf --preview="echo {} | cut -d'|' -f1 | xargs -I {} sh -c 'echo \"File: {}\"; echo \"OCR Text:\"; echo {} | cut -d\"|\" -f2 | fold -w 60'" \
            --preview-window=right:50% \
            --header="Search screenshots by OCR text content" \
            --prompt="OCR Search > " \
            --delimiter="|" \
            --with-nth=2 \
            --bind="ctrl-p:preview-up,ctrl-n:preview-down")
    
    if [[ -n "$selected_line" ]]; then
        local selected_file=$(echo "$selected_line" | cut -d'|' -f1)
        echo -e "${GREEN}Opening: $selected_file${NC}"
        
        # Get the directory containing the selected file
        local selected_dir=$(dirname "$selected_file")
        
        # Open yazi with the selected file pre-focused
        yazi "$selected_dir" --chooser-file=/tmp/yazi_selected
    fi
}

# Function to browse all screenshots
browse_screenshots() {
    echo -e "${CYAN}Opening screenshot browser...${NC}"
    yazi "$PRINTSCREEN_DIR"
}

# Function to show recent screenshots
show_recent() {
    echo -e "${CYAN}Recent screenshots (last 20):${NC}"
    
    # Find and sort by modification time, show last 20
    find "$PRINTSCREEN_DIR" -name "*.png" -printf "%T@ %p\n" | \
        sort -nr | head -20 | cut -d' ' -f2- | \
        fzf --preview="echo {} | xargs -I {} sh -c 'echo \"File: {}\"; stat -c \"Size: %s bytes, Modified: %y\" \"{}\"; if command -v identify >/dev/null; then identify \"{}\"; fi'" \
            --preview-window=right:50% \
            --header="Recent Screenshots" \
            --prompt="Select > " | \
        xargs -I {} yazi "$(dirname "{}")"
}

# Function to browse by month
browse_by_month() {
    local month="$1"
    
    if [[ -z "$month" ]]; then
        echo -e "${CYAN}Available months:${NC}"
        ls -1 "$PRINTSCREEN_DIR" | grep -E '^[0-9]{4}-[0-9]{2}$' | sort -r | \
            fzf --header="Select month to browse" --prompt="Month > " | \
            xargs -I {} yazi "$PRINTSCREEN_DIR/{}"
    else
        if [[ -d "$PRINTSCREEN_DIR/$month" ]]; then
            echo -e "${GREEN}Browsing screenshots from $month${NC}"
            yazi "$PRINTSCREEN_DIR/$month"
        else
            echo -e "${RED}Month directory not found: $month${NC}"
            exit 1
        fi
    fi
}

# Function to rebuild OCR index
rebuild_index() {
    echo -e "${YELLOW}Rebuilding OCR search index with parallel processing...${NC}"
    "$SCRIPT_DIR/screenshot-indexer-parallel.sh" --rebuild
}

# Function to show statistics
show_stats() {
    echo -e "${WHITE}Screenshot Statistics${NC}"
    echo -e "${CYAN}===================${NC}"
    
    if [[ -d "$PRINTSCREEN_DIR" ]]; then
        local total_screenshots=$(find "$PRINTSCREEN_DIR" -name "*.png" | wc -l)
        local total_size=$(find "$PRINTSCREEN_DIR" -name "*.png" -exec stat -c%s {} \; | awk '{sum+=$1} END {print sum}')
        local total_size_mb=$((total_size / 1024 / 1024))
        
        echo -e "Total screenshots: ${GREEN}$total_screenshots${NC}"
        echo -e "Total size: ${GREEN}${total_size_mb} MB${NC}"
        echo
        
        echo -e "${CYAN}By month:${NC}"
        for month_dir in $(ls -1 "$PRINTSCREEN_DIR" | grep -E '^[0-9]{4}-[0-9]{2}$' | sort -r); do
            local month_count=$(find "$PRINTSCREEN_DIR/$month_dir" -name "*.png" | wc -l)
            local month_size=$(find "$PRINTSCREEN_DIR/$month_dir" -name "*.png" -exec stat -c%s {} \; | awk '{sum+=$1} END {print sum}')
            local month_size_mb=$((month_size / 1024 / 1024))
            echo -e "  $month_dir: ${GREEN}$month_count${NC} files (${GREEN}${month_size_mb}${NC} MB)"
        done
        
        if [[ -f "$INDEX_FILE" ]]; then
            local indexed_count=$(grep -v '^#' "$INDEX_FILE" | wc -l)
            echo
            echo -e "OCR indexed: ${GREEN}$indexed_count${NC} screenshots"
        fi
    else
        echo -e "${RED}Printscreen directory not found${NC}"
    fi
}

# Main menu for interactive mode
show_main_menu() {
    while true; do
        clear
        echo -e "${WHITE}📸 Screenshot Browser${NC}"
        echo -e "${CYAN}====================${NC}"
        echo
        echo -e "${CYAN}What would you like to do?${NC}"
        echo
        echo -e "1. ${GREEN}🔍 Search by text content (OCR)${NC}"
        echo -e "2. ${GREEN}📁 Browse all screenshots${NC}"
        echo -e "3. ${GREEN}⏰ Show recent screenshots${NC}"
        echo -e "4. ${GREEN}📅 Browse by month${NC}"
        echo -e "5. ${GREEN}🔧 Rebuild search index${NC}"
        echo -e "6. ${GREEN}📊 Show statistics${NC}"
        echo -e "7. ${GREEN}❓ Help${NC}"
        echo -e "8. ${RED}❌ Exit${NC}"
        echo
        echo -ne "${YELLOW}Enter your choice (1-8): ${NC}"
        
        read -r choice
        
        case $choice in
            1) search_screenshots ;;
            2) browse_screenshots ;;
            3) show_recent ;;
            4) browse_by_month ;;
            5) rebuild_index ;;
            6) show_stats ;;
            7) show_help ;;
            8) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice. Please try again.${NC}"; sleep 1 ;;
        esac
        
        echo
        echo -ne "${YELLOW}Press Enter to continue...${NC}"
        read -r
    done
}

# Main script logic
main() {
    check_dependencies
    
    # Ensure Printscreen directory exists
    mkdir -p "$PRINTSCREEN_DIR"
    
    case "${1:-menu}" in
        "search") search_screenshots ;;
        "browse") browse_screenshots ;;
        "recent") show_recent ;;
        "month") browse_by_month "$2" ;;
        "rebuild") rebuild_index ;;
        "stats") show_stats ;;
        "help") show_help ;;
        "menu"|"") show_main_menu ;;
        *) echo -e "${RED}Unknown command: $1${NC}"; show_help; exit 1 ;;
    esac
}

# Run main function
main "$@"