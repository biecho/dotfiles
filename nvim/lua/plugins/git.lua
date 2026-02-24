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

      -- Review branch changes against main
      { "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff vs Main" },

      -- View last commit
      { "<leader>gh", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Diff Last Commit (HEAD)" },
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

  -- Octo: GitHub PR/issue review inside Neovim
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>go", "<cmd>Octo<cr>", desc = "Octo (GitHub)" },
      { "<leader>gpl", "<cmd>Octo pr list<cr>", desc = "List PRs" },
      { "<leader>gps", "<cmd>Octo pr search<cr>", desc = "Search PRs" },
      { "<leader>gil", "<cmd>Octo issue list<cr>", desc = "List Issues" },
      { "<leader>gis", "<cmd>Octo issue search<cr>", desc = "Search Issues" },
    },
    opts = {
      enable_builtin = true, -- Use telescope picker for Octo commands
      default_merge_method = "squash",
      ssh_aliases = {},
    },
  },

  -- git-conflict: Inline merge conflict resolution
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPre",
    opts = {
      default_mappings = true, -- co=ours, ct=theirs, cb=both, c0=none
      default_commands = true, -- GitConflictChooseOurs, etc.
      disable_diagnostics = true, -- Less noise during conflict resolution
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
  },
}
