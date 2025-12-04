# Yazi - Terminal File Manager

Yazi is a blazing fast terminal file manager written in Rust with vim-style keybindings and image preview support in Kitty.

## Quick Start

```bash
yazi          # Open file manager
y             # Open + cd to directory on exit (recommended)
```

## Navigation

| Key | Action |
|-----|--------|
| `h` | Go to parent directory |
| `j` | Move down |
| `k` | Move up |
| `l` / `Enter` | Open file/directory |
| `H` | Back in history |
| `L` | Forward in history |
| `~` | Go to home directory |
| `/` | Search in current directory |
| `n` / `N` | Next/previous search result |
| `z` | Jump with zoxide (fuzzy cd) |
| `Z` | Jump with fzf |

## File Operations

| Key | Action |
|-----|--------|
| `Space` | Toggle selection |
| `v` | Visual mode (select range) |
| `V` | Select all |
| `y` | Copy (yank) selected |
| `x` | Cut selected |
| `p` | Paste |
| `P` | Paste (overwrite) |
| `d` | Trash selected |
| `D` | Permanently delete |
| `a` | Create new file |
| `A` | Create new directory |
| `r` | Rename |
| `c` | Copy filename to clipboard |
| `.` | Toggle hidden files |

## Tabs

| Key | Action |
|-----|--------|
| `t` | New tab |
| `1-9` | Switch to tab 1-9 |
| `[` / `]` | Previous/next tab |
| `{` / `}` | Swap tab left/right |

## Preview

| Key | Action |
|-----|--------|
| `Tab` | Toggle preview panel |
| `Ctrl+h/l` | Seek preview (for long files) |

## Sorting

Press `,` to open sort menu:
- `m` - Modified time
- `M` - Modified time (reverse)
- `c` - Created time
- `e` - Extension
- `a` - Alphabetical
- `s` - Size
- `n` - Natural sort

## Filter

| Key | Action |
|-----|--------|
| `f` | Filter files (fuzzy) |
| `Esc` | Clear filter |

## Shell Integration

The `y` function in `.zshrc` allows you to `cd` into the directory you were browsing when you quit yazi:

```bash
# yazi file manager (cd to directory on exit with 'y')
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

## Image Preview

Image preview works automatically in Kitty terminal. Supported formats:
- Images (png, jpg, gif, webp, etc.)
- Videos (thumbnails via ffmpegthumbnailer)
- PDFs (via poppler)
- Archives (via unar)

## Configuration

Yazi config files are located at `~/.config/yazi/`:
- `yazi.toml` - Main configuration
- `keymap.toml` - Custom keybindings
- `theme.toml` - Colors and styles

## Tips

1. **Quick navigation**: Use `z` to fuzzy-jump to directories (uses zoxide)
2. **Bulk rename**: Select files with `Space`, then `r` to rename pattern
3. **Open with**: Press `o` to open with a specific application
4. **Copy path**: Press `c` to copy the file path to clipboard
5. **Preview scroll**: Use `Ctrl+d/u` to scroll preview content

## Resources

- [Yazi Documentation](https://yazi-rs.github.io/docs)
- [Yazi GitHub](https://github.com/sxyazi/yazi)
