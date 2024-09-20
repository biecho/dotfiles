#!/bin/bash

# Define the version of ripgrep to install
RG_VERSION="14.1.1"

# Define the local install directory
INSTALL_DIR="$HOME/.local"

# Create the local bin directory if it doesn't exist
mkdir -p "$INSTALL_DIR/bin"

# Download the latest ripgrep release
echo "Downloading ripgrep version $RG_VERSION..."
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz

# Extract the release archive
echo "Extracting ripgrep..."
tar -xzf ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz

# Move ripgrep binary to the local bin directory
mv ripgrep-$RG_VERSION-x86_64-unknown-linux-musl/rg "$INSTALL_DIR/bin/"

# Add ~/.local/bin to the PATH in .zshrc if not already added
if ! grep -q "export PATH=\"$HOME/.local/bin:\$PATH\"" "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    echo "Added ~/.local/bin to PATH in .zshrc"
else
    echo "~/.local/bin is already in the PATH"
fi

# Clean up the downloaded and extracted files
rm -rf ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz ripgrep-$RG_VERSION-x86_64-unknown-linux-musl

# Verify the installation
echo "Verifying ripgrep installation..."
command -v rg && rg --version

echo "ripgrep installation complete! Please restart your terminal or run 'source ~/.zshrc' to apply changes."

