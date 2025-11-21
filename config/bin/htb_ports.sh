#!/bin/bash

# Verifica si el archivo existe
if [ -f ~/.config/bin/ports ]; then
    PORTS=$(cat ~/.config/bin/ports | tr ' ' '|')
    if [ -n "$PORTS" ]; then
        echo "⛩  $PORTS"
    else
        echo "⛩  No ports"
    fi
else
    echo "⛩  No ports"
fi

