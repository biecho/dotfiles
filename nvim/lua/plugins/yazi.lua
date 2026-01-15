-- Yazi file manager integration
-- Opens yazi in a floating window with seamless neovim integration
return {
  "mikavilpas/yazi.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
  keys = {
    -- `-` is the classic vim-vinegar pattern for "go to directory"
    { "-", "<cmd>Yazi<cr>", desc = "Yazi (current file)" },
    { "<leader>-", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Yazi (resume)" },
  },
  opts = {
    -- Don't replace netrw for directory arguments
    open_for_directories = false,
  },
}
