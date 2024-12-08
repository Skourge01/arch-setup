#!/bin/bash

# Função para instalar o git (se necessário)
install_git() {
    echo "Instalando git..."
    
    # Verifica se o git já está instalado
    if ! command -v git >/dev/null 2>&1; then
        echo "Git não está instalado. Instalando..."
        sudo pacman -S git --noconfirm --needed
        if command -v git >/dev/null 2>&1; then
            echo "Git instalado com sucesso!"
        else
            echo "Erro ao instalar o Git."
            exit 1
        fi
    else
        echo "Git já está instalado."
    fi
}

# Função para instalar o yay via git (se necessário)
install_yay() {
    echo "Instalando yay..."

    # Clona o repositório do yay e o compila
    cd /tmp || exit
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si --noconfirm
    cd .. || exit
    rm -rf yay
    echo "yay instalado com sucesso!"
}

# Verifica se o script está sendo executado como root
if [[ $EUID -eq 0 ]]; then
    echo "Não execute este script como root."
    exit 1
fi

# Instalar git, se necessário
install_git

# Verificar se o yay está instalado
if ! command -v yay >/dev/null 2>&1; then
    echo "yay não está instalado."
    install_yay
else
    echo "yay já está instalado."
fi

# Definindo arrays para pacotes oficiais e AUR
apps_official=("firefox" "neofetch" "htop" "git" "base-devel" "obsidian" "dropbox" "telegram-desktop" "kitty" "pcmanfm" "lxappearance" "materia-gtk-theme")
apps_aur=("visual-studio-code-bin")

# Função para instalar pacotes
install_apps() {
    local app_list=("$@")
    for app in "${app_list[@]}"; do
        if command -v "$app" >/dev/null 2>&1; then
            echo "$app já está instalado."
        else
            echo "Instalando $app..."
            yay -S "$app" --noconfirm
            if command -v "$app" >/dev/null 2>&1; then
                echo "$app instalado com sucesso!"
            else
                echo "Erro ao instalar $app."
            fi
        fi
    done
}

# Instalar pacotes oficiais
echo "Instalando pacotes oficiais..."
for app in "${apps_official[@]}"; do
    if command -v "$app" >/dev/null 2>&1; then
        echo "$app já está instalado."
    else
        echo "Instalando $app..."
        sudo pacman -S "$app" --noconfirm --needed
        if command -v "$app" >/dev/null 2>&1; then
            echo "$app instalado com sucesso!"
        else
            echo "Erro ao instalar $app."
        fi
    fi
done

# Instalar pacotes AUR
echo "Instalando pacotes AUR..."
install_apps "${apps_aur[@]}"

echo "Script concluído com sucesso!"
