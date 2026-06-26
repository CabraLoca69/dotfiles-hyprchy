#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; }
section() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

# ──────────────────────────────────────────────
# Dependencias
# ──────────────────────────────────────────────
AUR_DEPS=(
    elephant
    elephant-bluetooth
    elephant-calc
    elephant-clipboard
    elephant-desktopapplications
    elephant-files
    elephant-menus
    elephant-providerlist
    elephant-runner
    elephant-symbols
    elephant-todo
    elephant-unicode
    elephant-websearch
    xdg-terminal-exec
    yaru-icon-theme
    linux-wallpaperengine-git
    sunwait
    hyprland-preview-share-picker-git
)

# Paquetes de CachyOS (no AUR)
CACHYOS_DEPS=(
    walker
)

install_deps() {
    section "Instalando dependencias (AUR)"

    if ! command -v paru &>/dev/null; then
        error "paru no encontrado. Instalalo primero: https://github.com/Morganamilo/paru"
        exit 1
    fi

    local missing=()
    for pkg in "${AUR_DEPS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        info "Todas las dependencias AUR ya están instaladas."
    else
        info "Paquetes AUR a instalar: ${missing[*]}"
        paru -S --needed "${missing[@]}"
    fi

    section "Instalando dependencias (CachyOS)"

    if ! grep -q "^\[cachyos\]" /etc/pacman.conf 2>/dev/null; then
        warning "Repo de CachyOS no encontrado en pacman.conf."
        warning "Estos paquetes no se van a instalar: ${CACHYOS_DEPS[*]}"
        warning "Seguí la guía en https://wiki.cachyos.net/installation/repos/ para agregarlo."
        return
    fi

    local missing_c=()
    for pkg in "${CACHYOS_DEPS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing_c+=("$pkg")
        fi
    done

    if [ ${#missing_c[@]} -eq 0 ]; then
        info "Todas las dependencias CachyOS ya están instaladas."
    else
        info "Paquetes CachyOS a instalar: ${missing_c[*]}"
        sudo pacman -S --needed "${missing_c[@]}"
    fi
}

# ──────────────────────────────────────────────
# Symlinks
# ──────────────────────────────────────────────
symlink() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ]; then
        warning "Ya existe symlink: $dst → reemplazando"
        rm "$dst"
    elif [ -e "$dst" ]; then
        warning "Ya existe (no es symlink): $dst → haciendo backup en ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    info "$dst → $src"
}

create_symlinks() {
    section "Creando symlinks"

    for dir in "$DOTFILES_DIR"/.config/*/; do
        name="$(basename "$dir")"
        symlink "$dir" "$HOME/.config/$name"
    done

    for dir in "$DOTFILES_DIR"/.local/share/*/; do
        name="$(basename "$dir")"
        symlink "$dir" "$HOME/.local/share/$name"
    done

    mkdir -p "$HOME/.local/bin"
    for file in "$DOTFILES_DIR"/.local/bin/*; do
        name="$(basename "$file")"
        symlink "$file" "$HOME/.local/bin/$name"
    done
}

# ──────────────────────────────────────────────
# Avisos post-instalación
# ──────────────────────────────────────────────
post_install_notes() {
    section "Notas post-instalación"

    echo -e "${YELLOW}Atención — configuración manual requerida:${NC}"
    echo ""
    echo "  1. waybar-cpu-watts.sh usa paths de hwmon hardcodeados."
    echo "     Verificá que sean correctos en tu hardware:"
    echo "       /sys/class/hwmon/hwmon3/energy9_input  (energía CPU)"
    echo "       /sys/class/hwmon/hwmon4/temp1_input    (temperatura CPU)"
    echo "     Usá 'ls /sys/class/hwmon/' para identificar los correctos."
    echo ""
    echo "  2. waybar-gpu.sh usa ROCm (AMD)."
    echo "     Si el hardware es distinto ajustá el script manualmente."
    echo ""
    echo "  3. linux-wallpaperengine requiere Wallpaper Engine instalado en Steam."
    echo "     Sin eso el script no funciona, pero no rompe nada al iniciar."
    echo ""
}

# ──────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────
main() {
    echo -e "${CYAN}"
    echo "  ┌─────────────────────────────┐"
    echo "  │     dotfiles installer      │"
    echo "  └─────────────────────────────┘"
    echo -e "${NC}"

    install_deps
    create_symlinks
    post_install_notes

    echo ""
    info "Instalación completa."
}

main "$@"