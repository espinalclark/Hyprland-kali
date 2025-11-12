#!/bin/bash
# Hyprland installer cl4rksec
clear

OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
YELLOW="$(tput setaf 3)"
RESET="$(tput sgr0)"

echo ""
echo "========================================="
echo "   Hyprland Install cl4rk-sec"
echo "========================================="
echo ""
echo "Este script compilará e instalará Hyprland y sus dependencias desde fuente."
echo ""

read -rp "¿Deseas continuar con la instalación? [y/N]: " confirm
case "$confirm" in
    [yY][eE][sS]|[yY]) echo -e "${OK} Iniciando instalación..." ;;
    *) echo -e "${INFO} Instalación cancelada."; exit 1 ;;
esac

if [[ $EUID -eq 0 ]]; then
    echo -e "${ERROR} No ejecutes este script como root."
    exit 1
fi

mkdir -p Install-Logs
LOG="Install-Logs/install-$(date +%d-%H%M%S).log"
script_dir="install-scripts"

execute_script() {
    local script="$1"
    local path="$script_dir/$script"
    if [[ -f "$path" ]]; then
        chmod +x "$path"
        echo -e "${INFO} Ejecutando $script..." | tee -a "$LOG"
        "$path" 2>&1 | tee -a "$LOG"
    else
        echo -e "${ERROR} No se encontró $script" | tee -a "$LOG"
    fi
}

echo ""
echo -e "${INFO} Actualizando sistema..."
sudo apt update -y && sudo apt upgrade -y

# Ejecución secuencial según los archivos existentes
execute_script "00-dependencies.sh"
execute_script "01-hypr-pkgs.sh"
execute_script "Global_functions.sh"
execute_script "hyprutils.sh"
execute_script "hyprlang.sh"
execute_script "hyprgraphics.sh"
execute_script "hyprwayland-scanner.sh"
execute_script "hyprland-protocols.sh"
execute_script "wayland-protocols-src.sh"
execute_script "hyprland.sh"

echo ""
echo -e "${OK} Instalación completada."
echo -e "${YELLOW}Reinicia tu sistema antes de iniciar Hyprland.${RESET}"

