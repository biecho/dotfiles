-- ~/.config/nvim/lua/plugins/user-mappings.lua

---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local maps = opts.mappings

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

    return opts
  end,
}

