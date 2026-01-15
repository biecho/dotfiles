-- Full lspsaga setup - replaces several LazyVim defaults
-- This provides: hover, definition peek, code actions, rename, diagnostics,
-- call hierarchy, outline, breadcrumbs, finder
return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- Breadcrumbs in winbar (shows: class > method > block)
    symbol_in_winbar = {
      enable = true,
      separator = " › ",
      show_file = true,
      folder_level = 1,
    },

    -- Lightbulb indicator for code actions
    lightbulb = {
      enable = true,
      sign = true,
      virtual_text = false,
    },

    -- Prettier hover with treesitter markdown
    hover = {
      open_link = "gx",
    },

    -- Peek definition shows file path in header
    definition = {
      width = 0.6,
      height = 0.5,
    },

    -- Code action with live preview
    code_action = {
      num_shortcut = true,
      show_server_name = true,
      extend_gitsigns = true,
    },

    -- Rename with visual feedback
    rename = {
      in_select = true,
      auto_save = false,
    },

    -- Diagnostic jump and display
    diagnostic = {
      show_code_action = true,
      jump_num_shortcut = true,
      show_layout = "float",
    },

    -- Outline sidebar
    outline = {
      win_position = "right",
      win_width = 30,
      auto_preview = true,
      detail = true,
    },

    -- Call hierarchy UI
    callhierarchy = {
      layout = "float",
    },

    -- Finder for references/definitions/implementations
    finder = {
      max_height = 0.5,
      left_width = 0.3,
      default = "ref+imp",
      layout = "float",
    },

    -- UI settings
    ui = {
      border = "rounded",
      title = true,
    },
  },
  keys = {
    -- Hover (replaces default K)
    { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc" },
    { "K", "<cmd>Lspsaga hover_doc<CR>", mode = "v", desc = "Hover Doc" },

    -- Definition/Type Definition with peek (shows file path!)
    { "gp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition" },
    { "gd", "<cmd>Lspsaga goto_definition<CR>", desc = "Goto Definition" },
    { "gP", "<cmd>Lspsaga peek_type_definition<CR>", desc = "Peek Type Definition" },
    { "gy", "<cmd>Lspsaga goto_type_definition<CR>", desc = "Goto Type Definition" },

    -- Finder (references + implementations in one UI)
    { "gr", "<cmd>Lspsaga finder<CR>", desc = "Find References/Implementations" },

    -- Code actions with preview
    { "<leader>ca", "<cmd>Lspsaga code_action<CR>", desc = "Code Action" },
    { "<leader>ca", "<cmd>Lspsaga code_action<CR>", mode = "v", desc = "Code Action" },

    -- Rename with visual feedback
    { "<leader>cr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
    { "<leader>cR", "<cmd>Lspsaga rename ++project<CR>", desc = "Rename (Project-wide)" },

    -- Diagnostics
    { "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Prev Diagnostic" },
    { "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next Diagnostic" },
    { "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", desc = "Cursor Diagnostics" },
    { "<leader>cD", "<cmd>Lspsaga show_buf_diagnostics<CR>", desc = "Buffer Diagnostics" },

    -- Call hierarchy
    { "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", desc = "Incoming Calls" },
    { "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>", desc = "Outgoing Calls" },

    -- Outline sidebar
    { "<leader>cs", "<cmd>Lspsaga outline<CR>", desc = "Symbols Outline" },
  },
}
