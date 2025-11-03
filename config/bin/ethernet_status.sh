#!/bin/bash

ETH_IF=$(ip -o link show | awk -F': ' '/enp|eth/ {print $2; exit}')
WIFI_IF=$(ip -o link show | awk -F': ' '/wl/ {print $2; exit}')

ETH_IP=$(ip -4 addr show "$ETH_IF" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
WIFI_IP=$(ip -4 addr show "$WIFI_IF" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)

if [ -n "$ETH_IP" ]; then
    echo " $ETH_IP"
elif [ -n "$WIFI_IP" ]; then
    echo " $WIFI_IP"
else
    echo " Sin conexión"
fi

