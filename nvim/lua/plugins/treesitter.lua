-- Treesitter configuration
-- Note: Requires tree-sitter-cli 0.22.x (newer versions need GLIBC 2.39)
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
