# =============================================================================
# Brewfile - Homebrew Bundle
# =============================================================================
# Install: brew bundle --file=~/dotfiles/Brewfile
# Update:  brew bundle dump --file=~/dotfiles/Brewfile --force

# -----------------------------------------------------------------------------
# Taps
# -----------------------------------------------------------------------------
tap "felixkratz/formulae"       # borders
tap "homebrew/cask-fonts"
tap "homebrew/services"
tap "nikitabobko/tap"           # aerospace

# Development taps (keep if using these tools)
tap "adoptopenjdk/openjdk"
tap "coursier/formulas"
tap "d12frosted/emacs-plus"
tap "dart-lang/dart"
tap "ngrok/ngrok"
tap "scalacenter/bloop"

# -----------------------------------------------------------------------------
# Core CLI - Modern Replacements (Rust-based)
# -----------------------------------------------------------------------------
brew "bat"                      # cat replacement
brew "btop"                     # top/htop replacement
brew "duf"                      # df replacement
brew "dust"                     # du replacement
brew "eza"                      # ls replacement
brew "fd"                       # find replacement
brew "ripgrep"                  # grep replacement
brew "zoxide"                   # cd/autojump replacement
brew "git-delta"                # diff replacement

# -----------------------------------------------------------------------------
# Shell & Terminal
# -----------------------------------------------------------------------------
brew "atuin"                    # shell history with sync
brew "fzf"                      # fuzzy finder
brew "starship"                 # prompt
brew "tmux"                     # terminal multiplexer
brew "zellij"                   # modern terminal workspace

# -----------------------------------------------------------------------------
# Editor & Development
# -----------------------------------------------------------------------------
brew "neovim"
brew "lazygit"                  # git TUI
brew "gh"                       # github CLI
brew "just"                     # task runner

# -----------------------------------------------------------------------------
# File Management
# -----------------------------------------------------------------------------
brew "yazi"                     # terminal file manager
brew "ffmpegthumbnailer"        # yazi video thumbnails
brew "unar"                     # yazi archive preview
brew "glow"                     # markdown preview

# -----------------------------------------------------------------------------
# Languages & Runtimes
# -----------------------------------------------------------------------------
brew "go"
brew "node"
brew "python@3.13"
brew "rust"
brew "rustup"
brew "ruby"

# Java ecosystem
brew "openjdk"
brew "openjdk@11"
brew "openjdk@17"
brew "jenv"
brew "maven"
brew "gradle"
brew "sbt"
brew "scala"

# Python tools
brew "pipx"
brew "pyenv"
brew "pyenv-virtualenv"

# -----------------------------------------------------------------------------
# Data & JSON/YAML
# -----------------------------------------------------------------------------
brew "jq"                       # JSON processor
brew "yq"                       # YAML processor
brew "xsv"                      # CSV toolkit
brew "miller"                   # CSV/JSON/etc swiss army knife
brew "htmlq"                    # HTML processor (like jq)
brew "pup"                      # HTML parsing
brew "fx"                       # JSON viewer

# -----------------------------------------------------------------------------
# Network & HTTP
# -----------------------------------------------------------------------------
brew "httpie"                   # modern curl
brew "wget"
brew "curl"
brew "nmap"
brew "ngrep"
brew "socat"
brew "telnet"

# -----------------------------------------------------------------------------
# Kubernetes & Containers
# -----------------------------------------------------------------------------
brew "kubernetes-cli"           # kubectl
brew "kubectx"                  # switch contexts/namespaces
brew "helm"
brew "stern"                    # multi-pod log tailing
brew "kind"                     # k8s in docker
brew "minikube"
brew "dive"                     # explore docker images
brew "colima"                   # docker runtime for mac
brew "podman"
brew "skopeo"                   # container image tools

# -----------------------------------------------------------------------------
# PDF & Documents
# -----------------------------------------------------------------------------
brew "pandoc"
brew "pdfgrep"
brew "pdftk-java"
brew "qpdf"
brew "diff-pdf"
brew "ghostscript"
brew "poppler"

# -----------------------------------------------------------------------------
# Media
# -----------------------------------------------------------------------------
brew "ffmpeg"
brew "imagemagick"
brew "tesseract"                # OCR
brew "timg"                     # terminal image viewer
brew "youtube-dl"

# -----------------------------------------------------------------------------
# Security & Crypto
# -----------------------------------------------------------------------------
brew "gnupg"
brew "pinentry-mac"
brew "openssh"
brew "libfido2"                 # FIDO2/WebAuthn
brew "nmap"
brew "yara"                     # malware patterns

# -----------------------------------------------------------------------------
# Misc CLI Tools
# -----------------------------------------------------------------------------
brew "coreutils"
brew "tree"
brew "watch"
brew "tlrc"                     # tldr pages
brew "glances"                  # system monitoring
brew "cloc"                     # count lines of code
brew "rclone"                   # cloud storage sync
brew "ansible"

# -----------------------------------------------------------------------------
# macOS Window Management
# -----------------------------------------------------------------------------
brew "felixkratz/formulae/borders"  # window borders

# -----------------------------------------------------------------------------
# Casks - GUI Applications
# -----------------------------------------------------------------------------
cask "aerospace"                # tiling window manager
cask "kitty"                    # terminal
cask "ghostty"                  # terminal (alternative)

# Fonts
cask "font-jetbrains-mono-nerd-font"
cask "font-hack-nerd-font"
cask "font-fira-code-nerd-font"

# Apps
cask "keepassxc"                # password manager
cask "vlc"                      # media player
cask "calibre"                  # ebook management
cask "inkscape"                 # vector graphics
cask "ngrok"                    # tunneling

# -----------------------------------------------------------------------------
# REMOVED (kept for reference)
# -----------------------------------------------------------------------------
# brew "autojump"               # replaced by zoxide
# brew "yabai"                  # replaced by aerospace
# brew "skhd"                   # was for yabai
# brew "spacebar"               # was for yabai
# brew "zsh-autosuggestions"    # using zinit instead
# brew "zsh-syntax-highlighting" # using zinit instead
# brew "zsh-vi-mode"            # manual config in zshrc
