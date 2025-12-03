-- This will run last in the setup process.

-- Python provider for remote plugins (molten-nvim, etc.)
-- Searches for a Python with pynvim installed
local function find_python_with_pynvim()
  local candidates = {
    vim.fn.exepath("python3"),
    vim.fn.expand("~/.local/share/nvim/python/bin/python"),
    "/usr/bin/python3",
  }
  -- Also check current venv if active
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    table.insert(candidates, 1, venv .. "/bin/python")
  end

  for _, python in ipairs(candidates) do
    if vim.fn.executable(python) == 1 then
      local check = vim.fn.system(python .. ' -c "import pynvim" 2>/dev/null')
      if vim.v.shell_error == 0 then
        return python
      end
    end
  end
  return nil
end

local python = find_python_with_pynvim()
if python then
  vim.g.python3_host_prog = python
end

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

-- OSC 52 clipboard (allows yanking to local clipboard over SSH)
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}
