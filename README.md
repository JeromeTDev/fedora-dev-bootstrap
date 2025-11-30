# Fedora Dev Bootstrap

[🇩🇪 Deutsch](#deutsch) | [🇺🇸 English](#english)  

---

## **Deutsch** <a name="deutsch"></a>

Automatisiertes Setup für **Fedora**, das eine minimale GNOME-Entwicklungsumgebung einrichtet. Enthalten sind alle nötigen Entwickler-Tools, **Lua 5.1**, **LuaRocks**, **pdflatex**, **Mermaid CLI** und **LazyVim**. Dieses Repository ist öffentlich und enthält nur sichere, allgemein nutzbare Konfigurationen.

### **Features / Funktionen**

- **System-Optimierung:**
  - Systemupdate & DNF Performance-Tuning
- **Kern-Tools & Shell:**
  - Terminal & Shell: `kitty`, `fish`, `starship`
  - Utilities: `fzf`, `tree`, `ripgrep`, `btop`, `neofetch`, `zoxide`, `fd-find`
  - Fonts: JetBrains Mono Nerd Font
- **Entwicklungsumgebung:**
  - Compiler & Build-Tools: `git`, `lazygit`, `clang`, `gcc`, `cmake`, `make`
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

### **Installation**

**Ein Schritt / One-Step Setup:**

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/setup.sh)
```

Pop!_OS Variante:  

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/popos-setup.sh)
```

**Alternative: Clone + Ausführen**

```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git ~/fedora-dev-bootstrap
cd ~/fedora-dev-bootstrap
chmod +x setup.sh
./setup.sh
```

### **Nach der Installation**

- Starship wird automatisch beim Start von Fish geladen.  
- LazyVim Plugins werden beim ersten Start von Neovim installiert.  
- Öffentliche Dotfiles werden via Stow deployed.  

---

## **English** <a name="english"></a>

Automated setup for **Fedora** that configures a minimal GNOME development environment with all necessary developer tools, **Lua 5.1**, **LuaRocks**, **pdflatex**, **Mermaid CLI**, and **LazyVim**. This repository is public and contains only safe, generally usable configurations.

### **Features**

- **System Optimization:**
  - System update & DNF performance tuning
- **Core Tools & Shell:**
  - Terminal & Shell: `kitty`, `fish`, `starship`
  - Utilities: `fzf`, `tree`, `ripgrep`, `btop`, `neofetch`, `zoxide`, `fd-find`
  - Fonts: JetBrains Mono Nerd Font
- **Development Environment:**
  - Compiler & Build Tools: `git`, `lazygit`, `clang`, `gcc`, `cmake`, `make`
  - Runtimes: `nodejs`, `python3`, `lua 5.1` & `luarocks`
  - LaTeX: `pdflatex` via `texlive-scheme-basic`
  - Mermaid CLI: `mmdc` via npm
- **Neovim/LazyVim Integration:**
  - Installs `neovim`
  - Node.js & Python providers for Neovim
  - LazyVim plugins auto-installed on first start
  - Snacks.image auto-enabled if available
- **Configuration:**
  - Starship prompt enabled for Fish shell
  - Kitty as default terminal
  - Public dotfiles deployed via Stow
- **Extras:**
  - Flatpak & Flathub setup
  - Optional: removes unnecessary GNOME apps

### **Installation**

**One-Step Setup:**

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/setup.sh)
```

Pop!_OS variant:  

```bash
bash <(curl -s https://raw.githubusercontent.com/JeromeTDev/fedora-dev-bootstrap/main/popos-setup.sh)
```

**Alternative: Clone & Run**

```bash
git clone https://github.com/JeromeTDev/fedora-dev-bootstrap.git ~/fedora-dev-bootstrap
cd ~/fedora-dev-bootstrap
chmod +x setup.sh
./setup.sh
```

### **After Installation**

- Starship auto-loads when Fish starts.  
- LazyVim plugins installed on first Neovim start.  
- Public dotfiles deployed via Stow.  

