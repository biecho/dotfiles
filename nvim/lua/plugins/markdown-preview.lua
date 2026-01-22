-- Markdown preview in browser with LaTeX/MathJax support
-- Use :MarkdownPreview to start, :MarkdownPreviewStop to stop
---@type LazySpec
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = "cd app && npm install",
  keys = {
    {
      "<leader>mp",
      "<cmd>MarkdownPreviewToggle<cr>",
      desc = "Markdown Preview",
    },
  },
  config = function()
    -- Don't auto-close preview when switching buffers (allows multiple previews)
    vim.g.mkdp_auto_close = 0

    -- Open browser on local machine when using SSH via kitty remote control
    if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
      -- Detect hostname to determine port range (different hosts use different ranges)
      -- p12: 9700-9709, s16: 9710-9719, others: 9720-9799
      local hostname = vim.fn.hostname()
      local base_port, range_size
      if hostname == "p12" then
        base_port, range_size = 9700, 10
      elseif hostname == "s16" then
        base_port, range_size = 9710, 10
      else
        base_port, range_size = 9720, 80
      end
      local port = base_port + (vim.fn.getpid() % range_size)
      vim.g.mkdp_port = tostring(port)
      vim.g.mkdp_browserfunc = 'OpenMarkdownPreviewBrowser'
      -- Notify user which port is being used (helpful for SSH forwarding)
      vim.api.nvim_create_autocmd("User", {
        pattern = "MarkdownPreviewToggle",
        callback = function()
          vim.notify("Markdown Preview on " .. hostname .. " using port " .. port, vim.log.levels.INFO)
        end,
      })
      vim.cmd([[
        function! OpenMarkdownPreviewBrowser(url)
          " Replace remote address with localhost since we're using port forwarding
          let l:local_url = substitute(a:url, 'http://127\.0\.0\.1:', 'http://localhost:', '')
          " Use kitty remote control to open URL on local machine
          call system('kitty @ action open_url ' . l:local_url)
        endfunction
      ]])
    end

    -- Auto scroll sync between editor and preview
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 1,
      sync_scroll_type = "middle",
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {},
    }
  end,
}
