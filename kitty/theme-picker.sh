#!/bin/bash
# Theme picker wrapper - runs kitten themes then applies to ALL windows
kitten themes
kitty @ set-colors --all ~/dotfiles/kitty/current-theme.conf
