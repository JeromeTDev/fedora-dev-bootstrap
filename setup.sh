#!/bin/bash
#
# Fedora Dev Bootstrap + vereinfachte Btrfs Subvolume Struktur
# Autor: JeromeTDev (angepasst)
#

# --- Logging ---
log_info()    { echo -e "\n\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\n\033[1;32m[SUCCESS]\033[0m $1"; }
log_warn()    { echo -e "\n\033[1;33m[WARN]\033[0m $1"; }
log_error()   { echo -e "\n\033[1;31m[ERROR]\033[0m $1"; exit 1; }

# --- Sudo aktiv halten ---
sudo -v
(
  while true; do
    sudo -v
    sleep 60
    kill -0 "$$" || exit
  done
) &

###############################################################################
# SECTION 1: Btrfs Subvolumes einrichten
###############################################################################

FS_TYPE=$(findmnt -n -o FSTYPE /)
if [[ "$FS_TYPE" == "btrfs" ]]; then
    log_info "Btrfs erkannt auf /"
else
    log_error "Root-Dateisystem ist kein Btrfs. Abbruch."
fi


create_subvol() {
    local path="$1"
    local label="$2"
    if [ ! -d "$path" ]; then
        log_info "Erstelle Subvolume: $label → $path"
        sudo btrfs subvolume create "$path" || log_warn "Konnte $label nicht erstellen."
    else
        log_info "Subvolume $label existiert bereits → überspringe."
    fi
}

log_info "Richte vereinfachte Btrfs-Subvolumes ein..."
create_subvol "/.snapshots" "@snapshots"
create_subvol "/home" "@home"
create_subvol "/data" "@data"
create_subvol "/" "@"

# NO-COW für /data
sudo chattr +C /data

# Berechtigungen
sudo chown -R "$USER:$USER" /home /data

###############################################################################
# SECTION 2: Fedora Dev Setup
###############################################################################

DNF_PACKAGES=(
    # Development
    git make cmake gcc clang python3 nodejs

    # Terminal & Shell
    fish kitty neovim

    # TUI Tools
    fzf tree ripgrep btop neofetch zoxide fd-find ncdu

    # Utilities
    stow jq

    # Document & Media
    zathura zathura-pdf-mupdf zathura-djvu zathura-ps
    poppler-utils imagemagick mediainfo perl-Image-ExifTool

    # Extras
    zeal xournalpp texlive-scheme-basic lua-5.1 luarocks caffeine
)

COPR_REPOS=( atim/lazygit atim/starship )
COPR_PACKAGES=( lazygit starship )

FLATPAK_APPS=(
    com.mattjakeman.ExtensionManager
    com.teamspeak.TeamSpeak
    com.discordapp.Discord
    org.cryptomator.Cryptomator
    md.obsidian.Obsidian
    mega.MEGASync
)

DOTFILES_REPO="https://github.com/JeromeTDev/fedora-dev-bootstrap.git"
DOTFILES_DIR="$HOME/fedora-dev-bootstrap"

###############################################################################
# NPM Setup → global in /home/.npm-global
###############################################################################

configure_npm_path() {
    log_info "Konfiguriere NPM global in ~/.npm-global..."

    NPM_DIR="$HOME/.npm-global"
    mkdir -p "$NPM_DIR"

    npm config set prefix "$NPM_DIR"

    export PATH="$NPM_DIR/bin:$PATH"

    # Shell-PATH dauerhaft hinzufügen
    grep -q "$NPM_DIR/bin" ~/.bashrc || echo "export PATH=\"$NPM_DIR/bin:\$PATH\"" >> ~/.bashrc
    grep -q "$NPM_DIR/bin" ~/.zshrc || echo "export PATH=\"$NPM_DIR/bin:\$PATH\"" >> ~/.zshrc

    if [ "$(basename "$SHELL")" = "fish" ]; then
        grep -q "$NPM_DIR/bin" ~/.config/fish/config.fish || \
            echo "set -U fish_user_paths $NPM_DIR/bin \$fish_user_paths" >> ~/.config/fish/config.fish
    fi
}

setup_npm() {
    configure_npm_path
    log_info "Installiere globale NPM-Tools..."
    npm install -g neovim @mermaid-js/mermaid-cli || log_warn "NPM-Tools konnten nicht installiert werden."
}

###############################################################################
# Flatpak Installation → unter Home
###############################################################################

setup_flatpak() {
    log_info "Richte Flatpak ein (unter $HOME)..."

    mkdir -p "$HOME/.local/share/flatpak"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    for app in "${FLATPAK_APPS[@]}"; do
        flatpak install flathub "$app" -y || log_warn "Flatpak-App $app konnte nicht installiert werden."
    done
}

###############################################################################
# Restlicher Setup
###############################################################################

install_dnf_packages() { sudo dnf install -y "${DNF_PACKAGES[@]}" --skip-unavailable; }
install_copr_packages() { sudo dnf install -y "${COPR_PACKAGES[@]}"; }

configure_system() {
    log_info "Konfiguriere System..."

    sudo sed -i '/^max_parallel_downloads/d' /etc/dnf/dnf.conf
    sudo sed -i '/^fastestmirror/d' /etc/dnf/dnf.conf
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
    echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null

    if command -v fish &>/dev/null; then
        chsh -s "$(command -v fish)"
    fi

    if command -v kitty &>/dev/null; then
        gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
    fi
}

deploy_dotfiles() {
    log_info "Deploy Dotfiles..."
    if [ ! -d "$DOTFILES_DIR" ]; then
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi
    cd "$DOTFILES_DIR" || return
    for dir in *; do
        [ -d "$dir" ] && stow "$dir"
    done
}

###############################################################################
# RUN SCRIPT
###############################################################################

log_info "System aktualisieren..."
sudo dnf upgrade -y

configure_system
install_dnf_packages
setup_npm
install_copr_packages
setup_flatpak
deploy_dotfiles

log_success "🎉 Fedora Dev + vereinfachtes Btrfs Setup abgeschlossen!"
echo "--------------------------------------------------------"
echo "Nächste Schritte:"
echo "- Terminal neu starten (Fish + Starship aktiv)"
echo "- 'nvim' starten für LazyVim Setup"
echo "- In Neovim :checkhealth ausführen"
echo "- Große Dateien (Games/LLM) unter /data speichern"
echo "--------------------------------------------------------"
