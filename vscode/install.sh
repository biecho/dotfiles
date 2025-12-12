#!/bin/bash
# VS Code setup script
# Run from dotfiles directory: ./vscode/install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo "Setting up VS Code configuration..."
echo "Dotfiles directory: $DOTFILES_DIR"

# Determine VS Code config directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    VSCODE_CONFIG_DIR="$HOME/Library/Application Support/Code/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "VS Code config directory: $VSCODE_CONFIG_DIR"

# Create VS Code config directory if it doesn't exist
mkdir -p "$VSCODE_CONFIG_DIR"

# Backup existing configs if they're not symlinks
for file in settings.json keybindings.json; do
    target="$VSCODE_CONFIG_DIR/$file"
    if [[ -f "$target" && ! -L "$target" ]]; then
        echo "Backing up existing $file to $file.backup"
        mv "$target" "$target.backup"
    fi
done

# Create symlinks
echo "Creating symlinks..."
ln -sf "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_CONFIG_DIR/settings.json"
ln -sf "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_CONFIG_DIR/keybindings.json"

echo "Symlinks created:"
ls -la "$VSCODE_CONFIG_DIR"/*.json

# Install extensions (uncommented ones from extensions.txt)
echo ""
echo "Installing extensions..."
grep -v '^#' "$SCRIPT_DIR/extensions.txt" | grep -v '^$' | while read -r ext; do
    echo "  Installing: $ext"
    code --install-extension "$ext" --force 2>/dev/null || echo "    Warning: Failed to install $ext"
done

echo ""
echo "VS Code setup complete!"
echo ""
echo "Notes:"
echo "  - Restart VS Code for changes to take effect"
echo "  - vscode-neovim requires neovim installed:"
echo "    macOS: brew install neovim"
echo "    Linux: sudo apt install neovim"
echo "  - First launch will install lazy.nvim plugins for nvim-vscode config"
