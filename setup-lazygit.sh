#!/bin/bash

# Define the URL to download Lazygit latest release
LAZYGIT_URL=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep "browser_download_url.*Linux_x86_64.tar.gz" | cut -d '"' -f 4)

# Check if curl and tar are installed
if ! command -v curl &> /dev/null; then
    	echo "curl is required but not installed. Install it using your package manager."
	exit 1
fi

if ! command -v tar &> /dev/null; then
	echo "tar is required but not installed. Install it using your package manager."
	exit 1
fi

# Download the latest release tarball
echo "Downloading Lazygit from $LAZYGIT_URL"
curl -Lo lazygit.tar.gz $LAZYGIT_URL

# Extract the downloaded tarball
echo "Extracting Lazygit..."
tar -xf lazygit.tar.gz

# Move the lazygit binary to /usr/local/bin for global access
echo "Installing Lazygit..."
sudo mv lazygit /usr/local/bin

# Clean up the downloaded tarball
rm lazygit.tar.gz

# Confirm installation
if command -v lazygit &> /dev/null; then
    	echo "Lazygit installed successfully!"
else
	echo "Lazygit installation failed."
    	exit 1
fi

# Determine the user's default shell and add alias to shell config
SHELL_CONFIG="$HOME/.zshrc"

# Add the alias to the shell configuration file
if ! grep -q "alias lg=lazygit" "$SHELL_CONFIG"; then
	echo "Adding alias 'lg' for 'lazygit' to $SHELL_CONFIG"
	echo "alias lg=lazygit" >> "$SHELL_CONFIG"
else
    echo "Alias 'lg' already exists in $SHELL_CONFIG"
fi

# Source the shell configuration file to apply the alias immediately
source "$SHELL_CONFIG"

echo "Alias 'lg' for 'lazygit' added successfully. You can now use 'lg' to launch Lazygit."

