#!/bin/bash

# Ensure you have Zsh installed locally or compiled from source

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "zsh not found in PATH. Please ensure Zsh is installed locally. Exiting."
    exit 1
else
    echo "zsh is installed."
fi

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

# Reminder to restart the shell
echo "Setup complete. Please restart your terminal session to use zsh."
