-- Plugins disabled in favor of lspsaga
-- lspsaga provides: diagnostics UI, code actions, hover, rename, outline
return {
  -- trouble.nvim replaced by lspsaga diagnostics
  { "folke/trouble.nvim", enabled = false },

  -- LazyVim's default inc-rename replaced by lspsaga rename
  { "smjonas/inc-rename.nvim", enabled = false },
}
