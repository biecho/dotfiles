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
# Helper: Get latest GitHub release version (uses gh CLI if available for auth)
# Usage: gh_version "owner/repo" [strip_v]
# Examples: gh_version "junegunn/fzf"        -> "0.46.0" (strips v prefix)
#           gh_version "casey/just" "no"     -> "1.46.0" (no v prefix in tag)
# -----------------------------------------------------------------------------
gh_version() {
    local repo="$1"
    local strip_v="${2:-yes}"
    local version=""

    # Try gh CLI first (authenticated, higher rate limit)
    if command -v gh &> /dev/null; then
        version=$(gh api "repos/$repo/releases/latest" --jq '.tag_name' 2>/dev/null || true)
    fi

    # Fallback to curl
    if [[ -z "$version" ]]; then
        version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -Po '"tag_name": "\K[^"]*' || true)
    fi

    # Strip 'v' prefix if requested
    if [[ "$strip_v" == "yes" && "$version" == v* ]]; then
        version="${version#v}"
    fi

    echo "$version"
}

# -----------------------------------------------------------------------------
# Helper: Check glibc version meets minimum requirement
# Usage: check_glibc "2.28" && echo "OK" || echo "Too old"
# -----------------------------------------------------------------------------
check_glibc() {
    local required="$1"
    local current
    current=$(ldd --version 2>&1 | head -1 | grep -oP '\d+\.\d+$' || echo "0.0")

    # Compare versions (works for X.Y format)
    local req_major req_minor cur_major cur_minor
    req_major="${required%%.*}"
    req_minor="${required##*.}"
    cur_major="${current%%.*}"
    cur_minor="${current##*.}"

    if (( cur_major > req_major )) || { (( cur_major == req_major )) && (( cur_minor >= req_minor )); }; then
        return 0
    fi
    return 1
}

# -----------------------------------------------------------------------------
# Install binaries to ~/.local/bin
# -----------------------------------------------------------------------------
install_bins() {
    echo "==> Installing binaries to ~/.local/bin..."
    mkdir -p "$LOCAL_BIN"

    # gh (GitHub CLI) - install FIRST since gh_version uses it for authenticated API calls
    if ! command -v gh &> /dev/null; then
        echo "   Installing gh..."
        GH_VERSION=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep -Po '"tag_name": "v\K[^"]*' || true)
        if [[ -n "$GH_VERSION" ]]; then
            curl -sL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
                | tar xz --strip-components=2 -C "$LOCAL_BIN" --wildcards '*/bin/gh'
        else
            echo "   Warning: Could not fetch gh version, skipping"
        fi
    fi

    # Neovim (requires glibc 2.28+ / Ubuntu 20.04+)
    if ! command -v nvim &> /dev/null; then
        if check_glibc "2.28"; then
            echo "   Installing neovim..."
            curl -sL https://github.com/neovim/neovim/releases/download/stable/nvim.appimage \
                -o "$LOCAL_BIN/nvim"
            chmod +x "$LOCAL_BIN/nvim"
        else
            echo "   Skipping neovim: requires glibc 2.28+ (Ubuntu 20.04+)"
            echo "   Upgrade your OS with: sudo do-release-upgrade"
        fi
    fi

    # fzf
    if ! command -v fzf &> /dev/null; then
        echo "   Installing fzf..."
        FZF_VERSION=$(gh_version "junegunn/fzf")
        if [[ -n "$FZF_VERSION" ]]; then
            curl -sL "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz" \
                | tar xz -C "$LOCAL_BIN"
        else
            echo "   Warning: Could not fetch fzf version (rate limited?), skipping"
        fi
    fi

    # ripgrep
    if ! command -v rg &> /dev/null; then
        echo "   Installing ripgrep..."
        RG_VERSION=$(gh_version "BurntSushi/ripgrep" "no")
        if [[ -n "$RG_VERSION" ]]; then
            curl -sL "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
                | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/rg'
        else
            echo "   Warning: Could not fetch ripgrep version, skipping"
        fi
    fi

    # fd
    if ! command -v fd &> /dev/null; then
        echo "   Installing fd..."
        FD_VERSION=$(gh_version "sharkdp/fd")
        if [[ -n "$FD_VERSION" ]]; then
            curl -sL "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
                | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/fd'
        else
            echo "   Warning: Could not fetch fd version, skipping"
        fi
    fi

    # eza
    if ! command -v eza &> /dev/null; then
        echo "   Installing eza..."
        EZA_VERSION=$(gh_version "eza-community/eza")
        if [[ -n "$EZA_VERSION" ]]; then
            curl -sL "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-musl.tar.gz" \
                | tar xz -C "$LOCAL_BIN"
        else
            echo "   Warning: Could not fetch eza version, skipping"
        fi
    fi

    # lazygit
    if ! command -v lazygit &> /dev/null; then
        echo "   Installing lazygit..."
        LAZYGIT_VERSION=$(gh_version "jesseduffield/lazygit")
        if [[ -n "$LAZYGIT_VERSION" ]]; then
            curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
                | tar xz -C "$LOCAL_BIN" lazygit
        else
            echo "   Warning: Could not fetch lazygit version, skipping"
        fi
    fi

    # starship
    if ! command -v starship &> /dev/null; then
        echo "   Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$LOCAL_BIN" -y
    fi

    # zoxide
    if ! command -v zoxide &> /dev/null; then
        echo "   Installing zoxide..."
        ZOXIDE_VERSION=$(gh_version "ajeetdsouza/zoxide")
        if [[ -n "$ZOXIDE_VERSION" ]]; then
            curl -sL "https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/zoxide-${ZOXIDE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
                | tar xz -C "$LOCAL_BIN" zoxide
        else
            echo "   Warning: Could not fetch zoxide version, skipping"
        fi
    fi

    # git-delta
    if ! command -v delta &> /dev/null; then
        echo "   Installing git-delta..."
        DELTA_VERSION=$(gh_version "dandavison/delta" "no")
        if [[ -n "$DELTA_VERSION" ]]; then
            curl -sL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
                | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/delta'
        else
            echo "   Warning: Could not fetch delta version, skipping"
        fi
    fi

    # atuin (better shell history)
    if ! command -v atuin &> /dev/null; then
        echo "   Installing atuin..."
        curl -sS https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | bash -s -- --no-modify-path
    fi

    # bat (modern cat with syntax highlighting)
    if ! command -v bat &> /dev/null; then
        echo "   Installing bat..."
        BAT_VERSION=$(gh_version "sharkdp/bat")
        if [[ -n "$BAT_VERSION" ]]; then
            curl -sL "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
                | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/bat'
        else
            echo "   Warning: Could not fetch bat version, skipping"
        fi
    fi

    # btop (modern top/htop)
    if ! command -v btop &> /dev/null; then
        echo "   Installing btop..."
        BTOP_VERSION=$(gh_version "aristocratos/btop")
        if [[ -n "$BTOP_VERSION" ]]; then
            curl -sL "https://github.com/aristocratos/btop/releases/download/v${BTOP_VERSION}/btop-x86_64-unknown-linux-musl.tbz" -o /tmp/btop.tbz
            cd /tmp && tar xjf btop.tbz
            cp /tmp/btop/bin/btop "$LOCAL_BIN/"
            rm -rf /tmp/btop /tmp/btop.tbz
        else
            echo "   Warning: Could not fetch btop version, skipping"
        fi
    fi

    # tlrc (tldr pages - simplified man pages)
    if ! command -v tldr &> /dev/null; then
        echo "   Installing tlrc..."
        TLRC_VERSION=$(gh_version "tldr-pages/tlrc")
        if [[ -n "$TLRC_VERSION" ]]; then
            curl -sL "https://github.com/tldr-pages/tlrc/releases/download/v${TLRC_VERSION}/tlrc-v${TLRC_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
                | tar xz -C "$LOCAL_BIN" tldr
        else
            echo "   Warning: Could not fetch tlrc version, skipping"
        fi
    fi

    # cloc (count lines of code)
    if ! command -v cloc &> /dev/null; then
        echo "   Installing cloc..."
        CLOC_VERSION=$(gh_version "AlDanial/cloc")
        if [[ -n "$CLOC_VERSION" ]]; then
            curl -sL "https://github.com/AlDanial/cloc/releases/download/v${CLOC_VERSION}/cloc-${CLOC_VERSION}.pl" \
                -o "$LOCAL_BIN/cloc"
            chmod +x "$LOCAL_BIN/cloc"
        else
            echo "   Warning: Could not fetch cloc version, skipping"
        fi
    fi

    # yazi (file manager) and ya (plugin manager)
    if ! command -v yazi &> /dev/null; then
        echo "   Installing yazi..."
        YAZI_VERSION=$(gh_version "sxyazi/yazi")
        if [[ -n "$YAZI_VERSION" ]]; then
            curl -sL "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip" \
                -o /tmp/yazi.zip
            unzip -q -o /tmp/yazi.zip -d /tmp/yazi
            cp /tmp/yazi/yazi-x86_64-unknown-linux-musl/yazi "$LOCAL_BIN/"
            cp /tmp/yazi/yazi-x86_64-unknown-linux-musl/ya "$LOCAL_BIN/"
            rm -rf /tmp/yazi /tmp/yazi.zip
        else
            echo "   Warning: Could not fetch yazi version, skipping"
        fi
    fi

    # ImageMagick (required for image.nvim)
    if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
        echo "   Installing ImageMagick..."
        curl -sL --http1.1 --retry 3 https://imagemagick.org/archive/binaries/magick -o "$LOCAL_BIN/magick"
        chmod +x "$LOCAL_BIN/magick"
    fi

    # just (command runner)
    if ! command -v just &> /dev/null; then
        echo "   Installing just..."
        JUST_VERSION=$(gh_version "casey/just" "no")
        if [[ -n "$JUST_VERSION" ]]; then
            curl -sL "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
                | tar xz -C "$LOCAL_BIN" just
        else
            echo "   Warning: Could not fetch just version, skipping"
        fi
    fi

    # dust (modern du - disk usage analyzer)
    if ! command -v dust &> /dev/null; then
        echo "   Installing dust..."
        DUST_VERSION=$(gh_version "bootandy/dust")
        if [[ -n "$DUST_VERSION" ]]; then
            curl -sL "https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}/dust-v${DUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
                | tar xz --strip-components=1 -C "$LOCAL_BIN" --wildcards '*/dust'
        else
            echo "   Warning: Could not fetch dust version, skipping"
        fi
    fi

    # duf (modern df - disk free overview)
    if ! command -v duf &> /dev/null; then
        echo "   Installing duf..."
        DUF_VERSION=$(gh_version "muesli/duf")
        if [[ -n "$DUF_VERSION" ]]; then
            curl -sSL "https://github.com/muesli/duf/releases/download/v${DUF_VERSION}/duf_${DUF_VERSION}_linux_x86_64.tar.gz" \
                | tar xz -C "$LOCAL_BIN" duf
        else
            echo "   Warning: Could not fetch duf version, skipping"
        fi
    fi

    # abduco (session persistence - detach/reattach like tmux)
    if ! command -v abduco &> /dev/null; then
        echo "   Installing abduco..."
        local abduco_tmp=$(mktemp -d)
        git clone --depth 1 https://github.com/martanne/abduco.git "$abduco_tmp" 2>/dev/null
        cd "$abduco_tmp"
        if command -v cc &> /dev/null || command -v gcc &> /dev/null; then
            make 2>/dev/null && cp abduco "$LOCAL_BIN/"
            echo "   abduco installed to ~/.local/bin"
        else
            echo "   abduco: C compiler not found, install via: sudo apt install abduco"
        fi
        cd - > /dev/null
        rm -rf "$abduco_tmp"
    fi

    # huggingface-cli (HuggingFace Hub CLI for dataset/model sync)
    if ! command -v huggingface-cli &> /dev/null; then
        echo "   Installing huggingface-cli..."
        pip install --user --quiet huggingface_hub
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
    if [[ ! -f "$nvim_python_dir/bin/pip" ]]; then
        echo "   Creating dedicated Python venv for Neovim..."
        rm -rf "$nvim_python_dir"
        python3 -m venv "$nvim_python_dir"
    fi

    echo "   Installing pynvim and Jupyter dependencies..."
    "$nvim_python_dir/bin/pip" install --upgrade pip pynvim \
        jupyter_client jupyter_core \
        cairosvg pnglatex plotly kaleido pillow \
        --quiet

    # markdown-preview.nvim dependencies
    local mkdp_dir="$HOME/.local/share/nvim/lazy/markdown-preview.nvim/app"
    if [[ -d "$mkdp_dir" && ! -f "$mkdp_dir/bin/markdown-preview-linux" ]]; then
        echo "   Installing markdown-preview.nvim dependencies..."
        cd "$mkdp_dir" && ./install.sh
        cd - > /dev/null
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
# Set default shell to zsh
# -----------------------------------------------------------------------------
set_default_shell() {
    local current_shell
    current_shell=$(getent passwd "$(whoami)" | cut -d: -f7)

    if [[ "$current_shell" == */zsh ]]; then
        echo "==> Default shell is already zsh"
        return
    fi

    if ! command -v zsh &> /dev/null; then
        echo "==> zsh not found, skipping shell change"
        return
    fi

    echo "==> Setting default shell to zsh..."
    local zsh_path
    zsh_path=$(which zsh)

    if sudo -n true 2>/dev/null; then
        sudo chsh -s "$zsh_path" "$(whoami)"
        echo "   Default shell changed to zsh"
    else
        echo "   Sudo requires password. To change shell manually, run:"
        echo "   sudo chsh -s $zsh_path $(whoami)"
    fi
    echo ""
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

    echo ""
    set_default_shell

    # Register Neovim remote plugins (required for molten-nvim)
    # Note: This may fail on first run before Lazy installs plugins - that's OK
    echo "==> Registering Neovim remote plugins..."
    if command -v nvim &> /dev/null; then
        timeout 30 nvim --headless \
            -c "Lazy load molten-nvim" \
            -c "UpdateRemotePlugins" \
            -c "q" 2>/dev/null || true
        echo "   Remote plugins registered (or skipped if Lazy not installed yet)"
    else
        echo "   Skipping (nvim not found)"
    fi

    # Install tree-sitter-cli (required for nvim-treesitter)
    # Pin to 0.23.0 - newer versions require GLIBC 2.39
    if command -v npm &> /dev/null; then
        if ! command -v tree-sitter &> /dev/null; then
            echo "==> Installing tree-sitter-cli 0.23.0..."
            npm install -g tree-sitter-cli@0.23.0 --silent
        fi
    fi

    # Install common treesitter parsers
    echo "==> Installing treesitter parsers..."
    if command -v nvim &> /dev/null && command -v tree-sitter &> /dev/null; then
        nvim --headless \
            -c "TSInstall python bash lua json yaml toml" \
            -c "sleep 15" \
            -c "q" 2>/dev/null || true
        echo "   Treesitter parsers installed"
    else
        echo "   Skipping (nvim or tree-sitter not found)"
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
    echo "SSH session persistence:"
    echo "  Use 'abs <name>' to create/attach to persistent sessions"
    echo "  Detach with Ctrl+\\"
    echo ""
}

main "$@"
