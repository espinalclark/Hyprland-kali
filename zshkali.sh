#!/usr/bin/env bash

# 👾 https://github.com/espinalclark 👾 #

set -e

# Colores
green="\e[32m"; red="\e[31m"; blue="\e[34m"; end="\e[0m"

echo -e "${blue}[*] Iniciando instalación y configuración de ZSH...${end}"

# ---------------------------------------------
# 1. Verificación de carpeta actual
# ---------------------------------------------
BASE_DIR=$(pwd)

if [[ ! -f "$BASE_DIR/zshrc" ]] || [[ ! -f "$BASE_DIR/.p10k.zsh" ]]; then
    echo -e "${red}[!] ERROR: No encuentro los archivos zshrc / .p10k.zsh en este directorio.${end}"
    exit 1
fi

echo -e "${green}[+] Carpeta detectada correctamente${end}"

# ---------------------------------------------
# 2. Instalar ZSH si no existe
# ---------------------------------------------
if ! command -v zsh &>/dev/null; then
    echo -e "${blue}[*] Instalando Zsh...${end}"
    sudo apt install -y zsh
else
    echo -e "${green}[+] Zsh ya está instalado${end}"
fi

# ---------------------------------------------
# 3. Instalar Oh My Zsh (usuario)
# ---------------------------------------------
echo -e "${blue}[*] Instalando Oh My Zsh (usuario)...${end}"
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# ---------------------------------------------
# 4. Instalar Powerlevel10k (usuario)
# ---------------------------------------------
echo -e "${blue}[*] Instalando Powerlevel10k (usuario)...${end}"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    $HOME/.oh-my-zsh/custom/themes/powerlevel10k

# ---------------------------------------------
# 5. Copiar configuración del usuario
# ---------------------------------------------
echo -e "${blue}[*] Configurando ZSH del usuario...${end}"

cp -fv "$BASE_DIR/zshrc" "$HOME/.zshrc"
cp -fv "$BASE_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# ---------------------------------------------
# 6. Instalar Oh My Zsh (root)
# ---------------------------------------------
echo -e "${blue}[*] Instalando Oh My Zsh (root)...${end}"
sudo sh -c "RUNZSH=no sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"

# ---------------------------------------------
# 7. Instalar Powerlevel10k (root)
# ---------------------------------------------
echo -e "${blue}[*] Instalando Powerlevel10k (root)...${end}"
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    /root/.oh-my-zsh/custom/themes/powerlevel10k

# ---------------------------------------------
# 8. Copiar configuración root
# ---------------------------------------------
echo -e "${blue}[*] Configurando ZSH de root...${end}"

sudo cp -fv "$BASE_DIR/zshrcroot" /root/.zshrc
sudo cp -fv "$BASE_DIR/p10k.zshroot" /root/.p10k.zsh

# ---------------------------------------------
# 9. Cambiar shell por defecto a ZSH
# ---------------------------------------------
echo -e "${blue}[*] Estableciendo Zsh como shell predeterminado...${end}"

chsh -s "$(which zsh)"
sudo chsh -s "$(which zsh)" root

echo -e "${green}[+] Instalación y configuración completada.${end}"
echo -e "${green}[+] Reinicia la sesión para ver los cambios.${end}"

