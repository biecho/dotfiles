return {
  "nvim-telescope/telescope.nvim",
  -- Browsable undo history with diffs in the preview, like PyCharm's
  -- Local History (persists across sessions via LazyVim's undofile default).
  dependencies = { "debugloop/telescope-undo.nvim" },
  keys = {
    {
      "<leader>su",
      function()
        require("telescope").load_extension("undo")
        require("telescope").extensions.undo.undo()
      end,
      desc = "Undo History",
    },
  },
  -- Centered popup with code preview for ALL pickers, like PyCharm's
  -- Search Everywhere / Recent Locations. Applied via defaults so every
  -- LazyVim binding (<leader>sj, <leader>sg, <leader>ff, ...) inherits it.
  opts = function(_, opts)
    -- <M-p>: focus the preview window to move around in it with normal
    -- vim motions (read-only); <M-p> again in the preview returns to the
    -- prompt. To actually edit, use <CR> and resume the picker (<leader>sR).
    local function focus_preview(prompt_bufnr)
      local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
      local winid = picker.previewer and picker.previewer.state and picker.previewer.state.winid

      if not winid or not vim.api.nvim_win_is_valid(winid) then
        return
      end

      -- noautocmd: leaving the prompt normally fires its BufLeave autocmd,
      -- which closes the whole picker.
      local prompt_win = picker.prompt_win
      vim.keymap.set("n", "<M-p>", function()
        vim.cmd(("noautocmd lua vim.api.nvim_set_current_win(%d)"):format(prompt_win))
      end, { buffer = vim.api.nvim_win_get_buf(winid) })
      vim.cmd(("noautocmd lua vim.api.nvim_set_current_win(%d)"):format(winid))
    end

    opts.defaults = vim.tbl_deep_extend(
      "force",
      opts.defaults or {},
      require("telescope.themes").get_dropdown({
        previewer = true,
        layout_config = {
          width = 0.8,
          -- In the center layout `height` sizes only the prompt+results
          -- block; the preview gets all remaining space. Anchoring north
          -- puts the list on top and lets the preview fill down from there.
          height = 0.3,
          anchor = "N",
        },
      }),
      { mappings = { i = { ["<M-p>"] = focus_preview }, n = { ["<M-p>"] = focus_preview } } }
    )
  end,
}
