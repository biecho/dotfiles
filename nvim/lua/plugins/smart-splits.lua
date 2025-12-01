-- Seamless navigation between neovim and kitty splits
-- Uses ctrl+hjkl for navigation, alt+hjkl for resizing
---@type LazySpec
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- Must be false to work with kitty integration
  build = "./kitty/install-kittens.bash", -- Installs kittens to ~/.config/kitty
  opts = {
    -- Kitty multiplexer integration
    multiplexer_integration = "kitty",
    -- Disable default keymaps, we'll set our own
    disable_multiplexer_nav_when_zoomed = false,
  },
  keys = {
    -- Navigation (ctrl+hjkl)
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to split below" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to split above" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },
    -- Resizing (alt+hjkl)
    { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
    { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
    { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
    { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
    -- Swap buffers (leader+hjkl)
    { "<leader><leader>h", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left" },
    { "<leader><leader>j", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down" },
    { "<leader><leader>k", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up" },
    { "<leader><leader>l", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right" },
  },
}
