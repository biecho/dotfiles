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

    -- On remote/SSH hosts, serve the preview over Tailscale so it's reachable
    -- from the local browser directly -- no kitty remote control and no SSH
    -- port forwarding required (the old approach broke whenever the kitty
    -- control socket wasn't forwarded, e.g. nested SSH / compute nodes).
    if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
      -- The Tailscale IP already disambiguates hosts, so a single shared port
      -- range is enough -- only multiple nvim instances on the *same* host can
      -- collide, and the pid keeps those apart.
      local port = 9700 + (vim.fn.getpid() % 100)
      vim.g.mkdp_port = tostring(port)

      -- Bind the preview server to 0.0.0.0 so it's reachable over the network...
      vim.g.mkdp_open_to_the_world = 1
      -- ...and advertise this host's Tailscale IP in the preview URL so the
      -- link the browser is pointed at is reachable from the local machine.
      local ts_ip = vim.fn.system({ "tailscale", "ip", "-4" })
      if vim.v.shell_error == 0 then
        ts_ip = vim.trim(vim.split(ts_ip, "\n")[1] or "")
        if ts_ip ~= "" then
          vim.g.mkdp_open_ip = ts_ip
        end
      end

      -- Instead of auto-opening a browser on the remote host, open the
      -- Tailscale URL in the *local* browser via kitty remote control, and
      -- always surface the URL as a clickable fallback.
      vim.g.mkdp_browserfunc = "OpenMarkdownPreviewBrowser"
      vim.cmd([[
        function! OpenMarkdownPreviewBrowser(url) abort
          let l:kitty = executable('kitten') ? 'kitten' : (executable('kitty') ? 'kitty' : '')
          if !empty(l:kitty)
            " Inside tmux $KITTY_LISTEN_ON is stale (a new ssh connection
            " forwards a new socket), so ask the tmux server for the current
            " client's value (tracked via update-environment in tmux.conf).
            let l:listen = $KITTY_LISTEN_ON
            if !empty($TMUX)
              let l:out = trim(system('tmux show-environment KITTY_LISTEN_ON 2>/dev/null'))
              if v:shell_error == 0 && l:out =~# '^KITTY_LISTEN_ON='
                let l:listen = l:out[16:]
              endif
            endif
            let l:cmd = [l:kitty, '@']
            if !empty(l:listen)
              let l:cmd += ['--to', l:listen]
            endif
            call jobstart(l:cmd + ['action', 'open_url', a:url])
          endif
          call luaeval('vim.notify("Markdown Preview: " .. _A, vim.log.levels.INFO)', a:url)
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
