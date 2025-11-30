#!/bin/bash
#
# Pop!_OS Dev Bootstrap - Clean Edition
# Author: JeromeTDev (Optimized by ChatGPT)
#

# --- Logging ---
log_info() { echo -e "\n\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; exit 1; }

# Keep sudo alive
log_info "Prüfe sudo-Rechte..."
sudo -v
(
  while true; do
    sudo -v
    sleep 60
  done
) &

# --- Package Lists ---
APT_PACKAGES=(
    git make cmake gcc clang
    python3 python3-pip
    fish kitty neovim
    fzf tree ripgrep btop neofetch zoxide fd-find
    flatpak stow
    xdg-desktop-portal-gtk
    zathura 
    texlive-base
)

PPAS=(
    ppa:lazygit-team/release
    ppa:fish-shell/release-3
)

PPA_PACKAGES=(
    lazygit
)

FLATPAK_APPS=(
    com.mattjakeman.ExtensionManager
)

DOTFILES_REPO="https://github.com/JeromeTDev/fedora-dev-bootstrap.git"
DOTFILES_DIR="$HOME/popos-dev-bootstrap"

# --- Functions ---

install_apt_packages() {
    log_info "Installiere APT-Pakete..."
    sudo apt update
    sudo apt install -y "${APT_PACKAGES[@]}" || log_warn "Einige Pakete konnten nicht installiert werden."
}

install_ppas() {
    log_info "Füge PPAs hinzu..."
    for ppa in "${PPAS[@]}"; do
        if ! grep -R "$ppa" /etc/apt/sources.list.d &>/dev/null; then
            sudo add-apt-repository -y "$ppa" || log_warn "Konnte $ppa nicht hinzufügen."
        else
            log_info "PPA $ppa bereits vorhanden."
        fi
    done

    sudo apt update
    sudo apt install -y "${PPA_PACKAGES[@]}"
}

set_kitty_default_terminal() {
    if command -v kitty >/dev/null; then
        log_info "Setze Kitty als Standardterminal..."
        gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
        gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
    fi
}

set_fish_default_shell() {
    if command -v fish >/dev/null; then
        if [ "$SHELL" != "$(command -v fish)" ]; then
            log_info "Setze Fish als Standard-Shell..."
            chsh -s "$(command -v fish)" || log_warn "Konnte Fish nicht als Standardshell setzen."
        fi
    fi
}

activate_starship() {
    if ! command -v starship &>/dev/null; then
        log_info "Installiere Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    case "$(basename "$SHELL")" in
        fish)
            echo 'starship init fish | source' >> ~/.config/fish/config.fish
            ;;
        bash)
            echo "eval \"\$(starship init bash)\"" >> ~/.bashrc
            ;;
        zsh)
            echo "eval \"\$(starship init zsh)\"" >> ~/.zshrc
            ;;
    esac
}

install_yazi() {
    log_info "Installiere Yazi..."
    curl -sSL https://yazi-rs.github.io/install.sh | bash || log_warn "Yazi Installation fehlgeschlagen."
}

install_fonts() {
    log_info "Installiere Fonts..."
    sudo apt install -y fonts-jetbrains-mono fonts-noto-cjk fonts-droid-fallback
}

install_nvm_node() {
    log_info "Installiere Node.js via nvm..."
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -f "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

    nvm install --lts
    nvm use --lts
}

setup_npm_tools() {
    log_info "Installiere globale NPM Tools..."
    npm install -g neovim @mermaid-js/mermaid-cli
}

setup_flatpak() {
    log_info "Richte Flathub ein..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    for app in "${FLATPAK_APPS[@]}"; do
        flatpak install -y flathub "$app"
    done
}

deploy_dotfiles() {
    log_info "Deploye Dotfiles..."

    if [ ! -d "$DOTFILES_DIR" ]; then
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi

    cd "$DOTFILES_DIR" || exit

    for dir in */; do
        [ "$dir" != ".git/" ] && stow "$dir"
    done

   cd - >/dev/null
}

# --- Main ---
echo "🚀 Starte Pop!_OS Dev Bootstrap..."

sudo apt update && sudo apt upgrade -y

install_apt_packages
install_ppas
set_fish_default_shell
set_kitty_default_terminal
activate_starship
install_yazi
install_fonts
install_nvm_node
setup_npm_tools
setup_flatpak
deploy_dotfiles

log_success "🎉 Pop!_OS Dev Bootstrap abgeschlossen!"
echo "--------------------------------------------------------"
echo "Nächste Schritte:"
echo "- Terminal neu starten (Fish + Starship aktiv)"
echo "- 'nvim' starten für LazyVim Setup"
echo "- In Neovim :checkhealth ausführen"
echo "--------------------------------------------------------"

