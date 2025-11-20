#!/bin/bash

# Asegúrate de tener pamixer instalado
volume=$(pamixer --get-volume)
mute=$(pamixer --get-mute)

if [ "$mute" = "true" ]; then
    icon=""
else
    if [ "$volume" -eq 0 ]; then
        icon=""
    elif [ "$volume" -lt 50 ]; then
        icon=""
    else
        icon=""
    fi
fi

echo "$icon $volume%"

