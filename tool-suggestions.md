# Tool Suggestions for macOS Developer Setup

Based on research from popular dotfiles repos: [mathiasbynens](https://github.com/mathiasbynens/dotfiles), [holman](https://github.com/holman/dotfiles), [paulirish](https://github.com/paulirish/dotfiles), [ThePrimeagen](https://github.com/ThePrimeagen/.dotfiles).

---

## Currently Installed

### Core CLI Replacements (Rust-based)
| Tool | Replaces | Notes |
|------|----------|-------|
| eza | ls | Icons, git-aware, tree view |
| bat | cat | Syntax highlighting, line numbers |
| ripgrep | grep | Fast, respects .gitignore |
| fd | find | Simple syntax, fast |
| dust | du | Visual disk usage |
| duf | df | Better disk free output |
| zoxide | cd/autojump | Frecency-based jumping |
| delta | diff | Syntax-highlighted git diffs |

### Productivity
| Tool | Purpose |
|------|---------|
| fzf | Fuzzy finder (files, history, branches) |
| atuin | Shell history with sync |
| yazi | Terminal file manager |
| lazygit | Git TUI |
| just | Task runner (Makefile alternative) |
| starship | Fast, customizable prompt |
| btop | System monitor |
| tlrc | Simplified man pages (tldr) |

### macOS-Specific
| Tool | Purpose |
|------|---------|
| AeroSpace | Tiling window manager (i3-like) |
| Borders | Window border styling |
| Karabiner | Keyboard remapping |

---

## Missing (High Value)

These are common in professional dotfiles and would add real value:

| Tool | Why | Used By |
|------|-----|---------|
| **Brewfile** | Reproducible package installs. Run `brew bundle dump` | mathiasbynens, holman, paulirish |
| **.macos script** | Automate macOS system preferences (key repeat, Dock, Finder) | mathiasbynens (famous for this), paulirish |
| **direnv** | Auto-load `.envrc` per project. Essential for API keys, project configs | Almost universal in pro setups |
| **jq** | JSON parsing. Pairs with curl for API work | Universal |
| **gh** | GitHub CLI (PRs, issues from terminal) | Already using for git credential, but not installed explicitly |

---

## Worth Considering

### Fits the Rust/Modern Theme
| Tool | Replaces | Why |
|------|----------|-----|
| sd | sed | Intuitive find & replace, regex |
| procs | ps | Colorful, tree view, Docker column |
| hyperfine | time | Benchmarking with statistical analysis |
| bandwhich | - | Network utilization by process |
| ouch | tar/zip/etc | Universal archive tool |

### Development
| Tool | Purpose |
|------|---------|
| mise | Polyglot version manager (replaces fnm, pyenv, goenv). Single tool for all runtimes |
| httpie / curlie | Modern HTTP clients. Better than curl for API testing |
| watchexec | Run commands on file changes |
| tokei | Code statistics by language |

### Alternative Approaches
| Tool | Purpose | Trade-off |
|------|---------|-----------|
| zellij | Terminal workspace | More modern than tmux, but heavier |
| chezmoi | Dotfiles manager | More features than stow, but more complex |
| Ansible | Machine provisioning | ThePrimeagen uses this. Overkill for personal use? |

---

## Not Needed

These are popular but redundant given current setup:

| Tool | Why Skip |
|------|----------|
| exa | Unmaintained, use eza instead (already installed) |
| autojump | zoxide is faster and better |
| oh-my-zsh | Using zinit (lighter weight) |
| tmux plugins (tpm) | Minimal tmux usage, AeroSpace handles windows |
| nvm | Using fnm (faster) or could switch to mise |

---

## Quick Wins

```bash
# Generate Brewfile from current packages
brew bundle dump --file=~/dotfiles/Brewfile

# Install missing essentials
brew install jq direnv

# Add direnv to zshrc
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

---

## Notes

- All installed tools configured in `~/dotfiles/`
- macOS install: `scripts/macos/install.sh`
- Linux install: `scripts/linux/install.sh`
- Philosophy: Terminal-first, keyboard-driven, modern Rust tools
