#!/bin/bash
# 💫 Instalador de todos los paquetes de KooL Hyprland (solo instalación) 💫 #

set -e

# Colores
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"

# Comprobar sudo
if [ "$EUID" -ne 0 ]; then
    echo "$ERROR Run this script as root or with sudo"
    exit 1
fi

echo -e "$INFO Actualizando repositorios..."
pacman -Syu --noconfirm

# Lista de paquetes oficiales de pacman
packages=(
    btop
    brightnessctl
    cava
    cliphist
    fastfetch
    ffmpegthumbnailer
    grim
    imagemagick
    kitty
    kvantum
    mousepad
    mpv
    mpv-mpris
    network-manager-applet
    nvtop
    nwg-displays
    nwg-look
    pamixer
    pavucontrol
    playerctl
    pyprland
    qalculate-gtk
    qt5ct
    qt6ct
    quickshell
    rofi-wayland
    slurp
    swappy
    swaync
    swww
    thunar
    thunar-archive-plugin
    thunar-volman
    tumbler
    wallust
    waybar
    wl-clipboard
    wlogout
    xdg-desktop-portal-hyprland
    yad
    yt-dlp
    xarchiver
    hypridle
    hyprlock
    hyprpolkitagent
    hyprland
)

echo -e "$INFO Instalando paquetes oficiales..."
for pkg in "${packages[@]}"; do
    echo -e "$INFO Instalando $pkg..."
    pacman -S --needed --noconfirm "$pkg" && echo -e "$OK $pkg instalado" || echo -e "$ERROR $pkg falló"
done

# Paquetes AUR
aur_packages=(
    "pokemon-colorscripts-git"
)

# Comprobar si yay está instalado
if ! command -v yay &>/dev/null; then
    echo -e "$INFO Instalando yay (AUR helper)..."
    pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
fi

echo -e "$INFO Instalando paquetes de AUR..."
for pkg in "${aur_packages[@]}"; do
    yay -S --needed --noconfirm "$pkg" && echo -e "$OK $pkg instalado" || echo -e "$ERROR $pkg falló"
done

echo -e "$INFO Todos los paquetes fueron instalados con éxito."

