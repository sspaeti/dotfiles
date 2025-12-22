#!/bin/bash
# Fix Ente Auth keyring integration - prevents duplicate keyring creation
# Ensures libsecret can properly "unlock" the unencrypted default keyring
# Preserves all existing passwords
#
# Author: Adapted for Omarchy/Hyprland setup
# Location: ~/.config/hypr/sspaeti/fix-ente-keyring.sh

set -e

KEYRING_DIR="$HOME/.local/share/keyrings"
KEYRING_FILE="$KEYRING_DIR/Default_keyring.keyring"
BACKUP_DIR="/tmp/keyring_backups_$(date +%Y%m%d_%H%M%S)"

echo "=== Ente Auth Keyring Fix (Preserving Passwords) ==="
echo ""

# Step 1: Check if keyring exists
if [ ! -f "$KEYRING_FILE" ]; then
    echo "❌ Default keyring not found at: $KEYRING_FILE"
    echo "   Please run the Omarchy default-keyring.sh script first"
    exit 1
fi

echo "✓ Found existing keyring: $KEYRING_FILE"

# Step 2: Create backup directory and backup current keyring
mkdir -p "$BACKUP_DIR"
cp "$KEYRING_FILE" "$BACKUP_DIR/Default_keyring.keyring"
echo "✓ Backed up to: $BACKUP_DIR/"

# Step 3: Update the keyring file to have proper libsecret metadata
# This ensures libsecret can "unlock" it properly
echo ""
echo "Updating keyring metadata for libsecret compatibility..."

# Check if it has the required FlutterSecureStorage control entry
if ! grep -q "FlutterSecureStorage Control" "$KEYRING_FILE"; then
    echo "  Adding FlutterSecureStorage control entry..."

    # Append the control entry to the keyring
    cat >> "$KEYRING_FILE" << EOF

[2]
item-type=0
display-name=FlutterSecureStorage Control
secret=The meaning of life
mtime=$(date +%s)
ctime=$(date +%s)

[2:attribute0]
name=explanation
type=string
value=Because of quirks in the gnome libsecret API, flutter_secret_storage needs to store a dummy entry to guarantee that this keyring was properly unlocked. More details at http://crbug.com/660005.
EOF
    echo "  ✓ FlutterSecureStorage control entry added"
else
    echo "  ✓ FlutterSecureStorage control entry already exists"
fi

# Step 4: Ensure proper permissions
chmod 600 "$KEYRING_FILE"
chmod 644 "$KEYRING_DIR/default"
chmod 700 "$KEYRING_DIR"
echo "✓ Permissions verified"

# Step 5: Restart gnome-keyring-daemon to reload the keyring
echo ""
echo "Restarting keyring daemon..."
systemctl --user restart gnome-keyring-daemon.service 2>/dev/null || \
    systemctl --user restart gnome-keyring-daemon.socket 2>/dev/null || \
    pkill -HUP gnome-keyring-daemon 2>/dev/null || true
sleep 2
echo "✓ Daemon restarted"

# Step 6: Verify the keyring is recognized
echo ""
echo "Verifying keyring status..."
if dbus-send --session --print-reply --dest=org.freedesktop.secrets \
    /org/freedesktop/secrets org.freedesktop.DBus.Properties.Get \
    string:org.freedesktop.Secret.Service string:Collections 2>&1 | grep -q "Default_5fkeyring"; then
    echo "✓ Keyring is recognized by secret service"
else
    echo "⚠ Warning: Keyring may not be fully initialized"
    echo "  Try logging out and back in"
fi

# Step 7: Clean up any duplicate keyrings if they exist
echo ""
echo "Checking for duplicate keyrings..."
DUPLICATES_FOUND=0
for keyring in "$KEYRING_DIR"/Default_keyring_*.keyring; do
    if [ -f "$keyring" ]; then
        echo "  Found duplicate: $(basename "$keyring")"
        # Move to backup directory instead of cluttering keyring dir
        mv "$keyring" "$BACKUP_DIR/"
        echo "  ✓ Moved to: $BACKUP_DIR/$(basename "$keyring")"
        DUPLICATES_FOUND=$((DUPLICATES_FOUND + 1))
    fi
done

if [ $DUPLICATES_FOUND -eq 0 ]; then
    echo "✓ No duplicate keyrings found"
else
    echo "✓ Cleaned up $DUPLICATES_FOUND duplicate keyring(s)"
    echo "  Backups saved in: $BACKUP_DIR/"
fi

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Your passwords have been preserved in:"
echo "  $KEYRING_FILE"
echo ""
echo "Backups saved to:"
echo "  $BACKUP_DIR/"
echo ""
echo "Test Ente Auth:"
echo "  enteauth"
echo ""
echo "If issues persist, check logs:"
echo "  tail -f ~/.local/share/io.ente.auth/logs/$(date +%Y-%m-%d).txt"
echo "  journalctl --user -u gnome-keyring-daemon -f"
echo ""
