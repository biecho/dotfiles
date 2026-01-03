-- Disable markdown linting while keeping LSP features
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {}, -- Disable markdownlint-cli2
      },
    },
  },
}
