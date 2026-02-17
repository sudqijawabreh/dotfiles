#!/bin/bash
name='sjawabreh'
if output=$(nmcli connection show --active | grep  "$name"); then
    if output=$(nmcli connection down id "$name" 2>&1); then
        notify-send -u normal -i network-vpn "VPN Disconnected" -t 800
    else
        notify-send -u critical -i network-error "VPN Failed" "$output" -t 800
    fi
else
    notify-send -u normal -i network-vpn "VPN" "Connecting to $name" -t 800
    if output=$(nmcli connection up id "$name" 2>&1); then
        notify-send -u normal -i network-vpn "VPN Connected" "You are now connected to $name" -t 800
    else
        notify-send -u critical -i network-error "VPN Failed" "$output" -t 800
    fi

fi
