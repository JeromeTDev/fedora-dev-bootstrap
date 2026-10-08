# FedDev

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Fedora](https://img.shields.io/badge/Fedora-Btrfs-blue.svg)](https://getfedora.org/)

Ein **vollautomatischer Fedora-Developer-Bootstrap** für Power-User: sauberes
**Btrfs-Layout**, schlanke **Snapper**-Snapshots und eine sofort einsatzbereite
**Dev-Umgebung** – gedacht für die **einmalige** Ausführung auf einer frischen
Fedora-Installation.

> **Inklusive Dotfiles:** Fish, Kitty/Ghostty, Sway, Neovim, tmux, Yazi u. v. m.
> liegen unter [`dotfiles/`](dotfiles) und werden per **GNU Stow** deployt.

![Fedora Dev Bootstrap – Terminal](https://github.com/user-attachments/assets/58df73b9-9492-4b25-9bbd-38b9af24d120)

---

## Status

Das Projekt wird auf ein **Ansible-basiertes Setup** umgebaut. Das vollständige
Bash-Script liegt weiterhin unter [`legacy/feddev-setup.sh`](legacy/feddev-setup.sh)
und ist aktuell der einzige **vollständige** Installationsweg.

| Rolle              | Status |
| ------------------ | ------ |
| `base`             | ✅ fertig |
| `packages`         | ✅ fertig |
| `sway`             | ✅ fertig (nur wenn Sway vorhanden) |
| `dnf`              | 🚧 geplant |
| `copr`             | 🚧 geplant |
| `btrfs`            | 🚧 geplant |
| `snapper`          | 🚧 geplant |
| `fonts`            | 🚧 geplant |
| `flatpak`          | 🚧 geplant |
| `mise`             | 🚧 geplant |
| `cache_redirects`  | 🚧 geplant |
| `shell`            | 🚧 geplant |
| `dotfiles`         | 🚧 geplant |

---

## Was das macht

- Optimiert Fedora für **Btrfs + Snapper** (NO-COW-Caches, Snapshot-Excludes)
- Installiert eine moderne **Developer-Toolchain**
- Richtet **mise** für Runtime-Management ein (Node, Lua, …)
- Deployt **Dotfiles automatisch** via GNU Stow
- Hinterlässt ein sauberes, **rollback-fähiges** System

---

## Voraussetzungen

- Fedora Linux (Workstation oder Minimal), aktuell getestet auf **Fedora 44**
- **Btrfs** als Root-Filesystem
- Frische Installation **empfohlen**
- Aktive Internetverbindung
- `sudo`-Zugang

> Warnung: Nicht für stark angepasste oder seit Langem laufende Systeme gedacht.
> Das Script ändert das Dateisystem-Layout und wird nur für frische Setups
> getestet.

---

## Installation

### One-liner (legacy, empfohlen)

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/legacy/feddev-setup.sh)
```

### Clone & Run (legacy)

```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git
cd fedora-dev-bootstrap
./legacy/feddev-setup.sh
```

### Ansible (in Arbeit)

Deckt bisher nur `base` und `packages` ab:

```bash
cp inventory.ini.example inventory.ini   # Host/User anpassen
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbook.yml
```

Host/User werden in der lokalen `inventory.ini` gesetzt (siehe
[`inventory.ini.example`](inventory.ini.example)).

---

## Was wird installiert?

### System & Filesystem

- Btrfs-Subvolumes mit NO-COW für `~/.cache`, `/var/cache`, `/var/tmp` und
  `~/.local/share/mise`
- Snapper mit schlanken Snapshot-Policies
- `btrfs-assistant` für GUI-Snapshot-Management

### Developer-Toolchain

- `git`, `gh`
- `gcc`, `clang`, `make`, `cmake`
- `python3`
- `lua` 5.1 + `luarocks`
- `jq`, `fd`, `ripgrep`, `ncdu`

### Shell, Editor & Terminal

- `fish` (Default-Shell), `starship`-Prompt
- `kitty` und `ghostty` als Terminals
- LazyVim (Neovim), `tmux` (mit TPM-Plugins)

### Desktop (Sway)

Die Sway-Configs (`sway`, `waybar`, `rofi`, `mako`, `swaybg`, …) werden per Stow
deployt; die Desktop-Pakete kommen i. d. R. vom **Fedora Sway Spin**.

Die Ansible-Rolle `sway` läuft **nur, wenn Sway installiert ist**, und
- installiert `rofi` + `mako` (im Spin nicht enthalten),
- ersetzt `sway` durch `swayfx` (SwayFX, `Provides: sway`).

> SwayFX ist ein Drop-in-Fork mit gleichem Config-Format. Das Bash-Script
> installiert **keine** Desktop-Pakete.

### CLI-Utilities

- `fzf`, `zoxide`, `btop`, `lazygit`, `yazi`, `fastfetch`

### Flatpak-Apps

- Discord, Obsidian, Cryptomator, TeamSpeak, Extension Manager

### Runtime-Management

- `mise` mit globalem Node.js und Shell-Aktivierung (Fish, Bash, Zsh)

### Fonts

- JetBrainsMono Nerd Font

### Dotfiles

- Deployment aller Configs via **GNU Stow** (siehe unten)

---

## Dotfiles

Alle geteilten Configs liegen im Unterordner [`dotfiles/.config/`](dotfiles/.config)
und werden per Stow nach `~/.config` verlinkt:

```bash
# Variante A: aus dem Repo-Root
stow --adopt -t "$HOME" dotfiles

# Variante B: direkt im dotfiles-Ordner
cd dotfiles && stow --adopt -t "$HOME" .
```

> Nicht `stow .` auf das **Repo-Root** anwenden – sonst landen `roles/`,
> `playbook.yml`, `inventory.ini` usw. im Home-Verzeichnis.

Verwaltete Configs (Auszug): `fish`, `kitty`, `ghostty`, `tmux`, `nvim`, `sway`,
`waybar`, `rofi`, `mako`, `btop`, `yazi`, `mise`, `zathura`, `fontconfig`,
`autostart`, `starship.toml`, `xdg-desktop-portal`.

**Nicht** im Repo (bewusst): jegliche persönliche oder geheime Konfiguration –
z. B. `keepassxc/`, `Cryptomator/`, `~/.gitconfig`, SSH-Keys oder MEGA-/Cloud-Pfade.
Diese Dateien müssen lokal bleiben.

**tmux-Plugins** werden nicht mitgeliefert (siehe [`.gitignore`](.gitignore));
das Deploy-Script installiert `tpm` und die Plugins nach `~/.tmux/plugins`.
Manuell: `~/.tmux/plugins/tpm/bin/install_plugins` oder in tmux `Prefix + I`.

---

## Wichtige Hinweise

- Ändert das **Filesystem-Layout** (Btrfs-Subvolumes, Snapper)
- Für **frische** Fedora-Installationen gedacht
- Dotfiles werden mit `stow --adopt` deployed – **vorhandene Configs können
  überschrieben bzw. übernommen werden**
- Lest das Script vor dem Ausführen durch, wenn ihr unsicher seid

---

## License

MIT License – (c) JeromeTDev