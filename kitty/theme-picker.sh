#!/bin/bash
# Theme picker wrapper - runs kitten themes then applies to ALL windows.
# kitten themes writes the choice to ~/.config/kitty/current-theme.conf (a real
# file, not a repo symlink), so apply the colors from that same path.
kitten themes
kitty @ set-colors --all "${KITTY_CONFIG_DIRECTORY:-$HOME/.config/kitty}/current-theme.conf"
