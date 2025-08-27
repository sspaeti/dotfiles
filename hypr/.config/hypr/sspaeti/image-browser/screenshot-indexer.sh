#!/bin/bash

# Screenshot OCR Indexer - extracts text from screenshots for searching

PICTURES_DIR="/home/sspaeti/Pictures"
PRINTSCREEN_DIR="$PICTURES_DIR/Printscreen"
INDEX_FILE="$PRINTSCREEN_DIR/.screenshot_index.txt"
TEMP_DIR="/tmp/screenshot_ocr"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Function to extract text from image using tesseract
extract_text() {
    local image_path="$1"
    local temp_text_file="$TEMP_DIR/temp_ocr.txt"
    
    # Try OCR with German and English languages
    # Use stdout directly instead of file output to avoid issues
    local ocr_text=""
    
    # Try German first (since you mentioned "Bestellübersicht")
    if ocr_text=$(tesseract "$image_path" stdout -l deu 2>/dev/null); then
        echo "$ocr_text"
    elif ocr_text=$(tesseract "$image_path" stdout -l eng 2>/dev/null); then
        echo "$ocr_text" 
    fi | tr '\n' ' ' | tr -s ' ' | sed 's/^ *//;s/ *$//'
}

# Function to get file modification time
get_file_time() {
    local file_path="$1"
    stat -c %Y "$file_path" 2>/dev/null
}

# Main indexing function
index_screenshots() {
    local force_reindex="$1"
    local index_tmp="$INDEX_FILE.tmp"
    
    echo "Building screenshot index..."
    
    # Create header for new index
    echo "# Screenshot OCR Index - Generated $(date)" > "$index_tmp"
    echo "# Format: filepath|ocr_text|file_size|mod_time" >> "$index_tmp"
    
    local processed_count=0
    local total_files=$(find "$PRINTSCREEN_DIR" -name "*.png" | wc -l)
    
    find "$PRINTSCREEN_DIR" -name "*.png" | sort | while read -r image_path; do
        processed_count=$((processed_count + 1))
        printf "\rProcessing %d/%d: %s" "$processed_count" "$total_files" "$(basename "$image_path")"
        
        # Skip if already indexed and not forcing reindex
        if [[ "$force_reindex" != "force" && -f "$INDEX_FILE" ]]; then
            local current_mod_time=$(get_file_time "$image_path")
            local indexed_mod_time=$(grep "^$(echo "$image_path" | sed 's/[[\].*^$(){}?+|/]/\\&/g')|" "$INDEX_FILE" 2>/dev/null | cut -d'|' -f4)
            
            if [[ "$indexed_mod_time" == "$current_mod_time" ]]; then
                # Copy existing entry
                grep "^$(echo "$image_path" | sed 's/[[\].*^$(){}?+|/]/\\&/g')|" "$INDEX_FILE" 2>/dev/null >> "$index_tmp"
                continue
            fi
        fi
        
        # Extract OCR text
        local ocr_text=$(extract_text "$image_path")
        local file_size=$(stat -c%s "$image_path" 2>/dev/null || echo "0")
        local mod_time=$(get_file_time "$image_path")
        
        # Add to index
        echo "$image_path|$ocr_text|$file_size|$mod_time" >> "$index_tmp"
    done
    
    echo
    
    # Replace old index with new one
    mv "$index_tmp" "$INDEX_FILE"
    echo "Index complete! $(wc -l < "$INDEX_FILE") entries processed."
    
    # Cleanup
    rm -rf "$TEMP_DIR"
}

# Check if we need to build or update index
if [[ "$1" == "--rebuild" ]] || [[ ! -f "$INDEX_FILE" ]]; then
    index_screenshots "force"
else
    index_screenshots
fi