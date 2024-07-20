#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update

# Install dependencies
sudo apt install -y zsh

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "zsh installation failed or not found in PATH. Exiting."
    exit 1
else
    echo "zsh is installed."
fi

# Set zsh as the default shell
echo "Setting zsh as the default shell..."
chsh -s $(which zsh)

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
if sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" "" --unattended; then
    echo "oh-my-zsh installed successfully."
else
    echo "oh-my-zsh installation failed. Exiting."
    exit 1
fi

# Define ZSH_CUSTOM directory
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Install Powerlevel10k
echo "Installing Powerlevel10k..."
if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k; then
    echo "Powerlevel10k installed successfully."
else
    echo "Powerlevel10k installation failed. Exiting."
    exit 1
fi

# Install zsh plugins
echo "Installing zsh-autosuggestions..."
sudo apt install -y autojump
if git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions; then
    echo "zsh-autosuggestions installed successfully."
else
    echo "zsh-autosuggestions installation failed. Exiting."
    exit 1
fi

echo "Installing zsh-syntax-highlighting..."
if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting; then
    echo "zsh-syntax-highlighting installed successfully."
else
    echo "zsh-syntax-highlighting installation failed. Exiting."
    exit 1
fi

echo "All necessary configurations and dependencies installed successfully."

# Reminder to log out and back in
echo "Setup complete. Please log out and log back in for the default shell change to take effect."