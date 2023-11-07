#!/bin/bash

# Update package list
sudo apt update

# Install dependencies first

# Autojump
echo "Installing Autojump..."
sudo apt install -y autojump

# Git (necessary for cloning Oh My Zsh, Powerlevel10k, and plugins)
echo "Installing Git..."
sudo apt install -y git

# Docker plugin (if Docker is used, uncomment the next line to install Docker)
# echo "Installing Docker..."
# sudo apt install -y docker.io

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "zsh not installed. Installing zsh..."
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

# Install Powerlevel10k
echo "Installing Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install zsh plugins
echo "Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "Installing zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "All necessary configurations and dependencies installed."

# Reminder to log out and back in
echo "Setup complete. Please log out and log back in for the default shell change to take effect."

