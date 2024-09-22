#!/bin/bash

# Local installation directory for Autojump
INSTALL_DIR="$HOME/.local/autojump"
ZSHRC_FILE="$HOME/.zshrc"
AUTOJUMP_INIT_LINE="[[ -s \"$HOME/.local/etc/profile.d/autojump.sh\" ]] && source \"$HOME/.local/etc/profile.d/autojump.sh\""

# Remove Autojump directory
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing Autojump from $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
else
    echo "Autojump directory not found at $INSTALL_DIR. Skipping."
fi

# Remove Autojump initialization from .zshrc
if grep -q "$AUTOJUMP_INIT_LINE" "$ZSHRC_FILE"; then
    echo "Removing Autojump initialization from $ZSHRC_FILE..."
    # Create a backup of .zshrc before modifying
    cp "$ZSHRC_FILE" "$ZSHRC_FILE.bak"
    
    # Remove the line from .zshrc
    sed -i "/$AUTOJUMP_INIT_LINE/d" "$ZSHRC_FILE"
    echo "Initialization line removed."
else
    echo "Autojump initialization not found in $ZSHRC_FILE. Skipping."
fi

echo "Autojump uninstallation completed."
echo "Please restart your terminal or run 'source $ZSHRC_FILE' to apply changes."
