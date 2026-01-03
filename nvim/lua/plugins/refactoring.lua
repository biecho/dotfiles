return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    -- Refactor menu
    { "<leader>r", "", desc = "+refactor", mode = { "n", "v" } },
    { "<leader>rs", function() require("refactoring").select_refactor() end, mode = { "n", "v" }, desc = "Refactor" },

    -- Extract operations
    { "<leader>rf", function() require("refactoring").refactor("Extract Function") end, mode = "v", desc = "Extract Function" },
    { "<leader>rF", function() require("refactoring").refactor("Extract Function To File") end, mode = "v", desc = "Extract Function To File" },
    { "<leader>rx", function() require("refactoring").refactor("Extract Variable") end, mode = "v", desc = "Extract Variable" },
    { "<leader>rb", function() require("refactoring").refactor("Extract Block") end, mode = { "n", "v" }, desc = "Extract Block" },
    { "<leader>rf", function() require("refactoring").refactor("Extract Block To File") end, mode = { "n", "v" }, desc = "Extract Block To File" },

    -- Inline operations
    { "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, mode = { "n", "v" }, desc = "Inline Variable" },

    -- Debug helpers
    { "<leader>rp", function() require("refactoring").debug.print_var() end, mode = { "n", "v" }, desc = "Debug Print Variable" },
    { "<leader>rP", function() require("refactoring").debug.printf({ below = false }) end, desc = "Debug Print" },
    { "<leader>rc", function() require("refactoring").debug.cleanup({}) end, desc = "Debug Cleanup" },
  },
  opts = {
    prompt_func_return_type = {
      go = false,
      java = false,
      cpp = false,
      c = false,
      h = false,
      hpp = false,
      cxx = false,
    },
    prompt_func_param_type = {
      go = false,
      java = false,
      cpp = false,
      c = false,
      h = false,
      hpp = false,
      cxx = false,
    },
    printf_statements = {},
    print_var_statements = {},
  },
  config = function(_, opts)
    require("refactoring").setup(opts)
    -- Load Telescope extension if available
    if LazyVim.has("telescope.nvim") then
      require("telescope").load_extension("refactoring")
    end
  end,
}
