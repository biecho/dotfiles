-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

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
vim.keymap.set("n", "<leader>xy", function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  yank_diagnostics(diagnostics, "on current line")
end, { desc = "Yank diagnostics on line" })

-- Yank all diagnostics in file
vim.keymap.set("n", "<leader>xY", function()
  local diagnostics = vim.diagnostic.get(0)
  yank_diagnostics(diagnostics, "in file")
end, { desc = "Yank all diagnostics in file" })

-- Yank diagnostics in visual selection
vim.keymap.set("v", "<leader>xy", function()
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

-- Call hierarchy now handled by lspsaga (see plugins/lspsaga.lua)

-- Remap macro recording to Q to prevent accidental triggers
vim.keymap.set("n", "q", "<Nop>")
vim.keymap.set("n", "Q", "q", { desc = "Record macro" })

-- Trim trailing whitespace in visual selection
vim.keymap.set("v", "<leader>tw", [[:s/\s\+$//g<CR>]], { desc = "Trim trailing whitespace" })

-- Toggle explorer with reveal current file (PyCharm-style)
-- Reveal handles cwd adjustment automatically for files outside the project root.
-- Hidden files are enabled so dotdirs (e.g. .ssh/) are visible.
vim.keymap.set("n", "<leader>e", function()
  local explorers = Snacks.picker.get({ source = "explorer" })
  if #explorers > 0 then
    explorers[1]:close()
  else
    -- Override default hidden=false so reveal works for dotfiles
    local orig_open = Snacks.explorer.open
    Snacks.explorer.open = function(opts)
      opts = vim.tbl_deep_extend("force", opts or {}, { hidden = true })
      return orig_open(opts)
    end
    Snacks.explorer.reveal()
    Snacks.explorer.open = orig_open
  end
end, { desc = "Explorer (reveal)" })
