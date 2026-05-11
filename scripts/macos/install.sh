#!/bin/bash
# =============================================================================
# macOS Install Script
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

echo "Installing dotfiles for macOS..."
echo ""

# -----------------------------------------------------------------------------
# Install Homebrew + packages from Brewfile
# -----------------------------------------------------------------------------
install_deps() {
    echo "==> Checking Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "==> Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"

    # Set up fzf key bindings
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish

    # Install Python CLI tools via pipx
    echo "==> Installing Python CLI tools via pipx..."
    if ! command -v huggingface-cli &> /dev/null; then
        pipx install huggingface_hub
    fi
    if ! command -v nvitop &> /dev/null; then
        pipx install nvitop
    fi
}

# -----------------------------------------------------------------------------
# Backup existing configs
# -----------------------------------------------------------------------------
backup_existing() {
    echo "==> Backing up existing configs..."
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    local needs_backup=false

    for f in "$HOME/.zshrc" "$HOME/.config/starship.toml" "$HOME/.config/karabiner/karabiner.json" "$HOME/.gitconfig"; do
        [[ -f "$f" && ! -L "$f" ]] && needs_backup=true && break
    done
    [[ -d "$HOME/.config/kitty" && ! -L "$HOME/.config/kitty/kitty.conf" ]] && needs_backup=true

    if $needs_backup; then
        mkdir -p "$backup_dir"
        for f in "$HOME/.zshrc" "$HOME/.config/starship.toml" "$HOME/.config/karabiner/karabiner.json" "$HOME/.gitconfig"; do
            [[ -f "$f" && ! -L "$f" ]] && cp "$f" "$backup_dir/"
        done
        [[ -d "$HOME/.config/kitty" && ! -L "$HOME/.config/kitty/kitty.conf" ]] && cp -r "$HOME/.config/kitty" "$backup_dir/"
        echo "   Backup saved to: $backup_dir"
    else
        echo "   Nothing to back up (already symlinked or absent)"
    fi
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

    mkdir -p "$HOME/.config/kitty"
    ln -sfn "$DOTFILES_DIR/kitty/themes" "$HOME/.config/kitty/themes"
    ln -sf "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    ln -sf "$DOTFILES_DIR/kitty/current-theme.conf" "$HOME/.config/kitty/current-theme.conf"
    ln -sf "$DOTFILES_DIR/kitty/ssh.conf" "$HOME/.config/kitty/ssh.conf"
    ln -sf "$DOTFILES_DIR/kitty/tab_bar.py" "$HOME/.config/kitty/tab_bar.py"
    ln -sf "$DOTFILES_DIR/kitty/choose-files.conf" "$HOME/.config/kitty/choose-files.conf"
    echo "   ~/.config/kitty/{kitty.conf,current-theme.conf,ssh.conf,tab_bar.py,choose-files.conf}"

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
    for hook in "$DOTFILES_DIR"/git/hooks/*; do
        [[ -f "$hook" ]] || continue
        ln -sf "$hook" "$HOME/.config/git/hooks/$(basename "$hook")"
    done
    echo "   ~/.gitconfig"
    echo "   ~/.config/git/hooks (global git hooks)"

    # Lazygit config (for delta integration)
    # macOS uses ~/Library/Application Support/lazygit/
    mkdir -p "$HOME/Library/Application Support/lazygit"
    ln -sf "$DOTFILES_DIR/lazygit/config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
    echo "   ~/Library/Application Support/lazygit/config.yml"

    # Tmux
    ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
    echo "   ~/.tmux.conf"

    # Yazi config (file manager)
    mkdir -p "$HOME/.config/yazi"
    ln -sf "$DOTFILES_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
    ln -sf "$DOTFILES_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
    ln -sf "$DOTFILES_DIR/yazi/init.lua" "$HOME/.config/yazi/init.lua"
    ln -sf "$DOTFILES_DIR/yazi/package.toml" "$HOME/.config/yazi/package.toml"
    echo "   ~/.config/yazi/{yazi.toml,keymap.toml,init.lua,package.toml}"
    # Install yazi plugins
    if command -v ya &> /dev/null; then
        ya pack -i 2>/dev/null || true
    fi

    # Karabiner Elements
    mkdir -p "$HOME/.config/karabiner"
    ln -sf "$DOTFILES_DIR/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
    echo "   ~/.config/karabiner/karabiner.json"

    # IdeaVim (JetBrains Vim emulation)
    if [[ -f "$DOTFILES_DIR/ideavim/ideavimrc" ]]; then
        ln -sf "$DOTFILES_DIR/ideavim/ideavimrc" "$HOME/.ideavimrc"
        echo "   ~/.ideavimrc"
    fi

    # YouTube TUI
    mkdir -p "$HOME/.config/youtube-tui"
    ln -sf "$DOTFILES_DIR/youtube-tui/main.yml" "$HOME/.config/youtube-tui/main.yml"
    echo "   ~/.config/youtube-tui/main.yml"
}

# -----------------------------------------------------------------------------
# Install required dependencies for Neovim plugins
# -----------------------------------------------------------------------------
install_nvim_deps() {
    echo "==> Installing Neovim plugin dependencies..."

    # markdown-preview.nvim dependencies
    local mkdp_dir="$HOME/.local/share/nvim/lazy/markdown-preview.nvim/app"
    if [[ -d "$mkdp_dir" && ! -f "$mkdp_dir/bin/markdown-preview-macos" ]]; then
        echo "   Installing markdown-preview.nvim dependencies..."
        cd "$mkdp_dir" && ./install.sh
        cd - > /dev/null
    fi

    echo ""
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
    install_nvim_deps

    # Optional: VSCode config
    read -p "Install VSCode configuration? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        "$DOTFILES_DIR/vscode/install.sh"
    fi

    # Optional: Termusic config
    read -p "Install Termusic configuration? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        "$DOTFILES_DIR/termusic/install.sh"
    fi

    # Optional: Claude Code
    read -p "Install Claude Code (Node.js + fnm)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        "$SCRIPTS_DIR/install-claude.sh"
    fi

    echo ""
    echo "============================================="
    echo "  Done!"
    echo "============================================="
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal (or: source ~/.zshrc)"
    echo "  2. Zinit will auto-install plugins on first run"
    echo ""
}

main "$@"
