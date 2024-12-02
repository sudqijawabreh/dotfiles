#!/bin/bash

# A better alternative script is in demnu scripts repo
#
# Get list of all active windows using xprop and format the output
windows=$(xprop -root _NET_CLIENT_LIST | awk -F'#' '{print $2}' | tr ',' '\n' | while read -r wid; do
    # For each window ID, get the window title and window name
    title=$(xprop -id "$wid" WM_NAME | cut -d '"' -f 2)
    name=$(xprop -id "$wid" WM_CLASS | awk -F'"' '{print $4}')
    
    # Use the window name if the title is empty
    if [[ -z "$title" || "$title" != *-* ]]; then
        if [[ -z "$title" ]]; then
            echo "$wid - $name"
        else
            echo "$wid - $title - $name"
        fi
    else
        echo "$wid - $title"
    fi
done)

# Display the list in dmenu and capture the selected window
selected=$(echo "$windows" | dmenu -i -l 10 -p "Select a window:" | awk '{print $1}')
echo "$selected"

# Check if a window was selected
if [ -n "$selected" ]; then
    # Use xdo to focus the selected window
    xdo activate "$selected" 
    # && sleep 0.1 && xdotool key --clearmodifiers "Super+Return"
fi
