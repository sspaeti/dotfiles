#!/bin/bash
# Minimal weather for waybar — uses wttr.in, monochrome Nerd Font icons

data=$(curl -sf "wttr.in/Biel~Switzerland?format=%C|%t" 2>/dev/null)

if [ -z "$data" ]; then
  echo '{"text": "", "tooltip": "Weather unavailable"}'
  exit 0
fi

condition="${data%%|*}"
temp="${data##*|}"
temp=$(echo "$temp" | sed 's/^ *//;s/ *$//')

# Map condition text to monochrome Nerd Font icons (using unicode escapes)
case "$condition" in
  *"Sunny"*|*"Clear"*)               icon=$(echo -e "\uf185") ;;
  *"Partly cloudy"*|*"Partly Cloudy"*) icon=$(echo -e "\uf0c2") ;;
  *"Cloudy"*|*"Overcast"*)           icon=$(echo -e "\uf0c2") ;;
  *"Mist"*|*"Fog"*)                  icon=$(echo -e "\uf73c") ;;
  *"Rain"*|*"Drizzle"*|*"shower"*)   icon=$(echo -e "\uf740") ;;
  *"Thunderstorm"*|*"Thunder"*)      icon=$(echo -e "\uf76c") ;;
  *"Snow"*|*"Blizzard"*|*"Sleet"*)   icon=$(echo -e "\uf2dc") ;;
  *)                                  icon=$(echo -e "\uf0c2") ;;
esac

echo "{\"text\": \"${temp}  ${icon}\", \"tooltip\": \"${condition}\"}"
