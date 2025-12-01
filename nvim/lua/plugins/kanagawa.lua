return {
  "rebelot/kanagawa.nvim",
  priority = 1000,
  config = function()
    local kanagawa = require("kanagawa")

    kanagawa.setup({
      compile = false,
      transparent = false,
      theme = "lotus",
    })

    -- start with wave (you can change this)
    vim.cmd.colorscheme("kanagawa-wave")

    -- simple toggle function
    local current_theme = "wave"
    local function toggle_kanagawa_theme()
      if current_theme == "wave" then
        vim.cmd.colorscheme("kanagawa-lotus")
        current_theme = "lotus"
      else
        vim.cmd.colorscheme("kanagawa-wave")
        current_theme = "wave"
      end
      vim.notify("Switched to Kanagawa " .. current_theme)
    end

    vim.keymap.set("n", "<leader>tt", toggle_kanagawa_theme, { desc = "Toggle Kanagawa theme" })
  end,
}

