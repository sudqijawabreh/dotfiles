#!/bin/bash

# Get battery percentage
BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')

# Optional: get battery state (Charging/Discharging)
BATTERY_STATE=$(acpi -b | grep -o 'Discharging\|Charging')

# Threshold and notification
if [ "$BATTERY_LEVEL" -le 15 ] && [ "$BATTERY_STATE" = "Discharging" ]; then
    notify-send -u critical "⚠️ Low Battery" "Battery is at ${BATTERY_LEVEL}%! Plug in your charger."
fi

