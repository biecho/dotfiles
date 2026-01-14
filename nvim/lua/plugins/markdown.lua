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
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      html = {
        comment = {
          conceal = false, -- Don't hide HTML comments
        },
      },
    },
  },
}
