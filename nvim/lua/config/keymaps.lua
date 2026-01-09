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

-- Helper to format and yank diagnostics
local function yank_diagnostics(diagnostics, scope_desc)
  if #diagnostics == 0 then
    vim.notify("No diagnostics " .. scope_desc, vim.log.levels.WARN)
    return
  end
  local filename = vim.fn.expand("%:.") -- relative path
  local lines = {}
  for _, d in ipairs(diagnostics) do
    local source = d.source or "unknown"
    local code = d.code and (" [" .. d.code .. "]") or ""
    local loc = string.format("%s:%d:%d", filename, d.lnum + 1, d.col + 1)
    table.insert(lines, string.format("%s: %s: %s%s", loc, source, d.message, code))
  end
  vim.fn.setreg("+", table.concat(lines, "\n"))
  vim.notify("Copied " .. #diagnostics .. " diagnostic(s)")
end

-- Yank diagnostics on current line
vim.keymap.set("n", "<leader>yd", function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  yank_diagnostics(diagnostics, "on current line")
end, { desc = "Yank diagnostics on line" })

-- Yank all diagnostics in file
vim.keymap.set("n", "<leader>yD", function()
  local diagnostics = vim.diagnostic.get(0)
  yank_diagnostics(diagnostics, "in file")
end, { desc = "Yank all diagnostics in file" })

-- Yank diagnostics in visual selection
vim.keymap.set("v", "<leader>yd", function()
  -- Exit visual mode to populate '< and '> marks
  vim.cmd([[execute "normal! \<Esc>"]])
  local start_line = vim.fn.line("'<") - 1 -- 0-indexed
  local end_line = vim.fn.line("'>") - 1

  local all_diagnostics = vim.diagnostic.get(0)
  local diagnostics = {}
  for _, d in ipairs(all_diagnostics) do
    if d.lnum >= start_line and d.lnum <= end_line then
      table.insert(diagnostics, d)
    end
  end
  yank_diagnostics(diagnostics, "in selection")
end, { desc = "Yank diagnostics in selection" })

-- Call hierarchy (with Telescope preview)
vim.keymap.set("n", "<leader>ci", "<cmd>Telescope lsp_incoming_calls<cr>", { desc = "Incoming calls" })
vim.keymap.set("n", "<leader>co", "<cmd>Telescope lsp_outgoing_calls<cr>", { desc = "Outgoing calls" })
