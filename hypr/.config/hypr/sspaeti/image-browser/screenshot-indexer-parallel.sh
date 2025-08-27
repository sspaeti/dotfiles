#!/bin/bash

# Fast Parallel Screenshot OCR Indexer

PICTURES_DIR="/home/sspaeti/Pictures"
PRINTSCREEN_DIR="$PICTURES_DIR/Printscreen"
INDEX_FILE="$PRINTSCREEN_DIR/.screenshot_index.txt"
TEMP_DIR="/tmp/screenshot_ocr_$$"
WORKERS=4  # Fixed to 4 workers to avoid resource contention

# Create temp directory with unique name
mkdir -p "$TEMP_DIR"

# Function to process a single image (runs in parallel)
process_image() {
    local image_path="$1"
    local worker_id="$2"
    local worker_file="$TEMP_DIR/worker_${worker_id}.txt"
    
    # Extract OCR text with both German and English
    local ocr_text=""
    ocr_text=$(tesseract "$image_path" stdout -l deu+eng 2>/dev/null | tr '\n' ' ' | tr -s ' ' | sed 's/^ *//;s/ *$//')
    
    # Get file metadata
    local file_size=$(stat -c%s "$image_path" 2>/dev/null || echo "0")
    local mod_time=$(stat -c%Y "$image_path" 2>/dev/null || echo "0")
    
    # Write to worker-specific file to avoid race conditions
    echo "$image_path|$ocr_text|$file_size|$mod_time" >> "$worker_file"
}

# Export function so GNU parallel can use it
export -f process_image
export TEMP_DIR

# Fast parallel indexing function
index_screenshots_parallel() {
    local force_reindex="$1"
    local index_tmp="$INDEX_FILE.tmp"
    
    echo "🚀 Building screenshot index with $WORKERS parallel workers..."
    
    # Create header
    echo "# Screenshot OCR Index - Generated $(date)" > "$index_tmp"
    echo "# Format: filepath|ocr_text|file_size|mod_time" >> "$index_tmp"
    
    # Get list of images to process
    local image_list="$TEMP_DIR/image_list.txt"
    find "$PRINTSCREEN_DIR" -name "*.png" | sort > "$image_list"
    local total_files=$(wc -l < "$image_list")
    
    echo "📸 Processing $total_files screenshots..."
    
    # Simple batch processing with 4 workers
    echo "⚡ Processing with $WORKERS parallel workers..."
    
    # Split files into batches
    local batch_size=$((total_files / WORKERS + 1))
    local batch_num=0
    
    # Process in batches
    split -l "$batch_size" "$image_list" "$TEMP_DIR/batch_"
    
    local batch_pids=()
    
    for batch_file in "$TEMP_DIR"/batch_*; do
        [[ ! -f "$batch_file" ]] && continue
        
        # Process batch in background
        {
            local worker_id="$batch_num"
            while IFS= read -r image_path; do
                [[ -z "$image_path" ]] && continue
                process_image "$image_path" "$worker_id"
            done < "$batch_file"
            echo "Batch $worker_id completed"
        } &
        
        batch_pids+=($!)
        ((batch_num++))
        
        # Limit to max workers
        if [[ ${#batch_pids[@]} -ge $WORKERS ]]; then
            wait "${batch_pids[0]}"
            batch_pids=("${batch_pids[@]:1}")  # Remove first element
        fi
    done
    
    # Wait for all remaining batches
    for pid in "${batch_pids[@]}"; do
        wait "$pid"
    done
    
    echo "All batches completed"
    
    # Combine all worker results into final index
    echo "📝 Combining results..."
    for worker_file in "$TEMP_DIR"/worker_*.txt; do
        [[ -f "$worker_file" ]] && cat "$worker_file" >> "$index_tmp"
    done
    
    # Sort by filepath for consistency
    {
        head -2 "$index_tmp"  # Keep header
        tail -n +3 "$index_tmp" | sort
    } > "$INDEX_FILE"
    
    local final_count=$(grep -v '^#' "$INDEX_FILE" | wc -l)
    echo "✅ Index complete! $final_count entries processed."
    
    # Cleanup
    rm -rf "$TEMP_DIR"
}

# Performance optimized version with pre-filtering
index_screenshots_smart() {
    local force_reindex="$1"
    
    if [[ "$force_reindex" == "force" ]] || [[ ! -f "$INDEX_FILE" ]]; then
        index_screenshots_parallel "$force_reindex"
        return
    fi
    
    echo "🔍 Smart incremental indexing..."
    
    # Find only new or modified files
    local new_files=0
    local temp_new_list="$TEMP_DIR/new_files.txt"
    
    find "$PRINTSCREEN_DIR" -name "*.png" | while read -r image_path; do
        local current_mod_time=$(stat -c%Y "$image_path" 2>/dev/null)
        local indexed_mod_time=$(grep "^$(echo "$image_path" | sed 's/[[\].*^$(){}?+|/]/\\&/g')|" "$INDEX_FILE" 2>/dev/null | cut -d'|' -f4)
        
        if [[ "$indexed_mod_time" != "$current_mod_time" ]]; then
            echo "$image_path" >> "$temp_new_list"
            ((new_files++))
        fi
    done
    
    if [[ $new_files -eq 0 ]]; then
        echo "✅ Index is up to date!"
        rm -rf "$TEMP_DIR"
        return
    fi
    
    echo "📸 Processing $new_files new/modified screenshots..."
    
    # Process new files with simple batch processing
    if [[ $new_files -le 4 ]]; then
        # For few files, process sequentially
        local worker_id=0
        while IFS= read -r image_path; do
            [[ -z "$image_path" ]] && continue
            process_image "$image_path" "$worker_id"
            ((worker_id++))
        done < "$temp_new_list"
    else
        # For many files, use batch processing
        local batch_size=$((new_files / WORKERS + 1))
        split -l "$batch_size" "$temp_new_list" "$TEMP_DIR/newbatch_"
        
        local batch_pids=()
        local batch_num=0
        
        for batch_file in "$TEMP_DIR"/newbatch_*; do
            [[ ! -f "$batch_file" ]] && continue
            
            {
                while IFS= read -r image_path; do
                    [[ -z "$image_path" ]] && continue
                    process_image "$image_path" "$batch_num"
                done < "$batch_file"
            } &
            
            batch_pids+=($!)
            ((batch_num++))
        done
        
        # Wait for all batches
        for pid in "${batch_pids[@]}"; do
            wait "$pid"
        done
    fi
    
    # Merge new results with existing index
    local index_tmp="$INDEX_FILE.tmp"
    {
        head -2 "$INDEX_FILE"  # Keep header
        grep -v '^#' "$INDEX_FILE"  # Existing entries
        cat "$TEMP_DIR"/worker_*.txt 2>/dev/null  # New entries
    } | {
        head -2  # Header
        tail -n +3 | sort -u  # Deduplicate and sort
    } > "$index_tmp"
    
    mv "$index_tmp" "$INDEX_FILE"
    echo "✅ Incremental index complete! $new_files new entries added."
    
    rm -rf "$TEMP_DIR"
}

# Main execution
case "${1:-smart}" in
    "--rebuild"|"--force")
        index_screenshots_parallel "force"
        ;;
    "--smart"|"")
        index_screenshots_smart
        ;;
    *)
        echo "Usage: $0 [--rebuild|--smart]"
        echo "  --rebuild  Force full rebuild (slower)"
        echo "  --smart    Incremental update (default, faster)"
        exit 1
        ;;
esac