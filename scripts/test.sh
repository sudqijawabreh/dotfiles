#!/bin/bash

# Get list of all windows using xwininfo and xprop
windows=$(xwininfo -root -tree | grep -E '0x[0-9a-f]+' | while read -r line; do
    # Extract window ID
    wid=$(echo "$line" | awk '{print $1}')
    
    # Try to get the window title using WM_NAME, then _NET_WM_NAME if WM_NAME is empty
    title=$(xprop -id "$wid" WM_NAME | cut -d '"' -f 2 2>/dev/null)
    if [ -z "$title" ]; then
        title=$(xprop -id "$wid" _NET_WM_NAME | cut -d '"' -f 2 2>/dev/null)
    fi
    
    # Get the window class name
    class=$(xprop -id "$wid" WM_CLASS | cut -d '"' -f 2 2>/dev/null)
    
    # Only add windows with a title or class to the list
    if [ -n "$title" ] || [ -n "$class" ]; then
        echo "$wid - ${title:-No Title} (${class:-No Class})"
    fi
done)

# Display the list in dmenu and capture the selected window
selected=$(echo "$windows" | dmenu -i -l 10 -p "Select a window:" | awk '{print $1}')

# Check if a window was selected
if [ -n "$selected" ]; then
    # Use xdo to focus the selected window
    xdo activate "$selected"
    
    # Optional: Swap the selected window to the master position
    xdotool key --clearmodifiers "Super+Return"
fi
