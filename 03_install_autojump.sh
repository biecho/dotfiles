#!/bin/bash

# Local installation directory for Autojump
INSTALL_DIR="$HOME/.local/autojump"

# Check if git is installed
if ! command -v git &> /dev/null
then
	echo "git is required but not installed. Please install git first."
	exit 1
fi

# Clone the Autojump repository into the local directory
echo "Cloning Autojump repository..."
git clone git@github.com:wting/autojump.git "$INSTALL_DIR"

# Navigate to the installation directory
cd "$INSTALL_DIR" || { echo "Failed to navigate to the installation directory"; exit 1; }

# Install Autojump locally
echo "Installing Autojump..."
./install.py --dest="$HOME/.local"

# Define the exact initialization line
AUTOJUMP_INIT_LINE="[[ -s \"$HOME/.local/etc/profile.d/autojump.sh\" ]] && source \"$HOME/.local/etc/profile.d/autojump.sh\""

# Add Autojump to .zshrc if the exact line is not already there
if ! grep -Fxq "$AUTOJUMP_INIT_LINE" "$HOME/.zshrc"; then
    echo "Adding Autojump initialization to .zshrc"
    echo "$AUTOJUMP_INIT_LINE" >> "$HOME/.zshrc"
else
    echo "Autojump initialization already present in .zshrc"
fi

echo "Autojump installation completed!"
echo "Please restart your terminal or run 'source $HOME/.zshrc' to start using Autojump."

