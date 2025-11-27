#!/bin/bash
# Decrypt newsboat urls and launch newsboat

NEWSBOAT_DIR="$HOME/.config/newsboat"
URLS_ENCRYPTED="$NEWSBOAT_DIR/urls.gpg"
URLS_DECRYPTED="$NEWSBOAT_DIR/urls"

# Decrypt the urls file
if [ -f "$URLS_ENCRYPTED" ]; then
    gpg --quiet --decrypt "$URLS_ENCRYPTED" > "$URLS_DECRYPTED" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Failed to decrypt $URLS_ENCRYPTED"
        exit 1
    fi
else
    echo "Error: Encrypted urls file not found at $URLS_ENCRYPTED"
    exit 1
fi

# Launch newsboat with any provided arguments
exec newsboat "$@"
