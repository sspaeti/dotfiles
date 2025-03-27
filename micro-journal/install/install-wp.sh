#!/bin/bash

# Simple installation script for Pi Pico typewriter setup
# Usage: ./install-wp.sh

# Install all packages listed in wp-packages.txt
echo "Installing packages..."
cat wp-packages.txt | grep -v "^#" | xargs sudo apt install -y

# Create symlink for fd (Debian packages fd as fdfind)
if [ -f "/usr/bin/fdfind" ] && [ ! -f "/usr/local/bin/fd" ]; then
    sudo ln -s $(which fdfind) /usr/local/bin/fd
fi

# Configure zoxide (better cd command)
if ! grep -q "zoxide init" ~/.bashrc; then
    echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
    echo "Added zoxide to bashrc"
fi

echo "Installation complete!"
