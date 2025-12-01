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
    ln -sf "$DOTFILES_DIR/kitty/ssh.conf" "$HOME/.config/kitty/ssh.conf"
    echo "   ~/.config/kitty/{kitty.conf,ssh.conf}"

    # Neovim config (backup existing, then symlink entire directory)
    if [[ -d "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup"
        echo "   Backed up existing nvim config to ~/.config/nvim.backup"
    fi
    ln -sfn "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    echo "   ~/.config/nvim"

    # Global git hooks
    mkdir -p "$HOME/.config/git/hooks"
    ln -sf "$DOTFILES_DIR/git/hooks/prepare-commit-msg" "$HOME/.config/git/hooks/prepare-commit-msg"
    git config --global core.hooksPath "$HOME/.config/git/hooks"
    echo "   ~/.config/git/hooks (global git hooks)"
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
    echo "  3. Reload Ghostty: Cmd+Shift+,"
    echo ""
}

main "$@"
