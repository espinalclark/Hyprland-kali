#!/usr/bin/env bash
set -e

# -------------------------
# Colores
# -------------------------
OK="\e[32m[OK]\e[0m"
ERROR="\e[31m[ERROR]\e[0m"
INFO="\e[34m[INFO]\e[0m"

# -------------------------
# Variables
# -------------------------
DOTFILES_DIR="$HOME/Hyprland-Kali"
BASE_DIR=$(pwd)

# -------------------------
# Comprobar sudo
# -------------------------
if [ "$EUID" -ne 0 ]; then
    echo -e "$ERROR Ejecuta este script con sudo o root"
    exit 1
fi

# -------------------------
# 1. Actualizar sistema
# -------------------------
echo -e "$INFO Actualizando repositorios..."
pacman -Syu --noconfirm

# -------------------------
# 2. Paquetes oficiales
# -------------------------
packages=(
    btop brightnessctl cava cliphist fastfetch ffmpegthumbnailer grim
    imagemagick kitty kvantum mousepad mpv mpv-mpris network-manager-applet
    nvtop nwg-displays nwg-look pamixer pavucontrol playerctl pyprland
    qalculate-gtk qt5ct qt6ct quickshell rofi-wayland slurp swappy swaync
    swww thunar thunar-archive-plugin thunar-volman tumbler wallust waybar
    wl-clipboard wlogout xdg-desktop-portal-hyprland yad yt-dlp xarchiver
    hypridle hyprlock hyprpolkitagent hyprland
)

echo -e "$INFO Instalando paquetes oficiales..."
for pkg in "${packages[@]}"; do
    echo -e "$INFO Instalando $pkg..."
    pacman -S --needed --noconfirm "$pkg" && echo -e "$OK $pkg instalado" || echo -e "$ERROR $pkg falló"
done

# -------------------------
# 3. AUR packages
# -------------------------
aur_packages=(
    "pokemon-colorscripts-git" "hyprland-git" "swaync-git" "rofi-wayland-git"
    "pamixer-git" "hyprlock-git" "wlogout-git"
)

if ! command -v yay &>/dev/null; then
    echo -e "$INFO Instalando yay (AUR helper)..."
    pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

echo -e "$INFO Instalando paquetes AUR..."
for pkg in "${aur_packages[@]}"; do
    yay -S --needed --noconfirm "$pkg" && echo -e "$OK $pkg instalado" || echo -e "$ERROR $pkg falló"
done

# -------------------------
# 4. Zsh + Oh My Zsh + Powerlevel10k
# -------------------------
echo -e "$INFO Instalando Zsh y dependencias..."
pacman -Sy --noconfirm zsh git curl wget

# Validar archivos Zsh
for file in zshrc .p10k.zsh zshrcroot p10k.zshroot; do
    if [[ ! -f "$BASE_DIR/$file" ]]; then
        echo -e "$ERROR Falta el archivo $file"
        exit 1
    fi
done

# Usuario
echo -e "$INFO Instalando Oh My Zsh para usuario..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
cp -fv "$BASE_DIR/zshrc" "$HOME/.zshrc"
cp -fv "$BASE_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# Root
echo -e "$INFO Instalando Oh My Zsh para root..."
sudo sh -c "RUNZSH=no sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    /root/.oh-my-zsh/custom/themes/powerlevel10k
sudo cp -fv "$BASE_DIR/zshrcroot" /root/.zshrc
sudo cp -fv "$BASE_DIR/p10k.zshroot" /root/.p10k.zsh

# Cambiar shell por defecto
sudo chsh -s "$(command -v zsh)" $USER
sudo chsh -s "$(command -v zsh)" root

# -------------------------
# 5. Copiar dotfiles personales
# -------------------------
echo -e "$INFO Copiando dotfiles personales..."
mkdir -p "$HOME/.config"
cp -r "$DOTFILES_DIR/config/" "$HOME/.config/"
mkdir -p "$HOME/Pictures"
cp -r "$DOTFILES_DIR/wallpapers/" "$HOME/Pictures/"

for f in .p10k.zsh .zshrc p10k.zshroot zshrcroot zsh_historyroot; do
    if [ -f "$DOTFILES_DIR/$f" ]; then
        cp "$DOTFILES_DIR/$f" "$HOME/$f"
    fi
done

# Permisos a scripts
if [ -d "$HOME/.config/hypr/scripts" ]; then
    chmod +x "$HOME/.config/hypr/scripts/"*
fi

# -------------------------
# 6. Crear directorios de usuario
# -------------------------
xdg-user-dirs-update

echo -e "$OK ¡Instalación completa! Reinicia tu sesión para aplicar todos los cambios."

