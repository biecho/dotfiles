-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- Lua development
  { import = "astrocommunity.pack.lua" },

  -- Python: only use ruff from astrocommunity, rest is in plugins/python.lua
  -- (pack.python adds pyright + null-ls which conflicts with basedpyright)
  { import = "astrocommunity.pack.python-ruff" }, -- ruff linter/formatter
}
