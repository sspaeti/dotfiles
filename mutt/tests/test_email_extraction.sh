
#!/bin/bash

# Path to the email.txt file
email_file="emails.txt"

# Regular expression for extracting email addresses
email_regex='[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}'

# Function to extract email address from a line
extract_email() {
    local line=$1
    if [[ $line =~ $email_regex ]]; then
        echo "${BASH_REMATCH[0]}"
    fi
}

# Read each line from the email file and extract email addresses
while IFS= read -r line; do
    extracted_email=$(extract_email "$line")
    if [ ! -z "$extracted_email" ]; then
        echo "Extracted Email: $extracted_email"
    fi
done < "$email_file"
