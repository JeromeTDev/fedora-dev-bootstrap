#!/bin/bash
#
# Fedora Dev Bootstrap + vereinfachte Btrfs Subvolume Struktur
# Autor: angepasst für sauberes Setup
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

# --- Root prüfen ---
FS_TYPE=$(findmnt -n -o FSTYPE /)
[[ "$FS_TYPE" == "btrfs" ]] || log_error "Root-Dateisystem ist kein Btrfs. Abbruch."

# --- Root Device ermitteln ---
ROOT_DEV=$(findmnt -n -o SOURCE /)
UUID=$(blkid -s UUID -o value "$ROOT_DEV")
log_info "Root-Device: $ROOT_DEV, UUID: $UUID"

# --- Subvolumes erstellen (Fedora Standard Konform) ---
# Fedora nutzt standardmäßig 'root' und 'home'
create_subvol() {
    local label="$1"
    local mountpoint="$2"
    
    if ! sudo btrfs subvolume list / | grep -q "path $label$"; then
        log_info "Erstelle Subvolume: $label"
        # Wir erstellen das Subvolume auf der obersten Ebene
        sudo mount -o subvolid=5 "$ROOT_DEV" /mnt
        sudo btrfs subvolume create "/mnt/$label"
        sudo umount /mnt
    else
        log_info "Subvolume $label existiert bereits."
    fi
}

log_info "Subvolumes prüfen/erstellen..."
# 'root' und 'home' existieren bei Fedora bereits
create_subvol "data" "/data"
create_subvol "snapshots" "/.snapshots"

# --- Mountpoints und Berechtigungen ---
sudo mkdir -p /data /.snapshots

# --- NO-COW für data ---
# Wichtig für Datenbanken, VMs oder LLMs
sudo mount -o subvol=data "$ROOT_DEV" /data
sudo chattr +C /data 2>/dev/null || log_warn "Konnte NO-COW Attribut nicht setzen."
log_info "NO-COW für /data gesetzt."

# --- fstab-Einträge idempotent ---
update_fstab() {
    local mountpoint="$1"
    local subvol="$2"

    if ! grep -q "subvol=$subvol" /etc/fstab; then
        # Nutze die Standard-Fedora Mount-Optionen (relatime, ssd, discard=async, etc.)
        echo "UUID=$UUID $mountpoint btrfs subvol=$subvol,compress=zstd:1,defaults 0 0" | sudo tee -a /etc/fstab
        log_info "fstab-Eintrag für $mountpoint hinzugefügt."
    else
        log_info "fstab-Eintrag für $mountpoint existiert bereits."
    fi
}

# Wir fügen nur die neuen Subvolumes hinzu. 
# Fedora's / und /home stehen bereits in der fstab.
update_fstab "/data" "data"
update_fstab "/.snapshots" "snapshots"

# --- Berechtigungen für Daten ---
sudo chown "$USER:$USER" /data

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
# Funktionen für Dev Setup
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
        sudo dnf install -y "$pkg" || log_warn "Konnte $pkg nicht installieren."
    done
}

setup_npm() {
    log_info "Konfiguriere NPM global in ~/.npm-global..."
    NPM_DIR="$HOME/.npm-global"
    mkdir -p "$NPM_DIR"
    npm config set prefix "$NPM_DIR"
    export PATH="$NPM_DIR/bin:$PATH"

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

    # Fish als Standard-Shell setzen, falls noch nicht aktiv
    if command -v fish &>/dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
        chsh -s "$(command -v fish)"
        log_info "Fish als Standard-Shell gesetzt."
    fi

    # Kitty als Standard-Terminal für GNOME
    if command -v kitty &>/dev/null && command -v gsettings &>/dev/null; then
        KITTY_PATH=$(command -v kitty)
        gsettings set org.gnome.desktop.default-applications.terminal exec "$KITTY_PATH"
        log_info "Kitty als Standard-Terminal gesetzt."
    fi
}


install_fonts() {
    log_info "Installiere Standard-Fonts via DNF..."
    sudo dnf install -y \
        adobe-source-code-pro-fonts \
        liberation-sans-fonts \
        dejavu-sans-fonts || log_warn "Einige Fonts konnten nicht installiert werden."

    log_info "Aktiviere Copr-Repo für JetBrainsMono Nerd Font..."
    sudo dnf copr enable maveonair/jetbrains-mono-nerd-fonts -y || log_warn "Copr-Repo konnte nicht aktiviert werden."

    log_info "Installiere JetBrainsMono Nerd Font via DNF..."
    sudo dnf install -y jetbrains-mono-nerd-fonts || log_warn "JetBrainsMono Nerd Font konnte nicht installiert werden."

    log_info "Font-Cache aktualisieren..."
    fc-cache -fv

    log_success "JetBrainsMono Nerd Font (Copr) installiert und bereit."
}

deploy_dotfiles() {
    log_info "Deploy Dotfiles..."
    
    # Dotfiles-Repo klonen, falls noch nicht vorhanden
    [ ! -d "$DOTFILES_DIR" ] && git clone "$DOTFILES_REPO" "$DOTFILES_DIR"

    cd "$DOTFILES_DIR" || return

    # Für jedes Verzeichnis im Repo (also jedes Paket) ...
    for dir in *; do
        [ -d "$dir" ] || continue
        # Symlinks neu setzen, vorhandene Dateien & Symlinks überschreiben
        stow -R --override "$dir"
    done

    log_success "Dotfiles deployed und Symlinks korrekt gesetzt."
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
