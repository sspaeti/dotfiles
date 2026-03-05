#!/bin/bash
# Fix Intel AX210 WiFi speed issues
# Run as root: sudo ~/.config/hypr/sspaeti/fix-wifi-speed.sh

set -e

echo "=== Fixing WiFi speed ==="

# 1. Disable power save
echo "[1/3] Disabling WiFi power save..."
iw dev wlan0 set power_save off
echo "  Done: $(iw dev wlan0 get power_save)"

# 2. Restore IgnorePkg in pacman.conf
if ! grep -q "IgnorePkg.*linux-firmware-intel" /etc/pacman.conf; then
    echo "[2/3] Adding IgnorePkg to pacman.conf..."
    sed -i '/^\[options\]/a IgnorePkg = linux-firmware-intel' /etc/pacman.conf
    echo "  Done"
else
    echo "[2/3] IgnorePkg already present, skipping"
fi

# 3. Downgrade firmware if needed
fw_version=$(pacman -Q linux-firmware-intel 2>/dev/null | awk '{print $2}')
if [ "$fw_version" != "20251021-1" ]; then
    cache="/var/cache/pacman/pkg/linux-firmware-intel-20251021-1-any.pkg.tar.zst"
    if [ -f "$cache" ]; then
        read -p "[3/3] Downgrade firmware from $fw_version to 20251021-1? [y/N] " confirm
        if [[ "$confirm" == [yY] ]]; then
            pacman -U --noconfirm "$cache"
            echo "  Done. Reloading WiFi driver..."
            modprobe -r iwlmvm && modprobe -r iwlwifi && modprobe iwlwifi && modprobe iwlmvm
            echo "  Reconnect to WiFi now"
        else
            echo "  Skipped"
        fi
    else
        echo "[3/3] ERROR: Cache file not found: $cache"
        echo "  Download manually or find another cached version"
    fi
else
    echo "[3/3] Firmware already at 20251021-1, skipping"
fi

echo ""
echo "=== Done. Check speed with: iw dev wlan0 station dump | grep bitrate ==="
