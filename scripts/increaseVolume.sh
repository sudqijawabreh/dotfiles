#!/bin/bash

value="$(amixer get Master | grep -o '[0-9]*%' | head -1 | tr -d '%')"
icon=audio-volume-high

if [ "$value" -lt 30 ]; then
    icon=audio-volume-low
elif [ "$value" -lt 80 ]; then
    icon=audio-volume-medium
else
    icon=audio-volume-high
fi

amixer set Master 5%+ && notify-send -i $icon -a "volume-notifier" "Volume" "$value"  -h int:value:"$(amixer get Master | grep -o '[0-9]*%' | head -1 | tr -d '%')"
