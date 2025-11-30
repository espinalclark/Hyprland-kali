#!/usr/bin/env bash

# 👾 https://github.com/espinalclark 👾#

set -e

green="\e[32m"; red="\e[31m"; blue="\e[34m"; end="\e[0m"

echo -e "${blue}[*] Iniciando instalación ZSH en Arch Linux...${end}"

# -------------------------------------------------------
# 1. Validación de carpeta actual
# -------------------------------------------------------
BASE_DIR=$(pwd)

for file in zshrc .p10k.zsh zshrcroot p10k.zshroot; do
    if [[ ! -f "$BASE_DIR/$file" ]]; then
        echo -e "${red}[!] ERROR: Falta el archivo '$file' en esta carpeta.${end}"
        exit 1
    fi
done

echo -e "${green}[+] Archivos detectados correctamente${end}"

# -------------------------------------------------------
# 2. Instalar paquetes necesarios
# -------------------------------------------------------
echo -e "${blue}[*] Instalando dependencias...${end}"

sudo pacman -Sy --noconfirm \
    zsh git curl wget

echo -e "${green}[+] Dependencias instaladas${end}"

# -------------------------------------------------------
# 3. Instalar Oh My Zsh (usuario)
# -------------------------------------------------------
echo -e "${blue}[*] Instalando Oh My Zsh (usuario)...${end}"

export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo -e "${green}[+] Oh My Zsh instalado para usuario${end}"

# -------------------------------------------------------
# 4. Instalar Powerlevel10k (usuario)
# -------------------------------------------------------
echo -e "${blue}[*] Instalando Powerlevel10k (usuario)...${end}"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    $HOME/.oh-my-zsh/custom/themes/powerlevel10k

echo -e "${green}[+] Tema Powerlevel10k instalado (usuario)${end}"

# -------------------------------------------------------
# 5. Copiar configuraciones del usuario
# -------------------------------------------------------
echo -e "${blue}[*] Configurando ZSH de usuario...${end}"

cp -fv "$BASE_DIR/zshrc" "$HOME/.zshrc"
cp -fv "$BASE_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

echo -e "${green}[+] Configuración usuario aplicada${end}"

# -------------------------------------------------------
# 6. Instalar Oh My Zsh para root
# -------------------------------------------------------
echo -e "${blue}[*] Instalando Oh My Zsh (root)...${end}"

sudo sh -c "RUNZSH=no sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"

echo -e "${green}[+] Oh My Zsh instalado para root${end}"

# -------------------------------------------------------
# 7. Powerlevel10k (root)
# -------------------------------------------------------
echo -e "${blue}[*] Instalando Powerlevel10k (root)...${end}"

sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    /root/.oh-my-zsh/custom/themes/powerlevel10k

echo -e "${green}[+] Tema Powerlevel10k instalado (root)${end}"

# -------------------------------------------------------
# 8. Copiar configuraciones root
# -------------------------------------------------------
echo -e "${blue}[*] Configurando ZSH de root...${end}"

sudo cp -fv "$BASE_DIR/zshrcroot" /root/.zshrc
sudo cp -fv "$BASE_DIR/p10k.zshroot" /root/.p10k.zsh

echo -e "${green}[+] Configuración root aplicada${end}"

# -------------------------------------------------------
# 9. Cambiar shell por defecto
# -------------------------------------------------------
echo -e "${blue}[*] Estableciendo ZSH como shell predeterminado...${end}"

sudo chsh -s "$(command -v zsh)" $USER
sudo chsh -s "$(command -v zsh)" root

echo -e "${green}[+] ZSH establecida como shell predeterminada${end}"

# -------------------------------------------------------
# Fin
# -------------------------------------------------------
echo -e "${green}[✓] Instalación y configuración completada exitosamente.${end}"
echo -e "${blue}[*] Reinicia sesión para aplicar cambios.${end}"

