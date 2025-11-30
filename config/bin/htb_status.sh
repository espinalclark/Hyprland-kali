#!/bin/bash

HTB_ICON="❖"
THM_ICON="♰"
VPN_ICON="X"
DISCONNECTED_ICON="✗"

get_vpn_iface() {
    ip -o link show 2>/dev/null | awk -F': ' 'BEGIN{IGNORECASE=1} $2 ~ /^(tun|utun|wg|tap|vpn)/ {print $2; exit}'
}

get_ip() {
    ip -4 addr show "$1" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1
}

VPN_IF=$(get_vpn_iface)

if [ -z "$VPN_IF" ]; then
    echo "$DISCONNECTED_ICON sin vpn"
    exit 0
fi

VPN_IP=$(get_ip "$VPN_IF")

if pgrep -a openvpn | grep -Eiq 'htb|hackthebox'; then
    echo "$HTB_ICON $VPN_IP"
elif pgrep -a openvpn | grep -Eiq 'tryhackme|thm'; then
    echo "$THM_ICON $VPN_IP"
else
    echo "$VPN_ICON $VPN_IP"
fi

