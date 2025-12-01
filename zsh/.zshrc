# =============================================================================
# Minimal ZSH Config with Zinit
# =============================================================================

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

# -----------------------------------------------------------------------------
# Prompt - Starship with transient prompt
# -----------------------------------------------------------------------------
eval "$(starship init zsh)"

# Transient prompt - collapse previous prompts to minimal
zle-line-init() {
  emulate -L zsh
  [[ $CONTEXT == start ]] || return 0

  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT
  PROMPT='❯ '
  RPROMPT=''
  zle .reset-prompt
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  if (( ret )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}
zle -N zle-line-init

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

# Fix Ctrl+[ for Ghostty (CSI u encoding)
bindkey '^[[91;5u' vi-cmd-mode

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
# fzf - fuzzy finder
# -----------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------
export VISUAL="nvim"
export EDITOR="nvim"

# PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$(go env GOPATH 2>/dev/null)/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"

# Java
export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null)

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias vi='nvim'
alias vim='nvim'
alias lg='lazygit'
alias k='kubectl'

# Clipboard (cross-platform)
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias c='pbcopy'
    alias p='pbpaste'
else
    alias c='xclip -selection clipboard'
    alias p='xclip -selection clipboard -o'
fi

# Git
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -20'

# Navigation & listing (eza = modern ls)
alias ..='cd ..'
alias ...='cd ../..'
alias ll='eza -l'
alias l='eza -la'
alias la='eza -la'
alias lt='eza -la --tree --level=2'

# Ports
alias listenports="lsof -iTCP -sTCP:LISTEN -n"

# Time zones
alias swisstime='TZ="Europe/Zurich" date "+%Y-%m-%d %H:%M:%S %Z"'
alias sgtime='TZ="Asia/Singapore" date "+%Y-%m-%d %H:%M:%S %Z"'

# Fuzzy kill processes
alias fkill='ps -ef | fzf --multi | awk "{print \$2}" | xargs kill'

# -----------------------------------------------------------------------------
# Custom functions
# -----------------------------------------------------------------------------
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

