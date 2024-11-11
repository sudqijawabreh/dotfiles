#!/bin/sh

# List of layouts
# layouts="tile\nfloating\nmonocle\nspiral\ndwindle\ndeck\nbstack\nbstackhoriz\ngrid\nnrowgrid\nhorizgrid\ngaplessgrid\ncenteredmaster\ncenteredfloatingmaster"

# # Use dmenu to choose a layout
# chosen=$(echo -e "$layouts" | dmenu -i -p "Choose layout:")

# # Map chosen layout to dwm layout function index
# case "$chosen" in
#     tile) layout_index=0 ;;
#     floating) layout_index=1 ;;
#     monocle) layout_index=2 ;;
#     spiral) layout_index=3 ;;
#     dwindle) layout_index=4 ;;
#     deck) layout_index=5 ;;
#     bstack) layout_index=6 ;;
#     bstackhoriz) layout_index=7 ;;
#     grid) layout_index=8 ;;
#     nrowgrid) layout_index=9 ;;
#     horizgrid) layout_index=10 ;;
#     gaplessgrid) layout_index=11 ;;
#     centeredmaster) layout_index=12 ;;
#     centeredfloatingmaster) layout_index=13 ;;
#     *) exit 1 ;; # Exit if no valid layout is chosen
# esac

# # Send the chosen layout index to dwm using xprop
# xprop -root -f _DWM_COMMAND 8s -set _DWM_COMMAND "setlayout $layout_index"

#!/bin/sh

# List of layouts
layouts="tile\nfloating\nmonocle\nspiral\ndwindle\ndeck\nbstack\nbstackhoriz\ngrid\nnrowgrid\nhorizgrid\ngaplessgrid\ncenteredmaster\ncenteredfloatingmaster"

# Use dmenu to choose a layout
chosen=$(echo -e "$layouts" | dmenu -i -p "Choose layout:")

# Check if a valid layout is chosen
if [ -z "$chosen" ]; then
    exit 1
fi

# Send the chosen layout name to dwm using xprop
xprop -root -f _DWM_COMMAND 8s -set _DWM_COMMAND "setlayout $chosen"
