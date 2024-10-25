#!/bin/bash

# Check if dwm is the active window manager
if [[ $(pgrep -x "dwm") ]]; then
    # Set XDG_CURRENT_DESKTOP to X-Generic if dwm is running
    XDG_CURRENT_DESKTOP=X-Generic xdg-open "$@"
else
    # Use the default xdg-open if not in dwm
    xdg-open "$@"
fi
