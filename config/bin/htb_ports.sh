#!/bin/bash

TARGET_FILE="$HOME/.config/bin/target"

if [ ! -r "$TARGET_FILE" ]; then
    echo "ﲅ No target"
    exit 0
fi

read -r ip_target name_target _ < "$TARGET_FILE"

if [ -n "$ip_target" ] && [ -n "$name_target" ]; then
    echo "什 $ip_target - $name_target"
elif [ -n "$ip_target" ]; then
    echo "什 $ip_target"
else
    echo "ﲅ No target"
fi

