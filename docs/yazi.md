# Yazi - Terminal File Manager

Yazi is a blazing fast terminal file manager written in Rust with vim-style keybindings and image preview support in Kitty.

## Quick Start

```bash
yazi          # Open file manager
y             # Open + cd to directory on exit (recommended)
```

## Installed Plugins

| Plugin | Description |
|--------|-------------|
| **git** | Shows git status (M/A/D/?) in file listing |
| **full-border** | Adds nice borders around panes |
| **smart-enter** | `Enter` opens files OR enters directories |
| **chmod** | Change file permissions with `cm` |
| **diff** | Diff selected file with hovered (`dd`) |
| **jump-to-char** | Vim-like `f` to jump to file |
| **smart-filter** | Better filtering with `F` |
| **glow** | Markdown preview (requires `glow` CLI) |

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

## Custom Keybindings (from keymap.toml)

| Key | Action |
|-----|--------|
| `f` | Jump to file starting with char (vim-style) |
| `F` | Smart filter |
| `e` | Open in editor (nvim) |
| `E` | Open with picker |
| `!` | Open shell here |
| `@` | Run shell command |
| `dd` | Diff selected with hovered |
| `cm` | Change file permissions |
| `cp` | Copy file path to clipboard |
| `cn` | Copy filename to clipboard |
| `cd` | Copy directory path to clipboard |
| `gr` | Go to git root |
| `gh` | Go to home |
| `gc` | Go to ~/.config |
| `gd` | Go to ~/dotfiles |
| `gD` | Go to ~/Downloads |
| `gp` | Go to ~/projects |
| `sm` | Sort by modified (newest first) |
| `sn` | Sort by name |
| `ss` | Sort by size (largest first) |
| `se` | Sort by extension |

## Tips

1. **Quick navigation**: Use `z` to fuzzy-jump to directories (uses zoxide)
2. **Bulk rename**: Select files with `Space`, then `r` to rename pattern
3. **Open with**: Press `E` to open with a specific application
4. **Copy path**: Press `cp` to copy the file path to clipboard
5. **Preview scroll**: Use `Ctrl+d/u` to scroll preview content
6. **Git status**: Files show M (modified), A (added), D (deleted), ? (untracked)
7. **Diff files**: Select one file with `Space`, hover another, press `dd`

## Plugin Management

```bash
ya pkg install    # Install plugins from package.toml
ya pkg upgrade    # Update all plugins
ya pkg list       # List installed plugins
```

## Configuration Files

Located in `~/.config/yazi/` (symlinked from `~/dotfiles/yazi/`):
- `yazi.toml` - Main configuration
- `keymap.toml` - Custom keybindings
- `init.lua` - Plugin initialization
- `package.toml` - Plugin dependencies

## Resources

- [Yazi Documentation](https://yazi-rs.github.io/docs)
- [Yazi GitHub](https://github.com/sxyazi/yazi)
- [Awesome Yazi Plugins](https://github.com/AnirudhG07/awesome-yazi)

---

# Yazi.nvim - Neovim Integration

[yazi.nvim](https://github.com/mikavilpas/yazi.nvim) integrates yazi directly into Neovim as a floating window file manager with full buffer synchronization.

## Opening Yazi from Neovim

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>-` | `:Yazi` | Open at **current file's directory** |
| `<leader>cw` | `:Yazi cwd` | Open at **working directory** |
| `Ctrl+Up` | `:Yazi toggle` | **Resume** last yazi session (keeps state) |

## Keybindings Inside Yazi (Neovim-specific)

These work only when yazi is opened from Neovim:

### Opening Files

| Key | Action |
|-----|--------|
| `Enter` | Open file in current buffer |
| `Ctrl+v` | Open in **vertical split** |
| `Ctrl+x` | Open in **horizontal split** |
| `Ctrl+t` | Open in **new tab** |
| `Ctrl+o` | Open and **pick window** (choose which split) |

### Multi-file Operations

| Key | Action |
|-----|--------|
| `Space` | Select/toggle file (in yazi) |
| `Ctrl+q` | Send selected files to **quickfix list** |
| `Enter` (with selection) | Open all selected files |

### Navigation & Buffers

| Key | Action |
|-----|--------|
| `Tab` | **Cycle through open Neovim buffers** as yazi tabs |
| `Ctrl+\` | **Change Neovim's cwd** to current yazi directory |
| `F1` | Show help menu |

### Search & Replace Integration

| Key | Action | Requires |
|-----|--------|----------|
| `Ctrl+s` | **Live grep** in directory or selected files | telescope.nvim, fzf-lua, or snacks.picker |
| `Ctrl+g` | **Search & replace** in directory or selected files | grug-far.nvim |

### Clipboard

| Key | Action |
|-----|--------|
| `Ctrl+y` | Copy **relative paths** of selected files to clipboard |

## Key Features

### Buffer Synchronization
Files renamed, moved, or deleted in yazi automatically update:
- Open Neovim buffers (paths update, no "file not found" errors)
- LSP servers receive rename notifications
- Buffer names stay in sync

### Toggle/Resume Session
`Ctrl+Up` (or `:Yazi toggle`) resumes your last yazi session:
- Keeps your navigation position
- Preserves selected files
- Great for quick back-and-forth editing

### Open Buffers as Tabs
When yazi opens, your visible splits and quickfix items appear as yazi tabs. Press `Tab` to cycle through them — useful for jumping between open files.

### Hovered Buffer Highlighting
When you hover over a file in yazi that's open in Neovim, the corresponding buffer gets highlighted.

## Configuration (Current Setup)

From `nvim/lua/plugins/yazi.lua`:

```lua
{
  "mikavilpas/yazi.nvim",
  keys = {
    { "<leader>-", "<cmd>Yazi<cr>", desc = "Yazi (current file)" },
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Yazi (resume)" },
  },
  opts = {
    open_for_directories = false,
  },
}
```

## Available Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `open_for_directories` | `false` | Replace netrw when opening directories |
| `change_neovim_cwd_on_close` | `false` | Change nvim cwd to yazi's directory on close |
| `floating_window_scaling_factor` | `0.9` | Window size (0.9 = 90% of screen) |
| `yazi_floating_window_winblend` | `0` | Transparency (0-100, 0 = opaque) |
| `yazi_floating_window_border` | `"rounded"` | Border style (none/single/double/rounded/shadow) |
| `clipboard_register` | `"*"` | Register for copy operations |
| `enable_mouse_support` | `false` | Enable mouse interaction |
| `open_multiple_tabs` | `false` | Open files across multiple tabs |
| `highlight_hovered_buffers_in_same_directory` | `true` | Highlight buffers in same dir as hovered file |
| `log_level` | `OFF` | Logging level (for debugging) |

## Customizing Keymaps

Disable specific keymaps by setting them to `false`:

```lua
opts = {
  keymaps = {
    open_file_in_vertical_split = false,  -- disable Ctrl+v
    grep_in_directory = false,            -- disable Ctrl+s
  },
}
```

Or disable all default keymaps:

```lua
opts = {
  keymaps = false,
}
```

## Hooks (Advanced)

For custom behavior, use hooks:

```lua
opts = {
  hooks = {
    -- Runs when yazi opens
    yazi_opened = function(preselected_path, yazi_buffer_id, config)
      vim.notify("Yazi opened at: " .. preselected_path)
    end,

    -- Runs when a file is selected
    yazi_closed_successfully = function(chosen_file, config, state)
      -- custom file handling
    end,

    -- Runs when multiple files are selected
    yazi_opened_multiple_files = function(chosen_files, config, state)
      -- handle multiple files
    end,
  },
}
```

## Tips & Workflows

1. **Quick file jump**: `<leader>-` → navigate → `Enter` — fastest way to open nearby files

2. **Change project root**: Navigate to new project in yazi → `Ctrl+\` → now nvim's cwd is updated

3. **Bulk open files**: Select multiple with `Space` → `Enter` → all open in buffers

4. **Send to quickfix**: Select files → `Ctrl+q` → use `:cnext`/`:cprev` to navigate

5. **Grep in selection**: Select specific files → `Ctrl+s` → search only within those files

6. **Resume navigation**: Close yazi to edit → `Ctrl+Up` → back exactly where you were

7. **Split workflow**: Find file → `Ctrl+v` or `Ctrl+x` → opens in split without closing yazi's position

## Troubleshooting

Run `:checkhealth yazi` to diagnose issues. Common fixes:

- **yazi not found**: Ensure yazi is in PATH
- **No image preview**: Use Kitty terminal or another with image protocol support
- **Ctrl+y not working**: Install GNU `realpath` (macOS: `brew install coreutils` for `grealpath`)

## Resources

- [yazi.nvim GitHub](https://github.com/mikavilpas/yazi.nvim)
- [yazi.nvim Wiki](https://github.com/mikavilpas/yazi.nvim/wiki)
