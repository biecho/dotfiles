-- ============================================================================
-- LSPSAGA CONFIGURATION
-- ============================================================================
-- Repository: https://github.com/nvimdev/lspsaga.nvim
-- Docs: https://nvimdev.github.io/lspsaga/
--
-- Lspsaga provides a modern, polished UI for Neovim's built-in LSP features.
-- This config replaces several LazyVim defaults with lspsaga equivalents.
--
-- DISABLED PLUGINS (see plugins/disabled.lua):
--   - trouble.nvim (replaced by lspsaga diagnostics)
--   - inc-rename.nvim (replaced by lspsaga rename)
--
-- ============================================================================
-- KEYBINDINGS QUICK REFERENCE
-- ============================================================================
--
-- HOVER & DOCUMENTATION
--   K           Hover documentation (prettier than default, treesitter markdown)
--               Press K twice to focus the hover window, then q to close
--               Press gx inside hover to open links in browser
--
-- NAVIGATION - DEFINITIONS
--   gd          Goto definition (jump to where symbol is defined)
--   gp          Peek definition in floating window (SHOWS FILE PATH in header!)
--               You can edit directly in the peek window
--               Press q to close, or use splits: <C-c>s (vsplit), <C-c>i (split)
--   gy          Goto type definition (jump to the type's definition)
--   gP          Peek type definition in floating window
--
-- NAVIGATION - REFERENCES & IMPLEMENTATIONS
--   gr          Open finder (shows BOTH references AND implementations)
--               Two-pane UI: left=results, right=preview (editable)
--               Press o to open, s for vsplit, i for split, t for tab
--               Press q or <Esc> to close
--
-- CODE ACTIONS
--   <leader>ca  Show code actions with LIVE PREVIEW
--               Move cursor to see what each action will change before applying
--               Press number (1-9) for quick selection, or <CR> to apply
--               Shows which LSP server provides each action
--               Includes gitsigns actions (stage hunk, reset, etc.)
--
-- RENAME
--   <leader>cr  Rename symbol (highlights all references as you type)
--               Press <CR> to apply, <Esc> to cancel
--   <leader>cR  Project-wide rename (uses ripgrep to find all occurrences)
--
-- DIAGNOSTICS
--   [d          Jump to previous diagnostic
--   ]d          Jump to next diagnostic
--   <leader>cd  Show diagnostics at cursor position (floating window)
--   <leader>cD  Show all diagnostics in buffer (filterable list)
--               Press o to jump, q to close
--
-- CALL HIERARCHY
--   <leader>ci  Show incoming calls (who calls this function?)
--   <leader>co  Show outgoing calls (what does this function call?)
--               Two-pane UI similar to finder
--               Press o to expand/jump, q to close
--
-- OUTLINE
--   <leader>cs  Toggle symbols outline sidebar
--               Shows file structure: classes, functions, variables
--               Navigation: j/k to move, o to toggle/jump, e to jump, q to close
--               Auto-preview enabled: cursor movement shows code preview
--
-- BREADCRUMBS (automatic, no keybinding)
--   Shows current code context in winbar: file › class › method › block
--   Updates automatically as you navigate
--
-- LIGHTBULB (automatic, no keybinding)
--   Shows 💡 in sign column when code actions are available
--
-- ============================================================================
-- WITHIN LSPSAGA WINDOWS
-- ============================================================================
--
-- Common keys in lspsaga floating windows:
--   q / <Esc>   Close window
--   o           Open/jump to location (or toggle expand in outline)
--   e           Jump even on expand nodes
--   s           Open in vertical split
--   i           Open in horizontal split
--   t           Open in new tab
--   <C-c>s      (in peek) Open vsplit
--   <C-c>i      (in peek) Open split
--   K           (in finder) Toggle preview
--   [w / ]w     (in call hierarchy) Switch between left/right panes
--
-- ============================================================================

return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- Better syntax highlighting in previews
    "nvim-tree/nvim-web-devicons", -- Icons in UI
  },
  opts = {
    -- -------------------------------------------------------------------------
    -- BREADCRUMBS: Shows current code location in winbar
    -- Example: "config.lua › return › opts › symbol_in_winbar"
    -- -------------------------------------------------------------------------
    symbol_in_winbar = {
      enable = true,
      separator = " › ",
      show_file = true, -- Show filename before symbols
      folder_level = 1, -- Show 1 parent folder
    },

    -- -------------------------------------------------------------------------
    -- LIGHTBULB: Shows 💡 when code actions available
    -- -------------------------------------------------------------------------
    lightbulb = {
      enable = true,
      sign = true, -- Show in sign column
      virtual_text = false, -- Don't show as virtual text (less noisy)
    },

    -- -------------------------------------------------------------------------
    -- HOVER: Enhanced documentation popup (K)
    -- -------------------------------------------------------------------------
    hover = {
      open_link = "gx", -- Key to open URLs in hover docs
    },

    -- -------------------------------------------------------------------------
    -- PEEK DEFINITION: Floating window preview (gp, gP)
    -- Shows file path in header - the original feature request!
    -- -------------------------------------------------------------------------
    definition = {
      width = 0.6, -- 60% of screen width
      height = 0.5, -- 50% of screen height
    },

    -- -------------------------------------------------------------------------
    -- CODE ACTIONS: Shows available fixes/refactors (<leader>ca)
    -- -------------------------------------------------------------------------
    code_action = {
      num_shortcut = true, -- Press 1-9 to quick-select action
      show_server_name = true, -- Shows which LSP provides each action
      extend_gitsigns = true, -- Include gitsigns actions (stage, reset, etc.)
    },

    -- -------------------------------------------------------------------------
    -- RENAME: Symbol renaming with live preview (<leader>cr)
    -- -------------------------------------------------------------------------
    rename = {
      in_select = true, -- Start with name selected for easy replacement
      auto_save = false, -- Don't auto-save after rename
    },

    -- -------------------------------------------------------------------------
    -- DIAGNOSTICS: Error/warning display ([d, ]d, <leader>cd)
    -- -------------------------------------------------------------------------
    diagnostic = {
      show_code_action = true, -- Show available fixes in diagnostic float
      jump_num_shortcut = true, -- Press number to jump to specific diagnostic
      show_layout = "float", -- Use floating windows (not inline)
    },

    -- -------------------------------------------------------------------------
    -- OUTLINE: File structure sidebar (<leader>cs)
    -- -------------------------------------------------------------------------
    outline = {
      win_position = "right", -- Sidebar on right side
      win_width = 30, -- 30 columns wide
      auto_preview = true, -- Show code preview as you navigate
      detail = true, -- Show extra symbol details
    },

    -- -------------------------------------------------------------------------
    -- CALL HIERARCHY: Function call relationships (<leader>ci, <leader>co)
    -- -------------------------------------------------------------------------
    callhierarchy = {
      layout = "float", -- Floating window (vs normal split)
    },

    -- -------------------------------------------------------------------------
    -- FINDER: Unified search for refs/impl/def (gr)
    -- -------------------------------------------------------------------------
    finder = {
      max_height = 0.5, -- Max 50% screen height
      left_width = 0.3, -- Results pane 30% width
      default = "ref+imp", -- Show references AND implementations by default
      layout = "float", -- Floating window
    },

    -- -------------------------------------------------------------------------
    -- UI: General appearance settings
    -- -------------------------------------------------------------------------
    ui = {
      border = "rounded", -- Rounded window borders
      title = true, -- Show titles on windows
    },
  },

  -- ===========================================================================
  -- KEYBINDINGS
  -- ===========================================================================
  keys = {
    ---------------------------------------------------------------------------
    -- HOVER (replaces vim.lsp.buf.hover)
    ---------------------------------------------------------------------------
    { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc" },
    { "K", "<cmd>Lspsaga hover_doc<CR>", mode = "v", desc = "Hover Doc" },

    ---------------------------------------------------------------------------
    -- DEFINITIONS (peek shows file path in header!)
    ---------------------------------------------------------------------------
    { "gp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition" },
    { "gd", "<cmd>Lspsaga goto_definition<CR>", desc = "Goto Definition" },
    { "gP", "<cmd>Lspsaga peek_type_definition<CR>", desc = "Peek Type Definition" },
    { "gy", "<cmd>Lspsaga goto_type_definition<CR>", desc = "Goto Type Definition" },

    ---------------------------------------------------------------------------
    -- FINDER (references + implementations in unified UI)
    ---------------------------------------------------------------------------
    { "gr", "<cmd>Lspsaga finder<CR>", desc = "Find References/Implementations" },

    ---------------------------------------------------------------------------
    -- CODE ACTIONS (with live preview of changes)
    ---------------------------------------------------------------------------
    { "<leader>ca", "<cmd>Lspsaga code_action<CR>", desc = "Code Action" },
    { "<leader>ca", "<cmd>Lspsaga code_action<CR>", mode = "v", desc = "Code Action" },

    ---------------------------------------------------------------------------
    -- RENAME (highlights all references as you type)
    ---------------------------------------------------------------------------
    { "<leader>cr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
    { "<leader>cR", "<cmd>Lspsaga rename ++project<CR>", desc = "Rename (Project-wide)" },

    ---------------------------------------------------------------------------
    -- DIAGNOSTICS
    ---------------------------------------------------------------------------
    { "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Prev Diagnostic" },
    { "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next Diagnostic" },
    { "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", desc = "Cursor Diagnostics" },
    { "<leader>cD", "<cmd>Lspsaga show_buf_diagnostics<CR>", desc = "Buffer Diagnostics" },

    ---------------------------------------------------------------------------
    -- CALL HIERARCHY
    ---------------------------------------------------------------------------
    { "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", desc = "Incoming Calls" },
    { "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>", desc = "Outgoing Calls" },

    ---------------------------------------------------------------------------
    -- OUTLINE
    ---------------------------------------------------------------------------
    { "<leader>cs", "<cmd>Lspsaga outline<CR>", desc = "Symbols Outline" },
  },
}
