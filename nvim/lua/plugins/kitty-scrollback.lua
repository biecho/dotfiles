return {
  "mikesmithgh/kitty-scrollback.nvim",
  enabled = true,
  lazy = true,
  cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
  event = { "User KittyScrollbackLaunch" },
  config = function()
    require("kitty-scrollback").setup({
      -- Global config must be at index 1 (first array element)
      {
        status_window = {
          enabled = false, -- cleaner look
        },
        paste_window = {
          yank_register_enabled = false, -- don't open paste window on yank
        },
        keymaps_enabled = false, -- disable plugin keymaps, use nvim as usual
        visual_selection_highlight_mode = "nvim", -- use native Visual highlight
        callbacks = {
          after_ready = function(kitty_data, opts)
            -- Close paste window if it opened
            local paste_winid = vim.fn.bufwinid("kitty-scrollback.nvim-paste-buf")
            if paste_winid ~= -1 then
              vim.api.nvim_win_close(paste_winid, true)
            end

            -- Fix visual highlight: copy from current colorscheme's Visual
            local visual_hl = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
            if visual_hl and next(visual_hl) then
              vim.api.nvim_set_hl(0, "KittyScrollbackNvimVisual", visual_hl)
            else
              -- Fallback: use reverse video if Visual is empty
              vim.api.nvim_set_hl(0, "KittyScrollbackNvimVisual", { reverse = true })
            end

            -- Only add q to quit (needed because global q=<Nop> in keymaps.lua)
            vim.keymap.set("n", "q", "<Cmd>qa!<CR>", { buffer = true, desc = "Quit scrollback" })
          end,
        },
      },
    })
  end,
}
