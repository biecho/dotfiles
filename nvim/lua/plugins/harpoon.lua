-- Harpoon 2: Quick file navigation
-- by ThePrimeagen - https://github.com/ThePrimeagen/harpoon
--
-- ============================================================================
-- WHAT IS HARPOON?
-- ============================================================================
--
-- Harpoon lets you "mark" files and jump to them instantly.
-- Instead of fuzzy-finding the same 4 files over and over, mark them once
-- and jump with a single keystroke.
--
-- Think of it as bookmarks for your most important project files.
--
-- ============================================================================
-- KEYMAPS
-- ============================================================================
--
-- ADDING & VIEWING:
--   <leader>a     Add current file to harpoon list
--   <C-e>         Open harpoon menu (view/edit/reorder list)
--   <leader>h     Open harpoon menu (alternative)
--
-- JUMPING TO FILES:
--   <C-1>         Jump to harpoon file 1
--   <C-2>         Jump to harpoon file 2
--   <C-3>         Jump to harpoon file 3
--   <C-4>         Jump to harpoon file 4
--
-- CYCLING:
--   <C-S-p>       Jump to previous file in list
--   <C-S-n>       Jump to next file in list
--
-- ============================================================================
-- IN THE HARPOON MENU
-- ============================================================================
--
-- The menu is a regular buffer - edit it like normal text:
--   - Delete a line to remove a file
--   - Reorder lines to change file order
--   - Save happens automatically on close
--
-- Menu keymaps:
--   <CR>          Open file under cursor
--   <C-v>         Open in vertical split
--   <C-x>         Open in horizontal split
--   q / <Esc>     Close menu
--
-- ============================================================================
-- WORKFLOW EXAMPLE
-- ============================================================================
--
-- Working on an ML project? Mark your core files:
--
--   <C-1>  →  src/models/transformer.py   (model definition)
--   <C-2>  →  src/train.py                (training loop)
--   <C-3>  →  configs/experiment.yaml     (hyperparameters)
--   <C-4>  →  tests/test_model.py         (tests)
--
-- Now you can instantly jump between them without thinking.
-- The list is saved per-project (based on working directory).
--
-- ============================================================================
-- TIPS
-- ============================================================================
--
-- - Best for 3-4 files you constantly switch between
-- - Lists persist across sessions (saved to disk)
-- - Use Telescope/frecency for files you access less often
-- - <C-o> jumps back after a harpoon jump (jumplist)
--
-- ============================================================================

---@type LazySpec
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    settings = {
      save_on_toggle = true, -- Save list when closing menu
      sync_on_ui_close = true, -- Sync to disk when menu closes
    },
  },
  keys = {
    -- Add file to list
    {
      "<leader>a",
      function() require("harpoon"):list():add() end,
      desc = "Harpoon: Add file",
    },
    -- Toggle quick menu (both keys for convenience)
    {
      "<C-e>",
      function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
      desc = "Harpoon: Open menu",
    },
    {
      "<leader>h",
      function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
      desc = "Harpoon: Open menu",
    },
    -- Quick select files 1-4
    {
      "<C-1>",
      function() require("harpoon"):list():select(1) end,
      desc = "Harpoon: File 1",
    },
    {
      "<C-2>",
      function() require("harpoon"):list():select(2) end,
      desc = "Harpoon: File 2",
    },
    {
      "<C-3>",
      function() require("harpoon"):list():select(3) end,
      desc = "Harpoon: File 3",
    },
    {
      "<C-4>",
      function() require("harpoon"):list():select(4) end,
      desc = "Harpoon: File 4",
    },
    -- Navigate through list
    {
      "<C-S-p>",
      function() require("harpoon"):list():prev() end,
      desc = "Harpoon: Previous file",
    },
    {
      "<C-S-n>",
      function() require("harpoon"):list():next() end,
      desc = "Harpoon: Next file",
    },
  },
  config = function(_, opts)
    local harpoon = require("harpoon")
    harpoon:setup(opts)

    -- Extend UI with split options
    harpoon:extend({
      UI_CREATE = function(cx)
        -- Open in vertical split
        vim.keymap.set("n", "<C-v>", function()
          harpoon.ui:select_menu_item({ vsplit = true })
        end, { buffer = cx.bufnr, desc = "Open in vsplit" })

        -- Open in horizontal split
        vim.keymap.set("n", "<C-x>", function()
          harpoon.ui:select_menu_item({ split = true })
        end, { buffer = cx.bufnr, desc = "Open in split" })
      end,
    })
  end,
}
