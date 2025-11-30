#!/bin/bash

if [ -f ~/.config/bin/ports ]; then
    PORTS=$(cat ~/.config/bin/ports | tr ' ' '|')
    if [ -n "$PORTS" ]; then
        echo "兀 $PORTS"
    else
        echo "兀 No ports"
    fi
else
    echo "兀 No ports"
fi

