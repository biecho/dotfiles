-- ╭─────────────────────────────────────────────────────────────╮
-- │ Markdown Filetype Settings                                  │
-- ╰─────────────────────────────────────────────────────────────╯
--
-- This file auto-activates Quarto LSP features for markdown files,
-- enabling LSP completion, diagnostics, and code actions in fenced
-- code blocks via otter.nvim.
--
-- KEYBINDINGS (from markdown.lua and quarto in python.lua):
-- ──────────────────────────────────────────────────────────────
-- Navigation:
--   ]]        Next heading
--   [[        Previous heading
--   ]c        Current heading (jump to it)
--   ]p        Parent heading
--   ]x / [x   Next/previous code cell (# %% markers)
--   gx        Follow link under cursor
--
-- Editing (markdown.nvim):
--   gsb + motion  Toggle **bold** (e.g., gsbiw)
--   gsi + motion  Toggle *italic*
--   gsc + motion  Toggle `code`
--   gss           Toggle on whole line
--   ds + char     Delete surrounding
--   cs + old+new  Change surrounding
--   gl + motion   Add link
--
-- Preview:
--   <leader>mp    Glow preview (floating window, works over SSH)
--
-- Quarto (<leader>q):
--   <leader>qp    Quarto preview
--   <leader>qc    Close preview
--   <leader>qa    Activate Quarto LSP
--   <leader>qr    Run cell
--   <leader>qR    Run all cells
--   <leader>ql    Run line
--   <leader>qA    Run all above
--   <leader>qb    Run all below
--
-- Cell Text Objects (vim-textobj-hydrogen):
--   ih            Inner cell (content between # %% markers)
--   ah            Around cell (including the marker)
--
-- ──────────────────────────────────────────────────────────────

-- Activate Quarto LSP features (otter.nvim for code block completion)
local ok, quarto = pcall(require, "quarto")
if ok then
  quarto.activate()
end

-- Markdown-specific display settings
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
