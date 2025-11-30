#!/bin/bash
#
# Pop!_OS Dev Bootstrap - Setup Script
# Author: JeromeTDev (adapted for Pop!_OS)
# Description: Automated setup for a minimal Pop!_OS GNOME development environment.
#

# --- Logging-Funktionen ---
log_info() { echo -e "\n\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; exit 1; }

# --- Sudo Cache aktiv halten ---
log_info "Prüfe sudo-Rechte..."
sudo -v
(
  while true; do
    sudo -v
    sleep 60
    kill -0 "$$" || exit
  done
) &

# --- Pakete & Repositories ---
APT_PACKAGES=(
    git make cmake gcc clang python3 nodejs
    fish kitty neovim
    fzf tree ripgrep btop neofetch zoxide fd-find
    flatpak stow
    xdg-desktop-portal-gtk
    texlive-base lua5.1 luarocks
    zathura steam xournalpp
)

PPAS=(
    ppa:lazygit-team/release
    ppa:fish-shell/release-3
    ppa:brave-browser/release
)

PPA_PACKAGES=(
    lazygit
    brave-browser
)

FLATPAK_APPS=(
    com.mattjakeman.ExtensionManager
)

DOTFILES_REPO="https://github.com/JeromeTDev/fedora-dev-bootstrap.git"
DOTFILES_DIR="$HOME/popos-dev-bootstrap"

# --- Funktionen ---
install_apt_packages() {
    log_info "Installiere APT-Pakete..."
    sudo apt update
    sudo apt install -y "${APT_PACKAGES[@]}" --ignore-missing || log_warn "Einige Pakete konnten nicht installiert werden."
}

install_ppa_packages() {
    log_info "Aktiviere PPAs..."
    for ppa in "${PPAS[@]}"; do
        if ! grep -q "$ppa" /etc/apt/sources.list.d/*; then
            sudo add-apt-repository -y "$ppa" || log_warn "PPA $ppa konnte nicht hinzugefügt werden."
        else
            log_info "PPA $ppa bereits hinzugefügt."
        fi
    done

    sudo apt update
    log_info "Installiere PPA-Pakete..."
    sudo apt install -y "${PPA_PACKAGES[@]}" --ignore-missing || log_warn "Einige PPA-Pakete konnten nicht installiert werden."
}

configure_system() {
    log_info "System konfigurieren..."

    # APT Performance Tuning (optional, Ubuntu has good defaults)

    # Fish als Standard-Shell
    if command -v fish &>/dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
        chsh -s "$(command -v fish)" || log_warn "chsh fehlgeschlagen."
    fi

    # Kitty als Standard-Terminal für GNOME
    if command -v kitty &>/dev/null; then
        gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
        mkdir -p ~/.local/share/applications
        cp /usr/share/applications/org.gnome.Terminal.desktop ~/.local/share/applications/ 2>/dev/null || cp /usr/share/applications/gnome-terminal.desktop ~/.local/share/applications/
        sed -i 's|Exec=.*terminal|Exec=kitty|' ~/.local/share/applications/*.desktop
        log_info "Kitty als Standard-Terminal gesetzt."
    fi
}

activate_starship() {
    # Install starship via curl if not available
    if ! command -v starship &>/dev/null; then
        log_info "Installiere Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y || log_warn "Starship-Installation fehlgeschlagen."
    fi

    SHELL_NAME=$(basename "$SHELL")
    case "$SHELL_NAME" in
        fish)
            CONFIG="$HOME/.config/fish/config.fish"
            grep -q 'starship init fish' "$CONFIG" || echo 'starship init fish | source' >> "$CONFIG"
            ;;
        zsh)
            CONFIG="$HOME/.zshrc"
            grep -q 'starship init zsh' "$CONFIG" || echo 'eval "$(starship init zsh)"' >> "$CONFIG"
            ;;
        bash)
            CONFIG="$HOME/.bashrc"
            grep -q 'starship init bash' "$CONFIG" || echo 'eval "$(starship init bash)"' >> "$CONFIG"
            ;;
        *)
            log_warn "Unbekannte Shell $SHELL_NAME. Starship muss manuell aktiviert werden."
            ;;
    esac
}

install_fonts() {
    log_info "Installiere Fonts..."
    sudo apt install -y fonts-jetbrains-mono fonts-noto-cjk fonts-droid-fallback || log_warn "Font-Installation fehlgeschlagen."
}

configure_npm_path() {
    log_info "Konfiguriere Nutzerlokalen NPM-Pfad..."
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'

    # PATH hinzufügen
    export PATH="$HOME/.npm-global/bin:$PATH"

    # Shells
    grep -q 'export PATH="$HOME/.npm-global/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
    grep -q 'export PATH="$HOME/.npm-global/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
    if [ "$(basename $SHELL)" = "fish" ]; then
        grep -q "$HOME/.npm-global/bin" ~/.config/fish/config.fish || \
            echo 'set -U fish_user_paths $HOME/.npm-global/bin $fish_user_paths' >> ~/.config/fish/config.fish
    fi
}

setup_npm() {
    configure_npm_path
    log_info "Installiere globale NPM-Pakete..."
    npm install -g neovim @mermaid-js/mermaid-cli || log_warn "NPM-Pakete konnten nicht installiert werden."
}

setup_flatpak() {
    log_info "Richte Flatpak/Flathub ein..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || log_warn "Flathub konnte nicht hinzugefügt werden."
    for app in "${FLATPAK_APPS[@]}"; do
        flatpak install flathub "$app" -y || log_warn "Flatpak App $app konnte nicht installiert werden."
    done
}

deploy_dotfiles() {
    log_info "Dotfiles bereitstellen..."
    if [ ! -d "$DOTFILES_DIR" ]; then
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || log_error "Klonen der Dotfiles fehlgeschlagen."
    else
        log_warn "Dotfiles-Verzeichnis existiert bereits, überspringe Klonen."
    fi
    cd "$DOTFILES_DIR" || log_error "Wechsel ins Dotfiles-Verzeichnis fehlgeschlagen."
    for dir in *; do
        [ -d "$dir" ] && [ "$dir" != ".git" ] && [ "$dir" != "setup.sh" ] && stow "$dir" || log_warn "Stow Deployment von $dir fehlgeschlagen."
    done
    cd - > /dev/null
}

install_yazi() {
    log_info "Installiere Yazi-Dateimanager..."
    sudo apt install -y ffmpeg libpoppler-glib-dev resvg fd-find ripgrep zoxide || log_warn "Abhängigkeiten fehlgeschlagen."
    # Yazi via PPA or snap
    sudo snap install yazi --classic || log_warn "Snap-Installation von Yazi fehlgeschlagen."
    command -v yazi &>/dev/null && log_success "Yazi erfolgreich installiert!"
}

install_lazvim() {
    if [ ! -d "$HOME/.config/nvim" ]; then
        log_info "Installiere LazyVim Starter..."
        git clone https://github.com/LazyVim/starter ~/.config/nvim || log_warn "LazyVim konnte nicht geklont werden."
        nvim --headless +Lazy! +qall
        SNACKS_FILE="$HOME/.config/nvim/lua/config/snacks.lua"
        [ -f "$SNACKS_FILE" ] && sed -i "s/enabled\s*=\s*false/enabled = true/" "$SNACKS_FILE"
    fi
}

# --- Hauptskript ---
echo "🚀 Starte Pop!_OS Dev Bootstrap..."

log_info "System aktualisieren..."
sudo apt update && sudo apt upgrade -y || log_warn "Systemupdate fehlgeschlagen."

configure_system
install_apt_packages
setup_npm
install_ppa_packages
activate_starship
install_yazi
install_fonts
setup_flatpak
deploy_dotfiles
install_lazvim

log_success "🎉 Pop!_OS Dev Bootstrap abgeschlossen!"
echo "--------------------------------------------------------"
echo "Nächste Schritte:"
echo "- Terminal neu starten für Fish/Starship"
echo "- Beim ersten Start von Neovim werden LazyVim Plugins installiert"
echo "- Neovim starten: nvim"
echo "- In Neovim :checkhealth ausführen"
echo "--------------------------------------------------------"