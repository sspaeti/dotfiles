#!/bin/bash

# Wait for WiFi interface and desktop notifications to be ready
sleep 5

# Check WiFi power save
power_save=$(iw dev wlan0 get power_save 2>/dev/null | awk '{print $3}')
if [ "$power_save" = "on" ]; then
    notify-send -u critical "WiFi: Power Save ON" \
        "Speed will be throttled. Run: sudo ~/.config/hypr/sspaeti/wifi/fix-wifi-speed.sh"
fi

# Check if linux-firmware-intel IgnorePkg is missing from pacman.conf
if ! grep -q "IgnorePkg.*linux-firmware-intel" /etc/pacman.conf; then
    notify-send -u critical "WiFi: IgnorePkg missing" \
        "linux-firmware-intel can be upgraded by omarchy. Run: sudo ~/.config/hypr/sspaeti/wifi/fix-wifi-speed.sh"
fi

# Check if firmware version is not the known-good one
fw_version=$(pacman -Q linux-firmware-intel 2>/dev/null | awk '{print $2}')
if [ "$fw_version" != "20251021-1" ]; then
    notify-send -u critical "WiFi: Bad firmware ($fw_version)" \
        "Expected 20251021-1. Run: sudo ~/.config/hypr/sspaeti/wifi/fix-wifi-speed.sh"
fi
