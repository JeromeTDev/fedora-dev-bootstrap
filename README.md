# Fedora Dev Bootstrap Pro

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Fedora](https://img.shields.io/badge/Fedora-43-blue.svg)](https://getfedora.org/)

---

[🇺🇸 English](#english) | [🇩🇪 Deutsch](#deutsch)

---

## 🇺🇸 English <a name="english"></a>

A fully automated **Fedora developer bootstrap** designed for power users.  
It optimizes your filesystem for **Btrfs**, sets up modular runtime management,  
and deploys a complete, opinionated **developer stack**.

### Requirements
- Fresh Fedora installation (recommended **Fedora 43+**)
- Active internet connection

### FedDev includes
- **Btrfs Optimization**
  - Dedicated subvolumes for:
    - `~/.cache`
    - `/var/cache`
    - `~/.local/share/mise`
  - Snapshot-excluded & **NO-COW** optimized

- **Runtime Management**
  - **mise** (modern replacement for asdf / nvm)
  - Node.js, Python, and more

- **Developer Tools**
  - git, gh
  - make, cmake
  - gcc / clang
  - python3
  - lua 5.1 + luarocks

- **Shell & Terminal**
  - fish (default shell)
  - starship prompt
  - kitty terminal

- **Editors**
  - Neovim (LazyVim-ready)

- **Utilities & CLI**
  - fzf, zoxide, ripgrep
  - btop, fd, yazi
  - lazygit

- **Flatpak Apps**
  - Discord
  - Obsidian
  - Cryptomator
  - TeamSpeak
  - Caffeine

- **Dotfiles**
  - Automated deployment via **GNU Stow**
  - Source: `JeromeTDev/.dotfiles`

- **Fonts**
  - JetBrainsMono Nerd Font

### 🚀 Features
- **Smart Snapshots**
  - Automated Snapper configuration for `/` and `/home`
  - Lean retention policies

- **Mise Integration**
  - Automatically installs the latest Node.js
  - Shell activation handled automatically

- **Btrfs Subvolume Shield**
  - Prevents snapshot bloat from caches & toolchains
  - Uses nested subvolumes

- **Multi-Shell Support**
  - Fish, Bash & Zsh
  - Starship + mise preconfigured

### 🧩 Installation

#### One-liner (recommended)
```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/feddev-setup.sh)
```

#### Alternative: Clone & Run
```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git ~/fedora-dev-bootstrap
cd ~/fedora-dev-bootstrap
chmod +x feddev-setup.sh
./feddev-setup.sh
```

### 🧪 After Installation
- Restart your terminal (Fish + Starship enabled by default)
- Run `mise ls` to see installed runtimes
- Start `nvim` to load your personal configuration via dotfiles

---

## 🇩🇪 Deutsch <a name="deutsch"></a>

Vollautomatisiertes **Fedora Developer Bootstrap** für Power-User.  
Optimiert **Btrfs**, richtet modulares Runtime-Management ein  
und installiert einen vollständigen Developer-Stack.

### Voraussetzungen
- Frische Fedora-Installation (empfohlen **Fedora 43+**)
- Aktive Internetverbindung

### FedDev beinhaltet
- **Btrfs-Optimierung**
  - Eigene Subvolumes für:
    - `~/.cache`
    - `/var/cache`
    - `~/.local/share/mise`
  - Snapshot-exkludiert & **NO-COW** optimiert

- **Runtime-Management**
  - **mise** (moderner Ersatz für asdf / nvm)
  - Node.js, Python u.v.m.

- **Developer-Tools**
  - git, gh
  - make, cmake
  - gcc / clang
  - python3
  - lua 5.1 + luarocks

- **Shell & Terminal**
  - fish (Standard-Shell)
  - starship prompt
  - kitty terminal

- **Editoren**
  - Neovim (LazyVim-ready)

- **Utilities & CLI**
  - fzf, zoxide, ripgrep
  - btop, fd, yazi
  - lazygit

- **Flatpak-Apps**
  - Discord
  - Obsidian
  - Cryptomator
  - TeamSpeak
  - Caffeine

- **Dotfiles**
  - Automatisches Deployment via **GNU Stow**
  - Quelle: `JeromeTDev/.dotfiles`

- **Fonts**
  - JetBrainsMono Nerd Font

### 🚀 Features
- **Intelligente Snapshots**
  - Snapper für `/` und `/home`
  - Schlanke Aufbewahrungsregeln

- **Mise Integration**
  - Installiert automatisch die neueste Node.js-Version
  - Shell-Aktivierung inklusive

- **Btrfs Subvolume Shield**
  - Verhindert aufgeblähte Snapshots durch Caches
  - Nutzt verschachtelte Subvolumes

- **Multi-Shell Support**
  - Fish, Bash & Zsh
  - Starship + mise vorkonfiguriert

### 🧩 Installation

#### Einzeiler (empfohlen)
```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/feddev-setup.sh)
```

#### Alternative: Klonen & Ausführen
```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git ~/fedora-dev-bootstrap
cd ~/fedora-dev-bootstrap
chmod +x feddev-setup.sh
./feddev-setup.sh
```

### 🧪 Nach der Installation
- Terminal neu starten (Fish + Starship aktiv)
- `mise ls` ausführen, um installierte Runtimes zu sehen
- `nvim` starten, um die Dotfile-Konfiguration zu laden

---

## 📘 License
MIT License © JeromeTDev
