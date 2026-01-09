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

vim.keymap.set("n", "<leader>yd", function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if #diagnostics == 0 then
    vim.notify("No diagnostics on current line", vim.log.levels.WARN)
    return
  end
  local filename = vim.fn.expand("%:.")  -- relative path
  local lines = {}
  for _, d in ipairs(diagnostics) do
    local source = d.source or "unknown"
    local code = d.code and (" [" .. d.code .. "]") or ""
    local loc = string.format("%s:%d:%d", filename, d.lnum + 1, d.col + 1)
    table.insert(lines, string.format("%s: %s: %s%s", loc, source, d.message, code))
  end
  local text = table.concat(lines, "\n")
  vim.fn.setreg("+", text)
  vim.notify("Copied " .. #diagnostics .. " diagnostic(s)")
end, { desc = "Yank diagnostics on line" })
