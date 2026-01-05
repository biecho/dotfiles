#!/bin/bash
# Install termusic configuration

set -e

DOTFILES_DIR="$HOME/dotfiles/termusic"
CONFIG_DIR=""

# Detect OS and set config directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/termusic"
    echo "Detected macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CONFIG_DIR="$HOME/.config/termusic"
    echo "Detected Linux"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR/themes"

# Backup existing configs if they exist
if [[ -f "$CONFIG_DIR/tui.toml" ]]; then
    echo "Backing up existing tui.toml to tui.toml.backup"
    cp "$CONFIG_DIR/tui.toml" "$CONFIG_DIR/tui.toml.backup"
fi

if [[ -f "$CONFIG_DIR/server.toml" ]]; then
    echo "Backing up existing server.toml to server.toml.backup"
    cp "$CONFIG_DIR/server.toml" "$CONFIG_DIR/server.toml.backup"
fi

# Link configuration files
echo "Linking tui.toml..."
ln -sf "$DOTFILES_DIR/tui.toml" "$CONFIG_DIR/tui.toml"

echo "Linking server.toml..."
ln -sf "$DOTFILES_DIR/server.toml" "$CONFIG_DIR/server.toml"

# Copy Cyberdream theme
echo "Installing Cyberdream theme..."
cp "$DOTFILES_DIR/themes/Cyberdream.yml" "$CONFIG_DIR/themes/Cyberdream.yml"

echo ""
echo "✓ Termusic configuration installed successfully!"
echo ""
echo "Config location: $CONFIG_DIR"
echo "Backups saved with .backup extension (if existed)"
echo ""
echo "To use Cyberdream theme:"
echo "  1. Run termusic"
echo "  2. Press Shift+C to open config editor"
echo "  3. Navigate to theme selection"
echo "  4. Select 'Cyberdream'"
echo ""
echo "Quick start:"
echo "  termusic         - Launch player"
echo "  Press '1'        - Library view"
echo "  Press 'Ctrl+h'   - Show help"
echo ""
