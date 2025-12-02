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
| `]c` | Current heading          |
| `]p` | Parent heading           |
| `gx` | Follow link under cursor |

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

## Spell (disabled by default)

| Key          | Action                 |
|--------------|------------------------|
| `<leader>us` | Toggle spell checking  |
| `]s`         | Next misspelled word   |
| `[s`         | Previous misspelled word |
| `z=`         | Suggest corrections    |

## Plugins

- **render-markdown.nvim** - In-buffer visual rendering (auto)
- **glow.nvim** - Terminal preview (works over SSH)
- **markdown.nvim** - Editing keymaps
- **marksman** - LSP for link completion
