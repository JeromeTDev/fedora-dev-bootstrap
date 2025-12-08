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
[[ "$FS_TYPE" == "btrfs" ]] || log_error "Root-Dateisystem ist kein Btrfs. Abbruch."

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
    git make cmake gcc clang python3 nodejs
    fish kitty neovim
    fzf tree ripgrep btop neofetch zoxide fd-find ncdu
    stow jq
    zathura zathura-pdf-mupdf zathura-djvu zathura-ps
    poppler-utils imagemagick mediainfo perl-Image-ExifTool
    zeal xournalpp texlive-scheme-basic lua-5.1 luarocks caffeine
)

COPR_REPOS=( atim/lazygit atim/starship lihaohong/yazi )
COPR_PACKAGES=( lazygit starship yazi )


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
# Funktionen
###############################################################################

install_dnf_packages() {
    log_info "Installiere DNF-Pakete..."
    sudo dnf install -y "${DNF_PACKAGES[@]}" --skip-unavailable
}

install_copr_packages() {
    log_info "Aktiviere COPR-Repos..."
    for repo in "${COPR_REPOS[@]}"; do
        sudo dnf copr enable "$repo" -y || log_warn "COPR-Repo $repo konnte nicht aktiviert werden."
    done

    log_info "Installiere COPR-Pakete..."
    for pkg in "${COPR_PACKAGES[@]}"; do
        if [ "$pkg" == "yazi" ]; then
            sudo dnf install -y --setopt=install_weak_deps=False "$pkg" || log_warn "Konnte $pkg nicht installieren."
        else
            sudo dnf install -y "$pkg" || log_warn "Konnte $pkg nicht installieren."
        fi
    done
}

setup_npm() {
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

    log_info "Installiere globale NPM-Tools..."
    npm install -g neovim @mermaid-js/mermaid-cli || log_warn "NPM-Tools konnten nicht installiert werden."
}

setup_flatpak() {
    log_info "Richte Flatpak ein..."
    mkdir -p "$HOME/.local/share/flatpak"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    for app in "${FLATPAK_APPS[@]}"; do
        flatpak install flathub "$app" -y || log_warn "Flatpak-App $app konnte nicht installiert werden."
    done
}

configure_system() {
    log_info "Konfiguriere System..."
    # DNF optimieren
    sudo sed -i '/^max_parallel_downloads/d' /etc/dnf/dnf.conf
    sudo sed -i '/^fastestmirror/d' /etc/dnf/dnf.conf
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
    echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null

    # Fish als Standard-Shell
    command -v fish &>/dev/null && chsh -s "$(command -v fish)"

    # Kitty als Standard-Terminal setzen (GNOME)
    if command -v kitty &>/dev/null && command -v gsettings &>/dev/null; then
        KITTY_PATH=$(command -v kitty)
        log_info "Setze Kitty als Standard-Terminal: $KITTY_PATH"
        gsettings set org.gnome.desktop.default-applications.terminal exec "$KITTY_PATH"
        gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'
    else
        log_warn "Kitty oder gsettings nicht gefunden → Standard-Terminal nicht gesetzt."
    fi
}

install_fonts() {
    log_info "Installiere Fonts..."
    sudo dnf install -y \
        google-roboto-fonts \
        google-noto-sans-cjk-ttc \
        jetbrains-mono-fonts \
        adobe-source-code-pro-fonts \
        liberation-sans-fonts \
        dejavu-sans-fonts || log_warn "Einige Fonts konnten nicht installiert werden."
}


deploy_dotfiles() {
    log_info "Deploy Dotfiles..."
    [ ! -d "$DOTFILES_DIR" ] && git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR" || return
    for dir in *; do
        [ -d "$dir" ] && stow "$dir"
    done
}

setup_starship() {
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$FISH_CONFIG")"
    if ! grep -q "starship init fish" "$FISH_CONFIG"; then
        echo 'if type starship >/dev/null 2>&1; starship init fish | source; end' >> "$FISH_CONFIG"
    fi
    log_info "Starship für Fish aktiviert."
}

###############################################################################
# RUN SCRIPT
###############################################################################

log_info "System aktualisieren..."
sudo dnf upgrade -y

install_dnf_packages
install_copr_packages
setup_starship
install_fonts
setup_npm
setup_flatpak
configure_system
deploy_dotfiles

log_success "🎉 Fedora Dev + vereinfachtes Btrfs Setup abgeschlossen!"
echo "--------------------------------------------------------"
echo "Nächste Schritte:"
echo "- Terminal neu starten (Fish + Starship aktiv)"
echo "- 'nvim' starten für LazyVim Setup"
echo "- In Neovim :checkhealth ausführen"
echo "- Große Dateien (Games/LLM) unter /data speichern"
echo "--------------------------------------------------------"
