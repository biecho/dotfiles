# Tool Suggestions for macOS Developer Setup

## Installed

| Tool | Description | Status |
|------|-------------|--------|
| **git-delta** | Syntax-highlighted git diffs | ✅ Installed |
| **atuin** | Better shell history with sync | ✅ Installed |
| **bat** | Modern `cat` with syntax highlighting | ✅ Installed |
| **btop** | Modern `top`/`htop` replacement | ✅ Installed |
| **tlrc** | tldr pages (simplified man pages) | ✅ Installed |
| **yazi** | Terminal file manager with image preview | ✅ Installed |
| **just** | Command runner (better Makefile) | ✅ Installed |

---

## Remaining Suggestions

### High Priority

| Tool | Description | Why |
|------|-------------|-----|
| **tmux** | Terminal multiplexer | Session persistence, split panes across SSH. Pairs well with Kitty but adds session survival if terminal crashes. |
| **direnv** | Auto-load env vars per directory | Automatically activates project-specific environment variables when you `cd` into directories. Great for managing API keys, project configs. |

### Medium Priority

| Tool | Description | Why |
|------|-------------|-----|
| **httpie** / **curlie** | Modern HTTP clients | Better than curl for API testing. `curlie` uses curl syntax with httpie output. |
| **jq** / **yq** | JSON/YAML processors | Essential for parsing API responses and config files. |
| **gh** | GitHub CLI | Create PRs, issues, browse repos from terminal. |
| **gum** | Shell script UI toolkit | Create beautiful interactive shell scripts. |
| **hyperfine** | Benchmarking tool | Time and compare command execution. |

### Nice to Have

| Tool | Description | Why |
|------|-------------|-----|
| **dust** | Modern `du` | Disk usage analyzer with visual output. |
| **duf** | Modern `df` | Disk free space with better formatting. |
| **procs** | Modern `ps` | Process viewer with tree view and search. |
| **tokei** | Code statistics | Count lines of code by language. |
| **gping** | Graphical ping | Visual ping with graph output. |
| **dog** | Modern `dig` | DNS lookup with colored output. |

### Development-Specific

| Tool | Description | Why |
|------|-------------|-----|
| **mise** (formerly rtx) | Polyglot version manager | Replaces nvm/pyenv/rbenv with one tool. Faster than asdf. |
| **watchexec** | File watcher | Run commands on file changes. |

---

## Notes

- All installed tools are configured in `~/dotfiles/` with symlinks
- macOS install: `scripts/macos/install.sh`
- Linux install: `scripts/linux/install.sh`
- Consider your actual workflow before adding more tools
