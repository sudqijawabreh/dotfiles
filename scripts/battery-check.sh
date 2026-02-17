#!/bin/bash

LOCKFILE="/tmp/low_battery_warned"

BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
BATTERY_STATE=$(acpi -b | grep -o 'Discharging\|Charging')

# Notify once per low battery event
if [ "$BATTERY_LEVEL" -le 15 ] && [ "$BATTERY_STATE" = "Discharging" ]; then
    if [ ! -f "$LOCKFILE" ]; then
        notify-send -u critical "⚠️ Low Battery" "Battery is at ${BATTERY_LEVEL}%! Plug in your charger."
        touch "$LOCKFILE"
    fi
else
    # Reset if battery level goes above 15% or charging
    [ -f "$LOCKFILE" ] && rm "$LOCKFILE"
fi

# Suspend at critical level
if [ "$BATTERY_LEVEL" -le 5 ] && [ "$BATTERY_STATE" = "Discharging" ]; then
    notify-send -u critical "💤 Suspending Now" "Battery is critically low at ${BATTERY_LEVEL}%!"
    systemctl suspend
fi

