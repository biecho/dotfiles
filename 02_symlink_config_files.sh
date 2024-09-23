#!/bin/bash

DOTFILES_DIR=~/dotfiles

create_link () {
    SRC=$1
    DEST=$2

    # Create parent directory of destination if it doesn't exist
    mkdir -p "$(dirname "$DEST")"

    # Remove the destination file if it exists
    [ -f "$DEST" ] && rm "$DEST"

    # Create the symbolic link
    ln -s "$SRC" "$DEST"
    echo "Linked $SRC to $DEST"
}

# Alacritty configuration
create_link "$DOTFILES_DIR/.config/alacritty/alacritty.yml" ~/.config/alacritty/alacritty.yml

# Tmux configuration
create_link "$DOTFILES_DIR/.config/tmux/tmux.conf" ~/.tmux.conf
create_link "$DOTFILES_DIR/.config/tmux/tmux.conf.local" ~/.tmux.conf.local

# Zsh configuration
create_link "$DOTFILES_DIR/.zshrc" ~/.zshrc

# Procs configuration
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    create_link "$DOTFILES_DIR/.config/procs/config.toml" ~/.config/procs/config.toml
elif [[ "$OSTYPE" == "darwin"* ]]; then
    create_link "$DOTFILES_DIR/.config/procs/config.toml" ~/Library/Preferences/com.github.dalance.procs/config.toml
else
    echo "Unsupported OS: $OSTYPE"
fi

echo "All symbolic links have been set up."

