#!/bin/bash
# Fuzzy tab picker for kitty using fzf
# Lists all tabs (except current) and switches to selected one
# Shows full context: path, processes, and terminal preview

export PATH="/opt/homebrew/bin:$PATH"

home_dir="$HOME"

# Build the list with tab_id, window_id, and display info
kitty @ ls 2>/dev/null | jq -r --arg home "$home_dir" '
  .[].tabs | to_entries[] |
  select(.value.is_focused == false) |
  (.value.windows[] | select(.is_active)) as $win |
  $win.cwd as $cwd |
  # Full path with ~ substitution
  ($cwd | sub("^\($home)"; "~")) as $full_path |
  # Get foreground process info
  ($win.foreground_processes | map(.cmdline | join(" ")) | join(" | ")) as $procs |
  # Format: tab_id:window_id<TAB>display_info
  "\(.value.id):\($win.id)\t\(.key + 1): \(.value.title)  │  \($full_path)  │  \($procs)"
' | fzf --with-nth 2.. --delimiter='\t' --prompt="Switch to tab: " \
      --height=80% --layout=reverse --border \
      --preview 'win_id=$(echo {} | cut -d: -f2 | cut -f1); kitty @ get-text -m id:$win_id --extent=screen 2>/dev/null | tail -50' \
      --preview-window=right:60%:wrap \
  | cut -d: -f1 \
  | xargs -I{} kitty @ focus-tab -m id:{}
