#!/bin/bash

# Buscar la interfaz Ethernet real y Wi-Fi
ETH_IF=$(ip -o link show | awk -F': ' '/^.*: (enp|eth)/ {print $2}' | head -n 1)
WIFI_IF=$(ip -o link show | awk -F': ' '/^.*: wl/ {print $2}' | head -n 1)

# Obtener estado y IP solo si la interfaz tiene carrier y dirección asignada
ETH_STATE=$(cat /sys/class/net/$ETH_IF/operstate 2>/dev/null)
WIFI_STATE=$(cat /sys/class/net/$WIFI_IF/operstate 2>/dev/null)

ETH_IP=""
WIFI_IP=""

# Solo tomar IP si el estado es 'up' y tiene 'carrier'
if [[ "$ETH_STATE" == "up" && -f /sys/class/net/$ETH_IF/carrier && $(cat /sys/class/net/$ETH_IF/carrier) -eq 1 ]]; then
    ETH_IP=$(ip -4 addr show "$ETH_IF" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
fi

if [[ "$WIFI_STATE" == "up" && -f /sys/class/net/$WIFI_IF/carrier && $(cat /sys/class/net/$WIFI_IF/carrier) -eq 1 ]]; then
    WIFI_IP=$(ip -4 addr show "$WIFI_IF" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
fi

# Mostrar resultados priorizando Ethernet solo si está realmente conectada
if [[ -n "$ETH_IP" ]]; then
    echo " $ETH_IP"
elif [[ -n "$WIFI_IP" ]]; then
    echo " $WIFI_IP"
else
    echo " Sin conexión"
fi

