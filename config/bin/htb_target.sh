#!/usr/bin/env bash
# htb_target.sh — muestra target para Waybar/Hyprland
TARGET_FILE="$HOME/.config/bin/target"
ICON="⚔"

# Si no existe o está vacío -> No target
if [ ! -f "$TARGET_FILE" ] || [ ! -s "$TARGET_FILE" ]; then
    echo "$ICON No target"
    exit 0
fi

# Leer la primera línea no vacía y que no sea un shebang accidental
line=""
while IFS= read -r l; do
    # eliminar CR si existe
    l="${l%$'\r'}"
    # trim de espacios
    l_trim="$(printf "%s" "$l" | awk '{$1=$1;print}')"
    [ -n "$l_trim" ] || continue
    case "$l_trim" in
        \#\!*) continue ;; # si es shebang accidental lo saltamos
        *) line="$l_trim"; break ;;
    esac
done < "$TARGET_FILE"

# Si no quedó nada válido
if [ -z "$line" ]; then
    echo "$ICON No target"
    exit 0
fi

# Separar posible IP del resto
first_token="$(printf "%s" "$line" | awk '{print $1}')"
rest="$(printf "%s" "$line" | cut -s -d' ' -f2- )"

is_ip() {
    [[ $1 =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]
}

if is_ip "$first_token"; then
    if [ -n "$rest" ]; then
        echo "$ICON $first_token - $rest"
    else
        echo "$ICON $first_token"
    fi
else
    echo "$ICON $line"
fi

exit 0

