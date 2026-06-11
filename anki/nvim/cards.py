"""Neovim keybinding flashcards.

Each card is (category, action, key, mode, notes). The pusher (push.py) turns
these into richly-styled Anki notes under the "nvim" deck, one subdeck per
category. The `action` is the prompt (front); the `key` is the answer (back),
so you train productive recall: "I want to do X — which keys?".

Sources:
- Cards tagged source "config" come from this repo's nvim/ Lua config.
- Cards tagged source "lazyvim" are LazyVim defaults you rely on but that are
  not written in your config files (kept here so the deck is complete).
"""

# fmt: off
CARDS = [
    # ---- LSP / Code (nvim/lua/plugins/lspsaga.lua) ----
    ("LSP / Code", "Show hover documentation for symbol under cursor", "K", "Normal/Visual", "Lspsaga hover_doc", "config"),
    ("LSP / Code", "Go to definition", "gd", "Normal", "Lspsaga goto_definition", "config"),
    ("LSP / Code", "Peek definition (inline window)", "gp", "Normal", "Lspsaga peek_definition", "config"),
    ("LSP / Code", "Go to type definition", "gy", "Normal", "Lspsaga goto_type_definition", "config"),
    ("LSP / Code", "Peek type definition", "gP", "Normal", "Lspsaga peek_type_definition", "config"),
    ("LSP / Code", "Find references & implementations", "gr", "Normal", "Lspsaga finder", "config"),
    ("LSP / Code", "Code action", "<leader>ca", "Normal/Visual", "Lspsaga code_action", "config"),
    ("LSP / Code", "Rename symbol", "<leader>cr", "Normal", "Lspsaga rename", "config"),
    ("LSP / Code", "Rename symbol project-wide", "<leader>cR", "Normal", "Lspsaga rename ++project", "config"),
    ("LSP / Code", "Symbols outline (sidebar)", "<leader>cs", "Normal", "Lspsaga outline", "config"),
    ("LSP / Code", "Incoming calls (call hierarchy)", "<leader>ci", "Normal", "Lspsaga incoming_calls", "config"),
    ("LSP / Code", "Outgoing calls (call hierarchy)", "<leader>co", "Normal", "Lspsaga outgoing_calls", "config"),
    ("LSP / Code", "Organize imports", "<leader>cO", "Normal", "Custom: source.organizeImports code action", "config"),

    # ---- Diagnostics (lspsaga.lua + keymaps.lua) ----
    ("Diagnostics", "Jump to previous diagnostic", "[d", "Normal", "Lspsaga diagnostic_jump_prev", "config"),
    ("Diagnostics", "Jump to next diagnostic", "]d", "Normal", "Lspsaga diagnostic_jump_next", "config"),
    ("Diagnostics", "Show diagnostics under cursor", "<leader>cd", "Normal", "Lspsaga show_cursor_diagnostics", "config"),
    ("Diagnostics", "Show all buffer diagnostics", "<leader>cD", "Normal", "Lspsaga show_buf_diagnostics", "config"),
    ("Diagnostics", "Yank diagnostics on current line", "<leader>xy", "Normal", "Copies to system clipboard", "config"),
    ("Diagnostics", "Yank all diagnostics in file", "<leader>xY", "Normal", "Copies to system clipboard", "config"),
    ("Diagnostics", "Yank diagnostics in visual selection", "<leader>xy", "Visual", "Copies to system clipboard", "config"),

    # ---- Search / Find (LazyVim defaults) ----
    ("Search / Find", "Grep (live search) across the project root", "<leader>/", "Normal", "Main project-wide search", "lazyvim"),
    ("Search / Find", "Grep across the project root", "<leader>sg", "Normal", "Same as <leader>/", "lazyvim"),
    ("Search / Find", "Grep in the current working dir", "<leader>sG", "Normal", "cwd instead of git root", "lazyvim"),
    ("Search / Find", "Grep word/selection under cursor", "<leader>sw", "Normal/Visual", "Searches the word or visual selection", "lazyvim"),
    ("Search / Find", "Fuzzy-find lines in current buffer", "<leader>sb", "Normal", "Search within the open file", "lazyvim"),
    ("Search / Find", "Find files in project root", "<leader>ff", "Normal", "Honors .gitignore", "lazyvim"),
    ("Search / Find", "Find files in current working dir", "<leader>fF", "Normal", "", "lazyvim"),
    ("Search / Find", "Open buffers picker", "<leader>fb", "Normal", "", "lazyvim"),
    ("Search / Find", "Recent files", "<leader>fr", "Normal", "", "lazyvim"),
    ("Search / Find", "Switch buffer (quick)", "<leader>,", "Normal", "", "lazyvim"),
    ("Search / Find", "Go to document symbol", "<leader>ss", "Normal", "", "lazyvim"),
    ("Search / Find", "Go to workspace symbol", "<leader>sS", "Normal", "", "lazyvim"),
    ("Search / Find", "Send picker results to quickfix list", "<C-q>", "Normal", "Inside a Telescope/Snacks picker", "lazyvim"),

    # ---- Splits / Windows (nvim/lua/plugins/smart-splits.lua) ----
    ("Splits / Windows", "Move to split on the left", "<C-h>", "Normal", "smart-splits, integrates with tmux/kitty", "config"),
    ("Splits / Windows", "Move to split below", "<C-j>", "Normal", "smart-splits", "config"),
    ("Splits / Windows", "Move to split above", "<C-k>", "Normal", "smart-splits", "config"),
    ("Splits / Windows", "Move to split on the right", "<C-l>", "Normal", "smart-splits", "config"),
    ("Splits / Windows", "Resize split leftward", "<C-A-h>", "Normal", "smart-splits", "config"),
    ("Splits / Windows", "Resize split downward", "<C-A-j>", "Normal", "smart-splits", "config"),
    ("Splits / Windows", "Resize split upward", "<C-A-k>", "Normal", "smart-splits", "config"),
    ("Splits / Windows", "Resize split rightward", "<C-A-l>", "Normal", "smart-splits", "config"),
    ("Splits / Windows", "Swap buffer with split on the left", "<leader><leader>h", "Normal", "smart-splits swap_buf", "config"),
    ("Splits / Windows", "Swap buffer with split below", "<leader><leader>j", "Normal", "smart-splits swap_buf", "config"),
    ("Splits / Windows", "Swap buffer with split above", "<leader><leader>k", "Normal", "smart-splits swap_buf", "config"),
    ("Splits / Windows", "Swap buffer with split on the right", "<leader><leader>l", "Normal", "smart-splits swap_buf", "config"),

    # ---- Files / Explorer (yazi.lua + keymaps.lua) ----
    ("Files / Explorer", "Toggle file explorer & reveal current file", "<leader>e", "Normal", "Snacks explorer, PyCharm-style reveal, shows dotfiles", "config"),
    ("Files / Explorer", "Open Yazi at current file", "<leader>.", "Normal", "", "config"),
    ("Files / Explorer", "Open Yazi at current working dir", "<leader>cw", "Normal", "", "config"),
    ("Files / Explorer", "Resume last Yazi session", "<C-Up>", "Normal", "Yazi toggle", "config"),
    ("Files / Explorer", "Copy current file's RELATIVE path to clipboard", "<leader>cp", "Normal", "expand('%:.') into the + register", "config"),
    ("Files / Explorer", "Copy current file's ABSOLUTE path to clipboard", "<leader>cP", "Normal", "expand('%:p') into the + register", "config"),
    ("Files / Explorer", "Copy current file's NAME (no dir) to clipboard", "<leader>cn", "Normal", "expand('%:t') into the + register", "config"),

    # ---- Git (nvim/lua/plugins/git.lua) ----
    ("Git", "Open Diffview (all changes)", "<leader>gv", "Normal", "DiffviewOpen", "config"),
    ("Git", "Close Diffview", "<leader>gV", "Normal", "DiffviewClose", "config"),
    ("Git", "File history of current file", "<leader>gF", "Normal", "DiffviewFileHistory %", "config"),
    ("Git", "Repository history", "<leader>gR", "Normal", "DiffviewFileHistory", "config"),
    ("Git", "Diff staged/cached changes", "<leader>gc", "Normal", "DiffviewOpen --staged", "config"),
    ("Git", "Diff vs main branch", "<leader>gm", "Normal", "DiffviewOpen origin/main...HEAD", "config"),
    ("Git", "Diff last commit (HEAD~1)", "<leader>gh", "Normal", "DiffviewOpen HEAD~1", "config"),
    ("Git", "Open Octo (GitHub)", "<leader>go", "Normal", "", "config"),
    ("Git", "List pull requests", "<leader>gpl", "Normal", "Octo pr list", "config"),
    ("Git", "Search pull requests", "<leader>gps", "Normal", "Octo pr search", "config"),
    ("Git", "List issues", "<leader>gil", "Normal", "Octo issue list", "config"),
    ("Git", "Search issues", "<leader>gis", "Normal", "Octo issue search", "config"),

    # ---- Editing / Misc (keymaps.lua) ----
    ("Editing / Misc", "Record a macro (q is remapped to Q)", "Q", "Normal", "q is disabled to avoid accidental macro recording", "config"),
    ("Editing / Misc", "Trim trailing whitespace in selection", "<leader>tw", "Visual", "", "config"),
    ("Editing / Misc", "Toggle Markdown preview", "<leader>mp", "Normal", "MarkdownPreviewToggle, markdown files", "config"),

    # ---- Motions / Textobjects (nvim/lua/plugins/treesitter.lua) ----
    ("Motions / Textobjects", "Jump to next assignment", "]=", "Normal", "treesitter-textobjects @assignment.outer", "config"),
    ("Motions / Textobjects", "Jump to previous assignment", "[=", "Normal", "treesitter-textobjects @assignment.outer", "config"),
    ("Motions / Textobjects", "Jump to next statement", "]s", "Normal", "treesitter-textobjects @statement.outer (overrides vim spell motion)", "config"),
    ("Motions / Textobjects", "Jump to previous statement", "[s", "Normal", "treesitter-textobjects @statement.outer (overrides vim spell motion)", "config"),
    ("Motions / Textobjects", "Operate on/select around an assignment", "a=", "Operator/Visual", "mini.ai textobject, e.g. da= / va= / ca=", "config"),
    ("Motions / Textobjects", "Operate on/select inside an assignment", "i=", "Operator/Visual", "mini.ai textobject, e.g. di= / vi= / ci=", "config"),
]
# fmt: on
