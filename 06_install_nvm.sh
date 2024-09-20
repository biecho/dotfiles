#!/bin/bash

# NVM (Node Version Manager) Local Installation Script
#
# This script installs NVM (Node Version Manager) locally for a single user,
# allowing them to manage multiple versions of Node.js without requiring sudo or root access.
# It's useful for developers who want isolated environments for different projects or those who lack admin rights.
# NVM helps in easily switching between Node.js versions, handling global dependencies safely in a local directory.
#
# Installation steps:
# 1. Downloads the official NVM installer.
# 2. Sets up the necessary environment variables.
# 3. Adds NVM to .zshrc for persistent access in future sessions.
#
# Why is this useful?
# - Allows you to switch Node.js versions effortlessly for different projects.
# - No need for system-wide installations, keeping your environment isolated.
# - Ideal for developers working in diverse Node.js setups.
# - Easy to maintain and update Node.js versions as needed.

# Define installation directory for NVM
NVM_DIR="$HOME/.nvm"

# Download and install NVM
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Add NVM to the current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Load NVM

# Add NVM to .zshrc for future sessions
if ! grep -q "NVM_DIR" "$HOME/.zshrc"; then
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.zshrc"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Load NVM' >> "$HOME/.zshrc"
fi

# Verify installation
echo "Verifying NVM installation..."
command -v nvm

echo "NVM installed successfully! Run 'nvm install node' to install Node.js."
