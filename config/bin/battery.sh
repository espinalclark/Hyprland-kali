#!/bin/bash

# Detecta la batería automáticamente (BAT0, BAT1, etc.)
BATTERY_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)

# Si no hay batería (por ejemplo, PC de escritorio)
if [ -z "$BATTERY_PATH" ]; then
    echo " 0%"
    exit 0
fi

capacity=$(cat "$BATTERY_PATH/capacity" 2>/dev/null)
status=$(cat "$BATTERY_PATH/status" 2>/dev/null)

# Validar que capacity tenga valor
if [ -z "$capacity" ]; then
    capacity=0
fi

# Seleccionar ícono según carga y estado
if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
    icon=""
else
    if [ "$capacity" -ge 95 ]; then
        icon=""
    elif [ "$capacity" -ge 70 ]; then
        icon=""
    elif [ "$capacity" -ge 40 ]; then
        icon=""
    elif [ "$capacity" -ge 15 ]; then
        icon=""
    else
        icon=""
    fi
fi

echo "$icon $capacity%"

