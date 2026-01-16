#!/bin/bash
# Fuzzy tab picker for kitty using fzf
# Shows: tab number, host, process, directory (remote cwd for SSH!)

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

  # Get foreground process info
  $win.foreground_processes[0] as $fg |
  ($fg.cmdline[0] // "shell" | split("/") | last) as $proc |

  # Detect SSH: find hostname after "--" separator (kitten ssh format)
  (if ($proc == "ssh") then
    ($fg.cmdline | to_entries | map(select(.value == "--")) | first.key) as $idx |
    (if $idx then $fg.cmdline[$idx + 1] else null end) //
    ($fg.cmdline[1:] | map(select(test("^[^-/][^/]*@"))) | first | split("@") | last) //
    null
  else
    null
  end) as $ssh_host |

  # For SSH tabs, parse remote cwd from title (format: "host: /path" or just use title)
  # For local tabs, use cwd with ~ substitution
  (if $ssh_host then
    # Title format from shell integration: "host: ~/path" or process name
    (.value.title | capture(": (?<path>.+)$") | .path) //
    (.value.title | capture("^[^:]+: (?<path>.+)") | .path) //
    "~"
  else
    ($win.cwd | sub("^\($home)"; "~"))
  end) as $path |

  # Output: id, tab_num, host, proc, path
  "\(.value.id)\t\(.key + 1)\t\($ssh_host // "local")\t\($proc)\t\($path)"
' | while IFS=$'\t' read -r id num host proc path; do
  # Format with colors
  if [[ "$host" == "local" ]]; then
    host_display="${DIM}local${RESET}"
  else
    host_display="${CYAN}${host}${RESET}"
  fi
  printf "%s\t${YELLOW}%s${RESET}  %s  ${GREEN}%s${RESET}  ${DIM}%s${RESET}\n" \
    "$id" "$num" "$host_display" "$proc" "$path"
done | fzf --ansi --with-nth 2.. --delimiter='\t' --prompt="❯ " \
      --height=50% --layout=reverse --border=rounded \
      --no-info --margin=1 --padding=1 \
  | cut -f1 \
  | xargs -I{} kitty @ focus-tab -m id:{}
