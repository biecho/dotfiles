# =============================================================================
# Minimal ZSH Config with Zinit
# =============================================================================

# -----------------------------------------------------------------------------
# PATH (set early so tools are available)
# -----------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.fzf/bin:$PATH"
export PATH="$HOME/.atuin/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/dotfiles/scripts:$PATH"

# -----------------------------------------------------------------------------
# fnm (Fast Node Manager) - user-local Node.js
# -----------------------------------------------------------------------------
if [[ -d "$HOME/.local/share/fnm" ]]; then
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"
fi

# -----------------------------------------------------------------------------
# Zinit setup
# -----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Auto-install zinit if not present
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# -----------------------------------------------------------------------------
# Plugins
# -----------------------------------------------------------------------------
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# Oh-My-Zsh git plugin (provides gco, gcb, gst, etc.)
zinit snippet OMZP::git

# -----------------------------------------------------------------------------
# Prompt - Starship
# -----------------------------------------------------------------------------
eval "$(starship init zsh)"

# -----------------------------------------------------------------------------
# Vi mode
# -----------------------------------------------------------------------------
bindkey -v
export KEYTIMEOUT=1

# Better vi mode bindings
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# Cursor shape for vi modes (block=normal, bar=insert)
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 == 'block' ]]; then
    echo -ne '\e[2 q'  # block cursor
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ $1 == 'beam' ]]; then
    echo -ne '\e[6 q'  # bar cursor
  fi
}
zle -N zle-keymap-select

# Start with bar cursor (insert mode is default)
echo -ne '\e[6 q'

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# -----------------------------------------------------------------------------
# Completion (cached - only rebuild once per day)
# -----------------------------------------------------------------------------
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # skip security check, use cache
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# -----------------------------------------------------------------------------
# Directory jumping - zoxide (faster autojump alternative)
# -----------------------------------------------------------------------------
eval "$(zoxide init zsh)"

# -----------------------------------------------------------------------------
# fzf - fuzzy finder (Ctrl+T for files, Alt+C for dirs, also cmd+alt+o in kitty)
# -----------------------------------------------------------------------------
if command -v fd &>/dev/null; then
    export FZF_CTRL_T_COMMAND="fd --type f --exclude .git"
    _fzf_show_hidden="fd --type f --hidden --exclude .git"
else
    export FZF_CTRL_T_COMMAND="find . -type f -not -path '*/.*'"
    _fzf_show_hidden="find . -type f -not -path '*/.git/*'"
fi
if command -v bat &>/dev/null; then
    _fzf_preview="bat --style=numbers --color=always --line-range=:100 {}"
else
    _fzf_preview="head -100 {}"
fi
export FZF_CTRL_T_OPTS="
    --preview '$_fzf_preview'
    --header 'ctrl-/: toggle hidden files'
    --bind 'ctrl-/:reload($_fzf_show_hidden)+unbind(ctrl-/)+rebind(ctrl-g)'
    --bind 'ctrl-g:reload($FZF_CTRL_T_COMMAND)+unbind(ctrl-g)+rebind(ctrl-/)'"
unset _fzf_preview _fzf_show_hidden
eval "$(fzf --zsh)"

# -----------------------------------------------------------------------------
# atuin - better shell history (Ctrl+R) - must be after fzf to override
# -----------------------------------------------------------------------------
if command -v atuin &> /dev/null; then
    eval "$(atuin init zsh)"
fi

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------
export VISUAL="nvim"
export EDITOR="nvim"

# Additional PATH (platform-specific)
command -v go &>/dev/null && export PATH="$(go env GOPATH)/bin:$PATH"
[[ -d "/Library/TeX/texbin" ]] && export PATH="/Library/TeX/texbin:$PATH"

# Java (macOS)
[[ "$OSTYPE" == "darwin"* ]] && export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null)

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias vi='nvim'
alias vim='nvim'
alias lg='lazygit'
alias icat='kitten icat'
alias kssh='kitten ssh'

# Clipboard (kitten clipboard works locally and over kitten ssh)
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias c='pbcopy'
    alias p='pbpaste'
else
    alias c='kitten clipboard'
    alias p='kitten clipboard --get-clipboard'
fi

# Navigation & listing (eza = modern ls)
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
eza_params='--icons --group-directories-first --no-git'
alias ls="eza $eza_params"
alias l="eza -la $eza_params"
alias ll="eza -l $eza_params"
alias la="eza -la --header $eza_params"
alias ld="eza -lD $eza_params"       # dirs only
alias lf="eza -lf $eza_params"       # files only
alias lm="eza -la --sort=modified $eza_params"
alias lz="eza -la --sort=size $eza_params"
alias tree="eza --tree $eza_params"
lt() { eza -la --tree --level="${1:-2}" ${=eza_params}; }  # lt [depth]

# bat (modern cat with syntax highlighting)
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'  # with paging
fi

# btop (modern top/htop)
if command -v btop &> /dev/null; then
    alias top='btop'
    alias htop='btop'
fi

# duf (modern df - disk free)
if command -v duf &> /dev/null; then
    alias df='duf'
fi

# yazi file manager (cd to directory on exit with 'y')
if command -v yazi &> /dev/null; then
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi

# Claude Code (skip permission prompts)
alias claude='claude --dangerously-skip-permissions'

# Ports
alias listenports="lsof -iTCP -sTCP:LISTEN -n"

# Time zones
alias swisstime='TZ="Europe/Zurich" date "+%Y-%m-%d %H:%M:%S %Z"'
alias sgtime='TZ="Asia/Singapore" date "+%Y-%m-%d %H:%M:%S %Z"'

# Fuzzy kill processes (with preview, sorted by CPU; optional signal: fkill 9)
fkill() {
  local pid sig=${1:-15}
  pid=$(ps -eo pid,user,%cpu,%mem,etime,comm --sort=-%cpu \
    | fzf --multi --header-lines=1 \
          --preview='ps -p {1} -o pid,ppid,user,%cpu,%mem,etime,args 2>/dev/null' \
          --preview-window=down:3:wrap \
    | awk '{print $1}')
  [ -n "$pid" ] && echo "$pid" | xargs kill -"$sig"
}

# Show files a process has open for writing (fzf picker or direct PID)
# Usage: ffiles [PID]  — omit PID to fuzzy-pick a process
ffiles() {
  local preview_cmd pid
  if [[ "$OSTYPE" == "darwin"* ]]; then
    preview_cmd='lsof -p {1} 2>/dev/null | grep -E "REG.*[0-9]+w" | head -20'
  else
    preview_cmd='ls -l /proc/{1}/fd 2>/dev/null | head -30'
  fi
  pid=${1:-$(ps -eo pid,user,%cpu,%mem,args --sort=-%cpu \
    | fzf --header-lines=1 --header "Select process to inspect" \
          --preview="$preview_cmd" \
          --preview-window=down:6:wrap \
    | awk '{print $1}')}
  [[ -z "$pid" ]] && return 1
  echo "Files open for writing by PID $pid ($(ps -p $pid -o comm= 2>/dev/null)):"
  typeset -A seen
  local found=0
  if [[ "$OSTYPE" == "darwin"* ]]; then
    lsof -p "$pid" 2>/dev/null | awk '$4 ~ /w$/ && $5 == "REG" {print $9}' | while read -r target; do
      [[ -n "${seen[$target]}" ]] && continue
      seen[$target]=1
      echo "  $target"
      found=1
    done
  else
    if [[ ! -d "/proc/$pid/fd" ]]; then
      echo "  Process $pid not found (or no permission)"
      return 1
    fi
    for fd in /proc/$pid/fd/*; do
      local mode=$(cat /proc/$pid/fdinfo/${fd##*/} 2>/dev/null | awk '/^flags:/{print $2}')
      if [[ -n "$mode" ]] && (( (0$mode & 3) > 0 )); then
        local target=$(readlink "$fd" 2>/dev/null)
        [[ "$target" == /proc/* || "$target" == pipe:* || "$target" == socket:* || "$target" == anon_inode:* ]] && continue
        [[ -n "${seen[$target]}" ]] && continue
        seen[$target]=1
        echo "  $target"
        found=1
      fi
    done
  fi
  (( ! found )) && echo "  (none — only reading or using pipes/sockets)"
}

# Recently modified files (recursive, fzf preview)
# Usage: frecent [-a] [count]   (-a = all files, no recency/hidden filter)
frecent() {
  local all=false
  [[ "$1" == "-a" ]] && { all=true; shift; }
  local count=${1:-20}
  if command -v fd &>/dev/null; then
    if $all; then
      fd --type f --hidden --no-ignore --exclude .git
    else
      fd --type f --hidden --exclude .git --change-newer-than 4weeks
    fi | xargs stat --format='%Y %n' 2>/dev/null \
       | sort -rn | head -"$count" \
       | while read -r epoch file; do
           printf "%s  %s\n" "$(date -d @"$epoch" '+%Y-%m-%d %H:%M')" "$file"
         done
  else
    find . -type f -not -path '*/.git/*' -printf '%T@ %p\n' \
      | sort -rn | head -"$count" \
      | while read -r epoch file; do
          printf "%s  %s\n" "$(date -d @"${epoch%.*}" '+%Y-%m-%d %H:%M')" "$file"
        done
  fi | fzf --multi --with-nth=1,2,3 --nth=3 \
       --preview "bat --style=numbers --color=always --line-range=:100 {3} 2>/dev/null || head -100 {3}" \
       --header "Recently modified files (top $count)" \
       --bind 'enter:become(nvim {+3})'
}

# Kill process on a specific port (usage: fkillport 8080)
fkillport() {
  local pid
  pid=$(lsof -ti :"${1:?usage: fkillport PORT}" 2>/dev/null || ss -tlnp "sport = :$1" 2>/dev/null | awk 'NR>1{match($0,/pid=([0-9]+)/,a); print a[1]}')
  [ -n "$pid" ] && echo "Killing PID $pid on port $1" && echo "$pid" | xargs kill -15 || echo "No process found on port $1"
}

# Utility aliases (inspired by mathiasbynens, jessfraz, paulirish dotfiles)
alias reload='exec $SHELL -l'                       # reload shell config
alias chmox='chmod +x'                              # make executable
alias pubip='curl -s https://ipinfo.io/ip'          # public IP address
alias localip='ipconfig getifaddr en0'              # local IP address
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"  # remove .DS_Store recursively
alias map='xargs -n1'                               # apply command to each line (e.g., find . | map wc -l)
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'  # simple stopwatch

# macOS specific utilities
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias afk='pmset displaysleepnow'               # lock screen / sleep display
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
fi

# Fuzzy git (fzf-powered branch/log navigation)
# gco   - checkout branch (local or remote, sorted by recent)
# glog  - browse commits with preview, enter to show full commit
unalias gco 2>/dev/null
gco() {
    if [[ -n "$1" ]]; then
        git checkout "$@"
    else
        git branch -a --sort=-committerdate --format="%(refname:short)" | fzf --header "Checkout branch" | sed "s#^origin/##" | xargs git checkout
    fi
}
alias glog='git log --oneline | fzf --preview "git show {1}" --bind "enter:execute(git show {1})"'

# Fuzzy git branch deletion (Tab to multi-select)
# gbd   - delete local branch(es), safe (checks if merged)
# gbD   - delete local branch(es), force (no merge check)
# gbdr  - delete remote branch(es) from origin
alias gbd='git branch --sort=-committerdate | grep -v "^\*" | fzf --multi --header "Delete local branch(es)" | xargs -r git branch -d'
alias gbD='git branch --sort=-committerdate | grep -v "^\*" | fzf --multi --header "FORCE delete local branch(es)" | xargs -r git branch -D'
alias gbdr='git branch -r --sort=-committerdate | grep -v HEAD | fzf --multi --header "Delete REMOTE branch(es)" | sed "s#origin/##" | xargs -I {} git push origin --delete {}'

# -----------------------------------------------------------------------------
# Custom functions
# -----------------------------------------------------------------------------

# Choose files (kitty kitten) - fuzzy file picker with previews
if [[ "$TERM" == "xterm-kitty" ]]; then
    # Select file(s) - prints path(s) to stdout
    cf() { kitten choose-files --mode=files "$@"; }

    # Select directory - prints path to stdout
    cfd() { kitten choose-files --mode=dir "$@"; }

    # Open file(s) in nvim via picker
    nvf() {
        local files=$(kitten choose-files --mode=files)
        [[ -n "$files" ]] && nvim $files
    }

    # Open directory in nvim via picker (oil.nvim / netrw)
    nvd() {
        local dir=$(kitten choose-files --mode=dir)
        [[ -n "$dir" ]] && nvim "$dir"
    }
fi

# fzf file picker - works locally and over SSH (no kitty kitten needed)
# Triggered by kitty shortcut (cmd+alt+o) via send_text
_fzf_pick_file() {
    local cmd preview
    if command -v fd &>/dev/null; then
        cmd="fd --type f --hidden --exclude .git"
    else
        cmd="find . -type f -not -path '*/.git/*'"
    fi
    if command -v bat &>/dev/null; then
        preview="bat --style=numbers --color=always --line-range=:100 {}"
    else
        preview="head -100 {}"
    fi
    local file=$(eval "$cmd" | fzf --preview "$preview" --height=80% --border)
    if [[ -n "$file" ]]; then
        LBUFFER+="$file"
    fi
    zle redisplay
}
zle -N _fzf_pick_file
bindkey '\e[pick-file' _fzf_pick_file

# Jump to project and open editor
workon() { z "$1" && nvim . }

# Make directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

# Pretty print PATH
alias path='echo $PATH | tr ":" "\n"'

# What's running on a port (usage: ports 3000)
ports() { lsof -i ":${1:-80}" }

# Universal archive extractor
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "Unknown archive format: $1" ;;
        esac
    else
        echo "File not found: $1"
    fi
}

function ssh_setup() {
    if [ -z "$1" ]; then
        echo "Usage: ssh_setup /path/to/your/key"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: SSH key '$1' does not exist."
        return 1
    fi
    eval "$(ssh-agent -s)"
    ssh-add "$1"
    echo "SSH Agent started and key added."
}

function daily() {
    mkdir -p ./daily
    local date=$(date +%Y-%m-%d)
    local filepath="./daily/${date}.md"

    if [[ ! -f "$filepath" ]]; then
        if [[ -f ~/.config/research-templates/daily.md ]]; then
            sed "s/{{DATE}}/${date}/g" ~/.config/research-templates/daily.md > "$filepath"
        else
            echo "# ${date}" > "$filepath"
        fi
        nvim "$filepath"
    else
        echo -e "\n---\n### $(date +%H:%M)\n" >> "$filepath"
        nvim + "$filepath"
    fi
}

function plog() {
    mkdir -p ./logs
    local date=$(date +%Y-%m-%d)
    local filepath="./logs/${date}.md"

    if [[ ! -f "$filepath" ]]; then
        if [[ -f ~/.config/research-templates/paper-log.md ]]; then
            sed "s/{{DATE}}/${date}/g" ~/.config/research-templates/paper-log.md > "$filepath"
        else
            echo "# ${date} - Paper Log" > "$filepath"
        fi
        nvim "$filepath"
    else
        echo -e "\n---\n### Session: $(date +%H:%M)\n" >> "$filepath"
        nvim + "$filepath"
    fi
}

# Serve files via HTTP
function serve_files() {
    local port=${1:-8000}
    local directory=${2:-$(pwd)}

    if lsof -i :"$port" > /dev/null 2>&1; then
        echo "Error: Port $port is already in use."
        return 1
    fi

    echo "Serving files from $directory on http://localhost:$port"
    python3 -m http.server "$port" --directory "$directory"
}

# -----------------------------------------------------------------------------
# Conda (lazy load - binary in PATH, full init on first use)
# -----------------------------------------------------------------------------
export PATH="/opt/miniconda3/bin:$PATH"

# Full init (for conda activate) happens on first conda command
conda() {
    unfunction conda 2>/dev/null
    . "/opt/miniconda3/etc/profile.d/conda.sh"
    conda "$@"
}


# -----------------------------------------------------------------------------
# YouTube audio download (controlled workflow)
# -----------------------------------------------------------------------------
_YT_DIR="$HOME/Music/YouTube"

# Add URL to queue for later download
ytq() {
    [[ -z "$1" ]] && { echo "Usage: ytq <url>"; return 1; }
    mkdir -p "$_YT_DIR"
    echo "$1" >> "$_YT_DIR/queue.txt"
    echo "Queued: $1"
    echo "Queue has $(wc -l < "$_YT_DIR/queue.txt" | tr -d ' ') item(s)"
}

# Download all queued items (skips already downloaded)
# Usage: ytd [subfolder]  (e.g., ytd Electronic/Melodic-Techno)
ytd() {
    mkdir -p "$_YT_DIR"
    local queue="$_YT_DIR/queue.txt"
    local dest="$_YT_DIR"

    # If subfolder provided, use it as destination
    if [[ -n "$1" ]]; then
        dest="$_YT_DIR/$1"
        mkdir -p "$dest"
    fi

    [[ ! -s "$queue" ]] && { echo "Queue is empty"; return 0; }

    echo "Downloading $(wc -l < "$queue" | tr -d ' ') item(s) to $dest..."
    yt-dlp -x --audio-format mp3 --audio-quality 0 \
        --no-playlist --restrict-filenames \
        -o "$dest/%(title)s.%(ext)s" \
        --download-archive "$_YT_DIR/.archive" \
        -a "$queue"

    > "$queue"  # clear queue after download
    echo "Done. Queue cleared."
}

# Show queue contents
ytls() {
    local queue="$HOME/Music/YouTube/queue.txt"
    [[ ! -s "$queue" ]] && { echo "Queue is empty"; return 0; }
    cat -n "$queue"
}

[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"

# Kitty shell integration
if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
fi

# Kitty shell integration for SSH (kitten ssh)
if [[ -z "$KITTY_INSTALLATION_DIR" ]] && [[ -f "$HOME/.local/share/kitty-ssh-kitten/shell-integration/zsh/kitty-integration" ]]; then
    export KITTY_SHELL_INTEGRATION="enabled"
    autoload -Uz -- "$HOME/.local/share/kitty-ssh-kitten/shell-integration/zsh/kitty-integration"
    kitty-integration
    unfunction kitty-integration
fi
