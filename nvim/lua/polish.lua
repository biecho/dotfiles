-- This will run last in the setup process.
-- Kitty terminal optimizations

-- Ensure true color support
vim.opt.termguicolors = true

-- Undercurl support (wavy underlines for diagnostics)
vim.g.kitty_undercurl = true
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Kitty keyboard protocol (disambiguates Ctrl+I from Tab, etc.)
-- Requires Neovim 0.9+
if vim.fn.has("nvim-0.9") == 1 then
  vim.g.kitty_protocol = "all"
end
