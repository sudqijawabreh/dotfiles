#!/bin/bash
xdotool search --class "zoom" | while read -r window_id; do
    xdotool getwindowname "$window_id" | grep -q "Meeting" && xdotool windowactivate "$window_id"
done

