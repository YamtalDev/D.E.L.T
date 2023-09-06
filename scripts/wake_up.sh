#!/bin/bash

# Turn on the system volume
pactl set-sink-mute @DEFAULT_SINK@ 0

# Turn on the microphone
pactl set-source-mute @DEFAULT_SOURCE@ 0

# Unblock Wi-Fi
rfkill unblock wifi

# Restore screen brightness
xrandr --output eDP-1 --brightness 1

# Open discord
discord &

