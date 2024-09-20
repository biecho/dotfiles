#!/bin/bash

# Define the install directory
INSTALL_DIR="$HOME/.local"
NVIM_DIR="$INSTALL_DIR/nvim"
BIN_DIR="$INSTALL_DIR/bin"

# Create necessary directories
mkdir -p "$NVIM_DIR" "$BIN_DIR"

# Download the latest stable version of Neovim
echo "Downloading Neovim..."
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz

# Extract the downloaded archive
echo "Extracting Neovim..."
tar -xzf nvim-linux64.tar.gz -C "$NVIM_DIR" --strip-components=1

# Create a symlink in the local bin directory if it doesn't exist
if [ ! -L "$BIN_DIR/nvim" ]; then
    echo "Creating symlink..."
    ln -s "$NVIM_DIR/bin/nvim" "$BIN_DIR/nvim"
else
    echo "Symlink for Neovim already exists. Skipping."
fi

# Add ~/.local/bin to the PATH if it's not already
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi

# Check if alias for vi already exists in .zshrc
if ! grep -q "alias vi='nvim'" "$HOME/.zshrc"; then
    # Create an alias for vi to point to nvim
    echo "alias vi='nvim'" >> "$HOME/.zshrc"
    echo "Alias for vi added to .zshrc"
else
    echo "Alias for vi already exists in .zshrc"
fi

# Clean up downloaded file
rm nvim-linux64.tar.gz

echo "Neovim has been installed locally under $NVIM_DIR"
echo "'vi' command will now open Neovim."

# Instructions for the user
echo "To apply the alias changes, please restart your terminal or run:"
echo "source ~/.zshrc"
