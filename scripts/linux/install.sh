#!/bin/bash
# =============================================================================
# Linux Install Script
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "Installing dotfiles for Linux..."
echo ""

# -----------------------------------------------------------------------------
# Detect package manager
# -----------------------------------------------------------------------------
detect_pkg_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# -----------------------------------------------------------------------------
# Install packages
# -----------------------------------------------------------------------------
install_deps() {
    local pkg_manager=$(detect_pkg_manager)
    echo "==> Detected package manager: $pkg_manager"

    case "$pkg_manager" in
        apt)
            echo "==> Updating apt..."
            sudo apt update

            echo "==> Installing packages..."
            sudo apt install -y zsh neovim fzf ripgrep fd-find xclip

            # Install eza (not in default repos)
            if ! command -v eza &> /dev/null; then
                echo "==> Installing eza..."
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo apt update
                sudo apt install -y eza
            fi

            # Install starship
            if ! command -v starship &> /dev/null; then
                echo "==> Installing starship..."
                curl -sS https://starship.rs/install.sh | sh
            fi

            # Install zoxide
            if ! command -v zoxide &> /dev/null; then
                echo "==> Installing zoxide..."
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi

            # Install lazygit
            if ! command -v lazygit &> /dev/null; then
                echo "==> Installing lazygit..."
                LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
                tar xf lazygit.tar.gz lazygit
                sudo install lazygit /usr/local/bin
                rm lazygit lazygit.tar.gz
            fi
            ;;

        dnf)
            echo "==> Installing packages..."
            sudo dnf install -y zsh neovim fzf ripgrep fd-find xclip eza

            if ! command -v starship &> /dev/null; then
                curl -sS https://starship.rs/install.sh | sh
            fi

            if ! command -v zoxide &> /dev/null; then
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi
            ;;

        pacman)
            echo "==> Installing packages..."
            sudo pacman -S --noconfirm zsh neovim fzf ripgrep fd starship zoxide lazygit eza xclip
            ;;

        *)
            echo "Error: Unknown package manager. Install manually:"
            echo "  - zsh, neovim, fzf, ripgrep, fd"
            echo "  - starship: https://starship.rs"
            echo "  - zoxide: https://github.com/ajeetdsouza/zoxide"
            echo "  - lazygit: https://github.com/jesseduffield/lazygit"
            return 1
            ;;
    esac

    echo ""
    echo "Note: Install Ghostty manually from https://ghostty.org"
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
    [[ -d "$HOME/.config/ghostty" ]] && cp -r "$HOME/.config/ghostty" "$backup_dir/"

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
}

# -----------------------------------------------------------------------------
# Set zsh as default shell
# -----------------------------------------------------------------------------
set_default_shell() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        read -p "Set zsh as default shell? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chsh -s $(which zsh)
            echo "   Default shell changed to zsh (takes effect on next login)"
        fi
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    read -p "Install packages? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_deps
    fi

    echo ""
    backup_existing

    echo ""
    create_symlinks

    echo ""
    set_default_shell

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
