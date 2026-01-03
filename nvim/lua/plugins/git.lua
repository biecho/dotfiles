return {
  -- Diffview: Best-in-class diff viewer for nvim
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      -- View all changes (non-conflicting with LazyVim's <leader>gd)
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff View (all changes)" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diff View Close" },

      -- File/Repo history (non-conflicting)
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (diffview)" },
      { "<leader>gR", "<cmd>DiffviewFileHistory<cr>", desc = "Repo History" },

      -- View staged changes (non-conflicting with LazyVim's <leader>gs)
      { "<leader>gc", "<cmd>DiffviewOpen --staged<cr>", desc = "Diff Cached/Staged" },
    },
    opts = {
      enhanced_diff_hl = true, -- Better syntax highlighting in diffs
      view = {
        default = {
          layout = "diff2_horizontal", -- side-by-side
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
      file_panel = {
        win_config = {
          width = 35,
        },
      },
    },
  },
}
