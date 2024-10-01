#!/bin/bash

# Set the version and binary name for yq
VERSION=v4.30.1
BINARY=yq_linux_amd64  # Change according to your platform (e.g., yq_darwin_amd64 for Mac)

# Define local installation directory
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Download the latest yq binary and place it in the local directory
wget "https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}" -O "$INSTALL_DIR/yq" && \
chmod +x "$INSTALL_DIR/yq"

# Add local bin directory to PATH if not already present
if ! [[ "$PATH" =~ "$INSTALL_DIR" ]]; then
  echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> ~/.bashrc
  source ~/.bashrc
fi

echo "yq installed successfully in $INSTALL_DIR!"

