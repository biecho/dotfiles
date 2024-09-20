#!/bin/bash

# Create the local fonts directory
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Array of fonts to install (you can add more as needed)
declare -A FONTS
FONTS["DroidSansMono"]="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf"
FONTS["FiraCode"]="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.otf"
FONTS["JetBrainsMono"]="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Regular/JetBrainsMonoNerdFont-Regular.otf"
FONTS["Hack"]="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Regular/HackNerdFont-Regular.otf"
FONTS["MesloLGS"]="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/L/Regular/MesloLGSNerdFont-Regular.otf"

# Download and install each font
for font in "${!FONTS[@]}"; do
    echo "Downloading $font Nerd Font..."
    curl -fLo "$FONT_DIR/${font}NerdFont-Regular.otf" "${FONTS[$font]}"
done

# Refresh the font cache (Linux specific)
if command -v fc-cache >/dev/null 2>&1; then
    echo "Refreshing font cache..."
    fc-cache -fv
else
    echo "Font cache not found, please refresh manually."
fi

echo "Nerd Fonts installation complete!"

