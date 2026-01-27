# VSCode Configuration (nvim-compatible)

This VSCode configuration replicates the nvim dotfiles setup as closely as possible.

## Quick Install

```bash
~/dotfiles/vscode/install.sh
```

## Feature Mapping: nvim → VSCode

| nvim Plugin | VSCode Equivalent |
|-------------|-------------------|
| **lspsaga.nvim** | Built-in LSP + custom keybindings |
| **flash.nvim** | vim.easymotion + vim.sneak |
| **which-key.nvim** | vim.whichkeyTimeout |
| **diffview.nvim** | GitLens + Git Graph |
| **gitsigns.nvim** | GitLens inline blame |
| **refactoring.nvim** | Built-in refactor commands |
| **telescope.nvim** | Quick Open + Find in Files |
| **todo-comments.nvim** | Todo Tree extension |
| **yanky.nvim** | vim.highlightedyank |
| **treesitter** | Built-in syntax + bracket matching |
| **conform.nvim** | Format on save |
| **mini.pairs** | vim.surround |
| **yazi.nvim** | File Explorer |
| **colorschemes** | Tokyo Night, Gruvbox, etc. |

## Keybindings Reference

### LSP/Code Navigation (lspsaga.nvim equivalent)

| Key | Action |
|-----|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gp` | Peek definition (floating) |
| `gy` | Go to type definition |
| `gP` | Peek type definition |
| `gr` | Find references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `[d` / `]d` | Previous/next diagnostic |
| `[e` / `]e` | Previous/next error (all files) |
| `<Space>ca` | Code actions |
| `<Space>cA` | Source actions |
| `<Space>cr` | Rename symbol |
| `<Space>cR` | Replace in files (project rename) |
| `<Space>cd` | Show diagnostic at cursor |
| `<Space>cD` | All diagnostics (problems panel) |
| `<Space>ci` | Incoming calls |
| `<Space>co` | Outgoing calls |
| `<Space>cs` | Document symbols |
| `<Space>cS` | Workspace symbols |

### Refactoring (refactoring.nvim equivalent)

| Key | Action |
|-----|--------|
| `<Space>rs` | Refactor menu |
| `<Space>rf` | Extract function/method |
| `<Space>rx` | Extract variable |
| `<Space>ri` | Inline variable |
| `<Space>rn` | Rename symbol |

### Git (diffview.nvim + gitsigns.nvim equivalent)

| Key | Action |
|-----|--------|
| `<Space>gg` | Git panel (SCM view) |
| `<Space>gb` | Toggle file blame |
| `<Space>gB` | Toggle line blame |
| `<Space>gv` | View changes (diff) |
| `<Space>gF` | File history view |
| `<Space>gR` | Repo history (git graph) |
| `<Space>gc` | View staged changes |
| `<Space>gd` | Diff with previous |
| `<Space>gh` | Quick file history |
| `<Space>gl` | Show commit details |
| `<Space>gs` | Stage all |
| `<Space>gu` | Unstage all |
| `[c` / `]c` | Previous/next hunk |
| `<Space>hs` | Stage hunk |
| `<Space>hr` | Revert hunk |

### File Operations (yazi.nvim + telescope.nvim equivalent)

| Key | Action |
|-----|--------|
| `<Space>e` | File explorer |
| `<Space>.` | Reveal file in explorer |
| `<Space>ff` | Find files (quick open) |
| `<Space>fg` | Find in files (grep) |
| `<Space>/` | Find in files |
| `<Space>fr` | Recent files |
| `<Space>fb` | Open buffers |
| `<Space>fn` | New file |
| `<Space>fs` | Document symbols |
| `<Space>fS` | Workspace symbols |
| `<Space>:` | Command palette |
| `<Space><Space>` | Quick open |

### Buffer/Tab Navigation

| Key | Action |
|-----|--------|
| `H` / `L` | Previous/next tab |
| `[b` / `]b` | Previous/next tab |
| `<Space>bd` | Close buffer |
| `<Space>bD` | Close other buffers |
| `<Space>bo` | Close other buffers |
| `<Space>bb` | Buffer list |
| `<Space>bp` | Pin editor |
| `` <Space>` `` | Last buffer |

### Windows/Splits (smart-splits.nvim equivalent)

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Focus left/down/up/right split |
| `<Space>wv` | Vertical split |
| `<Space>ws` | Horizontal split |
| `<Space>wd` | Close split |
| `<Space>wo` | Close other editors |
| `<Space>ww` | Focus next group |
| `<Space>w=` | Even editor widths |
| `<Space>-` | Horizontal split |
| `<Space>\|` | Vertical split |

### Navigation (flash.nvim equivalent)

| Key | Action |
|-----|--------|
| `s` | EasyMotion 2-char search forward |
| `S` | EasyMotion 2-char search backward |
| `<Space><Space>w` | EasyMotion word |
| `<Space><Space>j` | EasyMotion line down |
| `<Space><Space>k` | EasyMotion line up |

### UI Toggles

| Key | Action |
|-----|--------|
| `<Space>uw` | Toggle word wrap |
| `<Space>ul` | Toggle whitespace rendering |
| `<Space>un` | Toggle sidebar |
| `<Space>uz` | Toggle zen mode |
| `<Space>uf` | Toggle fullscreen |
| `<Space>um` | Toggle minimap |

### TODO Comments (todo-comments.nvim equivalent)

| Key | Action |
|-----|--------|
| `<Space>xt` | Show TODO tree |
| `<Space>xx` | Problems panel |
| `[t` / `]t` | Previous/next TODO |

### Copy Paths (keymaps.lua)

| Key | Action |
|-----|--------|
| `<Space>yf` | Copy relative path |
| `<Space>yF` | Copy absolute path |
| `<Space>yn` | Copy filename |

### Quit/Close

| Key | Action |
|-----|--------|
| `<Space>qq` | Close window |
| `<Space>qa` | Close all editors |

### Other

| Key | Action |
|-----|--------|
| `<Space>mp` | Markdown preview |
| `<Space>ft` | Toggle terminal |
| `<Space>l` | Command palette |
| `q` | Disabled (no accidental macros) |
| `Q` | Record macro |
| `jk` | Escape (insert mode) |
| `Ctrl+Space` | Trigger autocomplete (manual) |
| `>` / `<` | Indent/outdent (normal mode) |
| `J` / `K` | Move lines down/up (visual mode) |
| `p` | Paste without overwriting register (visual) |

### Notebook Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+j/k` | Navigate cells |
| `Shift+Enter` | Execute and move down |
| `Ctrl+Enter` | Execute cell |
| `a` | Add cell above |
| `b` | Add cell below |
| `m` | Change to markdown |
| `y` | Change to code |
| `dd` | Delete cell |

## Vim Features Enabled

- **EasyMotion**: Jump anywhere with `s` + 2 chars
- **Sneak**: 2-char search with smart case
- **Surround**: `cs`, `ds`, `ys` commands
- **Highlighted Yank**: Visual feedback when yanking
- **System Clipboard**: Yank goes to system clipboard
- **Relative Line Numbers**: Just like nvim
- **Manual Completion**: Press `Ctrl+Space` to trigger

## Colorschemes Available

All nvim colorschemes are available:
- Tokyo Night (default)
- Gruvbox Material
- Catppuccin
- Rose Pine
- Everforest
- GitHub Theme

Change with: `Ctrl+K Ctrl+T` or `<Space>:` → "color theme"

## Completion Behavior

Matches blink-cmp.lua - manual trigger only. Press `Ctrl+Space` to show suggestions.

## Python Environment

Uses conda environment `deeplearn_course` by default. Change interpreter with:
- Command palette → "Python: Select Interpreter"
- Or `<Space>:` → "select interpreter"
