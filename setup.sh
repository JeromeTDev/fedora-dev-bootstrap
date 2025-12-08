#!/bin/bash
#
# Fedora Dev Bootstrap + Btrfs FSTAB Setup + Mise (Option A: /code/mise)
# Variante: Vollständige @-Subvolume + Fstab-Autokonfiguration + Mise in /code/mise
#
set -euo pipefail
IFS=$'\n\t'

# --- Logging ---
log_info()    { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_warn()    { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_error()   { echo -e "\033[1;31m[ERROR]\033[0m $1"; exit 1; }

sudo -v

###############################################################################
# SECTION 0 — sanity
###############################################################################
if [ "$(id -u)" -eq 0 ]; then
  log_error "Bitte als normaler Nutzer (nicht root) ausführen. Das Script verwendet sudo."
fi

###############################################################################
# SECTION 1 — Btrfs Root erkennen
###############################################################################
ROOT_DEV=$(findmnt -n -o SOURCE /)

if [[ "$ROOT_DEV" != *"btrfs"* ]]; then
    log_error "Root ist kein Btrfs — Abbruch."
fi

# Normalize device: if it's /dev/mapper/... or contains UUID[...] keep as-is for blkid
BTRFS_DEV="$ROOT_DEV"
log_info "Btrfs-Device erkannt: $BTRFS_DEV"

###############################################################################
# SECTION 2 — Subvolumes erstellen (mit Checks)
###############################################################################
SUBVOLS=(
    "@"
    "@home"
    "@snapshots"
    "@code"
    "@data"
    "@games"
    "@flatpak"
)

log_info "Erstelle Subvolumes falls nötig…"

# list existing subvols once for speed
EXISTING=$(sudo btrfs subvolume list -o / 2>/dev/null || true)

for sv in "${SUBVOLS[@]}"; do
    if echo "$EXISTING" | grep -q "path $sv"; then
        log_info "Subvolume $sv existiert bereits."
    else
        log_info "Erstelle Subvolume: $sv"
        sudo btrfs subvolume create "/$sv" || log_warn "Konnte /$sv nicht erstellen (Bereits vorhanden oder Fehler)."
    fi
done

###############################################################################
# SECTION 3 — FSTAB erzeugen (Backup + Write)
###############################################################################
log_info "Erzeuge /etc/fstab Einträge…"

UUID_VAL=$(blkid -s UUID -o value "$BTRFS_DEV" 2>/dev/null || true)
if [ -z "$UUID_VAL" ]; then
    # Fall-back: use device path
    log_warn "Konnte UUID nicht lesen, verwende Gerät: $BTRFS_DEV"
    DEVICE_FOR_FSTAB="$BTRFS_DEV"
else
    DEVICE_FOR_FSTAB="UUID=$UUID_VAL"
fi

FSTAB_NEW=$(mktemp)
cat <<EOF > "$FSTAB_NEW"
# /etc/fstab — automatisch generiert by fedora-dev-bootstrap

$DEVICE_FOR_FSTAB  /               btrfs  subvol=@,compress=zstd:3,noatime 0 0
$DEVICE_FOR_FSTAB  /home           btrfs  subvol=@home,compress=zstd:3,noatime 0 0
$DEVICE_FOR_FSTAB  /.snapshots     btrfs  subvol=@snapshots,compress=zstd:3,noatime 0 0
$DEVICE_FOR_FSTAB  /code           btrfs  subvol=@code,compress=zstd:3,noatime 0 0
$DEVICE_FOR_FSTAB  /data           btrfs  subvol=@data,compress=zstd:3,noatime 0 0
$DEVICE_FOR_FSTAB  /games          btrfs  subvol=@games,compress=zstd:3,noatime 0 0
$DEVICE_FOR_FSTAB  /var/lib/flatpak btrfs subvol=@flatpak,compress=zstd:3,noatime 0 0

tmpfs   /tmp    tmpfs    defaults,noatime,mode=1777   0 0
EOF

sudo cp /etc/fstab /etc/fstab.bak_$(date +%s)
sudo cp "$FSTAB_NEW" /etc/fstab
log_success "Neue fstab installiert (Backup in /etc/fstab.bak_*)"

###############################################################################
# SECTION 4 — Remountes (versucht live zu mounten; wenn nötig Neustart)
###############################################################################
log_info "Versuche Remounts gemäß neuer fstab..."

# create mountpoints in case they don't exist
for mp in /home /.snapshots /code /data /games /var/lib/flatpak; do
    sudo mkdir -p "$mp"
done

# Try to mount (ignore failures for remounting root)
sudo mount -a || log_warn "mount -a hatte Probleme (ein Reboot kann nötig sein)."

sudo chown -R "$USER:$USER" /code /data /games /var/lib/flatpak || true

###############################################################################
# SECTION 5 — DNF Packages (Fedora dev stack)
###############################################################################
DNF_PACKAGES=(
    git make cmake gcc clang python3 nodejs

    fish kitty neovim

    fzf tree ripgrep btop neofetch zoxide fd-find ncdu

    flatpak stow jq
    zathura zathura-pdf-mupdf zathura-ps zathura-djvu
    poppler-utils imagemagick mediainfo perl-Image-ExifTool

    zeal xournalpp texlive-scheme-basic
)

log_info "Installiere DNF-Pakete…"
sudo dnf upgrade -y
sudo dnf install -y "${DNF_PACKAGES[@]}" --skip-unavailable

###############################################################################
# SECTION 6 — Flatpak setup (in @flatpak)
###############################################################################
log_info "Richte Flatpak ein (Subvolume @flatpak)..."
sudo mkdir -p /var/lib/flatpak
sudo chown "$USER:$USER" /var/lib/flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.mattjakeman.ExtensionManager || log_warn "Flatpak install hat Fehler."

###############################################################################
# SECTION 7 — NPM global prefix (keep in /code) — optional, mise handles tools but we keep this
###############################################################################
log_info "Konfiguriere globales NPM (prefix) nach /code/npm-global..."
sudo mkdir -p /code/npm-global
sudo chown "$USER:$USER" /code/npm-global
npm config set prefix "/code/npm-global" || log_warn "npm fehlgeschlagen (evtl. nodejs fehlt)."

# add to shells if absent
if ! grep -q "/code/npm-global/bin" ~/.bashrc 2>/dev/null; then
    echo 'export PATH="/code/npm-global/bin:$PATH"' >> ~/.bashrc
fi
if [ -d ~/.config/fish ]; then
    if ! grep -q "/code/npm-global/bin" ~/.config/fish/config.fish 2>/dev/null; then
        echo 'set -U fish_user_paths /code/npm-global/bin $fish_user_paths' >> ~/.config/fish/config.fish
    fi
fi

###############################################################################
# SECTION 8 — MISE: Install into /code/mise and activate in shells (Option A)
# Docs: curl https://mise.run | sh  (can set MISE_INSTALL_PATH)
# Set MISE_DATA_DIR/MISE_INSTALLS_DIR to /code/mise to keep all installs in /code
# (References: mise docs: getting-started, installing, config/directories)
###############################################################################

log_info "Installiere mise in /code/mise ..."

# prepare dirs
sudo mkdir -p /code/mise/bin
sudo mkdir -p /code/mise/data
sudo mkdir -p /code/mise/cache
sudo chown -R "$USER:$USER" /code/mise

# Run remote install script but instruct it to put the binary into /code/mise/bin
# the official installer accepts MISE_INSTALL_PATH=/usr/local/bin/mise (see docs)
# we set it to /code/mise/bin/mise
export MISE_INSTALL_PATH="/code/mise/bin/mise"

# Use the official installer (will drop the CLI binary into our MISE_INSTALL_PATH)
curl -fsSL https://mise.run | MISE_INSTALL_PATH="$MISE_INSTALL_PATH" sh || log_warn "mise installer schlug fehl (prüfe Netzwerk)."

# Ensure binary is executable
if [ -x "/code/mise/bin/mise" ]; then
    log_success "mise CLI installiert: /code/mise/bin/mise"
else
    log_warn "mise CLI nicht in /code/mise/bin/mise gefunden — versuche Fallback (~/.local/bin/mise)..."
fi

# Configure mise data/install dirs via env vars in shell rc files
# MISE_DATA_DIR is where mise stores installs, plugins etc. We'll put it under /code/mise/data
# MISE_CACHE_DIR under /code/mise/cache
MISE_DATA_DIR="/code/mise/data"
MISE_CACHE_DIR="/code/mise/cache"
MISE_INSTALLS_DIR="$MISE_DATA_DIR/installs"

# Export env vars for interactive shells (append if not already present)
append_if_missing() {
  local file="$1"; shift
  local line="$*"
  grep -F -- "$line" "$file" >/dev/null 2>&1 || echo "$line" >> "$file"
}

# bash
append_if_missing ~/.bashrc "export MISE_DATA_DIR=\"$MISE_DATA_DIR\""
append_if_missing ~/.bashrc "export MISE_CACHE_DIR=\"$MISE_CACHE_DIR\""
append_if_missing ~/.bashrc "export MISE_INSTALLS_DIR=\"$MISE_INSTALLS_DIR\""
# activate mise automatically in interactive shells
append_if_missing ~/.bashrc 'eval "$(/code/mise/bin/mise activate bash 2>/dev/null || true)"'

# zsh
append_if_missing ~/.zshrc "export MISE_DATA_DIR=\"$MISE_DATA_DIR\""
append_if_missing ~/.zshrc "export MISE_CACHE_DIR=\"$MISE_CACHE_DIR\""
append_if_missing ~/.zshrc "export MISE_INSTALLS_DIR=\"$MISE_INSTALLS_DIR\""
append_if_missing ~/.zshrc 'eval "$(/code/mise/bin/mise activate zsh 2>/dev/null || true)"'

# fish
mkdir -p ~/.config/fish
append_if_missing ~/.config/fish/config.fish "set -x MISE_DATA_DIR $MISE_DATA_DIR"
append_if_missing ~/.config/fish/config.fish "set -x MISE_CACHE_DIR $MISE_CACHE_DIR"
append_if_missing ~/.config/fish/config.fish "set -x MISE_INSTALLS_DIR $MISE_INSTALLS_DIR"
append_if_missing ~/.config/fish/config.fish '/code/mise/bin/mise activate fish | source || true'

log_success "Mise installiert und in Shells (bash/zsh/fish) aktiviert (via /code/mise/bin/mise)."

# Ensure installs dir exists and is owned by user
mkdir -p "$MISE_INSTALLS_DIR"
chown -R "$USER:$USER" "$MISE_DATA_DIR" "$MISE_CACHE_DIR"

###############################################################################
# SECTION 9 — (Optional) Beispiel: globale Node/Python via mise (auskommentiert)
# Wenn du willst, entferne die Kommentare und passe Versionen an.
# Hinweise: mise use --global <tool@version>
# z.B. mise use --global node@24
# siehe: mise install-into / mise use docs
###############################################################################
: <<'OPTIONAL_MISE_INSTALLS'
log_info "Optional: mise: Installiere Node LTS global (Beispiel)"
/code/mise/bin/mise use --global node@24 || log_warn "mise node install fehlgeschlagen"

log_info "Optional: mise: Installiere Python global (Beispiel)"
/code/mise/bin/mise use --global python@3 || log_warn "mise python install fehlgeschlagen"
OPTIONAL_MISE_INSTALLS

###############################################################################
# DONE
###############################################################################
log_success "🎉 Fedora + Btrfs + FSTAB + Mise (Option A) Setup abgeschlossen!"
echo "➡️  Starte dein Terminal neu (oder eine neue Shell), damit mise activation und PATHs wirken."
echo "➡️  Wenn du globale Tools mit mise installieren willst, entferne die Kommentare im Script-Block 'Optional: mise installs' oder führe 'mise use --global <tool@version>'."
