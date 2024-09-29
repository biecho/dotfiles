#!/bin/bash

# Define the local install path
INSTALL_DIR="$HOME/.local/bin"

# Check if the required directories exist, if not, create them
if [ ! -d "$INSTALL_DIR" ]; then
  echo "Creating local bin directory at $INSTALL_DIR..."
  mkdir -p "$INSTALL_DIR"
fi

# Install `xsv` using cargo with the local installation directory
echo "Installing xsv using cargo..."
cargo install --root "$HOME/.local" xsv

# Verify that `xsv` was installed to the local bin directory
if [ -f "$INSTALL_DIR/xsv" ]; then
  echo "xsv successfully installed to $INSTALL_DIR."
else
  echo "Installation failed. Please check the output for any errors."
  exit 1
fi

# Check if the local bin path is in the user's PATH
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo "Adding $INSTALL_DIR to your PATH in ~/.zshrc..."
  echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.zshrc"
  export PATH="$INSTALL_DIR:$PATH"
fi

echo "xsv installation completed and PATH updated (if required)."

