return {
  {
    "stevearc/aerial.nvim",
    config = function()
      require("aerial").setup({
        backends = { "treesitter", "lsp" },
        layout = {
          default_direction = "prefer_right",
          width = 45,       -- increased width for more readable outlines
          min_width = 35,   -- keep a solid minimum even in smaller windows
        },
        highlight_on_hover = true,
        show_guides = true,
        attach_mode = "window",
        manage_folds = true,
        link_folds_to_tree = true,
      })
      -- Keymaps
      vim.keymap.set("n", "<leader>ao", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial outline" })
      vim.keymap.set("n", "<leader>an", "<cmd>AerialNext<CR>", { desc = "Next section" })
      vim.keymap.set("n", "<leader>ap", "<cmd>AerialPrev<CR>", { desc = "Previous section" })
    end,
  },
}

