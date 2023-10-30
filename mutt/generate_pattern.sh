#!/bin/bash

file="$HOME/.config/mutt/screen_out.txt"

pattern=""
while IFS= read -r email; do
    # Escape any periods in email addresses
    email="${email//./\\.}"
    pattern="${pattern}!~f ${email} "
done < "$file"

# Print out the pattern
echo "$pattern"
