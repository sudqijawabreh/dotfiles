#!/bin/bash

value="$(brightnessctl| grep -o '[0-9]*%' | head -1 | tr -d '%')"
# Todo: use icon for brightness
#icon=audio-volume-high

# if [ "$value" -lt 30 ]; then
#     icon=audio-volume-low
# elif [ "$value" -lt 80 ]; then
#     icon=audio-volume-medium
# else
#     icon=audio-volume-high
# fi

# if [ "$1" == "i" ]; then
#     brightnessctl set +$2% && notify-send -a "brightness-notifier" "Brightness" "$value"  -h int:value:"$value"
# elif [ "$1" == "d" ]; t
#     brightnessctl set $2%- && notify-send -a "brightness-notifier" "Brightness" "$value"  -h int:value:"$value"
# fi
brightnessctl set $1 && notify-send -i "$icon" -a "brightness-notifier" "Brightness" "$value"  -h int:value:"$(brightnessctl| grep -o '[0-9]*%' | head -1 | tr -d '%')"
