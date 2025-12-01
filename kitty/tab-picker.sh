#!/bin/bash
# Fuzzy tab picker for kitty using fzf
# Lists all tabs (except current) and switches to selected one

export PATH="/opt/homebrew/bin:$PATH"

home_dir="$HOME"
kitty @ ls 2>/dev/null | jq -r --arg home "$home_dir" '
  .[].tabs | to_entries[] |
  select(.value.is_focused == false) |
  (.value.windows[] | select(.is_active) | .cwd) as $cwd |
  (if $cwd == $home then "~" else ($cwd | sub("^.*/"; "")) end) as $dir |
  "\(.value.id)\t\(.key + 1): \(.value.title)  \($dir)"
' | fzf --with-nth 2.. --delimiter='\t' --prompt="Switch to tab: " \
  | cut -f1 \
  | xargs -I{} kitty @ focus-tab -m id:{}
