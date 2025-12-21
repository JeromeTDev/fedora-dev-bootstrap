#!/bin/bash
#
# Pop!_OS Dev Bootstrap - Clean Edition (Optimized)
#

set -euo pipefail
IFS=$'\n\t'

# --- Logging ---
log_info()    { echo -e "\n\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\n\033[1;32m[SUCCESS]\033[0m $1"; }
log_warn()    { echo -e "\n\033[1;33m[WARN]\033[0m $1"; }
log_error()   { echo -e "\n\033[1;31m[ERROR]\033[0m $1"; exit 1; }

# --- Package Lists ---
APT_PACKAGES=(
    stow zathura
    fish kitty zoxide
    git gh make cmake gcc clang python3 python3-pip
    lazygit neovim xournalpp
    btop fd-find fzf ripgrep tree
    ffmpeg p7zip-full jq poppler-utils imagemagick mediainfo libimage-exiftool-perl chafa
    texlive-base keepassxc timeshift nodejs npm
)

FLATPAK_APPS=(
    com.teamspeak.TeamSpeak
    com.discordapp.Discord
    org.cryptomator.Cryptomator
)

PPAS=(ppa:fish-shell/release-3
  ppa:lazygit-team/release
)

# --- Funktionen ---
install_apt_packages() {
    log_info "Installiere APT-Pakete..."
    sudo apt update
    sudo apt install -y "${APT_PACKAGES[@]}" || log_warn "Einige Pakete konnten nicht installiert werden."
    # fd → fdfind Symlink setzen
    if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
        sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
    fi
}

install_ppas() {
    log_info "Füge PPAs hinzu..."
    for ppa in "${PPAS[@]}"; do
        if ! grep -R "$ppa" /etc/apt/sources.list.d &>/dev/null; then
            sudo add-apt-repository -y "$ppa" || log_error "Konnte $ppa nicht hinzufügen."
        else
            log_info "PPA $ppa bereits vorhanden."
        fi
    done
    sudo apt update
}

set_kitty_default_terminal() {
    if command -v kitty >/dev/null; then
        log_info "Setze Kitty als Standard-Terminal..."
        sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(command -v kitty)" 50
        sudo update-alternatives --set x-terminal-emulator "$(command -v kitty)" || true
    fi
}

set_fish_default_shell() {
    if command -v fish >/dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
        log_info "Setze Fish als Standard-Shell..."
        chsh -s "$(which fish)" || log_warn "Konnte Fish nicht als Standardshell setzen."
    fi
}

activate_starship() {
    if ! command -v starship &>/dev/null; then
        log_info "Installiere Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    case "$(basename "$SHELL")" in
        fish)
            grep -qxF 'starship init fish | source' ~/.config/fish/config.fish \
                || echo 'starship init fish | source' >> ~/.config/fish/config.fish
            ;;
        bash)
            grep -qxF 'eval "$(starship init bash)"' ~/.bashrc \
                || echo 'eval "$(starship init bash)"' >> ~/.bashrc
            ;;
        zsh)
            grep -qxF 'eval "$(starship init zsh)"' ~/.zshrc \
                || echo 'eval "$(starship init zsh)"' >> ~/.zshrc
            ;;
    esac
}

install_yazi() {
    log_info "Installiere Yazi..."
    LATEST_URL=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest \
        | grep "browser_download_url.*x86_64-unknown-linux-gnu" \
        | cut -d '"' -f 4)

    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR" || exit

    # Datei herunterladen
    curl -LO "$LATEST_URL" || log_warn "Download von Yazi fehlgeschlagen."

    # Datei dynamisch finden
    FILE=$(ls | grep 'x86_64-unknown-linux-gnu')
    if [ -z "$FILE" ]; then
        log_warn "Yazi-Binary nicht gefunden."
        cd - >/dev/null
        rm -rf "$TMP_DIR"
        return
    fi

    # ausführbar machen
    chmod +x "$FILE"

    # nach /usr/local/bin verschieben
    sudo mv "$FILE" /usr/local/bin/yazi

    cd - >/dev/null
    rm -rf "$TMP_DIR"
    log_success "Yazi installiert!"
} 


# ausführbar machen
chmod +x "$FILE"

# nach /usr/local/bin verschieben
sudo mv "$FILE" /usr/local/bin/yazi

cd - >/dev/null
rm -rf "$TMP_DIR"
log_success "Yazi installiert!"


install_fonts() {
    log_info "Installiere Fonts..."
    sudo apt install -y fonts-jetbrains-mono fonts-noto-cjk fonts-droid-fallback
}

setup_flatpak() {
    log_info "Installiere Flatpak-Apps..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    for app in "${FLATPAK_APPS[@]}"; do
        if ! flatpak list | grep -q "$app"; then
            flatpak install -y --user flathub "$app"
        else
            log_info "Flatpak $app bereits installiert."
        fi
    done
}

setup_data_partition() {
    DATA_DEV=$(lsblk -no NAME,FSTYPE,SIZE | grep -E 'ext4' | grep -v "$(df / | tail -1 | awk '{print $1}' | sed 's|/dev/||')" | head -n1 | awk '{print "/dev/"$1}')
    if [ -n "$DATA_DEV" ]; then
        sudo mkdir -p /data
        sudo mount "$DATA_DEV" /data
        sudo chown "$USER:$USER" /data
        if ! grep -q "/data" /etc/fstab; then
            UUID=$(blkid -s UUID -o value "$DATA_DEV")
            echo "UUID=$UUID /data ext4 defaults 0 2" | sudo tee -a /etc/fstab
        fi
        log_success "/data Partition eingerichtet und gemountet!"
    else
        log_warn "Keine separate ext4-Partition für /data gefunden."
    fi
}

deploy_dotfiles() {
    DOTFILES_REPO="https://github.com/JeromeTDev/fedora-dev-bootstrap.git"
    DOTFILES_DIR="$HOME/.dotfiles"
    if [ ! -d "$DOTFILES_DIR" ]; then
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi
    cd "$DOTFILES_DIR"
    stow --adopt .
    log_success "Dotfiles deployed und Symlinks gesetzt."
}

# --- Main ---
echo "🚀 Starte Pop!_OS Dev Bootstrap..."

sudo apt update && sudo apt upgrade -y

install_ppas
install_apt_packages
set_kitty_default_terminal
setup_flatpak
set_fish_default_shell
activate_starship
install_yazi
install_fonts
setup_data_partition
deploy_dotfiles

log_success "🎉 Pop!_OS Dev Bootstrap abgeschlossen!"
echo "--------------------------------------------------------"
echo "Nächste Schritte:"
echo "- Terminal neu starten (Fish + Starship aktiv)"
echo "- 'nvim' starten für LazyVim Setup"
echo "- In Neovim :checkhealth ausführen"
echo "- Große Dateien (Games/LLM) unter /data speichern"
echo "--------------------------------------------------------"
