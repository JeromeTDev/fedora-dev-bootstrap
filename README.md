# FedDev

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Fedora](https://img.shields.io/badge/Fedora-Btrfs-blue.svg)](https://getfedora.org/)

> **Status: Wird erweitert** – Das Projekt wird gerade auf ein **Ansible-basiertes Setup** umgebaut.  
> Das originale Bash-Script findet sich unter [`legacy/feddev-setup.sh`](legacy/feddev-setup.sh) und kann weiterhin genutzt werden.

A **fully automated Fedora developer bootstrap** for power users who want  
a **clean Btrfs layout**, **lean snapshots**, and a **ready-to-use dev environment**  
without manual post-install fiddling.

Designed to be run **once on a fresh Fedora system**.  
![Fedora Dev Bootstrap – Terminal](https://github.com/user-attachments/assets/58df73b9-9492-4b25-9bbd-38b9af24d120))

---

## Was das macht

- Optimiert Fedora fuer **Btrfs + Snapper**
- Schliesst Caches & Toolchains von Snapshots aus
- Installiert ein modernes **Developer Toolchain**
- Richtet **mise** fuer Runtime-Management ein
- Deployt **Dotfiles automatisch**
- Hinterlaesst ein sauberes, rollback-faehiges System

---

## Voraussetzungen

- Fedora Linux (Workstation oder Minimal)
- Btrfs als Root-Filesystem
- Frische Installation empfohlen
- Aktive Internetverbindung
- sudo-Zugang

> Warnung: Nicht fuer stark angepasste oder laenger laufende Systeme gedacht.

---

## Installation

### One-liner (empfohlen)

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/legacy/feddev-setup.sh)
```

### Alternative: Clone & Run

```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git
cd fedora-dev-bootstrap
chmod +x legacy/feddev-setup.sh
./legacy/feddev-setup.sh
```

---

## Was wird installiert?

### System & Filesystem

- Btrfs-Subvolumes mit NO-COW:
  - ~/.cache
  - /var/cache
  - /var/tmp
  - ~/.local/share/mise
- Snapper mit schlanken Snapshot-Policies
- btrfs-assistant fuer GUI-Snapshot-Management

### Developer Toolchain

- git, gh
- gcc, clang
- make, cmake
- python3
- lua 5.1 + luarocks
- jq, fd, ripgrep, ncdu

### Shell, Editor & Terminal

- fish (Default Shell)
- starship prompt
- kitty terminal
- LazyVim

### CLI Utilities

- fzf, zoxide, btop, lazygit, yazi, fastfetch

### Flatpak Apps

- Discord, Obsidian, Cryptomator, TeamSpeak, Extension Manager

### Runtime Management

- mise mit globalen Node.js
- Shell-Aktivierung fuer Fish, Bash & Zsh

### Fonts

- JetBrainsMono Nerd Font

### Dotfiles

- Automatisches Deployment via GNU Stow

---

## Wichtige Hinweise

- Aendert das Filesystem-Layout
- Fuer frische Fedora-Installationen gedacht
- Dotfiles werden mit stow --adopt deployed
- Vorhandene Configs koennen ueberschrieben werden

Lies das Script vor dem Ausfuehren durch, wenn du unsicher bist.

---

## License

MIT License
(c) JeromeTDev
