#!/bin/bash

# Paths to screened lists
screened_in="$HOME/.config/mutt/screened_in.txt"
screened_out="$HOME/.config/mutt/screened_out.txt"

# Function to check if an email sender is in a file
in_file() {
    local sender=$1
    local file=$2
    grep -Fxq "$sender" "$file"
}

# Path to your mail directory
mail_dir="~/Documents/mutt/sspaeti.com"

# Process each new email
for email in $(find $mail_dir/new -type f); do
    # Extract sender's email address
    sender=$(grep "^From:" $email | head -1 | sed 's/.*<\(.*\)>/\1/')
    
    # Check if sender is in screened lists
    if ! in_file "$sender" "$screened_in" && ! in_file "$sender" "$screened_out"; then
        # Move to ToScreen folder (adjust command based on your mail setup)
        mv "$email" "~/Documents/mutt/ToScreen/"
    fi
done

