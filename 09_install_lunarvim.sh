#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Dependencies list
DEPENDENCIES=("nvim" "git" "make" "pip" "python" "npm" "node" "cargo" "rg")

# Check for all dependencies
for dep in "${DEPENDENCIES[@]}"; do
    if ! command_exists "$dep"; then
        echo "Error: $dep is not installed. Aborting."
        exit 1
    fi
done

# Check Neovim version
NVIM_VERSION=$(nvim --version | head -n 1 | awk '{print $2}')
if [[ "$(printf '%s\n' "0.9" "$NVIM_VERSION" | sort -V | head -n1)" != "0.9" ]]; then
    echo "Error: Neovim version must be 0.9 or later. Aborting."
    exit 1
fi

# If all dependencies are met, install LunarVim
echo "All dependencies are met. Installing LunarVim..."
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

# Add ~/.local/bin to PATH in .zshrc if not already added
if ! grep -q "export PATH=\"$HOME/.local/bin:\$PATH\"" "$HOME/.zshrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    echo "Added ~/.local/bin to PATH in .zshrc"
fi

# Overwrite or add alias for vi to lvim
if grep -q "alias vi=" "$HOME/.zshrc"; then
    sed -i "s/alias vi=.*/alias vi='lvim'/" "$HOME/.zshrc"
    echo "Overwritten existing 'vi' alias to point to 'lvim'."
else
    echo "alias vi='lvim'" >> "$HOME/.zshrc"
    echo "Alias 'vi' to 'lvim' added in .zshrc"
fi

# Do not source .zshrc here to avoid issues with bash.
# Inform the user to manually source .zshrc or restart the shell
echo "LunarVim installation complete!"
echo "You can start it by running: $HOME/.local/bin/lvim"
echo "Do not forget to use a font with glyphs (icons) support [https://github.com/ryanoasis/nerd-fonts]"
echo "To apply the 'vi' alias, please restart your shell or run: source ~/.zshrc"

