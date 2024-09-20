#!/bin/bash

# Define the installation URL for Rust
RUST_INSTALL_URL="https://sh.rustup.rs"

# Install Rust locally using rustup
echo "Installing Rust locally using rustup..."
curl --proto '=https' --tlsv1.2 -sSf $RUST_INSTALL_URL | sh -s -- -y

# Add Rust to the PATH in .zshrc
if ! grep -q "cargo/bin" "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.zshrc"
    echo "Added Rust to PATH in .zshrc"
else
    echo "Rust is already in the PATH"
fi

# Source Rust environment for current shell
source "$HOME/.cargo/env"

# Verify the installation
echo "Verifying Rust installation..."
command -v rustc && rustc --version
command -v cargo && cargo --version

echo "Rust installation complete! Please restart your terminal or run 'source ~/.zshrc' to apply changes."
