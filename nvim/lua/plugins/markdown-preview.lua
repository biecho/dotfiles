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
    -- Use the default browser
    vim.g.mkdp_auto_close = 1

    -- Open browser on local machine when using SSH via kitty remote control
    if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
      -- Fixed port for SSH forwarding
      vim.g.mkdp_port = '9765'
      vim.g.mkdp_browserfunc = 'OpenMarkdownPreviewBrowser'
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
      disable_sync_scroll = 0,
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
