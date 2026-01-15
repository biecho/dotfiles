-- Yazi file manager integration
-- Opens yazi in a floating window with seamless neovim integration
return {
  "mikavilpas/yazi.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
  keys = {
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Yazi (resume)" },
  },
  -- Use init to set <leader>- AFTER LazyVim keymaps load
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        vim.keymap.set("n", "<leader>-", "<cmd>Yazi<cr>", { desc = "Yazi (current file)" })
      end,
    })
  end,
  opts = {
    -- Don't replace netrw for directory arguments
    open_for_directories = false,
  },
}
