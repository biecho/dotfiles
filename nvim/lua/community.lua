-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- Lua development
  { import = "astrocommunity.pack.lua" },

  -- Python development (the serious setup)
  { import = "astrocommunity.pack.python" },      -- pyright + debugpy + treesitter
  { import = "astrocommunity.pack.python-ruff" }, -- ruff linter/formatter
}
