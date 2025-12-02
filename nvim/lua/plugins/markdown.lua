-- Professional Markdown Configuration
-- Enhances markdown editing with visual rendering, preview, and editing tools

---@type LazySpec
return {
  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ render-markdown.nvim: Beautiful in-buffer rendering        │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "quarto" },
    opts = {
      heading = {
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
      },
      code = {
        style = "full",
        border = "thin",
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰄵 " },
      },
      callout = {}, -- uses defaults (NOTE, TIP, WARNING, etc.)
      link = {
        hyperlink = "󰌹 ",
      },
      anti_conceal = { enabled = true }, -- show raw on cursor line
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ glow.nvim: Terminal-based markdown preview (works over SSH) │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    opts = {
      border = "rounded",
      width_ratio = 0.8,
      height_ratio = 0.8,
    },
    keys = {
      { "<leader>mp", "<cmd>Glow<cr>", desc = "Markdown Preview (Glow)" },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ markdown.nvim: Editing enhancements                         │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "tadmccorkle/markdown.nvim",
    ft = { "markdown" },
    opts = {
      mappings = {
        inline_surround_toggle = "gs", -- gs + motion (e.g., gsiw for bold)
        inline_surround_toggle_line = "gss",
        inline_surround_delete = "ds",
        inline_surround_change = "cs",
        link_add = "gl", -- add link (visual or motion)
        link_follow = "gx", -- follow link under cursor
        go_curr_heading = "]c",
        go_parent_heading = "]p",
        go_next_heading = "]]",
        go_prev_heading = "[[",
      },
      toc = {
        omit_heading = "toc omit heading",
        omit_section = "toc omit section",
      },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Markdown-specific settings                                  │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        markdown_settings = {
          {
            event = "FileType",
            pattern = { "markdown", "quarto" },
            callback = function()
              vim.opt_local.wrap = true
              vim.opt_local.linebreak = true
              vim.opt_local.spell = false -- toggle with <leader>us
              vim.opt_local.conceallevel = 2
            end,
          },
        },
      },
      mappings = {
        n = {
          ["<leader>m"] = { desc = "󰍔 Markdown" },
        },
      },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Mason: Install markdown LSP (marksman)                      │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "marksman" })
    end,
  },
}
