#!/bin/bash
# Omarchy weather icon + current temperature for waybar.

icon=$(omarchy-weather-icon 2>/dev/null)
temp=$(curl -fsS --max-time 3 "https://wttr.in?format=%t" 2>/dev/null | tr -d '\n')
temp=${temp#+}

if [[ -n $icon && -n $temp ]]; then
  icon_esc=$(printf '%s' "$icon" | sed 's/["\\]/\\&/g')
  printf '{"text":"%s  %s"}\n' "$icon_esc" "$temp"
elif [[ -n $icon ]]; then
  icon_esc=$(printf '%s' "$icon" | sed 's/["\\]/\\&/g')
  printf '{"text":"%s"}\n' "$icon_esc"
else
  printf '{"text":"","class":"unavailable"}\n'
fi
