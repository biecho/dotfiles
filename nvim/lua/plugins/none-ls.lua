-- Disable none-ls/null-ls for Python (we use ruff + basedpyright directly)

---@type LazySpec
return {
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      -- Clear all sources - we don't need null-ls for anything
      -- ruff handles linting/formatting, basedpyright handles type checking
      opts.sources = {}
    end,
  },
}
