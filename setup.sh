#!/bin/bash
#
# Fedora Dev Bootstrap + Btrfs FSTAB Setup
# Variante 2: Vollständige @-Subvolume + Fstab-Autokonfiguration
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
# SECTION 1 — Btrfs Root erkennen
###############################################################################

ROOT_DEV=$(findmnt -n -o SOURCE /)

if [[ "$ROOT_DEV" != *"btrfs"* ]]; then
    log_error "Root ist kein Btrfs — Abbruch."
fi

BTRFS_DEV=$(echo "$ROOT_DEV" | sed 's/\[.*\]//')

log_info "Btrfs-Device erkannt: $BTRFS_DEV"

###############################################################################
# SECTION 2 — Subvolumes erstellen
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

for sv in "${SUBVOLS[@]}"; do
    if sudo btrfs subvolume list / | grep -q "path $sv"; then
        log_info "Subvolume $sv existiert bereits."
    else
        log_info "Erstelle Subvolume: $sv"
        sudo btrfs subvolume create "/$sv"
    fi
done

sudo mkdir -p /mnt/newroot

###############################################################################
# SECTION 3 — Neue Mount-Hierarchie vorbereiten
###############################################################################

log_info "Erzeuge /etc/fstab Einträge…"

FSTAB_NEW=$(mktemp)

cat <<EOF > "$FSTAB_NEW"
# /etc/fstab — automatisch generiert

UUID=$(blkid -s UUID -o value "$BTRFS_DEV")  /               btrfs  subvol=@,compress=zstd:3,noatime 0 0
UUID=$(blkid -s UUID -o value "$BTRFS_DEV")  /home           btrfs  subvol=@home,compress=zstd:3,noatime 0 0
UUID=$(blkid -s UUID -o value "$BTRFS_DEV")  /.snapshots     btrfs  subvol=@snapshots,compress=zstd:3,noatime 0 0
UUID=$(blkid -s UUID -o value "$BTRFS_DEV")  /code           btrfs  subvol=@code,compress=zstd:3,noatime 0 0
UUID=$(blkid -s UUID -o value "$BTRFS_DEV")  /data           btrfs  subvol=@data,compress=zstd:3,noatime 0 0
UUID=$(blkid -s UUID -o value "$BTRFS_DEV")  /games          btrfs  subvol=@games,compress=zstd:3,noatime 0 0
UUID=$(blkid -s UUID -o value "$BTRFS_DEV")  /var/lib/flatpak btrfs subvol=@flatpak,compress=zstd:3,noatime 0 0

tmpfs   /tmp    tmpfs    defaults,noatime,mode=1777   0 0
EOF

log_success "Neue fstab vorbereitet: $FSTAB_NEW"

###############################################################################
# SECTION 4 — Fstab übernehmen (Backup + apply)
###############################################################################

sudo cp /etc/fstab /etc/fstab.bak_$(date +%s)
log_info "Backup von fstab erstellt."

sudo cp "$FSTAB_NEW" /etc/fstab
log_success "Neue fstab installiert!"

###############################################################################
# SECTION 5 — Remount + Ordnerrechte
###############################################################################

log_info "Remounte System gemäß neuer fstab…"

sudo mount -o remount,subvol=@ /
sudo mount -o remount /home
sudo mount -o remount /.snapshots
sudo mount -o remount /code
sudo mount -o remount /data
sudo mount -o remount /games
sudo mount -o remount /var/lib/flatpak || true

sudo chown "$USER:$USER" /code /data /games || true

log_success "Btrfs Subvolume Hierarchie aktiv!"

###############################################################################
# SECTION 6 — Fedora Dev Setup (Pakete)
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
sudo dnf install -y "${DNF_PACKAGES[@]}" --skip-unavailable

###############################################################################
# SECTION 7 — Flatpak einrichten (Subvolume @flatpak)
###############################################################################

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.mattjakeman.ExtensionManager

###############################################################################
# SECTION 8 — NPM in /code isolieren
###############################################################################

log_info "Konfiguriere globales NPM nach /code/npm-global…"

mkdir -p /code/npm-global
sudo chown "$USER:$USER" /code/npm-global

npm config set prefix "/code/npm-global"

grep -q "/code/npm-global/bin" ~/.bashrc || echo 'export PATH="/code/npm-global/bin:$PATH"' >> ~/.bashrc
grep -q "/code/npm-global/bin" ~/.config/fish/config.fish || echo 'set -U fish_user_paths /code/npm-global/bin $fish_user_paths' >> ~/.config/fish/config.fish

###############################################################################
# DONE
###############################################################################

log_success "🎉 Fedora + Btrfs + FSTAB + Dev Bootstrap abgeschlossen!"
echo "➡️  Starte das System neu, damit alle Mounts aktiv werden."
