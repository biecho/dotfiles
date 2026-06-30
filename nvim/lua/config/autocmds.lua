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

-- When a buffer is reloaded from disk, the partial didChange that the reload
-- emits can leave the language server's document copy out of sync, so it keeps
-- reporting stale diagnostics until a manual `:e`. Force a full resync by
-- detaching (sends didClose) and reattaching (sends didOpen) every LSP client
-- on the buffer -- the same effect as `:e`, without restarting the server.
local function resync_lsp(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    vim.lsp.buf_detach_client(bufnr, client.id)
    vim.schedule(function()
      if vim.api.nvim_buf_is_loaded(bufnr) then
        vim.lsp.buf_attach_client(bufnr, client.id)
      end
    end)
  end
end

-- Resync LSP and notify when a buffer was reloaded because the file changed
-- externally.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("checktime_notify", { clear = true }),
  callback = function(event)
    resync_lsp(event.buf)
    vim.notify(
      "File reloaded from disk: " .. vim.fn.fnamemodify(event.file, ":t"),
      vim.log.levels.INFO,
      { title = "Auto-reload" }
    )
  end,
})

-- basedpyright cold-start race: on a fresh open the server analyzes the
-- document under its noisy default `typeCheckingMode` before honoring the
-- "standard" setting Neovim sends, so a flood of recommended-mode diagnostics
-- (reportAny, reportUnusedCallResult, ...) shows until a manual `:e`. The
-- client's settings are already correct -- basedpyright just won't re-analyze
-- the already-open buffer. Forcing a full resync (didClose + didOpen) makes it
-- re-analyze under "standard", the same effect as `:e`.
--
-- Timing matters: the resync only works once basedpyright is warm (has resolved
-- its config); doing it too early just re-races. basedpyright emitting its first
-- diagnostics is a reliable "now warm" signal, so wait for that rather than
-- guessing a delay. A per-buffer flag makes it fire exactly once and keeps the
-- resync's own reattach from looping back through here.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("basedpyright_resync_on_attach", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "basedpyright" then
      return
    end
    local bufnr = event.buf
    if vim.b[bufnr].basedpyright_resynced then
      return
    end
    -- Resync on basedpyright's first diagnostics, then self-delete (return true).
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
      buffer = bufnr,
      callback = function()
        if vim.b[bufnr].basedpyright_resynced then
          return true
        end
        local warm = false
        for _, d in ipairs(vim.diagnostic.get(bufnr)) do
          if d.source == "basedpyright" then
            warm = true
            break
          end
        end
        if not warm then
          return
        end
        vim.b[bufnr].basedpyright_resynced = true
        resync_lsp(bufnr)
        return true
      end,
    })
  end,
})
