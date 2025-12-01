#!/bin/bash
# =============================================================================
# Dotfiles Install Script - Auto-detects OS
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

main() {
    local os=$(detect_os)

    echo "============================================="
    echo "  Dotfiles Installer"
    echo "============================================="
    echo ""
    echo "Detected OS: $os"
    echo ""

    case "$os" in
        macos)
            exec "$SCRIPTS_DIR/macos/install.sh"
            ;;
        linux)
            exec "$SCRIPTS_DIR/linux/install.sh"
            ;;
        *)
            echo "Error: Unsupported operating system"
            exit 1
            ;;
    esac
}

main "$@"
