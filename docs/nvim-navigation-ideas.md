# Neovim Navigation & Telescope Ideas

Research notes for potential improvements to the nvim setup.

---

## Telescope Improvements

### 1. Resume Last Search (Essential)

Never lose your search state:

```lua
-- Add to nvim/lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
  },
}
```

### 2. Search Hidden Files (dotfiles)

Current setup may miss `.env`, `.gitignore`, etc:

```lua
return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local telescopeConfig = require("telescope.config")
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
    table.insert(vimgrep_arguments, "--hidden")
    table.insert(vimgrep_arguments, "--glob")
    table.insert(vimgrep_arguments, "!**/.git/*")

    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      vimgrep_arguments = vimgrep_arguments,
    })
    opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
      find_files = {
        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
      },
    })
  end,
}
```

### 3. Smart Project Files (git_files with fallback)

Use `git_files` in repos (faster, respects .gitignore), `find_files` elsewhere:

```lua
keys = {
  { "<leader><space>", function()
    local builtin = require("telescope.builtin")
    vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error == 0 then
      builtin.git_files({ show_untracked = true })
    else
      builtin.find_files()
    end
  end, desc = "Find files (smart)" },
}
```

### 4. Delete Buffers from Picker

Close buffers without leaving telescope:

```lua
opts = {
  pickers = {
    buffers = {
      mappings = {
        i = { ["<C-d>"] = require("telescope.actions").delete_buffer },
        n = { ["dd"] = require("telescope.actions").delete_buffer },
      },
    },
  },
}
```

### 5. Toggle Preview

Useful for small screens or faster browsing:

```lua
opts = {
  defaults = {
    mappings = {
      i = { ["<M-p>"] = require("telescope.actions.layout").toggle_preview },
      n = { ["<M-p>"] = require("telescope.actions.layout").toggle_preview },
    },
  },
}
```

### 6. Quick Wins (Single-line keymaps)

```lua
-- Find sibling files (files in same directory as current file)
{ "<leader>.", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
end, desc = "Find sibling files" },

-- Grep from git root (not cwd)
{ "<leader>sG", function()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  require("telescope.builtin").live_grep({ cwd = git_root })
end, desc = "Grep (git root)" },

-- Search current buffer (like Ctrl+F)
{ "<leader>s/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer" },
```

### Telescope Extensions to Consider

| Extension                                                                                    | What it does                                                          |
| -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| [smart-open.nvim](https://github.com/danielfalk/smart-open.nvim)                             | **Best file finder** - combines frecency, path matching, and learning |
| [telescope-frecency.nvim](https://github.com/nvim-telescope/telescope-frecency.nvim)         | Prioritizes files by frequency + recency (Mozilla algorithm)          |
| [telescope-undo.nvim](https://github.com/debugloop/telescope-undo.nvim)                      | Browse and restore undo history visually                              |
| [telescope-file-browser.nvim](https://github.com/nvim-telescope/telescope-file-browser.nvim) | Full file browser in telescope                                        |
| [telescope-lazy-plugins.nvim](https://github.com/polirritmico/telescope-lazy-plugins.nvim)   | Jump to any plugin's config instantly                                 |

### Hidden Gems in Built-in Telescope

| Keymap                | What it does                   |
| --------------------- | ------------------------------ |
| `<C-/>` (insert mode) | **Show all available actions** |
| `<C-q>`               | Send all results to quickfix   |
| `<M-q>`               | Send selected to quickfix      |
| `<C-u>`               | Scroll preview up              |
| `<C-d>`               | Scroll preview down            |
| `<Tab>`               | Toggle selection + move down   |
| `<S-Tab>`             | Toggle selection + move up     |

---

## Jump Back to Recent Code Locations

### Built-in (Already Available)

| Key        | Action                                             |
| ---------- | -------------------------------------------------- |
| `Ctrl+o`   | **Jump back** through locations you've visited     |
| `Ctrl+i`   | Jump forward through locations                     |
| `g;`       | **Jump to previous edit location** (change list)   |
| `g,`       | Jump to next edit location                         |
| `gi`       | Jump to last insert location and enter insert mode |
| `:jumps`   | View your jump history                             |
| `:changes` | View your change history                           |

**Tip:** `g;` is the closest to PyCharm's "Recent Locations" — it takes you exactly where you made edits.

### What Counts as a Jump

These movements add to the jump list (navigable with `Ctrl+o`/`Ctrl+i`):

- `/pattern` and `?pattern` searches
- `*` and `#` (search word under cursor)
- `%` (jump to matching bracket)
- `gg`, `G`, `{count}G` (jump to line)
- `{`, `}` (paragraph jumps)
- Marks (`'a`, `` `a ``)

These do NOT add to jump list:

- `hjkl` movements
- `w`, `b`, `e` word movements
- `f`, `t` character finds
- `:42` (colon line number) — use `42G` instead

### Plugins for Enhanced Navigation

#### 1. portal.nvim (Visual Jump Preview)

Shows a preview window of locations before jumping — closest to PyCharm experience:

```lua
{
  "cbochs/portal.nvim",
  dependencies = { "cbochs/grapple.nvim" }, -- optional
  keys = {
    { "<C-o>", "<cmd>Portal jumplist backward<cr>", desc = "Portal backward" },
    { "<C-i>", "<cmd>Portal jumplist forward<cr>", desc = "Portal forward" },
  },
}
```

#### 2. harpoon (Mark Key Files)

Mark 4-5 important files/locations and jump instantly:

```lua
{
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
    { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
    { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
    { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
    { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
    { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
  },
  opts = {},
}
```

#### 3. trailblazer.nvim (Breadcrumb Stack)

Drop breadcrumbs as you navigate, pop back to them:

```lua
{
  "LeonHeidelbach/trailblazer.nvim",
  keys = {
    { "<A-s>", "<cmd>TrailBlazerNewTrailMark<cr>", desc = "Drop breadcrumb" },
    { "<A-b>", "<cmd>TrailBlazerTrackBack<cr>", desc = "Pop back to breadcrumb" },
    { "<A-j>", "<cmd>TrailBlazerPeekMovePreviousUp<cr>", desc = "Previous mark" },
    { "<A-k>", "<cmd>TrailBlazerPeekMoveNextDown<cr>", desc = "Next mark" },
  },
}
```

### Comparison

| Need                                | Solution            |
| ----------------------------------- | ------------------- |
| Jump to last edit                   | `g;` (built-in)     |
| Jump back through history           | `Ctrl+o` (built-in) |
| Preview before jumping              | portal.nvim         |
| Mark specific files to quick-switch | harpoon             |
| Temporary breadcrumbs               | trailblazer.nvim    |

---

## Resources

- [Telescope Configuration Recipes](https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes)
- [Telescope Extensions Wiki](https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions)
- [Vim Jump List Explained](https://vimtricks.com/p/vim-jump-list/)
- [portal.nvim](https://github.com/cbochs/portal.nvim)
- [harpoon](https://github.com/ThePrimeagen/harpoon)
- [smart-open.nvim](https://github.com/danielfalk/smart-open.nvim)
