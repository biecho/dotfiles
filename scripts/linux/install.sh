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

    # git-delta
    if ! command -v delta &> /dev/null; then
        echo "   Installing git-delta..."
        DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -Po '"tag_name": "\K[^"]*')
        curl -sL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/delta'
    fi

    # atuin (better shell history)
    if ! command -v atuin &> /dev/null; then
        echo "   Installing atuin..."
        curl -sS https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | bash -s -- --no-modify-path
    fi

    # bat (modern cat with syntax highlighting)
    if ! command -v bat &> /dev/null; then
        echo "   Installing bat..."
        BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
        curl -sL "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/bat'
    fi

    # btop (modern top/htop)
    if ! command -v btop &> /dev/null; then
        echo "   Installing btop..."
        BTOP_VERSION=$(curl -s https://api.github.com/repos/aristocratos/btop/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
        curl -sL "https://github.com/aristocratos/btop/releases/download/v${BTOP_VERSION}/btop-x86_64-linux-musl.tbz" -o /tmp/btop.tbz
        cd /tmp && tar xjf btop.tbz
        cp /tmp/btop/bin/btop "$LOCAL_BIN/"
        rm -rf /tmp/btop /tmp/btop.tbz
    fi

    # tlrc (tldr pages - simplified man pages)
    if ! command -v tldr &> /dev/null; then
        echo "   Installing tlrc..."
        TLRC_VERSION=$(curl -s https://api.github.com/repos/tldr-pages/tlrc/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
        curl -sL "https://github.com/tldr-pages/tlrc/releases/download/v${TLRC_VERSION}/tlrc-v${TLRC_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz -C "$LOCAL_BIN" tldr
    fi

    # yazi (file manager)
    if ! command -v yazi &> /dev/null; then
        echo "   Installing yazi..."
        YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
        curl -sL "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip" \
            -o /tmp/yazi.zip
        unzip -q -o /tmp/yazi.zip -d /tmp/yazi
        cp /tmp/yazi/yazi-x86_64-unknown-linux-musl/yazi "$LOCAL_BIN/"
        rm -rf /tmp/yazi /tmp/yazi.zip
    fi

    # ImageMagick (required for image.nvim)
    if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
        echo "   Installing ImageMagick..."
        curl -sL https://imagemagick.org/archive/binaries/magick -o "$LOCAL_BIN/magick"
        chmod +x "$LOCAL_BIN/magick"
    fi

    # just (command runner)
    if ! command -v just &> /dev/null; then
        echo "   Installing just..."
        JUST_VERSION=$(curl -s https://api.github.com/repos/casey/just/releases/latest | grep -Po '"tag_name": "\K[^"]*')
        curl -sL "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz -C "$LOCAL_BIN" just
    fi

    # dust (modern du - disk usage analyzer)
    if ! command -v dust &> /dev/null; then
        echo "   Installing dust..."
        DUST_VERSION=$(curl -s https://api.github.com/repos/bootandy/dust/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
        curl -sL "https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}/dust-v${DUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
            | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/dust'
    fi

    # duf (modern df - disk free overview)
    if ! command -v duf &> /dev/null; then
        echo "   Installing duf..."
        # Note: duf uses linux_x86_64 naming convention, not linux_amd64
        curl -sSL "https://github.com/muesli/duf/releases/download/v0.8.1/duf_0.8.1_linux_x86_64.tar.gz" \
            | tar xz -C "$LOCAL_BIN" duf
    fi

    echo ""
}

# -----------------------------------------------------------------------------
# Install required dependencies for Neovim plugins
# -----------------------------------------------------------------------------
install_nvim_deps() {
    echo "==> Installing Neovim plugin dependencies..."
    mkdir -p "$LOCAL_BIN"

    # fd is required for venv-selector.nvim and telescope file finding
    if ! command -v fd &> /dev/null; then
        echo "   Installing fd (required for venv-selector)..."
        local fd_tmp=$(mktemp -d)
        curl -sL "https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-musl.tar.gz" \
            -o "$fd_tmp/fd.tar.gz"
        tar -xzf "$fd_tmp/fd.tar.gz" -C "$fd_tmp"
        cp "$fd_tmp"/fd-*/fd "$LOCAL_BIN/"
        chmod +x "$LOCAL_BIN/fd"
        rm -rf "$fd_tmp"
    fi

    # Python venv for pynvim and molten-nvim
    local nvim_python_dir="$HOME/.local/share/nvim/python"
    if [[ ! -d "$nvim_python_dir" ]]; then
        echo "   Creating dedicated Python venv for Neovim..."
        python3 -m venv "$nvim_python_dir"
    fi

    echo "   Installing pynvim and Jupyter dependencies..."
    "$nvim_python_dir/bin/pip" install --upgrade pip pynvim \
        jupyter_client jupyter_core \
        cairosvg pnglatex plotly kaleido pillow \
        --quiet

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
    # Linux uses ~/.config/lazygit/
    mkdir -p "$HOME/.config/lazygit"
    ln -sf "$DOTFILES_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
    echo "   ~/.config/lazygit/config.yml"

    # Yazi config (file manager)
    mkdir -p "$HOME/.config/yazi"
    ln -sf "$DOTFILES_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
    ln -sf "$DOTFILES_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
    ln -sf "$DOTFILES_DIR/yazi/init.lua" "$HOME/.config/yazi/init.lua"
    ln -sf "$DOTFILES_DIR/yazi/package.toml" "$HOME/.config/yazi/package.toml"
    echo "   ~/.config/yazi/{yazi.toml,keymap.toml,init.lua,package.toml}"

    # Install yazi plugins (use full path since ~/.local/bin may not be in PATH yet)
    if [[ -x "$LOCAL_BIN/ya" ]]; then
        echo "   Installing yazi plugins..."
        "$LOCAL_BIN/ya" pkg install
    fi
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
    install_nvim_deps

    # Register Neovim remote plugins (required for molten-nvim)
    echo "==> Registering Neovim remote plugins..."
    if command -v nvim &> /dev/null; then
        nvim --headless \
            -c "Lazy load molten-nvim" \
            -c "UpdateRemotePlugins" \
            -c "q" 2>/dev/null
        echo "   Remote plugins registered"
    else
        echo "   Skipping (nvim not found)"
    fi

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
