#!/bin/bash

# cut_video_segment - Remove time segments from video files
# Usage: cut_video_segment <input> <start> <end> <output>
# Times: HH:MM:SS, MM:SS, or seconds
# Example: ffmpeg_cut_video_segment video.mp4 7:22 7:33 clean.mp4
ffmpeg_cut_video_segment() {
    if [[ $# -ne 4 ]]; then
        echo "Usage: cut_video_segment <input_file> <start_time> <end_time> <output_file>"
        echo "Time format: HH:MM:SS or seconds"
        echo "Example: cut_video_segment video.mp4 7:22 7:33 output.mp4"
        return 1
    fi
    
    local input_file="$1"
    local start_time="$2"
    local end_time="$3"
    local output_file="$4"
    
    # Check if input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' not found"
        return 1
    fi
    
    # Convert time to seconds if needed
    local start_seconds=$(ffmpeg -f lavfi -i "nullsrc" -t 1 -f null - 2>&1 | grep -o "time=[0-9:]*" | head -1 | cut -d= -f2)
    start_seconds=$(echo "$start_time" | awk -F: '{if(NF==1) print $1; else if(NF==2) print $1*60+$2; else print $1*3600+$2*60+$3}')
    local end_seconds=$(echo "$end_time" | awk -F: '{if(NF==1) print $1; else if(NF==2) print $1*60+$2; else print $1*3600+$2*60+$3}')
    
    echo "Cutting segment from $start_time to $end_time..."
    echo "Working with temporary files..."
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    local part1="$temp_dir/part1.mp4"
    local part2="$temp_dir/part2.mp4"
    local filelist="$temp_dir/filelist.txt"
    
    # Step 1: Extract everything before the cut
    echo "Step 1: Extracting part before $start_time..."
    ffmpeg -i "$input_file" -t "$start_seconds" -c copy "$part1" -loglevel error
    
    # Step 2: Extract everything after the cut
    echo "Step 2: Extracting part after $end_time..."
    ffmpeg -i "$input_file" -ss "$end_seconds" -c copy "$part2" -loglevel error
    
    # Step 3: Create file list for concatenation
    echo "file '$part1'" > "$filelist"
    echo "file '$part2'" >> "$filelist"
    
    # Step 4: Concatenate the parts
    echo "Step 3: Joining parts together..."
    ffmpeg -f concat -safe 0 -i "$filelist" -c copy "$output_file" -loglevel error
    
    # Clean up
    rm -rf "$temp_dir"
    
    echo "✅ Done! Output saved as: $output_file"
}

# ffmpeg_extract_video_segment - Extract ONLY the segment between two timestamps
# Usage: ffmpeg_extract_video_segment <input> <start> <end> <output>
# Times: HH:MM:SS, MM:SS, or seconds
# Example: ffmpeg_extract_video_segment video.mp4 7:22 7:33 highlight.mp4
ffmpeg_extract_video_segment() {
    if [[ $# -ne 4 ]]; then
        echo "Usage: ffmpeg_extract_video_segment <input_file> <start_time> <end_time> <output_file>"
        echo "Time format: HH:MM:SS or seconds"
        echo "Example: ffmpeg_extract_video_segment video.mp4 7:22 7:33 highlight.mp4"
        return 1
    fi
    
    local input_file="$1"
    local start_time="$2"
    local end_time="$3"
    local output_file="$4"
    
    # Check if input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' not found"
        return 1
    fi
    
    # Convert time to seconds if needed
    local start_seconds=$(echo "$start_time" | awk -F: '{if(NF==1) print $1; else if(NF==2) print $1*60+$2; else print $1*3600+$2*60+$3}')
    local end_seconds=$(echo "$end_time" | awk -F: '{if(NF==1) print $1; else if(NF==2) print $1*60+$2; else print $1*3600+$2*60+$3}')
    
    # Calculate duration
    local duration=$((end_seconds - start_seconds))
    
    if [[ $duration -le 0 ]]; then
        echo "Error: End time must be after start time"
        return 1
    fi
    
    echo "Extracting segment from $start_time to $end_time (duration: ${duration}s)..."
    
    # Extract the segment directly
    ffmpeg -i "$input_file" -ss "$start_seconds" -t "$duration" -c copy "$output_file" -loglevel error
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Done! Extracted segment saved as: $output_file"
    else
        echo "❌ Error: Failed to extract segment"
        return 1
    fi
}
