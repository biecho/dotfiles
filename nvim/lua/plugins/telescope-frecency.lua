---@type LazySpec
return {
  "nvim-telescope/telescope-frecency.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("frecency")
    require("telescope").setup {
      extensions = {
        frecency = {
          show_scores = false,
          show_unindexed = true,
          ignore_patterns = { "*.git/*", "*/tmp/*" },
          workspace = "CWD",
        },
      },
    }
  end,
}

