#!/bin/bash

# Check if zsh is installed
if ! command -v zsh &> /dev/null
then
    echo "zsh not installed. Installing zsh..."
    sudo apt update
    sudo apt install -y zsh
    echo "zsh installed successfully."
else
    echo "zsh is already installed."
fi

# Set zsh as the default shell
echo "Setting zsh as the default shell..."
chsh -s $(which zsh)

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" "" --unattended
echo "oh-my-zsh installed successfully."

# Additional configurations (if any) can be added here

echo "Setup complete. Please log out and log back in for default shell change to take effect."

