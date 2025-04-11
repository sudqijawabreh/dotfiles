#!/bin/bash

BATTERY_LEVEL=$(acpi -b | grep -P -o '[0-9]+(?=%)')
BATTERY_STATE=$(acpi -b | grep -o 'Discharging\|Charging')

# Normal notification threshold
if [ "$BATTERY_LEVEL" -le 15 ] && [ "$BATTERY_STATE" = "Discharging" ]; then
    notify-send -u critical "⚠️ Low Battery" "Battery is at ${BATTERY_LEVEL}%! Plug in your charger."
    brightnessctl 10
fi

# Critical threshold: suspend
if [ "$BATTERY_LEVEL" -le 5 ] && [ "$BATTERY_STATE" = "Discharging" ]; then
    notify-send -u critical "💤 Suspending Now" "Battery is critically low at ${BATTERY_LEVEL}%!"
    systemctl suspend
fi

