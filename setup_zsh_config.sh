#!/bin/bash

CONFIG_LINE="source ~/.zsh_configs/clipboard_config.sh"

# Check if .zshrc already contains the line
if grep -q "$CONFIG_LINE" ~/.zshrc; then
    echo "Configuration already added to .zshrc"
else
    echo "$CONFIG_LINE" >> ~/.zshrc
    echo "Configuration added to .zshrc"
fi

