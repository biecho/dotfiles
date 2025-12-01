#!/bin/bash
# =============================================================================
# Claude Code Install Script - User-local (no sudo required)
# =============================================================================
# Installs:
#   - fnm (Fast Node Manager) - for managing Node.js versions
#   - Node.js LTS - via fnm
#   - Claude Code - via npm
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}==>${NC} $1"; }

# -----------------------------------------------------------------------------
# Install fnm (Fast Node Manager)
# -----------------------------------------------------------------------------
install_fnm() {
    if command -v fnm &> /dev/null; then
        info "fnm already installed: $(fnm --version)"
        return 0
    fi

    info "Installing fnm (Fast Node Manager)..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

    # Source fnm for current session (explicit bash shell for non-interactive use)
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"

    info "fnm installed successfully"
}

# -----------------------------------------------------------------------------
# Install Node.js via fnm
# -----------------------------------------------------------------------------
install_node() {
    # Ensure fnm is available in current session
    if ! command -v fnm &> /dev/null; then
        export PATH="$HOME/.local/share/fnm:$PATH"
        eval "$(fnm env --shell bash)" 2>/dev/null || true
    fi

    if command -v node &> /dev/null; then
        info "Node.js already installed: $(node --version)"
        return 0
    fi

    info "Installing Node.js LTS via fnm..."
    fnm install --lts
    fnm default lts-latest

    info "Node.js $(node --version) installed successfully"
}

# -----------------------------------------------------------------------------
# Install Claude Code via npm
# -----------------------------------------------------------------------------
install_claude() {
    # Ensure fnm/node is available in current session
    if ! command -v node &> /dev/null; then
        export PATH="$HOME/.local/share/fnm:$PATH"
        eval "$(fnm env --shell bash)" 2>/dev/null || true
    fi

    if command -v claude &> /dev/null; then
        info "Claude Code already installed: $(claude --version 2>/dev/null || echo 'installed')"
        return 0
    fi

    if ! command -v npm &> /dev/null; then
        error "npm not found. Please install Node.js first."
        return 1
    fi

    info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code

    info "Claude Code installed successfully"
}

# -----------------------------------------------------------------------------
# Print shell configuration instructions
# -----------------------------------------------------------------------------
print_shell_config() {
    echo ""
    echo "============================================="
    echo "  Installation Complete!"
    echo "============================================="
    echo ""
    echo "Add the following to your shell config (~/.zshrc or ~/.bashrc):"
    echo ""
    echo '  # fnm (Fast Node Manager)'
    echo '  if [[ -d "$HOME/.local/share/fnm" ]]; then'
    echo '      export PATH="$HOME/.local/share/fnm:$PATH"'
    echo '      eval "$(fnm env --use-on-cd)"'
    echo '  fi'
    echo ""
    echo "Then restart your shell or run: source ~/.zshrc"
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo "============================================="
    echo "  Claude Code Installer (user-local)"
    echo "============================================="
    echo ""

    install_fnm
    echo ""
    install_node
    echo ""
    install_claude

    print_shell_config
}

main "$@"
