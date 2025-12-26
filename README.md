# Fedora Dev Bootstrap Pro

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Fedora](https://img.shields.io/badge/Fedora-Btrfs-blue.svg)](https://getfedora.org/)


A **fully automated Fedora developer bootstrap** for power users who want  
a **clean Btrfs layout**, **lean snapshots**, and a **ready-to-use dev environment**  
without manual post-install fiddling.

Designed to be run **once on a fresh Fedora system**.

---

## ✨ What this does

- Optimizes Fedora for **Btrfs + Snapper**
- Excludes caches & toolchains from snapshots
- Installs a modern **developer toolchain**
- Sets up **mise** for runtime management
- Deploys **dotfiles automatically**
- Leaves you with a clean, rollback-capable system

---

## 🧩 Requirements

- Fedora Linux (Workstation or minimal)
- Btrfs as root filesystem
- Fresh installation recommended
- Active internet connection
- sudo access

> ⚠️ Not intended for heavily customized or long-running systems.

---

## 📦 What gets installed

### 🧱 System & Filesystem
- Btrfs subvolumes with NO-COW:
  - ~/.cache
  - /var/cache
  - /var/tmp
  - ~/.local/share/mise
- Snapper with lean snapshot policies
- btrfs-assistant for GUI snapshot management

### 🛠 Developer Toolchain
- git, gh
- gcc, clang
- make, cmake
- python3
- lua 5.1 + luarocks
- jq, fd, ripgrep, ncdu

### 🧑‍💻 Shell, Editor & Terminal
- fish (default shell)
- starship prompt
- kitty terminal
- Neovim (LazyVim-ready)

### 🧰 CLI Utilities
- fzf
- zoxide
- btop
- lazygit
- yazi
- fastfetch

### 📦 Flatpak Apps
- Discord
- Obsidian
- Cryptomator
- TeamSpeak
- Caffeine
- Extension Manager

### 🔧 Runtime Management
- mise
  - Global latest Node.js installed
  - Shell activation for Fish, Bash & Zsh
  - Own Btrfs subvolume (snapshot-excluded)

### 🎨 Fonts
- JetBrainsMono Nerd Font

### 🗂 Dotfiles
- Automatic deployment via GNU Stow

---

## 🚀 Features in Detail

### 🧠 Smart Snapshots
- Root (/)
  - Daily snapshots only
  - DNF plugin handles transactional snapshots
- Home (/home)
  - Short-lived hourly & daily snapshots
- User access enabled (ALLOW_USERS)

### 🛡 Snapshot Shield
Cache-heavy paths are isolated into separate subvolumes so that:
- Snapshots stay small
- Rollbacks are fast
- Toolchains don’t pollute history

### 🐚 Multi-Shell Support
- Fish (default)
- Bash
- Zsh  
Starship & mise activation injected automatically.

---

## 🧩 Installation

### One-liner (recommended)

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/feddev-setup.sh)
```

### Alternative: Clone & Run

```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git
cd fedora-dev-bootstrap
chmod +x feddev-setup.sh
./feddev-setup.sh
```

---

## 🧪 After Installation

- Restart your terminal
- Fish + Starship should be active
- Verify runtimes:
```bash
mise ls
```
- Open Neovim:
```bash
nvim
```
- Snapshots:
  - /.snapshots
  - /home/.snapshots

---

## ⚠️ Important Notes

- Modifies filesystem layout
- Intended for fresh Fedora installs
- Dotfiles deployed using stow --adopt
- Existing configs may be overwritten

Read the script before running if unsure.

---

## 📘 License

MIT License  
© JeromeTDev
