return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "black" },
    },
    formatters = {
      -- Prefer a project-local virtualenv black, fall back to the one on PATH.
      black = {
        command = function()
          local venv = vim.fn.getcwd() .. "/.venv/bin/black"
          if vim.fn.executable(venv) == 1 then
            return venv
          end
          return "black"
        end,
      },
    },
  },
}
