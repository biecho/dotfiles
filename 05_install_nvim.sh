#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Catch errors in pipes

# Define the install directory
INSTALL_DIR="$HOME/.local"
NVIM_DIR="$INSTALL_DIR/nvim"
BIN_DIR="$INSTALL_DIR/bin"
NVIM_TAR="nvim-linux64.tar.gz"
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"

# Create necessary directories
mkdir -p "$NVIM_DIR" "$BIN_DIR"

# Download Neovim with validation
echo "Downloading Neovim..."
rm -f "$NVIM_TAR"
if ! curl -fL --retry 3 --output "$NVIM_TAR" "$NVIM_URL"; then
    echo "Error: Failed to download Neovim. Check your internet connection or verify the URL."
    exit 1
fi

# Validate the downloaded file
if ! file "$NVIM_TAR" | grep -q "gzip compressed data"; then
    echo "Error: Downloaded file is not a valid gzip archive."
    rm -f "$NVIM_TAR"
    exit 1
fi

# Extract Neovim
echo "Extracting Neovim..."
rm -rf "$NVIM_DIR"
tar -xzf "$NVIM_TAR" -C "$INSTALL_DIR"

# Move extracted files to the correct location
mv "$INSTALL_DIR/nvim-linux64" "$NVIM_DIR"

# Create a symlink in the local bin directory
if [ ! -L "$BIN_DIR/nvim" ]; then
    echo "Creating symlink..."
    ln -s "$NVIM_DIR/bin/nvim" "$BIN_DIR/nvim"
else
    echo "Symlink for Neovim already exists. Skipping."
fi

# Ensure ~/.local/bin is in the PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    echo "Added ~/.local/bin to PATH in .zshrc."
fi

# Ensure alias for vi exists
if ! grep -q "alias vi='nvim'" "$HOME/.zshrc"; then
    echo "alias vi='nvim'" >> "$HOME/.zshrc"
    echo "Alias for vi added to .zshrc."
else
    echo "Alias for vi already exists in .zshrc."
fi

# Clean up
rm -f "$NVIM_TAR"

# Final message
echo "Neovim has been installed locally under $NVIM_DIR."
echo "'vi' command will now open Neovim."
echo "To apply the changes, restart your terminal or run: source ~/.zshrc"
