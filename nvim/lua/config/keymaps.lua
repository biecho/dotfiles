-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Copy filename to clipboard
vim.keymap.set("n", "<leader>yf", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
  vim.notify("Copied relative path: " .. vim.fn.expand("%"))
end, { desc = "Yank filename (relative path)" })

vim.keymap.set("n", "<leader>yF", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied absolute path: " .. vim.fn.expand("%:p"))
end, { desc = "Yank filename (absolute path)" })

vim.keymap.set("n", "<leader>yn", function()
  vim.fn.setreg("+", vim.fn.expand("%:t"))
  vim.notify("Copied filename: " .. vim.fn.expand("%:t"))
end, { desc = "Yank filename only" })
