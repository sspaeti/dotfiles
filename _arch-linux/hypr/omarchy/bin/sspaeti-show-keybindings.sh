#!/bin/bash

# Hyprland Keybindings Help Script
# Shows all configured keybindings in Wofi

# Create formatted keybinding list
cat << 'EOF' | wofi --dmenu \
    --width 800 \
    --height 600 \
    --prompt "Hyprland Keybindings" \
    --insensitive \
    --style ~/.config/wofi/style.css

🚀 APPLICATIONS
SUPER + Enter          Terminal (alacritty)
SUPER + O              File Manager (nautilus)
SUPER + B              Browser (brave)
SUPER + M              Music (spotify)
SUPER + A              System Monitor (btop)
SUPER + D              Docker Monitor (lazydocker)
SUPER + N              Obsidian (toggle)
SUPER + C              Calendar (morgen)
SUPER + /              Password Manager (1password)
SUPER + Space          App Launcher (wofi)
SUPER + CTRL + M       Messenger (signal)
SUPER + ALT + M        Slack

🌐 WEB APPS
SUPER + SHIFT + W      Claude AI
SUPER + SHIFT + A      ChatGPT
SUPER + Y              YouTube
SUPER + SHIFT + M      WhatsApp Web
SUPER + X              Blue Social
SUPER + SHIFT + X      Bluesky Compose

🎨 UTILITIES
SUPER + G              Toggle Waybar
SUPER + SHIFT + G      Next Background
SUPER + SHIFT + CTRL + G  Next Theme
SUPER + CTRL + Space   Emoji Picker
SUPER + SHIFT + F      Fuzzy File Search
SUPER + SHIFT + ALT + F  Fuzzy Content Search

🪟 WINDOW MANAGEMENT
SUPER + W              Kill Active Window
SUPER + F              Fullscreen
SUPER + I              Toggle Split
SUPER + P              Pseudo Mode
SUPER + SHIFT + T      Toggle Floating

🔐 SYSTEM
SUPER + Escape         Lock Screen
SUPER + SHIFT + Escape Suspend System

🧭 NAVIGATION
SUPER + H/J/K/L        Move Focus (Vim Keys)
SUPER + 1-9,0          Switch Workspace
SUPER + SHIFT + 1-9,0  Move Window to Workspace
SUPER + SHIFT + H/J/K/L  Resize Window
SUPER + SHIFT + Arrows Swap Windows
SUPER + Mouse Scroll   Navigate Workspaces

🖱️ MOUSE
SUPER + LMB            Move Window
SUPER + RMB            Resize Window

📷 SCREENSHOT
Print                  Region Screenshot
SHIFT + Print          Window Screenshot
CTRL + Print           Full Screen Screenshot
SUPER + Print          Color Picker

🎵 MEDIA KEYS
XF86AudioRaiseVolume   Volume Up
XF86AudioLowerVolume   Volume Down
XF86AudioMute          Mute Audio
XF86AudioMicMute       Mute Microphone
XF86MonBrightnessUp    Brightness Up
XF86MonBrightnessDown  Brightness Down
XF86AudioPlay/Pause    Play/Pause
XF86AudioNext          Next Track
XF86AudioPrev          Previous Track

🖥️ DISPLAY
CTRL + F1              Apple Display Brightness Down
CTRL + F2              Apple Display Brightness Up
SHIFT + CTRL + F2      Apple Display Max Brightness

📋 CLIPBOARD
SUPER + SHIFT + C      Clipboard Manager (clipse)

Press ESC to close this help window
EOF




# trying dynamically - not working yet
### # Hyprland Keybindings Help Script
### # Dynamically reads bindings from configuration files
### 
### BINDINGS_FILE="$HOME/.local/share/omarchy/default/hypr/bindings.conf"
### HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
### 
### # Function to format key combinations
### format_key() {
###     local key="$1"
###     key=$(echo "$key" | sed 's/SUPER/⊞/g')
###     key=$(echo "$key" | sed 's/CTRL/⌃/g')
###     key=$(echo "$key" | sed 's/SHIFT/⇧/g')
###     key=$(echo "$key" | sed 's/ALT/⌥/g')
###     key=$(echo "$key" | sed 's/,/ + /g')
###     echo "$key"
### }
### 
### # Function to get description for common applications
### get_app_description() {
###     local cmd="$1"
###     case "$cmd" in
###         *terminal*|*alacritty*|*ghostty*) echo "Terminal" ;;
###         *nautilus*) echo "File Manager" ;;
###         *brave*) echo "Browser" ;;
###         *spotify*) echo "Music Player" ;;
###         *btop*) echo "System Monitor" ;;
###         *lazydocker*) echo "Docker Monitor" ;;
###         *obsidian*) echo "Obsidian Notes" ;;
###         *morgen*) echo "Calendar" ;;
###         *1password*) echo "Password Manager" ;;
###         *wofi*) echo "App Launcher" ;;
###         *signal*) echo "Signal Messenger" ;;
###         *slack*) echo "Slack" ;;
###         *hyprlock*) echo "Lock Screen" ;;
###         *suspend*) echo "Suspend System" ;;
###         *hyprshot*) echo "Screenshot" ;;
###         *hyprpicker*) echo "Color Picker" ;;
###         *clipse*) echo "Clipboard Manager" ;;
###         *emoji*) echo "Emoji Picker" ;;
###         *fuzzy-file-content*) echo "Fuzzy Content Search" ;;
###         *fuzzy-file-names*) echo "Fuzzy File Search" ;;
###         *waybar*) echo "Toggle Waybar" ;;
###         *swaybg*) echo "Next Background" ;;
###         *theme*) echo "Next Theme" ;;
###         *claude.ai*) echo "Claude AI" ;;
###         *chatgpt*) echo "ChatGPT" ;;
###         *youtube*) echo "YouTube" ;;
###         *whatsapp*) echo "WhatsApp Web" ;;
###         *blue.ssp.sh*) echo "Blue Social" ;;
###         *bsky.app*) echo "Bluesky" ;;
###         killactive) echo "Kill Active Window" ;;
###         fullscreen) echo "Fullscreen" ;;
###         togglesplit) echo "Toggle Split" ;;
###         pseudo) echo "Pseudo Mode" ;;
###         togglefloating) echo "Toggle Floating" ;;
###         movefocus*) echo "Move Focus" ;;
###         workspace*) echo "Switch Workspace" ;;
###         movetoworkspace*) echo "Move to Workspace" ;;
###         swapwindow*) echo "Swap Window" ;;
###         resizeactive*) echo "Resize Window" ;;
###         *) echo "$cmd" ;;
###     esac
### }
### 
### # Parse bindings and create formatted output
### {
###     echo "🎯 HYPRLAND KEYBINDINGS"
###     echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
###     echo ""
###     
###     # Read main config for variable definitions
###     if [[ -f "$HYPR_CONFIG" ]]; then
###         eval $(grep '^\$' "$HYPR_CONFIG" | sed 's/^\$//')
###     fi
###     
###     # Parse bindings file
###     while IFS= read -r line; do
###         # Skip comments and empty lines
###         [[ "$line" =~ ^[[:space:]]*# ]] && continue
###         [[ -z "${line// }" ]] && continue
###         
###         # Parse bind lines
###         if [[ "$line" =~ ^bind[elm]*[[:space:]]*=[[:space:]]*([^,]+),[[:space:]]*([^,]+),[[:space:]]*(.+)$ ]]; then
###             local modifiers="${BASH_REMATCH[1]// /}"
###             local key="${BASH_REMATCH[2]// /}"
###             local action="${BASH_REMATCH[3]}"
###             
###             # Format the key combination
###             local formatted_key=$(format_key "$modifiers, $key")
###             
###             # Get description
###             local description=$(get_app_description "$action")
###             
###             # Format output line
###             printf "%-25s %s\n" "$formatted_key" "$description"
###         fi
###     done < "$BINDINGS_FILE" | sort
###     
###     echo ""
###     echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
###     echo "Press ESC to close • Source: $BINDINGS_FILE"
###     
### } | wofi --dmenu \
###     --width 900 \
###     --height 700 \
###     --prompt "Hyprland Keybindings" \
###     --insensitive \
###     --style ~/.config/wofi/style.css
