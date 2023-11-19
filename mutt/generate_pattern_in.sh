#!/bin/bash

file="$HOME/.config/mutt/screened_in.txt"

pattern=""
while IFS= read -r email; do
    ## Properly escape special characters in email addresses
    # email=$(echo "$email" | sed 's/[][\\^$.|*?+(){}]/\\&/g')

    # Escape any periods in email addresses
    email="${email//./\\.}"
    pattern="${pattern}!~f ${email} "
done < "$file"

# Print out the pattern
echo "$pattern"
