#!/bin/bash
# Install nautilus context menu items:
#   - Scripts (under Scripts submenu): ExifTool Info
#   - Python extensions (root context menu): Open in Terminal, Copy File Name, Copy File Path

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install nautilus scripts (appear under Scripts submenu)
SCRIPTS_DIR="$HOME/.local/share/nautilus/scripts"
SCRIPTS_SOURCE="$DOTFILES_DIR/.local/share/nautilus/scripts"
mkdir -p "$SCRIPTS_DIR"

for script in "$SCRIPTS_SOURCE"/*; do
    name="$(basename "$script")"
    ln -sf "$script" "$SCRIPTS_DIR/$name"
done

# Install nautilus-python extensions (appear at root context menu level)
EXT_DIR="$HOME/.local/share/nautilus-python/extensions"
EXT_SOURCE="$DOTFILES_DIR/.local/share/nautilus-python/extensions"
mkdir -p "$EXT_DIR"

for ext in "$EXT_SOURCE"/*.py; do
    name="$(basename "$ext")"
    ln -sf "$ext" "$EXT_DIR/$name"
done

# Disable Ghostty's built-in extension (replaced by Open in Terminal)
GHOSTTY_EXT="/usr/share/nautilus-python/extensions/ghostty.py"
if [ -f "$GHOSTTY_EXT" ] && [ ! -f "${GHOSTTY_EXT}.disabled" ]; then
    echo "Disabling Ghostty nautilus extension (replaced by Open in Terminal)..."
    sudo mv "$GHOSTTY_EXT" "${GHOSTTY_EXT}.disabled"
fi

echo "Installed nautilus scripts and extensions."
echo "Restart nautilus (nautilus -q) for changes to take effect."
