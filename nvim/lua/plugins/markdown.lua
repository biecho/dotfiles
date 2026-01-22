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
  -- Ensure treesitter highlighting attaches for markdown (fixes SSH timing issues)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(args)
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(args.buf) then
              vim.treesitter.start(args.buf, "markdown")
            end
          end)
        end,
      })
    end,
  },
}
