#!/bin/bash

if [[ -z "$1" ]]; then
    chosen=$(echo -e "No Extend\nExtend To Right\nExtend To Left" | dmenu -i -p "Choose layout:")
fi


if [[ -n "$1" ]]; then

    positionCommand="--left-of eDP-1"

    xrandr --output eDP-1 --primary --auto --output HDMI-1 --off --output DP-1 --off
    if [[ "$1" == "-r" ]]; then
        positionCommand="--right-of eDP-1"
        notify-send "Extend To Right"
    elif [[ "$1" == "-l" ]]; then
        positionCommand="--left-of eDP-1"
        notify-send "Extend To Left"
    fi


    if [[ "$1" == "-n" ]]; then
        xrandr --output eDP-1 --primary --auto --output HDMI-1 --off --output DP-1 --off
    elif xrandr | grep "HDMI-1 connected"; then
        xrandr --output HDMI-1 --primary --auto $positionCommand --output eDP-1 --auto 
    elif xrandr | grep "DP-1 connected"; then
        xrandr --output DP-1 --primary --auto $positionCommand --output eDP-1 --auto
    else
        echo "No external display connected. Using e-DP-1 only."
        xrandr --output eDP-1 --primary --auto --output HDMI-1 --off --output DP-1 --off
    fi
    exit 0
fi

if [ -z "$chosen"]; then
    exit 1
fi


positionCommand="--left-of eDP-1"

if [[ "$chosen" == "Extend To Right" ]]; then
    positionCommand="--right-of eDP-1"
fi



if [[ "$chosen" == "No Extend" ]]; then
    xrandr --output eDP-1 --primary --auto --output HDMI-1 --off --output DP-1 --off
elif xrandr | grep "HDMI-1 connected"; then
    xrandr --output HDMI-1 --primary --auto $positionCommand --output eDP-1 --auto 
elif xrandr | grep "DP-1 connected"; then
    xrandr --output DP-1 --primary --auto $positionCommand --output eDP-1 --auto
else
    echo "No external display connected. Using e-DP-1 only."
    xrandr --output eDP-1 --primary --auto --output HDMI-1 --off --output DP-1 --off
fi

