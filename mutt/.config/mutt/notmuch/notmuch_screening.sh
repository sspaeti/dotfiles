#!/bin/bash

# Notmuch-based email screening script
# Uses tags instead of moving emails between folders

# Paths to screened lists
screened_in="$HOME/.dotfiles/mutt/.lists/screened_in.txt"
screened_out="$HOME/.dotfiles/mutt/.lists/screened_out.txt"
feed_list="$HOME/.dotfiles/mutt/.lists/feed.txt"
papertrail_list="$HOME/.dotfiles/mutt/.lists/papertrail.txt"

# Create files if they don't exist
touch "$screened_in" "$screened_out" "$feed_list" "$papertrail_list"

# Trim trailing spaces
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' 's/[[:space:]]*$//' "$screened_in"
    sed -i '' 's/[[:space:]]*$//' "$screened_out"
    sed -i '' 's/[[:space:]]*$//' "$feed_list"
    sed -i '' 's/[[:space:]]*$//' "$papertrail_list"
else
    # Linux
    sed -i 's/[[:space:]]*$//' "$screened_in"
    sed -i 's/[[:space:]]*$//' "$screened_out"
    sed -i 's/[[:space:]]*$//' "$feed_list"
    sed -i 's/[[:space:]]*$//' "$papertrail_list"
fi

# Set NOTMUCH_CONFIG to our custom location
export NOTMUCH_CONFIG="$HOME/.config/mutt/notmuch/notmuch-config"

printf "Starting notmuch screening at $(date '+%Y-%m-%d %H:%M:%S')...\n"

# First, run notmuch new to index any new emails
notmuch new

# Tag emails based on screened lists
# Process screened_out emails
while IFS= read -r email; do
    [ -z "$email" ] && continue
    printf "Tagging emails from %s as screened-out...\n" "$email"
    notmuch tag +screened-out +spam -inbox -new -- from:"$email" tag:new
done < "$screened_out"

# Process feed emails
while IFS= read -r email; do
    [ -z "$email" ] && continue
    printf "Tagging emails from %s as feed...\n" "$email"
    notmuch tag +feed -inbox -new -- from:"$email" tag:new
done < "$feed_list"

# Process papertrail emails
while IFS= read -r email; do
    [ -z "$email" ] && continue
    printf "Tagging emails from %s as papertrail...\n" "$email"
    notmuch tag +papertrail -inbox -new -- from:"$email" tag:new
done < "$papertrail_list"

# Process screened_in emails (approved senders)
while IFS= read -r email; do
    [ -z "$email" ] && continue
    printf "Tagging emails from %s as screened-in...\n" "$email"
    notmuch tag +screened-in -to-screen -new -- from:"$email" tag:new
done < "$screened_in"

# Tag remaining new emails that don't match any list as needing screening
printf "Tagging remaining new emails as to-screen...\n"
notmuch tag +to-screen -new -- tag:new and not tag:screened-in and not tag:screened-out and not tag:feed and not tag:papertrail

# Move previously screened emails if sender status changed
printf "Updating tags for emails in to-screen based on current lists...\n"

# Check to-screen emails and retag if sender is now in a list
for msg_id in $(notmuch search --output=messages tag:to-screen); do
    sender=$(notmuch show --format=json "$msg_id" | grep -o '"From":.*"' | head -1 | grep -Eo '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')

    if grep -Fxq "$sender" "$screened_in"; then
        notmuch tag +screened-in +inbox -to-screen -- id:"$msg_id"
        printf "Moved %s back to inbox (screened-in)\n" "$msg_id"
    elif grep -Fxq "$sender" "$screened_out"; then
        notmuch tag +screened-out +spam -to-screen -inbox -- id:"$msg_id"
        printf "Tagged %s as screened-out\n" "$msg_id"
    elif grep -Fxq "$sender" "$feed_list"; then
        notmuch tag +feed -to-screen -inbox -- id:"$msg_id"
        printf "Tagged %s as feed\n" "$msg_id"
    elif grep -Fxq "$sender" "$papertrail_list"; then
        notmuch tag +papertrail -to-screen -inbox -- id:"$msg_id"
        printf "Tagged %s as papertrail\n" "$msg_id"
    fi
done

printf "Notmuch screening completed at $(date '+%Y-%m-%d %H:%M:%S')\n"
printf -- "####################################\n"
