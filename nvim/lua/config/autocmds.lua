-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Persist colorscheme choice across restarts
local colorscheme_file = vim.fn.stdpath("config") .. "/.colorscheme"

-- Load saved colorscheme (runs on VeryLazy, after plugins are loaded)
if vim.fn.filereadable(colorscheme_file) == 1 then
  local scheme = vim.fn.readfile(colorscheme_file)[1]
  if scheme and scheme ~= "" then
    pcall(vim.cmd.colorscheme, scheme)
  end
end

-- Save colorscheme when changed
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("persist_colorscheme", { clear = true }),
  callback = function(event)
    vim.fn.writefile({ event.match }, colorscheme_file)
  end,
})

-- Reload files changed on disk while idling in the buffer (LazyVim only checks
-- on FocusGained/TermClose/TermLeave). Reloading updates the buffer contents,
-- which makes attached LSP clients send didChange automatically.
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("checktime_idle", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Poll for on-disk changes on a wall-clock timer, so reloads still happen when
-- nvim is fully idle (no cursor movement to trigger the CursorHold autocmd).
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(
  2000,
  2000,
  vim.schedule_wrap(function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end)
)

-- Notify when a buffer was reloaded because the file changed externally.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("checktime_notify", { clear = true }),
  callback = function(event)
    vim.notify(
      "File reloaded from disk: " .. vim.fn.fnamemodify(event.file, ":t"),
      vim.log.levels.INFO,
      { title = "Auto-reload" }
    )
  end,
})
