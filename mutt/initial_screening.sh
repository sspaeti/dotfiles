#!/bin/bash

# Paths to screened lists
screened_in="$HOME/.config/mutt/screened_in.txt"
screened_out="$HOME/.config/mutt/screened_out.txt"


## trim trailing spaces
sed -i '' 's/[[:space:]]*$//' "$screened_in"
sed -i '' 's/[[:space:]]*$//' "$screened_out"


# Function to check if an email sender is in a file
in_file() {
    local sender=$1
    local file=$2
    grep -Fxq "$sender" "$file" #debugging: && echo "Found $sender in $file" || echo "Not found in $file"
}
# in_file() {
#     local sender
#     sender=$(echo $1 | xargs)
#     local file=$2
#     grep -Fxq "$sender" "$file"
# }


# Correct the path to your mail directory (remove the trailing /)
mail_dir="$HOME/Documents/mutt/sspaeti.com"


printf "Sender: %s\n" "$sender"
printf "Screened-in Entry: %s\n" "$(head -n 1 "$HOME/.config/mutt/screened_in.txt"
)"


printf "Starting initial screening...\n"

# Process each new email in the 'new' directory
for email in $(find "$mail_dir" -maxdepth 3 -type f -path "*/new/*"); do
    # print a spacer ------------------- with a new line at the end
    printf -- "----------------------------------------\n"
    # printf "Processing %s\n" "$email"
    # Extract sender's email address
    sender=$(grep "^From:" "$email" | head -1 | sed 's/.*<\(.*\)>/\1/')
    printf "Sender: %s\n" "$sender"

    # Debugging print
    # printf "Screened-in Entry: %s\n" "$(head -n 1 "$screened_in")"

    # Check if sender is in screened lists
    if ! in_file "$sender" "$screened_in" && ! in_file "$sender" "$screened_out"; then
        # Move to ToScreen/new folder
        # mv "$email" "$mail_dir/ToScreen/new/"
        printf "!!!!!!!Moved to ToScreen/new --> %s\n" "$email"
    else
      printf "Not moved %s" "$email"
    fi
done
