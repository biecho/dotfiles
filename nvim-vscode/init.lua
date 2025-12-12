-- Minimal neovim config for vscode-neovim
-- This runs inside VS Code via the vscode-neovim extension
--
-- Your main nvim config (~/.config/nvim) is NOT loaded.
-- Only text-editing plugins make sense here (flash, surround, etc.)
-- UI plugins (telescope, harpoon, treesitter) are handled by VS Code.

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy-vscode/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"

-- VS Code specific: call VS Code commands
-- vscode-neovim provides the "vscode" module (only available inside VS Code)
local ok, vscode = pcall(require, "vscode")
if not ok then
  -- Running outside VS Code (e.g., testing) - provide stub
  vim.notify("nvim-vscode config: Not running in VS Code, keymaps disabled", vim.log.levels.WARN)
  return
end

-- Helper to call VS Code commands (async, non-blocking)
local function call(cmd)
  return function() vscode.action(cmd) end
end

-- Plugins that make sense in VS Code
require("lazy").setup({
  -- Flash: jump anywhere with s + pattern + label
  -- NOTE: Flash treesitter (S) may not work perfectly in VS Code since
  -- treesitter parsing is handled differently. Use 's' for most jumps.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm",
      search = { multi_window = false }, -- VS Code handles windows
      modes = {
        char = { enabled = true, keys = { "f", "F", "t", "T", ";", "," } },
        -- Treesitter mode - may have limited functionality in VS Code
        treesitter = {
          labels = "asdfghjklqwertyuiopzxcvbnm",
        },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },

  -- Surround: cs'" to change ' to ", ysiw" to surround word with "
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
}, {
  root = vim.fn.stdpath("data") .. "/lazy-vscode",
  lockfile = vim.fn.stdpath("data") .. "/lazy-vscode/lazy-lock.json",
})

-- ============================================================================
-- KEYMAPS - VS Code commands mapped to leader keys
-- ============================================================================

local keymap = vim.keymap.set

-- File navigation (replacing telescope)
keymap("n", "<leader>ff", call("workbench.action.quickOpen"), { desc = "Find files" })
keymap("n", "<leader>fr", call("workbench.action.openRecent"), { desc = "Recent files" })
keymap("n", "<leader>fb", call("workbench.action.showAllEditors"), { desc = "Find buffers" })
keymap("n", "<leader>fw", call("workbench.action.findInFiles"), { desc = "Find in files (grep)" })
keymap("n", "<leader>fW", call("workbench.action.findInFiles"), { desc = "Find in files" })

-- Symbol search (like PyCharm Ctrl+O / Cmd+Shift+O)
keymap("n", "<leader>fs", call("workbench.action.gotoSymbol"), { desc = "Symbols in file" })
keymap("n", "<leader>fS", call("workbench.action.showAllSymbols"), { desc = "Symbols in workspace" })

-- Buffer/editor navigation
keymap("n", "]b", call("workbench.action.nextEditor"), { desc = "Next buffer" })
keymap("n", "[b", call("workbench.action.previousEditor"), { desc = "Previous buffer" })
keymap("n", "<leader>bd", call("workbench.action.closeActiveEditor"), { desc = "Close buffer" })
keymap("n", "<leader>c", call("workbench.action.closeActiveEditor"), { desc = "Close buffer" })

-- Splits (matching your nvim config)
keymap("n", "<leader>v", call("workbench.action.splitEditorRight"), { desc = "Vertical split" })
keymap("n", "<leader>s", call("workbench.action.splitEditorDown"), { desc = "Horizontal split" })

-- Window navigation (Ctrl+hjkl)
keymap("n", "<C-h>", call("workbench.action.focusLeftGroup"), { desc = "Focus left" })
keymap("n", "<C-j>", call("workbench.action.focusBelowGroup"), { desc = "Focus below" })
keymap("n", "<C-k>", call("workbench.action.focusAboveGroup"), { desc = "Focus above" })
keymap("n", "<C-l>", call("workbench.action.focusRightGroup"), { desc = "Focus right" })

-- Ctrl+w window commands (passed through from VS Code to neovim)
keymap("n", "<C-w>v", call("workbench.action.splitEditorRight"), { desc = "Split right" })
keymap("n", "<C-w>s", call("workbench.action.splitEditorDown"), { desc = "Split down" })
keymap("n", "<C-w>q", call("workbench.action.closeActiveEditor"), { desc = "Close editor" })
keymap("n", "<C-w>c", call("workbench.action.closeActiveEditor"), { desc = "Close editor" })
keymap("n", "<C-w>o", call("workbench.action.closeOtherEditors"), { desc = "Close others" })
keymap("n", "<C-w>h", call("workbench.action.focusLeftGroup"), { desc = "Focus left" })
keymap("n", "<C-w>j", call("workbench.action.focusBelowGroup"), { desc = "Focus below" })
keymap("n", "<C-w>k", call("workbench.action.focusAboveGroup"), { desc = "Focus above" })
keymap("n", "<C-w>l", call("workbench.action.focusRightGroup"), { desc = "Focus right" })

-- LSP-like actions (VS Code handles these)
keymap("n", "gd", call("editor.action.revealDefinition"), { desc = "Go to definition" })
keymap("n", "gr", call("editor.action.goToReferences"), { desc = "Go to references" })
keymap("n", "gi", call("editor.action.goToImplementation"), { desc = "Go to implementation" })
keymap("n", "K", call("editor.action.showHover"), { desc = "Hover" })
keymap("n", "<leader>la", call("editor.action.quickFix"), { desc = "Code actions" })
keymap("n", "<leader>lr", call("editor.action.rename"), { desc = "Rename" })
keymap("n", "<leader>lf", call("editor.action.formatDocument"), { desc = "Format" })

-- Call hierarchy (like PyCharm)
keymap("n", "<leader>lci", call("editor.showIncomingCalls"), { desc = "Incoming calls (who calls this)" })
keymap("n", "<leader>lco", call("editor.showOutgoingCalls"), { desc = "Outgoing calls (what this calls)" })
keymap("n", "<leader>lh", call("references-view.showCallHierarchy"), { desc = "Call hierarchy" })

-- Type hierarchy
keymap("n", "<leader>lt", call("editor.showTypeHierarchy"), { desc = "Type hierarchy" })

-- Diagnostics
keymap("n", "]d", call("editor.action.marker.next"), { desc = "Next diagnostic" })
keymap("n", "[d", call("editor.action.marker.prev"), { desc = "Previous diagnostic" })
keymap("n", "<leader>ld", call("workbench.actions.view.problems"), { desc = "Diagnostics list" })

-- Git
keymap("n", "<leader>gg", call("workbench.view.scm"), { desc = "Git view" })
keymap("n", "<leader>gb", call("gitlens.toggleFileBlame"), { desc = "Git blame" })
keymap("n", "<leader>gG", call("git-graph.view"), { desc = "Git graph" })
keymap("n", "<leader>gl", call("gitlens.showCommitsInView"), { desc = "Git log" })

-- Todo Tree
keymap("n", "<leader>ft", call("todo-tree-view.focus"), { desc = "Todo tree" })

-- Explorer & terminal
keymap("n", "<leader>e", call("workbench.action.toggleSidebarVisibility"), { desc = "Toggle explorer" })
keymap("n", "<leader>E", call("workbench.view.explorer"), { desc = "Focus explorer" })
keymap("n", "<leader>tf", call("workbench.action.terminal.toggleTerminal"), { desc = "Toggle terminal" })

-- Focus switching (cycle between panels)
keymap("n", "<leader>o", call("workbench.action.focusActiveEditorGroup"), { desc = "Focus editor" })
keymap("n", "<leader>0", call("workbench.action.focusSideBar"), { desc = "Focus sidebar" })
keymap("n", "<leader>t", call("workbench.action.terminal.focus"), { desc = "Focus terminal" })

-- Quit
keymap("n", "<leader>Q", call("workbench.action.closeWindow"), { desc = "Quit" })
keymap("n", "<leader>q", call("workbench.action.closeActiveEditor"), { desc = "Close editor" })

-- Command palette (like telescope commands)
keymap("n", "<leader>fc", call("workbench.action.showCommands"), { desc = "Commands" })
