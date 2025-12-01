#!/bin/bash
# =============================================================================
# Linux Install Script (no sudo required)
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOCAL_BIN="$HOME/.local/bin"

echo "Installing dotfiles for Linux..."
echo ""

# -----------------------------------------------------------------------------
# Install binaries to ~/.local/bin
# -----------------------------------------------------------------------------
install_bins() {
    echo "==> Installing binaries to ~/.local/bin..."
    mkdir -p "$LOCAL_BIN"

    # Neovim
    if ! command -v nvim &> /dev/null; then
        echo "   Installing neovim..."
        curl -sL https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage \
            -o "$LOCAL_BIN/nvim"
        chmod +x "$LOCAL_BIN/nvim"
    fi

    # fzf
    if ! command -v fzf &> /dev/null; then
        echo "   Installing fzf..."
        FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | grep -Po '"tag_name": "v?\K[^"]*')
        curl -sL "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz" \
            | tar xz -C "$LOCAL_BIN"
    fi

    # ripgrep
    if ! command -v rg &> /dev/null; then
        echo "   Installing ripgrep..."
        RG_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep -Po '"tag_name": "\K[^"]*')
        curl -sL "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/rg'
    fi

    # fd
    if ! command -v fd &> /dev/null; then
        echo "   Installing fd..."
        FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
        curl -sL "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/fd'
    fi

    # eza
    if ! command -v eza &> /dev/null; then
        echo "   Installing eza..."
        EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
        curl -sL "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-musl.tar.gz" \
            | tar xz -C "$LOCAL_BIN"
    fi

    # lazygit
    if ! command -v lazygit &> /dev/null; then
        echo "   Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
        curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
            | tar xz -C "$LOCAL_BIN" lazygit
    fi

    # starship
    if ! command -v starship &> /dev/null; then
        echo "   Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$LOCAL_BIN" -y
    fi

    # zoxide
    if ! command -v zoxide &> /dev/null; then
        echo "   Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    echo ""
}

# -----------------------------------------------------------------------------
# Backup existing configs
# -----------------------------------------------------------------------------
backup_existing() {
    echo "==> Backing up existing configs..."
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$backup_dir/"
    [[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$backup_dir/"
    [[ -f "$HOME/.config/starship.toml" ]] && cp "$HOME/.config/starship.toml" "$backup_dir/"

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
    read -p "Install binaries to ~/.local/bin? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_bins
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
    echo "  2. Zinit will auto-install zsh plugins on first run"
    echo "  3. Neovim will auto-install plugins on first run"
    echo ""
}

main "$@"
