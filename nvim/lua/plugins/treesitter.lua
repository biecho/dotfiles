-- Treesitter configuration
-- Note: Requires tree-sitter-cli 0.23.x (newer versions need GLIBC 2.39)
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
        "bash",
        "lua",
        "vim",
        "vimdoc",
        "json",
        "yaml",
        "toml",
        "markdown",
        "markdown_inline",
      },
      auto_install = false, -- Don't auto-install, use ensure_installed list
    },
  },

  -- Add ]=/[= to jump between assignments (class fields, variables, etc.)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = function(_, opts)
      opts.move = opts.move or {}
      opts.move.keys = opts.move.keys or {}
      opts.move.keys.goto_next_start = opts.move.keys.goto_next_start or {}
      opts.move.keys.goto_next_start["]="] = "@assignment.outer"
      opts.move.keys.goto_next_start["]s"] = "@statement.outer"
      opts.move.keys.goto_previous_start = opts.move.keys.goto_previous_start or {}
      opts.move.keys.goto_previous_start["[="] = "@assignment.outer"
      opts.move.keys.goto_previous_start["[s"] = "@statement.outer"
    end,
  },

  -- Add a=/i= textobjects for assignments
  {
    "nvim-mini/mini.ai",
    opts = function(_, opts)
      local ai = require("mini.ai")
      opts.custom_textobjects = opts.custom_textobjects or {}
      opts.custom_textobjects["="] = ai.gen_spec.treesitter({
        a = "@assignment.outer",
        i = "@assignment.inner",
      })
    end,
  },

  -- Prevent Mason from installing tree-sitter-cli (we use npm version)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- Filter out tree-sitter-cli
      local filtered = {}
      for _, pkg in ipairs(opts.ensure_installed) do
        if pkg ~= "tree-sitter-cli" then
          table.insert(filtered, pkg)
        end
      end
      opts.ensure_installed = filtered
    end,
  },
}
