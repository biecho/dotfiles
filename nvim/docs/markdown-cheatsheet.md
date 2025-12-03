# Markdown Shortcuts Cheatsheet

## Preview

| Key          | Action                              |
|--------------|-------------------------------------|
| `<leader>mp` | Open Glow preview (floating window) |

## Navigation

| Key  | Action                   |
|------|--------------------------|
| `]]` | Next heading             |
| `[[` | Previous heading         |
| `]c` | Current heading (jump)   |
| `]p` | Parent heading           |
| `gx` | Follow link under cursor |

## Cell Navigation (for code blocks with `# %%` markers)

| Key  | Action                   |
|------|--------------------------|
| `]x` | Next cell                |
| `[x` | Previous cell            |

## Cell Text Objects (vim-textobj-hydrogen)

| Text Object | Action                           |
|-------------|----------------------------------|
| `ih`        | Inner cell (between # %%)        |
| `ah`        | Around cell (including marker)   |

## Editing (markdown.nvim)

| Key            | Action                              |
|----------------|-------------------------------------|
| `gsb` + motion | Toggle **bold** (e.g., `gsbiw`)     |
| `gsi` + motion | Toggle *italic*                     |
| `gsc` + motion | Toggle `code`                       |
| `gss`          | Toggle on whole line                |
| `ds` + char    | Delete surrounding                  |
| `cs` + old+new | Change surrounding                  |
| `gl` + motion  | Add link                            |

## Quarto (`<leader>q`) - for .qmd and markdown with code

| Key          | Action                              |
|--------------|-------------------------------------|
| `<leader>qp` | Quarto preview                      |
| `<leader>qc` | Close preview                       |
| `<leader>qa` | Activate Quarto LSP                 |
| `<leader>qr` | Run cell                            |
| `<leader>qR` | Run all cells                       |
| `<leader>ql` | Run line                            |
| `<leader>qA` | Run all above                       |
| `<leader>qb` | Run all below                       |

## Spell (disabled by default)

| Key          | Action                   |
|--------------|--------------------------|
| `<leader>us` | Toggle spell checking    |
| `]s`         | Next misspelled word     |
| `[s`         | Previous misspelled word |
| `z=`         | Suggest corrections      |

## Plugins

- **render-markdown.nvim** - In-buffer visual rendering (auto)
- **glow.nvim** - Terminal preview (works over SSH)
- **markdown.nvim** - Editing keymaps
- **marksman** - LSP for link completion
- **quarto-nvim** - Literate programming
- **otter.nvim** - LSP for code in markdown blocks
- **vim-textobj-hydrogen** - Cell text objects
