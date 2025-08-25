#!/bin/bash

# Get current default sink
current_sink=$(pactl info | grep "Default Sink:" | awk '{print $3}')

# Get all available sinks from pactl (include suspended ones - they can be activated)
available_sinks=$(pactl list sinks short | awk '{print $1 ":" $2}')

# Convert to arrays
sink_ids=()
sink_names=()
while IFS=':' read -r id name; do
    sink_ids+=("$id")
    sink_names+=("$name")
done <<< "$available_sinks"

# If only one sink available, notify and exit
if [ ${#sink_ids[@]} -lt 2 ]; then
    notify-send "Audio Output" "Only one audio device available" -i audio-card
    exit 0
fi

# Find current sink index
current_index=0
for i in "${!sink_names[@]}"; do
    if [[ "${sink_names[$i]}" = "${current_sink}" ]]; then
        current_index=$i
        break
    fi
done

# Get next sink (cycle to next available)
next_index=$(( (current_index + 1) % ${#sink_ids[@]} ))
next_sink_id=${sink_ids[$next_index]}
next_sink_name=${sink_names[$next_index]}

# Switch to next sink 
echo "Switching from $current_sink to $next_sink_name (ID: $next_sink_id)" >&2

# Set default sink for new streams  
if pactl set-default-sink "$next_sink_name"; then
    echo "Set default sink to $next_sink_name" >&2
    
    # Move all active sink inputs (streams) to the new sink
    pactl list short sink-inputs | while read -r input_id _; do
        if [ -n "$input_id" ]; then
            echo "Moving stream $input_id to sink $next_sink_name" >&2
            pactl move-sink-input "$input_id" "$next_sink_name" 2>/dev/null || echo "Failed to move stream $input_id" >&2
        fi
    done
else
    echo "Failed to set default sink to $next_sink_name" >&2
    exit 1
fi

# Get a clean name for notification
clean_name=$(echo "$next_sink_name" | sed -E 's/.*\.([^.]+)$/\1/' | sed 's/-/ /g' | sed 's/\b\w/\U&/g')

notify-send "Audio Output" "Switched to: $clean_name" -i audio-card
