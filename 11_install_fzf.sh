#!/bin/bash

# Clone the fzf repository to the local directory
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

# Run the installation script for fzf
~/.fzf/install --key-bindings --completion --no-update-rc

# Check if the fzf configuration is already added to .zshrc
if ! grep -q 'source ~/.fzf.zsh' ~/.zshrc; then
  echo 'Adding fzf configuration to ~/.zshrc'
  echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' >> ~/.zshrc
fi

# Add multi-selection fkill alias if not already defined
if ! grep -q 'alias fkill=' ~/.zshrc; then
  echo 'Adding fkill alias with multi-selection to ~/.zshrc'
  cat <<EOL >> ~/.zshrc
# fzf smart alias for killing multiple processes
alias fkill='ps -ef | fzf --multi | awk "{print \\$2}" | xargs kill'  # Fuzzy multi-selection kill
EOL
fi

# Inform the user to restart their terminal
echo "fzf installation is complete! The necessary configuration and aliases have been added to ~/.zshrc. Please restart your terminal to apply the changes."

