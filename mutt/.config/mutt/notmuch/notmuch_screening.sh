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

# Efficiently process to-screen emails against current lists
printf "Processing to-screen emails against screening lists...\n"

# Process screened_in list against to-screen emails (most efficient: bulk operations)
while IFS= read -r email; do
    [ -z "$email" ] && continue
    count=$(notmuch count from:"$email" tag:to-screen)
    if [ "$count" -gt 0 ]; then
        printf "  Screening in %d emails from %s\n" "$count" "$email"
        notmuch tag +screened-in +inbox -to-screen -- from:"$email" tag:to-screen
    fi
done < "$screened_in"

# Process screened_out list against to-screen emails
while IFS= read -r email; do
    [ -z "$email" ] && continue
    count=$(notmuch count from:"$email" tag:to-screen)
    if [ "$count" -gt 0 ]; then
        printf "  Screening out %d emails from %s\n" "$count" "$email"
        notmuch tag +screened-out +spam -to-screen -inbox -- from:"$email" tag:to-screen
    fi
done < "$screened_out"

# Process feed list against to-screen emails
while IFS= read -r email; do
    [ -z "$email" ] && continue
    count=$(notmuch count from:"$email" tag:to-screen)
    if [ "$count" -gt 0 ]; then
        printf "  Tagging %d emails from %s as feed\n" "$count" "$email"
        notmuch tag +feed -to-screen -inbox -- from:"$email" tag:to-screen
    fi
done < "$feed_list"

# Process papertrail list against to-screen emails
while IFS= read -r email; do
    [ -z "$email" ] && continue
    count=$(notmuch count from:"$email" tag:to-screen)
    if [ "$count" -gt 0 ]; then
        printf "  Tagging %d emails from %s as papertrail\n" "$count" "$email"
        notmuch tag +papertrail -to-screen -inbox -- from:"$email" tag:to-screen
    fi
done < "$papertrail_list"

printf "Notmuch screening completed at $(date '+%Y-%m-%d %H:%M:%S')\n"
printf -- "####################################\n"
