#!/bin/bash
DOTFILES_DIR="$HOME/Hyprland-Kali"

echo "1. Actualizando sistema..."
sudo pacman -Syu --noconfirm

echo "2. Instalando paquetes base..."
sudo pacman -S --noconfirm git base-devel xdg-user-dirs xdg-utils wget curl

echo "3. Instalando Hyprland y Wayland essentials..."
sudo pacman -S --noconfirm hyprland xorg-xwayland

echo "4. Instalando barra, launchers y notificaciones..."
sudo pacman -S --noconfirm waybar swaync rofi-wayland

echo "5. Instalando terminales y utilidades..."
sudo pacman -S --noconfirm kitty alacritty neofetch htop brightnessctl jq

echo "6. Instalando audio y multimedia..."
sudo pacman -S --noconfirm pipewire pipewire-pulse wireplumber pamixer playerctl mpv

echo "7. Instalando captura de pantalla y portapapeles..."
sudo pacman -S --noconfirm grim slurp swappy wl-clipboard cliphist

echo "8. Instalando bloqueo de pantalla y logout menu..."
sudo pacman -S --noconfirm hyprlock wlogout polkit-gnome

echo "9. Instalando fuentes y emojis..."
sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd ttf-fantasque-sans-mono-nerd noto-fonts noto-fonts-emoji

echo "10. Instalando GTK/QT theming y utilidades..."
sudo pacman -S --noconfirm qt5ct qt6ct kvantum-qt5 kvantum-qt6 nwg-look imagemagick nwg-displays

echo "11. Instalando dependencias opcionales para XWayland apps..."
sudo pacman -S --noconfirm xorg-xwayland

echo "12. Instalando Zsh y Oh My Zsh..."
sudo pacman -S --noconfirm zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "13. Copiando dotfiles personales..."

# Config
mkdir -p "$HOME/.config"
cp -r "$DOTFILES_DIR/config/" "$HOME/.config/"

# Wallpapers -> Pictures
mkdir -p "$HOME/Pictures"
cp -r "$DOTFILES_DIR/wallpapers/" "$HOME/Pictures/"

# Zsh configs
cp "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Archivos extra
if [ -f "$DOTFILES_DIR/p10k.zshroot" ]; then
    cp "$DOTFILES_DIR/p10k.zshroot" "$HOME/.p10k.zshroot"
fi
if [ -f "$DOTFILES_DIR/zshrcroot" ]; then
    cp "$DOTFILES_DIR/zshrcroot" "$HOME/.zshrcroot"
fi
if [ -f "$DOTFILES_DIR/zsh_historyroot" ]; then
    cp "$DOTFILES_DIR/zsh_historyroot" "$HOME/.zsh_historyroot"
fi

# Dar permisos a scripts dentro de ~/.config/hypr/scripts
if [ -d "$HOME/.config/hypr/scripts" ]; then
    chmod +x "$HOME/.config/hypr/scripts/"*
fi

echo "14. Instalando AUR helper (yay) si no existe..."
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

echo "15. Instalando paquetes AUR recomendados"
yay -S --noconfirm hyprland-git swaync-git rofi-wayland-git pamixer-git hyprlock-git wlogout-git

echo "16. Creando directorios de usuario..."
xdg-user-dirs-update

echo "¡Instalación completa!"

