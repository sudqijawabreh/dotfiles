#!/bin/bash

# Define the JIRA ticket pattern and base URL for JIRA
jira_regex='[A-Z]{2,10}-[0-9]{1,5}'
jira_base_url="https://restaurant365.atlassian.net/browse/"

# Get the clipboard content and trim whitespace
clipboard_content=$(xclip -selection primary -o | xargs)

# Function to display a message with dmenu
show_dmenu_message() {
    echo "$1" | dmenu -p "JIRA Script:"
}

tickets=()
content=$clipboard_content
# Find all JIRA ticket matches without duplicating entries
while [[ $content =~ $jira_regex ]]; do
    match="${BASH_REMATCH[0]}"
    # Only add non-empty matches to tickets array if not already present
    if [[ -n $match && ! " ${tickets[*]} " =~ " ${match} " ]]; then
        tickets+=("$match")
    fi
    # Remove the first occurrence of the matched ticket
    content="${content#*$match}"
done

# Check if the entire clipboard content matches the JIRA pattern
if [[ $clipboard_content =~ ^$jira_regex$ ]]; then
    # Full match: Open the URL with the entire content as the ticket
    /home/sudqi/dotfiles/scripts/xdg-open-dwm.sh "${jira_base_url}${clipboard_content}"
    #kshow_dmenu_message "Opening JIRA for ticket: ${clipboard_content}"

elif [[ $clipboard_content =~ $jira_regex ]]; then
    # Partial match: Extract the first matched JIRA ticket
    ticket="${BASH_REMATCH[0]}"
    ticket_to_open="${jira_base_url}${ticket}"
    if [[ $ticket_to_open = $clipboard_content ]]; then
        /home/sudqi/dotfiles/scripts/xdg-open-dwm.sh "${clipboard_content}"
    else
        # Check if any tickets were found
        if [[ ${#tickets[@]} -gt 0 ]]; then
            # Present matches in dmenu for selection
            selected_ticket=$(printf "\n%s\n" "${tickets[@]}" "${clipboard_content}" | awk NF | dmenu -p "Select a ticket to open:")
            
            # Open the selected ticket if not empty
            if [[ -n $selected_ticket ]]; then
                /home/sudqi/dotfiles/scripts/xdg-open-dwm.sh "${jira_base_url}${selected_ticket}"
            fi
        else
            # No match found: Show a message in dmenu
            show_dmenu_message "No JIRA ticket found in the clipboard."
        fi
        # selection=$(echo -e "${ticket_to_open}\n${clipboard_content}" | dmenu -p "Select:" )
        # /home/sudqi/dotfiles/scripts/xdg-open-dwm.sh "${selection}"
    fi
else
    # No match found: Show a message in dmenu
    /home/sudqi/dotfiles/scripts/xdg-open-dwm.sh "${clipboard_content}"
    # show_dmenu_message "No JIRA ticket found in the clipboard. $clipboard_content"
fi
