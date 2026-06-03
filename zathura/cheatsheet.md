# zathura cheatsheet

Minimal, vim-like PDF reader. Installed via the Ansible role
(`zathura` + `zathura-pdf-poppler` rendering backend). Open with `zathura file.pdf`.

## Zoom

| Key | Action |
|-----|--------|
| `+` / `-` | Zoom in / out |
| `=` | Reset zoom to default |
| `a` | Fit page to **width** |
| `s` | Fit page to **height** (whole page) |
| `Ctrl` + mouse scroll | Zoom in/out at the cursor |

After zooming, pan with `h` / `j` / `k` / `l`.

## Move around

| Key | Action |
|-----|--------|
| `j` / `k` | Scroll down / up |
| `h` / `l` | Scroll left / right (useful when zoomed in) |
| `Space` / `Shift+Space` | Page down / up |
| `Ctrl+d` / `Ctrl+u` | Half-page down / up |
| `gg` / `G` | First page / last page |
| `<n>G` | Jump to page *n* (e.g. `42G`) |
| `Ctrl+o` / `Ctrl+i` | Jump back / forward in location history |

## Search & navigate

| Key | Action |
|-----|--------|
| `/` then text, `Enter` | Search forward |
| `?` | Search backward |
| `n` / `N` | Next / previous match |
| `Tab` | Toggle table-of-contents sidebar (then `j`/`k`, `Enter` to jump) |
| `f` | Follow a link (shows hint numbers; type the number) |

## View modes

| Key | Action |
|-----|--------|
| `d` | Toggle dual-page (two pages side by side) |
| `r` | Rotate 90° |
| `Ctrl+r` | Recolor — invert to dark mode |
| `F5` | Presentation mode |
| `F11` | Fullscreen |

## Command mode (`:`)

Press `:` to type a command, vim-style:

- `:open <path>` — open another file (Tab-completes)
- `:zoom 150` — set zoom to a specific %
- `:bmark <name>` / `:blist` — set / list bookmarks
- `q` — quit

## Other

- `q` — quit
- `Ctrl+c` — abort current input
- Mouse: scroll to move, select text to copy, click TOC entries

## Customizing

zathura reads `~/.config/zathura/zathurarc` (not yet managed by this repo).
Common tweaks — dark mode by default and clipboard selection:

```
set recolor true
set recolor-lightcolor "#303446"
set recolor-darkcolor  "#c6d0f5"
set selection-clipboard clipboard
```
