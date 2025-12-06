# =============================================================================
# Minimal ZSH Config with Zinit
# =============================================================================

# -----------------------------------------------------------------------------
# PATH (set early so tools are available)
# -----------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.fzf/bin:$PATH"
export PATH="$HOME/.atuin/bin:$PATH"

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
# fzf - fuzzy finder (Ctrl+T for files, Alt+C for dirs)
# -----------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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

# Fuzzy kill processes
alias fkill='ps -ef | fzf --multi | awk "{print \$2}" | xargs kill'

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
alias gco='git branch -a --sort=-committerdate --format="%(refname:short)" | fzf --header "Checkout branch" | sed "s#^origin/##" | xargs git checkout'
alias glog='git log --oneline | fzf --preview "git show {1}" --bind "enter:execute(git show {1})"'

# -----------------------------------------------------------------------------
# Custom functions
# -----------------------------------------------------------------------------

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
# Conda (lazy load - only init when you run 'conda')
# -----------------------------------------------------------------------------
conda() {
    unfunction conda 2>/dev/null
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    fi
    conda "$@"
}

# -----------------------------------------------------------------------------
# Background jobs - run commands that survive disconnection
# -----------------------------------------------------------------------------
# run <cmd>  - run command in background with logging
# runs       - list background jobs
# runlog     - view/tail logs (fzf picker)
# runrm      - clean up finished job logs

_RUN_DIR="${HOME}/.local/share/run"

run() {
    [[ -z "$1" ]] && { echo "Usage: run <command> [args...]"; return 1; }
    mkdir -p "$_RUN_DIR"

    local name="${1:t}"  # basename of command
    local ts=$(date +%Y%m%d_%H%M%S)
    local logfile="${_RUN_DIR}/${name}_${ts}.log"

    echo "$ $*" > "$logfile"
    echo "Started: $(date)" >> "$logfile"
    echo "---" >> "$logfile"

    nohup "$@" >> "$logfile" 2>&1 &
    local pid=$!
    echo "$pid" > "${logfile%.log}.pid"

    echo "Running: $name (PID: $pid)"
    echo "Log: $logfile"
}

runs() {
    mkdir -p "$_RUN_DIR"
    local found=0

    for pidfile in "$_RUN_DIR"/*.pid(N); do
        [[ ! -f "$pidfile" ]] && continue
        found=1

        local pid=$(<"$pidfile")
        local logfile="${pidfile%.pid}.log"
        local name=$(basename "$logfile" .log)

        if kill -0 "$pid" 2>/dev/null; then
            echo "● $name (PID: $pid) - running"
        else
            echo "○ $name (PID: $pid) - done"
        fi
    done

    [[ $found -eq 0 ]] && echo "No background jobs"
}

runlog() {
    mkdir -p "$_RUN_DIR"
    local logs=("$_RUN_DIR"/*.log(N))

    [[ ${#logs[@]} -eq 0 ]] && { echo "No logs found"; return 1; }

    local logfile
    if [[ ${#logs[@]} -eq 1 ]]; then
        logfile="${logs[1]}"
    elif command -v fzf &> /dev/null; then
        logfile=$(printf '%s\n' "${logs[@]}" | xargs -n1 basename | \
            fzf --height=40% --reverse --prompt="log> " | \
            xargs -I{} echo "$_RUN_DIR/{}")
        [[ -z "$logfile" ]] && return 1
    else
        logfile="${logs[-1]}"  # most recent
    fi

    echo "=== $logfile ==="
    tail -f "$logfile"
}

runrm() {
    mkdir -p "$_RUN_DIR"
    local cleaned=0

    for pidfile in "$_RUN_DIR"/*.pid(N); do
        [[ ! -f "$pidfile" ]] && continue
        local pid=$(<"$pidfile")

        if ! kill -0 "$pid" 2>/dev/null; then
            rm -f "$pidfile" "${pidfile%.pid}.log"
            ((cleaned++))
        fi
    done

    echo "Cleaned $cleaned finished job(s)"
}

[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
