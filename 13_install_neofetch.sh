#!/bin/bash

# Create local bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Clone the neofetch repository into the local directory
git clone https://github.com/dylanaraps/neofetch.git ~/.local/neofetch

# Copy the neofetch script to ~/.local/bin
cp ~/.local/neofetch/neofetch ~/.local/bin/

# Ensure ~/.local/bin is in the user's PATH
if ! echo $PATH | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
  echo "Added ~/.local/bin to PATH. Please restart your terminal."
fi

# Notify user of completion
echo "Neofetch installed! Run it with 'neofetch'."

