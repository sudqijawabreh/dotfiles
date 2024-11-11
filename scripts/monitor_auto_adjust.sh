#!/bin/bash

# Check if HDMI (or external) monitor is connected
if xrandr | grep "HDMI-1 connected"; then
    # Set up dual monitors when HDMI is connected
    xrandr --output eDP-1 --auto --primary --output DP-1 --auto --right-of eDP-1
else
    # Revert to single monitor when HDMI is disconnected
    xrandr --output DP-1 --off --output eDP-1 --auto --primary
fi
