#!/bin/bash
# ==============================================
# Fedora Dev Bootstrap (One-Step Setup)
# ==============================================

set -e

echo "🚀 Starte Fedora Dev Bootstrap..."

# --- Systemupdate + DNF-Tuning ---
sudo dnf update -y
sudo sh -c 'echo -e "max_parallel_downloads=10\nfastestmirror=True" >> /etc/dnf/dnf.conf'

# --- Install Core Tools ---
sudo dnf install -y \
  kitty fish git lazygit neovim fzf tree ripgrep \
  gnome-tweaks gnome-shell-extensions gnome-extension-manager \
  xdg-desktop-portal-gtk btop neofetch zoxide \
  imagemagick poppler-utils ffmpegthumbnailer p7zip p7zip-plugins unzip \
  starship nodejs npm python3 python3-pip fd-find clang gcc make cmake

# --- Node.js & Python Provider für Neovim ---
npm install -g neovim
pip3 install --user pynvim

# --- Terminal & Shell Setup ---
gsettings set org.gnome.desktop.default-applications.terminal exec kitty
gsettings set org.gnome.desktop.default-applications.terminal exec-arg "-e"
chsh -s /usr/bin/fish

# --- Starship aktivieren ---
mkdir -p ~/.config/fish
if ! grep -q 'starship init fish' ~/.config/fish/config.fish 2>/dev/null; then
    echo 'starship init fish | source' >> ~/.config/fish/config.fish
fi

# --- Flatpak & Flathub ---
sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --- Nerd Font installieren ---
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
mkdir -p ~/.local/share/fonts/jetbrainsmono
curl -L $FONT_URL -o /tmp/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/jetbrainsmono
fc-cache -fv
rm /tmp/JetBrainsMono.zip

# --- Öffentliche Dotfiles deployen ---
DOTFILES_REPO="https://github.com/JeromeTDev/fedora-dev-bootstrap.git"
if [ ! -d ~/.dotfiles ]; then
    git clone "$DOTFILES_REPO" ~/.dotfiles
fi

if [ -d ~/.dotfiles ]; then
    cd ~/.dotfiles
    for dir in */; do
        stow "$dir"
    done
fi

# --- Optional GNOME Apps entfernen ---
sudo dnf remove -y gnome-tour cheese gnome-photos totem rhythmbox simple-scan \
gnome-maps gnome-weather libreoffice* gnome-contacts gnome-calendar || true

echo "========================================"
echo "✅ Fedora Dev Bootstrap abgeschlossen!"
echo "Starte Neovim, LazyVim installiert automatisch Plugins."
