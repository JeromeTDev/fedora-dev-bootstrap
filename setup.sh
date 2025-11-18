#!/bin/bash
#
# Fedora Dev Bootstrap - Setup Script
# Author: JeromeTDev
# Description: Automated setup for a minimal Fedora GNOME development environment.
#

# --- Konfiguration ---
DNF_PACKAGES=(
    git make cmake gcc clang python3 nodejs
    fish kitty
    fzf tree ripgrep btop neofetch zoxide fd-find
    flatpak stow
    xdg-desktop-portal-gtk
    texlive-scheme-basic lua-5.1 luarocks
)

COPR_REPOS=(
    atim/lazygit
    atim/starship
)

FLATPAK_APPS=(
    com.mattjakeman.ExtensionManager
)

DOTFILES_REPO="https://github.com/JeromeTDev/fedora-dev-bootstrap.git"
DOTFILES_DIR="$HOME/fedora-dev-bootstrap"

# --- Funktionen für Logging ---
log_info() { echo -e "\n\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; exit 1; }

# --- DNF5 Paketinstallation ---
install_dnf_packages() {
    log_info "Installiere DNF Pakete..."
    sudo dnf install -y "${DNF_PACKAGES[@]}" --skip-unavailable || log_warn "Einige Pakete konnten nicht installiert werden."
}

# --- NPM-Pakete ---
install_npm_packages() {
    log_info "Installiere globale NPM-Pakete..."
    npm install -g neovim @mermaid-js/mermaid-cli || log_warn "NPM-Pakete konnten nicht installiert werden."
}

# --- COPR Repos und Pakete ---
install_copr_packages() {
    log_info "Aktiviere COPR-Repositories..."
    for repo in "${COPR_REPOS[@]}"; do
        if ! sudo dnf copr list | grep -q "$repo"; then
            sudo dnf copr enable -y "$repo" || log_warn "COPR $repo konnte nicht aktiviert werden."
        else
            log_info "COPR $repo bereits aktiviert."
        fi
    done

    log_info "Installiere COPR-Pakete..."
    COPR_PACKAGES=(lazygit starship)
    sudo dnf install -y "${COPR_PACKAGES[@]}" --skip-unavailable || log_warn "Einige COPR-Pakete konnten nicht installiert werden."
}

# --- Starship Prompt aktivieren ---
activate_starship() {
    SHELL_NAME=$(basename "$SHELL")
    case "$SHELL_NAME" in
        fish)
            CONFIG="$HOME/.config/fish/config.fish"
            if ! grep -q 'starship init fish' "$CONFIG"; then
                echo 'starship init fish | source' >> "$CONFIG"
                log_info "Starship in Fish aktiviert."
            fi
            ;;
        zsh)
            CONFIG="$HOME/.zshrc"
            if ! grep -q 'starship init zsh' "$CONFIG"; then
                echo 'eval "$(starship init zsh)"' >> "$CONFIG"
                log_info "Starship in Zsh aktiviert."
            fi
            ;;
        bash)
            CONFIG="$HOME/.bashrc"
            if ! grep -q 'starship init bash' "$CONFIG"; then
                echo 'eval "$(starship init bash)"' >> "$CONFIG"
                log_info "Starship in Bash aktiviert."
            fi
            ;;
        *)
            log_warn "Unbekannte Shell $SHELL_NAME. Starship muss manuell aktiviert werden."
            ;;
    esac
}

# --- Fonts installieren ---
install_fonts() {
    log_info "Installiere JetBrains Mono Nerd Font (falls verfügbar)..."
    sudo dnf install -y 'google-droid-sans-fonts' 'google-noto-cjk-fonts' 'jetbrains-mono-fonts-all' || log_warn "Font-Installation fehlgeschlagen."
}

# --- System konfigurieren ---
configure_system() {
    log_info "Systemkonfigurationen anwenden..."

    # DNF Performance Tuning
    if [ -f "/etc/dnf/dnf.conf" ]; then
        sudo sed -i '/^max_parallel_downloads/d' /etc/dnf/dnf.conf
        sudo sed -i '/^fastestmirror/d' /etc/dnf/dnf.conf
        echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
        echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
    fi

    # Fish als Standard-Shell
    if command -v fish &>/dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
        chsh -s "$(command -v fish)" || log_warn "chsh fehlgeschlagen."
    fi

    # Kitty als Standard-Terminal
    if command -v kitty &>/dev/null; then
        gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
    fi
}

# --- Flatpak Setup ---
setup_flatpak() {
    log_info "Richte Flatpak/Flathub ein..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || log_warn "Flathub konnte nicht hinzugefügt werden."

    for app in "${FLATPAK_APPS[@]}"; do
        flatpak install flathub "$app" -y || log_warn "Flatpak App $app konnte nicht installiert werden."
    done
}

# --- Dotfiles Deployment ---
deploy_dotfiles() {
    log_info "Dotfiles vorbereiten..."
    if [ -d "$DOTFILES_DIR" ]; then
        log_warn "Dotfiles-Verzeichnis existiert bereits. Überspringe Klonen."
    else
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || log_error "Klonen fehlgeschlagen."
    fi

    cd "$DOTFILES_DIR" || log_error "Wechsel ins Dotfiles-Verzeichnis fehlgeschlagen."
    for dir in *; do
        if [ -d "$dir" ] && [ "$dir" != ".git" ] && [ "$dir" != "setup.sh" ]; then
            stow --verbose "$dir" || log_warn "Stow Deployment von $dir fehlgeschlagen."
        fi
    done
    cd - > /dev/null
}

# --- Hauptskript ---
echo "🚀 Starte Fedora Dev Bootstrap..."

log_info "System aktualisieren..."
sudo dnf upgrade -y || log_warn "Systemupdate fehlgeschlagen."

configure_system
install_dnf_packages
install_npm_packages
install_copr_packages
activate_starship
install_fonts
setup_flatpak
deploy_dotfiles

# LazyVim installieren **nach den Dotfiles**
if [ ! -d "$HOME/.config/nvim" ]; then
    log_info "Installiere LazyVim Starter..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim || log_warn "LazyVim konnte nicht geklont werden."
else
    log_warn "~/.config/nvim existiert bereits. LazyVim-Installation übersprungen."
fi

log_success "🎉 Fedora Dev Bootstrap abgeschlossen!"
echo "--------------------------------------------------------"
echo "Nächste Schritte:"
echo "- Terminal neu starten für Fish/Starship."
echo "- Beim ersten Start von Neovim werden LazyVim Plugins installiert."
echo "- Mermaid CLI (mmdc) ist über npm verfügbar."
echo "- pdflatex über texlive-scheme-basic installiert."
echo "- Lua 5.1 und LuaRocks installiert. LuaRocks-Pakete für Lua 5.1: luarocks-5.1 install <package>"
echo "--------------------------------------------------------"
