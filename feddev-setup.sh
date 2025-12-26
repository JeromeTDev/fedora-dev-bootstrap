#!/bin/bash

# --- Logging ---
log_info() { echo -e "\n\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\n\033[1;32m[SUCCESS]\033[0m $1"; }
log_warn() { echo -e "\n\033[1;33m[WARN]\033[0m $1"; }
log_error() {
  echo -e "\n\033[1;31m[ERROR]\033[0m $1"
  exit 1
}

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
DNF_PACKAGES=(git gh make cmake gcc clang python3 fish kitty neovim fzf tree ripgrep btop zoxide fd-find ncdu stow jq zathura zathura-pdf-mupdf snapper python3-dnf-plugin-snapper btrfs-assistant poppler-utils ImageMagick mediainfo perl-Image-ExifTool zeal xournalpp texlive-scheme-basic lua-5.1 luarocks caffeine keepassxc gnome-extensions-app fastfetch)
COPR_REPOS=(atim/lazygit atim/starship lihaohong/yazi)
COPR_PACKAGES=(lazygit starship yazi)
FLATPAK_APPS=(com.mattjakeman.ExtensionManager com.teamspeak.TeamSpeak com.discordapp.Discord org.cryptomator.Cryptomator md.obsidian.Obsidian)

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
    case "$shell" in
    fish)
      CONFIG="$HOME/.config/fish/config.fish"
      INIT_CODE='
# Starship Prompt
if type starship >/dev/null 2>&1
    starship init fish | source
end
'
      ;;
    bash)
      CONFIG="$HOME/.bashrc"
      INIT_CODE='
# Starship Prompt
if type starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi
'
      ;;
    zsh)
      CONFIG="$HOME/.zshrc"
      INIT_CODE='
# Starship Prompt
if type starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
'
      ;;
    esac

    mkdir -p "$(dirname "$CONFIG")"
    touch "$CONFIG"
    if ! grep -q "starship init $shell" "$CONFIG"; then
      echo "$INIT_CODE" >>"$CONFIG"
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
  DOTFILES_REPO="https://github.com/JeromeTDev/.dotfiles.git"
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


create_subvolume(){
  log_info "Richte BTRFS Subvolumes (Cache & Tmp) ein..."

  # --- User Cache ---
  rm -rf "$HOME/.cache"
  sudo btrfs subvolume create "$HOME/.cache"
  sudo chown "$USER:$USER" "$HOME/.cache"
  sudo chattr +C "$HOME/.cache"

  # --- /var/cache ---
  # Prüfen, ob es bereits ein Subvolume ist, um Fehler bei Doppel-Ausführung zu vermeiden
  if ! sudo btrfs subvolume show /var/cache >/dev/null 2>&1; then
    sudo mv /var/cache /var/cache_old 2>/dev/null
    sudo btrfs subvolume create /var/cache
    sudo chattr +C /var/cache
    sudo chmod 755 /var/cache
    sudo chown root:root /var/cache
    [ -d "/var/cache_old" ] && sudo rm -rf /var/cache_old
  fi

  # --- /var/tmp ---
  if ! sudo btrfs subvolume show /var/tmp >/dev/null 2>&1; then
    sudo mv /var/tmp /var/tmp_old 2>/dev/null
    sudo btrfs subvolume create /var/tmp
    sudo chattr +C /var/tmp
    sudo chmod 1777 /var/tmp
    sudo chown root:root /var/tmp
    [ -d "/var/tmp_old" ] && sudo rm -rf /var/tmp_old
  fi
  
  log_success "BTRFS Struktur optimiert."
}
# snapshots
setup_snapper() {
  log_info "Initialisiere Snapper-Konfiguration (Lean Setup)..."
  
  # Config für root erstellen
  [ ! -f "/etc/snapper/configs/root" ] && sudo snapper -c root create-config /
  # Config für home erstellen
  [ ! -f "/etc/snapper/configs/home" ] && sudo snapper -c home create-config /home

  # Limits für ROOT (Nur täglich, da DNF-Plugin extra sichert)
  sudo snapper -c root set-config "TIMELINE_LIMIT_HOURLY=0" "TIMELINE_LIMIT_DAILY=3" "TIMELINE_LIMIT_WEEKLY=0"
  
  # Limits für HOME (Kurzfristiger Schutz für Config-Fehler)
  sudo snapper -c home set-config "TIMELINE_LIMIT_HOURLY=3" "TIMELINE_LIMIT_DAILY=3" "TIMELINE_LIMIT_WEEKLY=0"

  # User-Zugriff erlauben
  sudo snapper -c root set-config "ALLOW_USERS=$USER"
  sudo snapper -c home set-config "ALLOW_USERS=$USER"
  sudo chmod a+rx /.snapshots
  sudo chmod a+rx /home/.snapshots
  
  log_success "Snapper minimalistisch konfiguriert!"
}

install_mise() {
  log_info "Bereite BTRFS Subvolume für mise vor..."
  
  # Pfad definieren
  MISE_DATA_DIR="$HOME/.local/share/mise"
  
  # Falls das Verzeichnis existiert, aber kein Subvolume ist: sichern und neu anlegen
  if [ -d "$MISE_DATA_DIR" ] && ! sudo btrfs subvolume show "$MISE_DATA_DIR" >/dev/null 2>&1; then
    mv "$MISE_DATA_DIR" "${MISE_DATA_DIR}_old"
  fi

  # Subvolume erstellen, falls noch nicht vorhanden
  if ! sudo btrfs subvolume show "$MISE_DATA_DIR" >/dev/null 2>&1; then
    mkdir -p "$(dirname "$MISE_DATA_DIR")"
    sudo btrfs subvolume create "$MISE_DATA_DIR"
    sudo chown "$USER:$USER" "$MISE_DATA_DIR"
    # NO-COW setzen (gut für viele kleine Binaries/Datenbanken in Runtimes)
    sudo chattr +C "$MISE_DATA_DIR"
    log_success "Subvolume für mise unter $MISE_DATA_DIR erstellt (Snapshot-Excl)."
  fi

  # Alte Daten zurückschieben, falls vorhanden
  if [ -d "${MISE_DATA_DIR}_old" ]; then
    cp -a "${MISE_DATA_DIR}_old/." "$MISE_DATA_DIR/"
    rm -rf "${MISE_DATA_DIR}_old"
  fi

  log_info "Installiere mise via DNF..."
  sudo dnf config-manager --add-repo https://mise.jdx.dev/rpm/mise.repo
  sudo dnf install -y mise

  # Shell-Aktivierung (wie gehabt)
  for shell in fish bash zsh; do
    case "$shell" in
      fish) CONFIG="$HOME/.config/fish/config.fish"; INIT_CODE='if type mise >/dev/null 2>&1; mise activate fish | source; end' ;;
      bash) CONFIG="$HOME/.bashrc"; INIT_CODE='if type mise >/dev/null 2>&1; eval "$(mise activate bash)"; fi' ;;
      zsh)  CONFIG="$HOME/.zshrc"; INIT_CODE='if type mise >/dev/null 2>&1; eval "$(mise activate zsh)"; fi' ;;
    esac

    mkdir -p "$(dirname "$CONFIG")"
    if ! grep -q "mise activate $shell" "$CONFIG" 2>/dev/null; then
      echo -e "\n# Mise Runtime Manager\n$INIT_CODE" >> "$CONFIG"
      log_success "Mise für $shell aktiviert."
    fi
  done

  sudo -u "$USER" mise use --global node@latest
}

###############################################################################
# RUN SCRIPT
###############################################################################

log_info "System-Update und Basis-Installation..."
sudo dnf upgrade -y

# 1. Basis-Tools installieren (Snapper & Btrfs-Tools müssen vorhanden sein)
install_dnf_packages
install_copr_packages

# 2. Dateisystem-Struktur optimieren (Ausschlusszonen definieren)
# Das sorgt dafür, dass Snapshots von Anfang an klein bleiben.
create_subvolume

# 3. Backup-System initialisieren
# Da die Subvolumes nun stehen, ist Snapper sofort perfekt konfiguriert.
setup_snapper

# 4. Anwendungen und persönliche Konfiguration
# Falls hier Fehler passieren, greift bereits das Snapper-Sicherheitsnetz.
install_fonts
setup_flatpak
install_mise
setup_starship
deploy_dotfiles
configure_system

log_success "🎉 Fedora Dev + Btrfs Setup abgeschlossen!"
echo "--------------------------------------------------------"
echo "Struktur-Check:"
echo "- System-Snapshots: /.snapshots (Nur täglich + DNF-Events)"
echo "- Home-Snapshots: /home/.snapshots (Stündlich + Täglich)"
echo "- NO-COW & Snapshot-Excl: ~/.cache, /var/cache, /var/tmp"
echo "- Externe Daten: /data & /games (Symlinked/Subvolumes)"
echo "--------------------------------------------------------"
