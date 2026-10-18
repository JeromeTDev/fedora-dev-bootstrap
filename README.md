# FedDev

[![Fedora Developer Bootstrap](https://img.shields.io/badge/Fedora%20Developer%20Bootstrap-Fedora-blue.svg)](https://getfedora.org/)
[![Ansible](https://img.shields.io/badge/Ansible-ee-blue.svg)](https://www.ansible.com/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Ein **vollautomatischer Fedora-Developer-Bootstrap** auf **Ansible**-Basis –
gedacht für die **einmalige** Ausführung auf einer frischen Fedora-Installation.

System-Setup, Pakete, Schriften, Flatpak-Apps, mise-Runtimes und per **GNU Stow**
deployte **Dotfiles** (Fish, Neovim/LazyVim, tmux, Yazi, Kitty/Ghostty, Sway u. v. m.).

## ![Fedora Dev Bootstrap – Terminal](https://github.com/user-attachments/assets/58df73b9-9492-4b25-9bbd-38b9af24d120)

## Installation

Voraussetzung: Fedora Linux (Workstation oder Minimal), getestet auf **Fedora 44**.

```bash
sudo dnf install -y ansible-core git

git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git
cd fedora-dev-bootstrap

ansible-galaxy collection install -r requirements.yml # einmalig: copr + flatpak
ansible-playbook playbook.yml -K
```

Ohne `inventory.ini` ist der Rechner, auf dem du das Playbook startest, das Ziel.
Für eine andere Maschine:

```bash
cp inventory.ini.example inventory.ini
$EDITOR inventory.ini          # Gruppe muss "fedora" heißen
ansible-playbook playbook.yml -K
```

```ini
[fedora]
fedora-vm ansible_host=192.168.1.xxx ansible_user=InsertUserName
```

Die `inventory.ini` wird über `ansible.cfg` automatisch erkannt und ist in
`.gitignore`, wird also nie mit committet.

Gut zu wissen:

- `-K` fragt das sudo-Passwort ab; bei passwortlosem sudo entfällt es. Nach ~15 Min.
  ohne sudo-Timestamp bricht der Play beim ersten `become`-Task ab (vorher `sudo -v`)
- `--check --diff` zeigt nur, was passieren würde
- das Playbook ist idempotent, ein zweiter Lauf ist unkritisch
- gesetzt werden **Fish als Standard-Shell** und die Dotfiles per `stow --adopt`

## Tools

Alles Anpassbare liegt in [`group_vars/fedora.yml`](group_vars/fedora.yml).

| Kategorie          | Quelle               | Tools                                                                                                             |
| ------------------ | -------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Dev & Build        | Fedora               | `git`, `gh`, `make`, `gcc`, `luarocks`, `texlive-scheme-medium`                                                   |
| Shell & Editor     | Fedora               | `fish` (Default-Shell), `neovim` (LazyVim), `tmux`                                                                |
| CLI                | Fedora               | `fzf`, `zoxide`, `btop`, `tree`, `ripgrep`, `fd-find`, `jq`, `ncdu`, `stow`, `fastfetch`                          |
| Medien & PDF       | Fedora               | `ImageMagick`, `mediainfo`, `perl-Image-ExifTool`, `poppler-utils`, `zathura`, `zathura-pdf-mupdf`                |
| Desktop            | Fedora               | `dolphin`, `gammastep`, `xournalpp`, `wl-clipboard`, `keepassxc`                                                  |
| Prompt & Terminals | COPR                 | `starship`, `lazygit`, `yazi`, `ghostty`                                                                          |
| Window Manager     | COPR – nur wenn Sway | `rofi`, `mako`, `swayfx` (ersetzt `sway` und `sway-systemd`)                                                      |
| Apps               | Flatpak, systemweit  | Discord, Obsidian, Cryptomator, TeamSpeak, ONLYOFFICE, Telegram, Signal                                           |
| Schriften          | GitHub-Release       | JetBrainsMono Nerd Font → `~/.local/share/fonts`                                                                  |
| Runtimes           | mise                 | `python`, `rust`, `uv`, `opencode`                                                                               |
| System             | DNF                  | `fastestmirror`, 15 Paralleldownloads, `defaultyes`, keine weak-deps, `clean_requirements_on_remove`, `plugins=1` |

Zusätzlich läuft ein vollständiges `dnf upgrade`. Die Runtimes kommen aus
[`dotfiles/.config/mise/config.toml`](dotfiles/.config/mise/config.toml); gibt es
die Datei nicht, greift `mise_tools` aus `group_vars/fedora.yml`.

## Dotfiles

Die mitgelieferten Configs liegen unter [`dotfiles/`](dotfiles) und werden beim
ersten Lauf nach `~/.dotfiles` kopiert und von dort in dein Home verlinkt:

```
dotfiles/  ->  ~/.dotfiles  --stow .-->  ~/.config/...
```

- Ein **vorhandenes** `~/.dotfiles` wird nie angefasst – deine Dotfiles gewinnen
- Gibt es den Ordner `dotfiles/` nicht, wird nichts gestowt: lege deine eigenen
  Dotfiles unter `~/.dotfiles` ab und führe das Playbook erneut aus
- Jeder Top-Level-Eintrag wird einzeln verlinkt (`.config`, `.local`, `.gitconfig`, …);
  ein vorhandenes echtes Verzeichnis wie `~/.config` wird dabei **nicht** ersetzt,
  sondern mit `--adopt` hinein gemischt

Eigene Dotfiles, die woanders liegen, vor dem ersten Lauf nach `~/.dotfiles`
umziehen, sonst zeigen die alten Symlinks ins Leere:

```bash
git clone git@github.com:dein-user/private-dotfiles.git ~/.dotfiles
```

Pfade sind in [`roles/dotfiles/defaults/main.yml`](roles/dotfiles/defaults/main.yml)
überschreibbar (`dotfiles_dir`, `dotfiles_src`, `dotfiles_stow_target`).

> **Achtung:** `--adopt` übernimmt vorhandene Dateien (z. B. ein vom Desktop
> angelegtes `~/.config/fontconfig/fonts.conf`) – vorher ggf. sichern. Und `stow .`
> niemals auf das **Repo-Root** anwenden, sonst landen `roles/` und `playbook.yml`
> in deinem Home.

**tmux-Plugins** sind nicht mitgeliefert (siehe [`.gitignore`](.gitignore)); `TPM`
installiert sie beim ersten `Prefix + I`, manuell:

```bash
git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins
```

## Updates

[`update.sh`](update.sh) aktualisiert DNF, mise und Flatpak in einem Durchgang:

```bash
./update.sh
```

---

Altes Bash-Script mit Btrfs-/Snapper-Strategie: [`legacy/feddev-setup.sh`](legacy/feddev-setup.sh)
– historische Referenz, nicht Teil des Ansible-Setups und nicht mehr gepflegt.

## License

MIT License – (c) JeromeTDev