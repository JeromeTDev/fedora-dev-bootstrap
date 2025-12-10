
# Fedora Dev Bootstrap Pro

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Fedora](https://img.shields.io/badge/Fedora-43-blue.svg)](https://getfedora.org/)

---
[🇺🇸 English](#english) | [🇩🇪 Deutsch](#deutsch)

---

## 🇺🇸 English <a name="english"></a>

A fully automated **Fedora developer bootstrap** for a clean, developer-friendly environment. 

### Requirements:

- A fresh Fedora installation (recommended Fedora 43 or newer)
- Internet connection

#### FedDev includes:

- **Btrfs subvolumes** for `/data` and snapshots (`/.snapshots`) with NO-COW optimization
- **Developer tools:** git, gcc/clang, cmake, make, python3, nodejs, lua 5.1 + luarocks
- **Shell & terminal:** fish, starship, kitty
- **Editors:** neovim with LazyVim
- **PDF/LaTeX & multimedia:** texlive-scheme-basic, zathura, ImageMagick, mediainfo
- **Flatpak apps:** Discord, Obsidian, Cryptomator, TeamSpeak, Caffeine
- **Dotfiles deployment** with stow
- **Fonts:** JetBrainsMono Nerd Font
- **NPM global tools:** `neovim`, `@mermaid-js/mermaid-cli`

### 🚀 Features
- Automatic Btrfs checks & subvolume creation  
- Idempotent `/etc/fstab` entries (`compress=zstd:1`)  
- Starship prompt configured for fish, bash, zsh  
- Kitty set as default GNOME terminal  

### 🧩 Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/feddev-setup.sh)
```

**Alternative: Clone & run**

```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git ~/fedora-dev-bootstrap
cd ~/fedora-dev-bootstrap
chmod +x feddev-setup.sh
./feddev-setup.sh
```

### 🧪 After installation

- Restart your terminal (Fish + Starship active)  
- Run `nvim` → LazyVim installs automatically  
- Inside Neovim: `:checkhealth`  
- Store large files, VMs, LLMs under `/data`  

---

## 🇩🇪 Deutsch <a name="deutsch"></a>

Vollautomatisiertes **Fedora-Developer-Bootstrap**, ideal für Entwickler:

### Voraussetzungen:
- Eine frisch installierte Fedora-Version (empfohlen: Fedora 43 oder neuer)
- Internetverbindung

FedDev beinhaltet:

- **Btrfs-Subvolumes:** `/data` & `/.snapshots` (NO-COW optimiert)  
- **Dev-Tools:** git, gcc/clang, cmake, make, python3, nodejs, lua 5.1 + luarocks  
- **Shell & Terminal:** fish, starship, kitty  
- **Editoren:** neovim + LazyVim  
- **PDF/LaTeX & Multimedia:** texlive-scheme-basic, zathura, ImageMagick, mediainfo  
- **Flatpak-Apps:** Discord, Obsidian, Cryptomator, TeamSpeak, Caffeine  
- **Dotfiles Deployment** via stow  
- **Fonts:** JetBrainsMono Nerd Font  
- **Globale NPM-Tools:** `neovim`, `@mermaid-js/mermaid-cli`

### 🚀 Features
- Automatische Btrfs-Prüfung & Subvolume-Erstellung  
- Idempotente `/etc/fstab`-Einträge (`compress=zstd:1`)  
- Starship Prompt für fish, bash, zsh  
- Kitty als Standard-GNOME-Terminal  

### 🧩 Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/feddev-setup.sh)
```

**Alternative: Klonen & Ausführen**

```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git ~/fedora-dev-bootstrap
cd ~/fedora-dev-bootstrap
chmod +x feddev-setup.sh
./feddev-setup.sh
```

### 🧪 Nach der Installation

- Terminal neu starten (Fish + Starship aktiv)  
- `nvim` starten → LazyVim installiert automatisch  
- In Neovim `:checkhealth` ausführen  
- Große Dateien/VMs/LLMs unter `/data` speichern  

---

## 📘 License
MIT License © JeromeTDev
