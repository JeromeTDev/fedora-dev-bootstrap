set -g fish_greeting

if status is-interactive
    # Android SDK
    set -gx ANDROID_SDK_ROOT $HOME/Android/Sdk
    set -gx PATH $ANDROID_SDK_ROOT/emulator $ANDROID_SDK_ROOT/platform-tools $PATH

    # LM Studio CLI
    set -gx PATH $PATH $HOME/.lmstudio/bin

    # opencode
    fish_add_path $HOME/.opencode/bin

    # Kitty Remote Control
    set -gx KITTY_LISTEN_ON /tmp/kitty

    # fzf Vi-Mode aktivieren
    set -x FZF_DEFAULT_OPTS "--bind 'h:up,j:down,k:up,l:accept' --reverse"
    set -x FZF_TMUX 0
    set -x FZF_DEFAULT_COMMAND 'find .'
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# =====
# Aliases
# =====

# Snapshot-Management
alias snls="sudo snapper ls" # Alle Root-Snapshots listen
alias snls-home="sudo snapper -c home ls" # Alle Home-Snapshots listen
alias sn-create="sudo snapper create --description" # Schneller Snapshot vor Experimenten
alias sn-space="sudo btrfs filesystem du -s --human-readable /.snapshots /home/.snapshots"

# Speicherplatz-Check (Btrfs-spezifisch)
alias btop-du="sudo btrfs filesystem du -s -x --human-readable"
alias v="nvim" # Neovim als Standard-Editor
alias lg="lazygit" # Git im Terminal
alias fast="fastfetch"

alias ld="lazydocker"
alias dcd="docker compose -f docker/compose.yml"

alias dev="cd ~/dev"
alias dot="cd ~/.local/share/fedora-dev-bootstrap/dotfiles" # Dotfiles-Repo
alias c="clear"

starship init fish | source
mise activate fish | source

fish_add_path --prepend ~/.npm-global/bin
