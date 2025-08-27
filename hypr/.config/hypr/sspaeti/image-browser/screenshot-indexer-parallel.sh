#!/bin/bash

# Fast Parallel Image OCR Indexer - Screenshots & Design Images

# Source the central configuration
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/image-library-config.sh"
TEMP_DIR="/tmp/screenshot_ocr_$$"
WORKERS=4  # Fixed to 4 workers to avoid resource contention

# Lock file to prevent multiple instances
LOCK_FILE="/tmp/screenshot_indexer.lock"

# Function to acquire lock
acquire_lock() {
    local mode="$1"
    local timeout=0
    
    # For recent mode, don't wait - just exit if locked
    if [[ "$mode" == "recent" ]]; then
        timeout=1
    else
        timeout=30
    fi
    
    local count=0
    while [[ $count -lt $timeout ]]; do
        if (set -C; echo $$ > "$LOCK_FILE") 2>/dev/null; then
            return 0
        fi
        
        # Check if the process holding the lock is still running
        if [[ -f "$LOCK_FILE" ]]; then
            local lock_pid=$(cat "$LOCK_FILE" 2>/dev/null)
            if [[ -n "$lock_pid" ]] && ! kill -0 "$lock_pid" 2>/dev/null; then
                # Stale lock file, remove it
                rm -f "$LOCK_FILE"
                continue
            fi
        fi
        
        if [[ "$mode" == "recent" ]]; then
            echo "Another indexer is running, skipping recent indexing"
            return 0
        fi
        
        echo "Waiting for another indexer to finish... ($count/$timeout)"
        sleep 1
        ((count++))
    done
    
    echo "Could not acquire lock after $timeout seconds"
    exit 1
}

# Function to release lock
release_lock() {
    rm -f "$LOCK_FILE"
}

# Set up cleanup trap
trap 'release_lock; rm -rf "$TEMP_DIR"' EXIT INT TERM

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
    
    echo "🚀 Building image OCR index with $WORKERS parallel workers..."
    
    # Create header
    echo "# Screenshot OCR Index - Generated $(date)" > "$index_tmp"
    echo "# Format: filepath|ocr_text|file_size|mod_time" >> "$index_tmp"
    
    # Get list of images to process from all directories
    local image_list="$TEMP_DIR/image_list.txt"
    
    echo "🔍 Finding images in all directories..."
    find_all_images > "$image_list"
    
    sort "$image_list" -o "$image_list"
    local total_files=$(wc -l < "$image_list")
    
    # Debug info
    echo "📊 Found $total_files total images"
    if [[ $total_files -eq 0 ]]; then
        echo "⚠️  No images found! Checking directories..."
        for dir in "${IMAGE_DIRS[@]}"; do
            if [[ -d "$dir" ]]; then
                local count=$(find "$dir" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | wc -l)
                echo "  $dir: $count files"
            else
                echo "  $dir: Directory not found"
            fi
        done
        echo "❌ Aborting indexing - no images to process"
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    echo "🖼️  Processing $total_files images across all directories..."
    
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

# Ultra-fast smart indexing using timestamp optimization
index_screenshots_smart() {
    local force_reindex="$1"
    
    if [[ "$force_reindex" == "force" ]] || [[ ! -f "$INDEX_FILE" ]]; then
        index_screenshots_parallel "$force_reindex"
        return
    fi
    
    echo "🔍 Ultra-fast smart incremental indexing..."
    
    # Get last index time from index file header or file modification time
    local last_index_time=0
    if [[ -f "$INDEX_FILE" ]]; then
        # Use index file modification time as baseline
        last_index_time=$(stat -c%Y "$INDEX_FILE" 2>/dev/null || echo 0)
        # Subtract 60 seconds as safety margin for files that might have been processing
        last_index_time=$((last_index_time - 60))
    fi
    
    echo "📅 Looking for files modified after $(date -d "@$last_index_time" 2>/dev/null || echo "unknown")"
    
    # Find only files newer than last index time (MUCH faster than checking all files)
    local temp_new_list="$TEMP_DIR/new_files.txt"
    > "$temp_new_list"
    
    local new_files=0
    for dir in "${IMAGE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            # Only check files newer than last index time
            while IFS= read -r -d '' image_path; do
                echo "$image_path" >> "$temp_new_list"
                ((new_files++))
            done < <(find "$dir" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -newermt "@$last_index_time" -print0 2>/dev/null)
        fi
    done
    
    if [[ $new_files -eq 0 ]]; then
        echo "✅ Index is up to date!"
        rm -rf "$TEMP_DIR"
        return
    fi
    
    echo "🖼️  Processing $new_files new/modified images..."
    
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

# Fast indexing for recent screenshots only (post-screenshot hook)
index_recent_screenshots() {
    echo "🚀 Fast indexing recent screenshots (last 2 minutes)..."
    
    # Find only very recent screenshots
    local recent_files="$TEMP_DIR/recent_files.txt"
    find "$PRINTSCREEN_DIR" -name "screenshot-*.png" -mmin -2 > "$recent_files"
    
    local file_count=$(wc -l < "$recent_files")
    
    if [[ $file_count -eq 0 ]]; then
        echo "No recent screenshots to index"
        rm -rf "$TEMP_DIR"
        return 0
    fi
    
    echo "📸 Processing $file_count recent screenshot(s)..."
    
    # Process each recent file quickly (sequential for speed with few files)
    local new_entries="$TEMP_DIR/new_entries.txt"
    > "$new_entries"
    
    while IFS= read -r image_path; do
        [[ -z "$image_path" || ! -f "$image_path" ]] && continue
        
        # Quick OCR with German+English
        local ocr_text=""
        ocr_text=$(tesseract "$image_path" stdout -l deu+eng 2>/dev/null | tr '\n' ' ' | tr -s ' ' | sed 's/^ *//;s/ *$//')
        
        # Get file metadata
        local file_size=$(stat -c%s "$image_path" 2>/dev/null || echo "0")
        local mod_time=$(stat -c%Y "$image_path" 2>/dev/null || echo "0")
        
        # Add to new entries
        echo "$image_path|$ocr_text|$file_size|$mod_time" >> "$new_entries"
        
        echo "✅ Indexed: $(basename "$image_path")"
    done < "$recent_files"
    
    # Append to existing index or create new one
    if [[ -f "$INDEX_FILE" && -s "$new_entries" ]]; then
        # Remove any existing entries for these files first, then append new ones
        local temp_index="$TEMP_DIR/temp_index.txt"
        
        # Copy header
        head -2 "$INDEX_FILE" > "$temp_index"
        
        # Add existing entries (exclude files we're updating)
        while IFS= read -r image_path; do
            grep -v -F "$image_path|" "$INDEX_FILE" 2>/dev/null || true
        done < "$recent_files" | grep -v '^#' >> "$temp_index"
        
        # Add new entries
        cat "$new_entries" >> "$temp_index"
        
        # Replace index with updated version
        mv "$temp_index" "$INDEX_FILE"
    elif [[ -s "$new_entries" ]]; then
        # Create new index
        echo "# Image OCR Index - Generated $(date)" > "$INDEX_FILE"
        echo "# Format: filepath|ocr_text|file_size|mod_time" >> "$INDEX_FILE"
        cat "$new_entries" >> "$INDEX_FILE"
    fi
    
    echo "🎉 Fast indexing complete! Recent screenshots are now searchable."
    
    # Cleanup
    rm -rf "$TEMP_DIR"
}

# Main execution
case "${1:-smart}" in
    "--rebuild"|"--force")
        acquire_lock "rebuild"
        index_screenshots_parallel "force"
        ;;
    "--smart"|"")
        acquire_lock "smart"
        index_screenshots_smart
        ;;
    "--recent")
        acquire_lock "recent"
        index_recent_screenshots
        ;;
    *)
        echo "Usage: $0 [--rebuild|--smart|--recent]"
        echo "  --rebuild  Force full rebuild (slower)"
        echo "  --smart    Incremental update (default, faster)"  
        echo "  --recent   Fast indexing of recent screenshots only (post-screenshot)"
        exit 1
        ;;
esac