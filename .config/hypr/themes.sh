#!/bin/bash

# === CONFIGURACIÓN ===
CONFIG="$HOME/.config"
KITTY_DIR="$CONFIG/kitty"
WALL="$1"

if [[ -z "$WALL" ]]; then
  echo "Uso: themes.sh [ruta_de_imagen]"
  exit 1
fi

# === Verificar que el archivo existe ===
if [[ ! -f "$WALL" ]]; then
  echo "No se encontró la imagen: $WALL"
  exit 1
fi

# === Mostrar fondo ===
if command -v swww &>/dev/null; then
  swww img "$WALL" --transition-type any
else
  echo "Instala swww para fondos dinámicos."
  exit 1
fi

# === Extraer paleta de colores dominante (usando Python y colorthief) ===
DOM_COLORS=$(python3 - <<EOF
from colorthief import ColorThief
import sys, json

color = ColorThief("$WALL").get_palette(color_count=6)
print(json.dumps(color))
EOF
)

# === Parsear colores (RGB -> Hex) ===
to_hex() {
  printf "#%02x%02x%02x" $1 $2 $3
}

COLORS=($(echo "$DOM_COLORS" | jq -r '.[] | @sh' | tr -d "'"))
BG_RGB=(${COLORS[0]//,/ })
FG_RGB=(${COLORS[1]//,/ })

BG=$(to_hex ${BG_RGB[@]})
FG=$(to_hex ${FG_RGB[@]})

# Ajuste básico de contraste
LUMINANCE=$(( (299*${FG_RGB[0]} + 587*${FG_RGB[1]} + 114*${FG_RGB[2]}) / 1000 ))
if [[ $LUMINANCE -lt 128 ]]; then
  FG="#FFFFFF"
fi

# === Crear archivo de colores para Kitty ===
cat > "$KITTY_DIR/colors.conf" <<EOF
foreground $FG
background $BG
color0 $BG
color1 $FG
color2 $FG
color3 $FG
color4 $FG
color5 $FG
color6 $FG
color7 $FG
EOF

# === Ajustar transparencia automáticamente ===
if [[ $(echo "$BG" | grep -E -i '000000|101010|202020') ]]; then
  sed -i 's/^background_opacity.*/background_opacity 0.85/' "$KITTY_DIR/kitty.conf"
else
  sed -i 's/^background_opacity.*/background_opacity 0.95/' "$KITTY_DIR/kitty.conf"
fi

# === Aplicar cambios en Kitty ===
kitty @ set-colors "$KITTY_DIR/colors.conf" >/dev/null 2>&1

# === Notificación opcional ===
if command -v notify-send &>/dev/null; then
  notify-send "Tema actualizado" "Basado en $(basename "$WALL")"
fi

echo "✅ Tema aplicado según la paleta de: $(basename "$WALL")"

