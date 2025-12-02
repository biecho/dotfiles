-- Diffview.nvim: Single tabpage interface for git diffs
-- by sindrets - https://github.com/sindrets/diffview.nvim
--
-- ============================================================================
-- WHAT IS DIFFVIEW?
-- ============================================================================
--
-- Diffview opens a dedicated tab showing all changed files with full syntax
-- highlighting. You can edit files directly in the diff view with LSP support.
--
-- Key advantages over other diff tools:
-- - Cycle through ALL changed files in one view
-- - Edit files directly (right side is your working tree)
-- - LSP works in diff buffers (completions, diagnostics)
-- - Excellent merge conflict resolution (3-way diff)
-- - File history with line-range tracking
--
-- ============================================================================
-- KEYMAPS (Global) - Git operations under <leader>g
-- ============================================================================
--
-- NOTE: These do NOT conflict with LSP keymaps!
--   - gd  (no leader) = LSP go to definition
--   - gD  (no leader) = LSP go to declaration
--   - <leader>gd (with Space) = Git diff (this plugin)
--
-- <leader>gd    Toggle diffview (open/close)
-- <leader>gD    Diffview against main/master branch (PR review)
-- <leader>gh    File history (current file)
-- <leader>gH    File history (entire repo)
-- <leader>gh    (visual) Line history for selection
-- <leader>gm    Open merge/rebase conflict view
--
-- ============================================================================
-- KEYMAPS (Inside Diffview)
-- ============================================================================
--
-- NAVIGATION:
--   <Tab>         Next file
--   <S-Tab>       Previous file
--   ]c            Next hunk (in diff buffer)
--   [c            Previous hunk (in diff buffer)
--   gf            Open file in previous tab
--   <C-w><C-f>    Open file in split
--   <leader>e     Focus file panel
--   <leader>b     Toggle file panel
--
-- STAGING (in file panel):
--   -             Stage/unstage file or hunk
--   s             Stage file
--   u             Unstage file
--   S             Stage all
--   U             Unstage all
--   X             Restore file (discard changes)
--
-- MERGE CONFLICTS:
--   ]x            Next conflict
--   [x            Previous conflict
--   <leader>co    Choose OURS (current branch)
--   <leader>ct    Choose THEIRS (incoming branch)
--   <leader>cb    Choose BASE (common ancestor)
--   <leader>ca    Choose ALL (keep both)
--   dx            Delete conflict region
--
-- OTHER:
--   g?            Show help
--   q             Close diffview
--   <Esc>         Close diffview
--   g<C-x>        Cycle layout (horizontal/vertical/etc)
--   L             Open commit log (in file panel)
--   R             Refresh
--
-- ============================================================================
-- COMMON COMMANDS
-- ============================================================================
--
-- :DiffviewOpen                    Compare working tree vs index (staged)
-- :DiffviewOpen HEAD               Compare working tree vs last commit
-- :DiffviewOpen HEAD~2             Compare vs 2 commits ago
-- :DiffviewOpen main               Compare vs main branch
-- :DiffviewOpen origin/main...HEAD Compare your branch vs main (PR review)
-- :DiffviewOpen --staged           Show only staged changes
--
-- :DiffviewFileHistory             History of current branch
-- :DiffviewFileHistory %           History of current file
-- :DiffviewFileHistory --follow %  History with rename tracking
--
-- :DiffviewClose                   Close diffview
-- :DiffviewToggleFiles             Toggle file panel
-- :DiffviewRefresh                 Refresh file list
--
-- ============================================================================
-- WORKFLOWS
-- ============================================================================
--
-- WORKFLOW 1: Review your changes before commit
--   <leader>gd → cycle files with Tab → stage with - → close with q
--
-- WORKFLOW 2: Review a PR / compare branches
--   :DiffviewOpen origin/main...HEAD --imply-local
--   (shows your branch changes vs main, with LSP on right side)
--
-- WORKFLOW 3: See file history
--   <leader>gh → navigate commits → Enter to see diff
--
-- WORKFLOW 4: Resolve merge conflicts
--   (during merge/rebase) <leader>gm
--   Navigate conflicts with ]x [x
--   Choose resolution: <leader>co (ours) / <leader>ct (theirs)
--
-- WORKFLOW 5: Inspect what changed in a function
--   Visual select lines → :DiffviewFileHistory
--   (traces evolution of those specific lines!)
--
-- ============================================================================
-- TIPS
-- ============================================================================
--
-- - The RIGHT side is editable (your working tree) - make changes directly!
-- - LSP works on right side: get completions, diagnostics while reviewing
-- - In file panel: edit lines to stage partial hunks (like git add -p)
-- - Use --imply-local for PR review to get LSP on your code
-- - ]c and [c jump between hunks (vim's built-in diff navigation)
-- - do and dp: obtain/put diff hunks between windows
--
-- ============================================================================

---@type LazySpec
return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
    "DiffviewFileHistory",
  },
  keys = {
    -- Toggle diffview (smart: opens if closed, closes if open)
    {
      "<leader>gd",
      function()
        local lib = require("diffview.lib")
        local view = lib.get_current_view()
        if view then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Git: Toggle diff view",
    },
    -- Compare against main branch (useful for PR review)
    {
      "<leader>gD",
      function()
        -- Try main, then master
        local main_branch = vim.fn.system("git rev-parse --verify main 2>/dev/null"):gsub("%s+", "")
        if main_branch == "" then
          main_branch = "master"
        else
          main_branch = "main"
        end
        vim.cmd("DiffviewOpen origin/" .. main_branch .. "...HEAD --imply-local")
      end,
      desc = "Git: Diff against main branch",
    },
    -- File history for current file
    {
      "<leader>gh",
      "<cmd>DiffviewFileHistory --follow %<cr>",
      desc = "Git: File history (current)",
    },
    -- File history for entire repo
    {
      "<leader>gH",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "Git: File history (repo)",
    },
    -- Visual mode: history for selected lines
    {
      "<leader>gh",
      "<cmd>'<,'>DiffviewFileHistory --follow<cr>",
      mode = "v",
      desc = "Git: Line history (selection)",
    },
    -- Open during merge conflicts
    {
      "<leader>gm",
      "<cmd>DiffviewOpen<cr>",
      desc = "Git: Merge/rebase view",
    },
  },
  opts = {
    diff_binaries = false,
    enhanced_diff_hl = true, -- Better syntax highlighting in diffs
    git_cmd = { "git" },
    hg_cmd = { "hg" },
    use_icons = true,
    show_help_hints = true,
    watch_index = true, -- Auto-refresh on index changes

    icons = {
      folder_closed = "",
      folder_open = "",
    },
    signs = {
      fold_closed = "",
      fold_open = "",
      done = "✓",
    },

    view = {
      -- Default diff layout
      default = {
        layout = "diff2_horizontal", -- side-by-side
        disable_diagnostics = false, -- Keep LSP diagnostics
        winbar_info = false,
      },
      -- Merge conflict layout
      merge_tool = {
        layout = "diff3_mixed", -- 3-way with mixed layout
        disable_diagnostics = true,
        winbar_info = true,
      },
      -- File history layout
      file_history = {
        layout = "diff2_horizontal",
        disable_diagnostics = false,
        winbar_info = false,
      },
    },

    file_panel = {
      listing_style = "tree", -- "list" or "tree"
      tree_options = {
        flatten_dirs = true, -- Flatten single-child directories
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 35,
        win_opts = {},
      },
    },

    file_history_panel = {
      log_options = {
        git = {
          single_file = {
            diff_merges = "combined",
            follow = true, -- Follow renames
          },
          multi_file = {
            diff_merges = "first-parent",
          },
        },
      },
      win_config = {
        position = "bottom",
        height = 16,
        win_opts = {},
      },
    },

    -- Default arguments for commands
    default_args = {
      DiffviewOpen = { "--imply-local" }, -- LSP works on right side
      DiffviewFileHistory = { "--follow" }, -- Track renames
    },

    hooks = {
      -- Customize diff buffer settings
      diff_buf_read = function(bufnr)
        -- Disable wrap in diff buffers for cleaner view
        vim.opt_local.wrap = false
        vim.opt_local.list = false
        -- Optional: set colorcolumn
        -- vim.opt_local.colorcolumn = { 80 }
      end,
      -- When view opens
      view_opened = function(view)
        -- You could add custom logic here
      end,
    },

    keymaps = {
      disable_defaults = false, -- Keep all defaults, add custom ones

      view = {
        -- Easy close with q or Esc
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        { "n", "<Esc>", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },

      file_panel = {
        -- Easy close
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        { "n", "<Esc>", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },

      file_history_panel = {
        -- Easy close
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        { "n", "<Esc>", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
      },
    },
  },
}
