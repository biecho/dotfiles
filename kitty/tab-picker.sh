#!/bin/bash
# Fuzzy tab picker for kitty using fzf
# Lists all tabs (except current) and switches to selected one

export PATH="/opt/homebrew/bin:$PATH"

kitty @ ls 2>/dev/null | jq -r '
  .[].tabs | to_entries[] |
  select(.value.is_focused == false) |
  "\(.value.id)\t\(.key + 1): \(.value.title)"
' | fzf --with-nth 2.. --delimiter='\t' --prompt="Switch to tab: " \
  | cut -f1 \
  | xargs -I{} kitty @ focus-tab -m id:{}
