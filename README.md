# Fedora Dev Bootstrap

#### Deutsch

Automatisiertes Setup für Fedora, das eine minimale GNOME-Entwicklungsumgebung mit allen nötigen Entwickler-Tools, Lua 5.1, LuaRocks, pdflatex, Mermaid CLI und LazyVim einrichtet. Dieses Repository ist öffentlich und enthält nur sichere, allgemein nutzbare Konfigurationen.

#### English

Automated setup for Fedora that configures a minimal GNOME development environment with all necessary developer tools, Lua 5.1, LuaRocks, pdflatex, Mermaid CLI, and LazyVim. This repository is public and contains only safe, generally usable configurations.

---

## Features / Funktionen

- **System-Optimierung:**
  - Systemupdate & DNF Performance-Tuning
- **Kern-Tools & Shell:**
  - Terminal & Shell: `kitty`, `fish`, `starship`
  - Utilities: `fzf`, `tree`, `ripgrep`, `btop`, `neofetch`, `zoxide`, `fd-find`
  - Fonts: JetBrains Mono Nerd Font
- **Entwicklungsumgebung:**
  - Compiler & Build: `git`, `lazygit`, `clang`, `gcc`, `cmake`, `make`
  - Laufzeiten: `nodejs`, `python3`, `lua 5.1` & `luarocks`
  - LaTeX: `pdflatex` über `texlive-scheme-basic`
  - Mermaid CLI: `mmdc` über npm
- **Neovim/LazyVim Integration:**
  - Installation von `neovim`
  - Node.js & Python Provider für Neovim
  - LazyVim Plugins werden beim ersten Start automatisch installiert
  - Snacks.image wird automatisch aktiviert, falls vorhanden
- **Konfiguration:**
  - Starship Prompt für Fish Shell aktiviert
  - Kitty als Standard-Terminal
  - Robustes Stow-Deploy der öffentlichen Dotfiles
- **Extras:**
  - Flatpak & Flathub eingerichtet
  - Optional: Entfernt überflüssige GNOME-Apps

---

## Installation / Installation

**Ein Schritt / One-Step Setup:**

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/setup.sh)
```
PopOs:
```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/popos-setup.sh)
```

### Alternative: Clone + Ausführen / Clone & Run

```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git ~/fedora-dev-bootstrap
cd ~/fedora-dev-bootstrap
chmod +x setup.sh
./setup.sh
```

## Nach der Installation / After installation

- Starship wird automatisch beim Start von Fish geladen.
- LazyVim Plugins werden beim ersten Start von Neovim installiert.
- Öffentliche Dotfiles werden via Stow deployed.
  /
- Starship is automatically loaded when Fish starts.
- LazyVim plugins are installed automatically on first Neovim start.
- Public dotfiles are deployed via Stow.
