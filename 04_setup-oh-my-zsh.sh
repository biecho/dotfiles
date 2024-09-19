#!/bin/bash

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl is required but not installed. Please install curl and try again. Exiting."
    exit 1
fi

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "zsh not found in PATH. Please ensure Zsh is installed locally or compiled from source. Exiting."
    exit 1
else
    echo "Zsh is installed."
fi

# Install Oh My Zsh (unattended)
echo "Installing Oh My Zsh..."
if sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    echo "Oh My Zsh installed successfully."
else
    echo "Oh My Zsh installation failed. Exiting."
    exit 1
fi

# Define ZSH_CUSTOM (custom themes and plugins directory)
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Ensure ZSH_CUSTOM directory exists
if [ ! -d "$ZSH_CUSTOM/themes" ]; then
    mkdir -p "$ZSH_CUSTOM/themes"
fi
if [ ! -d "$ZSH_CUSTOM/plugins" ]; then
    mkdir -p "$ZSH_CUSTOM/plugins"
fi

# Install Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"; then
    echo "Powerlevel10k installed successfully."
else
    echo "Powerlevel10k installation failed. Exiting."
    exit 1
fi

# Install Zsh plugins: zsh-autosuggestions
echo "Installing zsh-autosuggestions..."
if git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"; then
    echo "zsh-autosuggestions installed successfully."
else
    echo "zsh-autosuggestions installation failed. Exiting."
    exit 1
fi

# Install Zsh plugins: zsh-syntax-highlighting
echo "Installing zsh-syntax-highlighting..."
if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"; then
    echo "zsh-syntax-highlighting installed successfully."
else
    echo "zsh-syntax-highlighting installation failed. Exiting."
    exit 1
fi

# Notify the user that installation is complete
echo "All necessary configurations and dependencies installed successfully."

# Reminder to restart the terminal
echo "Setup complete. Please restart your terminal session to apply the changes."

# Optional instruction to manually change theme and plugins in .zshrc
echo "To activate Powerlevel10k, set ZSH_THEME=\"powerlevel10k/powerlevel10k\" in your .zshrc."
echo "Don't forget to add zsh-autosuggestions and zsh-syntax-highlighting to the plugins in .zshrc."
