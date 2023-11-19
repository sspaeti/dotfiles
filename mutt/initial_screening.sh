#!/bin/bash
#
# TODO
# `mail_dir` needs to be updated to local file path. As I'm using IMAP as mail_dir, I'd need to use local mail location and sync to IMAP with sync or similar.
# see more info on obsidian://open?vault=SecondBrain&file=%E2%9A%9B%EF%B8%8F%20Areas%2F%F0%9F%93%AC%20Inbox%2FScreener%20in%20(Neo)Mutt


#checks if the sender of a new email is in screened_in.txt or screen_out.txt. If not, the email is moved to =ToScreen.
#This script will check each new email in the Inbox and move it to =ToScreen if the sender is not listed in screened_in.txt or screened_out.txt. 
#Note that the specific implementation can vary depending on your mail server setup and how you access your emails (IMAP, local mailbox, etc.).
#
#

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
mail_dir="~/Documents/mutt/Mail/Inbox"

# Process each new email
for email in $(find $mail_dir/new -type f); do
    # Extract sender's email address
    sender=$(grep "^From:" $email | head -1 | sed 's/.*<\(.*\)>/\1/')
    
    # Check if sender is in screened lists
    if ! in_file "$sender" "$screened_in" && ! in_file "$sender" "$screened_out"; then
        # Move to ToScreen folder (adjust command based on your mail setup)
        mv "$email" "~/Mail/ToScreen/"
    fi
done

