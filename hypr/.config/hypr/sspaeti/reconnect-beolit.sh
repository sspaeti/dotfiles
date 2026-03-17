#!/bin/bash
# Reconnect Beolit 15 — removes old pairing, re-pairs, and sets A2DP sink profile

DEVICE="00:12:6F:4B:91:F1"
CARD="bluez_card.00_12_6F_4B_91_F1"

echo "=== Step 1: Installing bluez-utils ==="
sudo pacman -S --noconfirm --needed bluez-utils

echo ""
echo "=== Step 2: Restarting Bluetooth stack ==="
sudo systemctl restart bluetooth
systemctl --user restart pipewire pipewire-pulse wireplumber
sleep 3

echo ""
echo "=== Step 3: Removing old pairing ==="
bluetoothctl disconnect "$DEVICE" 2>/dev/null
sleep 1
bluetoothctl untrust "$DEVICE" 2>/dev/null
sleep 1
bluetoothctl remove "$DEVICE" 2>/dev/null
sleep 2

echo ""
echo "==========================================="
echo "  Put your Beolit 15 into PAIRING MODE"
echo "  (hold Bluetooth button until LED blinks)"
echo "==========================================="
read -p "Press Enter when the LED is blinking..."

echo ""
echo "=== Step 4: Scanning ==="
bluetoothctl --timeout 10 scan on

echo ""
echo "=== Step 5: Pairing ==="
for i in 1 2 3; do
    echo "Pair attempt $i..."
    bluetoothctl pair "$DEVICE" && break
    sleep 3
done

echo ""
echo "=== Step 6: Trusting ==="
bluetoothctl trust "$DEVICE"

echo ""
echo "=== Step 7: Connecting ==="
for i in 1 2 3; do
    echo "Connect attempt $i..."
    bluetoothctl connect "$DEVICE" && break
    sleep 3
done

echo ""
echo "=== Step 8: Waiting for PipeWire to pick up the device ==="
sleep 5

echo ""
echo "=== Step 9: Setting A2DP sink profile ==="
for i in 1 2 3; do
    echo "Profile attempt $i..."
    pactl set-card-profile "$CARD" a2dp-sink 2>/dev/null && break
    pactl set-card-profile "$CARD" a2dp-sink-sbc 2>/dev/null && break
    sleep 3
done

echo ""
echo "=== Step 10: Setting as default audio output ==="
SINK=$(pactl list sinks short 2>/dev/null | grep bluez | awk '{print $2}')
if [ -n "$SINK" ]; then
    pactl set-default-sink "$SINK"
    echo "Audio output set to: $SINK"
else
    echo "WARNING: No Bluetooth sink found. Listing available profiles:"
    pactl list cards 2>/dev/null | grep -A 20 "bluez_card" | grep -E "Profile|profile|Active"
fi

echo ""
echo "=== Done ==="
