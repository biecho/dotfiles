-- ~/.config/nvim/lua/plugins/user-mappings.lua
-- Custom keymaps and overrides for AstroNvim defaults
--
-- ============================================================================
-- BUFFER & FILE NAVIGATION
-- ============================================================================
--
-- FRECENCY (files sorted by usage - frequency + recency):
--   <leader>fr    Open frecency picker (most used files bubble to top)
--
-- BUFFERS (open buffers sorted by most recently used):
--   <leader>fb    Open buffer picker (MRU order, excludes current)
--
-- JUMPLIST (recent code locations - like PyCharm's "Recent Locations"):
--   <leader>fj    Open jumplist picker (shows line previews)
--   <C-o>         Jump to previous location (built-in)
--   <C-i>         Jump to next location (built-in)
--
-- ============================================================================

---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local maps = opts.mappings

    -- =========================================================================
    -- Disable AstroNvim defaults (to make room for Harpoon)
    -- =========================================================================
    maps.n["<leader>h"] = false -- Was: Dashboard (Home)
    maps.i["<C-e>"] = false -- Was: Cancel completion

    -- Moved to <leader>wr to avoid conflict with REPL (<leader>r)
    maps.n["<leader>wr"] = {
      function()
        vim.notify("Resize mode (Shift-H/J/K/L to resize, <Esc> to exit)", vim.log.levels.INFO, { timeout = 1500 })
        local local_opts = { noremap = true, silent = true, buffer = true }

        vim.keymap.set("n", "H", "<Cmd>vertical resize +2<CR>", local_opts)
        vim.keymap.set("n", "L", "<Cmd>vertical resize -2<CR>", local_opts)
        vim.keymap.set("n", "J", "<Cmd>resize -2<CR>", local_opts)
        vim.keymap.set("n", "K", "<Cmd>resize +2<CR>", local_opts)

        vim.keymap.set("n", "<Esc>", function()
          vim.notify("Exited resize mode", vim.log.levels.INFO, { timeout = 1000 })
          vim.cmd("mapclear <buffer>")
        end, local_opts)
      end,
      desc = "Window resize mode (Shift-H/J/K/L, Esc to exit)",
    }

    -- Window group label
    maps.n["<leader>w"] = { desc = " Windows" }

    maps.n["<leader>v"] = { "<cmd>vsplit<cr>", desc = "Vertical Split" }
    maps.n["<leader>s"] = { "<cmd>split<cr>", desc = "Horizontal Split" }

    -- Search all files (including ignored and hidden)
    maps.n["<leader>fF"] = {
      function() require("telescope.builtin").find_files({ no_ignore = true, hidden = true }) end,
      desc = "Find all files",
    }

    -- Frecency: files sorted by usage (frequency + recency)
    maps.n["<leader>fr"] = {
      function() require("telescope").extensions.frecency.frecency() end,
      desc = "Frecency (most used files)",
    }

    -- Buffers sorted by most recently used
    maps.n["<leader>fb"] = {
      function() require("telescope.builtin").buffers({ sort_mru = true, ignore_current_buffer = true }) end,
      desc = "Find buffers (MRU)",
    }

    -- Jumplist: recent code locations (like PyCharm's Recent Locations)
    maps.n["<leader>fj"] = {
      function() require("telescope.builtin").jumplist() end,
      desc = "Jumplist (recent locations)",
    }
    maps.n["<leader>fW"] = {
      function() require("telescope.builtin").live_grep({ additional_args = { "--no-ignore", "--hidden" } }) end,
      desc = "Search all files (grep)",
    }

    maps.n["<leader>yd"] = {
      function()
        local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
        if #diagnostics > 0 then
          local msg = diagnostics[1].message
          vim.fn.setreg("+", msg)
          vim.notify("Copied: " .. msg, vim.log.levels.INFO)
        else
          vim.notify("No diagnostic on this line", vim.log.levels.WARN)
        end
      end,
      desc = "Yank diagnostic to clipboard",
    }

    return opts
  end,
}

