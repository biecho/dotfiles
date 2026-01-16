#!/bin/bash
# Fuzzy tab picker for kitty using fzf
# Shows: tab number, user@host, process, directory

export PATH="/opt/homebrew/bin:$PATH"

# Colors
DIM=$'\033[2m'
CYAN=$'\033[36m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
RESET=$'\033[0m'

kitty @ ls 2>/dev/null | jq -r --arg home "$HOME" '
  .[].tabs | to_entries[] |
  select(.value.is_focused == false) |
  (.value.windows[] | select(.is_active)) as $win |

  # Path with ~ substitution
  ($win.cwd | sub("^\($home)"; "~")) as $path |

  # Get foreground process info
  $win.foreground_processes[0] as $fg |
  ($fg.cmdline[0] // "shell" | split("/") | last) as $proc |

  # Detect remote: check if process is ssh/kitten and find user@host in args
  (if ($proc == "ssh" or $proc == "kitten") then
    # Look for argument containing @ (user@host pattern)
    ($fg.cmdline[1:] | map(select(test("^[^-/][^/]*@"))) | first) //
    # Or just a simple hostname (second arg if not a flag)
    ($fg.cmdline[1] | select(startswith("-") | not) | select(contains("/") | not)) //
    "remote"
  else
    null
  end) as $dest |

  # Output: id, tab_num, dest (or "local"), proc, path
  "\(.value.id)\t\(.key + 1)\t\($dest // "local")\t\($proc)\t\($path)"
' | while IFS=$'\t' read -r id num dest proc path; do
  # Format with colors
  if [[ "$dest" == "local" ]]; then
    dest_display="${DIM}local${RESET}"
  else
    dest_display="${CYAN}${dest}${RESET}"
  fi
  printf "%s\t${YELLOW}%s${RESET}  %s  ${GREEN}%s${RESET}  ${DIM}%s${RESET}\n" \
    "$id" "$num" "$dest_display" "$proc" "$path"
done | fzf --ansi --with-nth 2.. --delimiter='\t' --prompt="❯ " \
      --height=50% --layout=reverse --border=rounded \
      --no-info --margin=1 --padding=1 \
  | cut -f1 \
  | xargs -I{} kitty @ focus-tab -m id:{}
