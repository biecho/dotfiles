#!/bin/bash
# =============================================================================
# macOS Install Script
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "Installing dotfiles for macOS..."
echo ""

# -----------------------------------------------------------------------------
# Install Homebrew + packages
# -----------------------------------------------------------------------------
install_deps() {
    echo "==> Checking Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "==> Installing packages..."
    brew install starship      # prompt
    brew install zoxide        # smart cd
    brew install fzf           # fuzzy finder
    brew install neovim        # editor
    brew install lazygit       # git TUI
    brew install ripgrep       # fast grep
    brew install fd            # fast find
    brew install eza           # modern ls
    brew install imagemagick   # image.nvim dependency
    brew install git-delta     # syntax-highlighted git diffs
    brew install atuin         # better shell history
    brew install bat           # modern cat with syntax highlighting
    brew install btop          # modern top/htop
    brew install tlrc          # tldr pages (simplified man pages)
    brew install yazi ffmpegthumbnailer unar  # file manager + preview deps
    brew install glow                         # markdown preview for yazi
    brew install just                         # command runner
    brew install dust                         # modern du (disk usage)
    brew install duf                          # modern df (disk free)

    # Window management
    brew install --cask nikitabobko/tap/aerospace  # tiling window manager
    brew install FelixKratz/formulae/borders       # window borders

    # Set up fzf key bindings
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish

    if ! command -v ghostty &> /dev/null; then
        echo ""
        echo "Note: Install Ghostty manually from https://ghostty.org"
    fi
}

# -----------------------------------------------------------------------------
# Backup existing configs
# -----------------------------------------------------------------------------
backup_existing() {
    echo "==> Backing up existing configs..."
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$backup_dir/"
    [[ -f "$HOME/.config/starship.toml" ]] && cp "$HOME/.config/starship.toml" "$backup_dir/"
    [[ -d "$HOME/.config/ghostty" ]] && cp -r "$HOME/.config/ghostty" "$backup_dir/"
    [[ -d "$HOME/.config/kitty" ]] && cp -r "$HOME/.config/kitty" "$backup_dir/"
    [[ -f "$HOME/.config/karabiner/karabiner.json" ]] && cp "$HOME/.config/karabiner/karabiner.json" "$backup_dir/"
    [[ -f "$HOME/.gitconfig" ]] && cp "$HOME/.gitconfig" "$backup_dir/"

    echo "   Backup saved to: $backup_dir"
}

# -----------------------------------------------------------------------------
# Create symlinks
# -----------------------------------------------------------------------------
create_symlinks() {
    echo "==> Creating symlinks..."

    ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    echo "   ~/.zshrc"

    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
    echo "   ~/.config/starship.toml"

    mkdir -p "$HOME/.config/ghostty"
    ln -sf "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
    echo "   ~/.config/ghostty/config"

    mkdir -p "$HOME/.config/kitty"
    ln -sfn "$DOTFILES_DIR/kitty/themes" "$HOME/.config/kitty/themes"
    ln -sf "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    ln -sf "$DOTFILES_DIR/kitty/current-theme.conf" "$HOME/.config/kitty/current-theme.conf"
    ln -sf "$DOTFILES_DIR/kitty/ssh.conf" "$HOME/.config/kitty/ssh.conf"
    ln -sf "$DOTFILES_DIR/kitty/tab_bar.py" "$HOME/.config/kitty/tab_bar.py"
    echo "   ~/.config/kitty/{kitty.conf,current-theme.conf,ssh.conf,tab_bar.py}"

    # Neovim config (backup existing, then symlink entire directory)
    if [[ -d "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup"
        echo "   Backed up existing nvim config to ~/.config/nvim.backup"
    fi
    ln -sfn "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    echo "   ~/.config/nvim"

    # Git config (symlink entire config, hooks handled via hooksPath in config)
    ln -sf "$DOTFILES_DIR/git/config" "$HOME/.gitconfig"
    mkdir -p "$HOME/.config/git/hooks"
    ln -sf "$DOTFILES_DIR/git/hooks/prepare-commit-msg" "$HOME/.config/git/hooks/prepare-commit-msg"
    echo "   ~/.gitconfig"
    echo "   ~/.config/git/hooks (global git hooks)"

    # Lazygit config (for delta integration)
    # macOS uses ~/Library/Application Support/lazygit/
    mkdir -p "$HOME/Library/Application Support/lazygit"
    ln -sf "$DOTFILES_DIR/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
    echo "   ~/Library/Application Support/lazygit/config.yml"

    # Yazi config (file manager)
    mkdir -p "$HOME/.config/yazi"
    ln -sf "$DOTFILES_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
    ln -sf "$DOTFILES_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
    ln -sf "$DOTFILES_DIR/yazi/init.lua" "$HOME/.config/yazi/init.lua"
    ln -sf "$DOTFILES_DIR/yazi/package.toml" "$HOME/.config/yazi/package.toml"
    echo "   ~/.config/yazi/{yazi.toml,keymap.toml,init.lua,package.toml}"
    # Install yazi plugins
    if command -v ya &> /dev/null; then
        ya pkg install 2>/dev/null || true
    fi

    # Karabiner Elements
    mkdir -p "$HOME/.config/karabiner"
    ln -sf "$DOTFILES_DIR/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
    echo "   ~/.config/karabiner/karabiner.json"

    # AeroSpace (tiling window manager)
    ln -sfn "$DOTFILES_DIR/aerospace" "$HOME/.config/aerospace"
    echo "   ~/.config/aerospace"

    # JankyBorders (window borders)
    ln -sfn "$DOTFILES_DIR/borders" "$HOME/.config/borders"
    echo "   ~/.config/borders"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    read -p "Install Homebrew packages? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_deps
    fi

    echo ""
    backup_existing

    echo ""
    create_symlinks

    echo ""
    echo "============================================="
    echo "  Done!"
    echo "============================================="
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal (or: source ~/.zshrc)"
    echo "  2. Zinit will auto-install plugins on first run"
    echo "  3. Start borders: brew services start borders"
    echo "  4. Log out and back in to start AeroSpace"
    echo ""
}

main "$@"
