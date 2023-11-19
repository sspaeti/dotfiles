#!/bin/bash

file="$HOME/.config/mutt/screened_out.txt"
pattern=""

while IFS= read -r email; do
    # Properly escape special characters in email addresses
    email=$(echo "$email" | sed 's/[][\\^$.|*?+(){}]/\\&/g')
    pattern="${pattern}!~f ${email} "
done < "$file"

# Print out the pattern
echo "$pattern"

