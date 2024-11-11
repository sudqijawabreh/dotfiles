#!/bin/bash
#!/bin/bash

# Toggle sound on/off
amixer set Master toggle > /dev/null

# Get the current mute status
status=$(amixer get Master | grep '\[on\]')

if [[ -n $status ]]; then
    # Sound is on
    notify-send -a "volume-notifier" "Sound" "Unmuted" -i audio-volume-high -h int:value:"$(amixer get Master | grep -o '[0-9]*%' | head -1 | tr -d '%')"
else
    # Sound is off
    notify-send -a "volume-notifier" "Sound" "Muted" -i audio-volume-muted -h int:value:"$(amixer get Master | grep -o '[0-9]*%' | head -1 | tr -d '%')"
fi
# amixer set Master toggle && notify-send -a "volume-notifier" "Volume" "Mute: $(amixer get Master | grep -o 'on\|off' | head -1)"
