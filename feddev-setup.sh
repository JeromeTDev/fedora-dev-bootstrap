#!/bin/bash

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

# --- Dev Pakete & Tools ---
DNF_PACKAGES=(git gh make cmake gcc clang python3 nodejs fish kitty neovim fzf tree ripgrep btop zoxide fd-find ncdu stow jq zathura zathura-pdf-mupdf snapper python3-dnf-plugin-snapper btrfs-assistant poppler-utils ImageMagick mediainfo perl-Image-ExifTool zeal xournalpp texlive-scheme-basic lua-5.1 luarocks caffeine keepassxc gnome-extensions-app)
COPR_REPOS=(atim/lazygit atim/starship lihaohong/yazi)
COPR_PACKAGES=(lazygit starship yazi)
FLATPAK_APPS=(com.mattjakeman.ExtensionManager com.github.caffeine-ng.Caffeine com.teamspeak.TeamSpeak com.discordapp.Discord org.cryptomator.Cryptomator md.obsidian.Obsidian)

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

setup_starship() {
  log_info "Aktiviere Starship Prompt..."
  for shell in fish bash zsh; do
    CONFIG="$HOME/.config/fish/config.fish"
    [ "$shell" = bash ] && CONFIG="$HOME/.bashrc"
    [ "$shell" = zsh ] && CONFIG="$HOME/.zshrc"
    mkdir -p "$(dirname "$CONFIG")"
    touch "$CONFIG"
    if ! grep -q "starship init $shell" "$CONFIG"; then
      echo -e "\n# Starship Prompt\nif type starship >/dev/null 2>&1; then eval \"\$(starship init $shell)\"; fi" >>"$CONFIG"
      log_success "Starship für $shell aktiviert."
    fi
  done
}

install_fonts() {
  log_info "Installiere Nerd Font (JetBrainsMono)..."
  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"
  TMP_FONT="/tmp/JetBrainsMono.zip"
  curl -L -o "$TMP_FONT" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -o "$TMP_FONT" -d "$FONT_DIR"
  fc-cache -fv
  log_success "Nerd Font installiert."
}

setup_flatpak() {
  log_info "Richte Flatpak ein..."
  mkdir -p "$HOME/.local/share/flatpak"
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak update -y || log_warn "Flatpak-Update fehlgeschlagen."
  for app in "${FLATPAK_APPS[@]}"; do
    flatpak install flathub "$app" -y || log_warn "Flatpak-App $app konnte nicht installiert werden."
  done
}

deploy_dotfiles() {
  DOTFILES_REPO="https://github.com/JeromeTDev/fedora-dev-bootstrap.git"
  DOTFILES_DIR="$HOME/.dotfiles"
  log_info "Deploy Dotfiles..."
  if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || log_warn "Dotfiles-Repo konnte nicht geklont werden."
  else
    cd "$DOTFILES_DIR" && git pull --rebase || log_warn "Dotfiles-Repo konnte nicht aktualisiert werden."
  fi
  cd "$DOTFILES_DIR" || return
  stow --adopt . || log_warn "Fehler beim Setzen der Symlinks."
}

configure_system() {
  log_info "System konfigurieren..."
  sudo tee -a /etc/dnf/dnf.conf >/dev/null <<EOF
fastestmirror=True
max_parallel_downloads=15
defaultyes=True
install_weak_deps=False
clean_requirements_on_remove=True
EOF
  if command -v fish &>/dev/null && [ "$SHELL" != "$(command -v fish)" ]; then
    chsh -s "$(command -v fish)"
  fi
}

###############################################################################
# RUN SCRIPT
###############################################################################

log_info "System aktualisieren..."
sudo dnf upgrade -y

# --- Pakete & Tools installieren ---
install_dnf_packages
install_copr_packages
setup_starship
install_fonts
setup_flatpak
deploy_dotfiles
configure_system

log_success "🎉 Fedora Dev + Btrfs Setup abgeschlossen!"
echo "--------------------------------------------------------"
echo "Struktur-Check:"
echo "- System-Snapshots: /.snapshots (snapshots_root)"
echo "- NO-COW Daten: /data"
echo "- NO-COW Spiele: /games"
echo "- Home: /home (Snapshot-frei für externes Backup)"
echo "--------------------------------------------------------"
