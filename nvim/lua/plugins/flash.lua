-- Flash.nvim: Navigate your code with search labels
-- by folke - https://github.com/folke/flash.nvim
--
-- ============================================================================
-- WHAT IS FLASH?
-- ============================================================================
--
-- Flash lets you jump anywhere on screen in 2-3 keystrokes.
-- Instead of `w w w w w` or `12j`, just:
--   1. Press `s`
--   2. Type what you see (e.g., "def")
--   3. Press the label to jump
--
-- It also enhances f/F/t/T motions and integrates with Treesitter.
--
-- ============================================================================
-- KEYMAPS
-- ============================================================================
--
-- JUMP MODE (main feature):
--   s             Flash jump - type pattern, press label to jump
--   S             Flash Treesitter - select AST nodes (functions, classes)
--
-- ENHANCED CHARACTER MOTIONS (automatic, just use them):
--   f{char}       Jump forward to {char}, labels shown if multiple
--   F{char}       Jump backward to {char}
--   t{char}       Jump forward to before {char}
--   T{char}       Jump backward to after {char}
--   ;             Repeat last f/F/t/T
--   ,             Repeat last f/F/t/T (reverse)
--
-- OPERATOR-PENDING (use with d, y, c, etc.):
--   r             Remote flash - operate on distant text
--   R             Treesitter search with operator
--
-- DURING SEARCH:
--   <C-s>         Toggle flash labels during / or ? search
--
-- ============================================================================
-- USAGE EXAMPLES
-- ============================================================================
--
-- EXAMPLE 1: Jump to a word
--   Position: start of file
--   Goal: jump to "config" on line 50
--
--   s  →  conf  →  [a]  →  jumped!
--
--   (Type 's', then 'conf', labels appear, press 'a' to jump)
--
-- ----------------------------------------------------------------------------
-- EXAMPLE 2: Jump to function definition
--   Position: anywhere
--   Goal: jump to "def train_model"
--
--   s  →  def t  →  [b]  →  jumped to second match labeled 'b'
--
-- ----------------------------------------------------------------------------
-- EXAMPLE 3: Select entire function with Treesitter
--   Position: inside a Python function
--   Goal: select the whole function
--
--   S  →  labels appear on AST nodes  →  press label  →  function selected!
--
--   Now you can: y (yank), d (delete), or just see it highlighted
--
-- ----------------------------------------------------------------------------
-- EXAMPLE 4: Delete to a distant word
--   Position: cursor at "The "
--   Line: "The quick brown fox jumps"
--   Goal: delete from cursor to "fox"
--
--   d  →  s  →  fox  →  [a]  →  "The quick brown " deleted
--
-- ----------------------------------------------------------------------------
-- EXAMPLE 5: Yank remote text without moving cursor
--   Goal: yank a word from another part of the file
--
--   yr  →  jump to word  →  select  →  yanked! (cursor stays put)
--
-- ----------------------------------------------------------------------------
-- EXAMPLE 6: Enhanced f motion
--   Line has multiple 'e' characters
--
--   fe  →  labels [a] [b] [c] appear on each 'e'  →  press label to jump
--
--   If only one match, jumps automatically (no label needed)
--
-- ============================================================================
-- TREESITTER MODE (S) - POWERFUL FOR PYTHON
-- ============================================================================
--
-- Press `S` to see labels on all AST nodes:
--   - Function definitions
--   - Class definitions
--   - If/else blocks
--   - For/while loops
--   - Parameters, arguments
--   - And more...
--
-- Combine with operators:
--   S + label             Jump to and select the node
--   dS + label            Delete entire node (function, class, block)
--   yS + label            Yank entire node
--   cS + label            Change entire node
--
-- ============================================================================
-- WHAT YOU LOSE (AND REPLACEMENTS)
-- ============================================================================
--
-- `s` was:    Substitute (delete char, enter insert mode)
-- Instead:    Use `cl` (change letter) - same result
--
-- `S` was:    Substitute line (delete line, enter insert mode)
-- Instead:    Use `cc` (change line) - same result
--
-- Worth it? Yes - you'll use flash hundreds of times daily.
--
-- ============================================================================
-- TIPS
-- ============================================================================
--
-- - Labels use home row first (a, s, d, f...) for speed
-- - Uppercase labels = farther matches
-- - Rainbow colors indicate distance (warm = close)
-- - Works across all visible splits/windows
-- - Auto-jumps if only one match
-- - <C-o> to jump back (jumplist)
--
-- ============================================================================

---@type LazySpec
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    -- Labels: home row first for speed
    labels = "asdfghjklqwertyuiopzxcvbnm",
    search = {
      multi_window = true, -- Search all visible windows
      forward = true,
      wrap = true,
      mode = "exact", -- "exact", "search" (regex), "fuzzy"
      incremental = false,
    },
    jump = {
      jumplist = true, -- Add to jumplist (<C-o> to go back)
      pos = "start", -- Jump to start of match
      autojump = true, -- Auto-jump if only one match
      nohlsearch = true, -- Clear highlight after jump
    },
    label = {
      uppercase = true, -- Uppercase for distant labels
      current = true, -- Show label on current match
      after = true,
      before = false,
      style = "overlay", -- "overlay", "eol", "right_align", "inline"
      reuse = "lowercase", -- Reuse labels (lowercase first)
      distance = true, -- Sort by distance
      rainbow = {
        enabled = true, -- Color by distance
        shade = 5,
      },
    },
    highlight = {
      backdrop = true, -- Dim non-matching text
      matches = true,
      priority = 5000,
    },
    modes = {
      -- Regular search (/ and ?)
      search = {
        enabled = true,
        highlight = { backdrop = false },
        jump = { history = true, register = true, nohlsearch = true },
      },
      -- Enhanced f, F, t, T
      char = {
        enabled = true,
        autohide = false,
        jump_labels = true, -- Show labels on char motions
        multi_line = true,
        keys = { "f", "F", "t", "T", ";", "," },
        highlight = { backdrop = true },
      },
      -- Treesitter node selection
      treesitter = {
        labels = "asdfghjklqwertyuiopzxcvbnm",
        jump = { pos = "range", autojump = true },
        label = { before = true, after = true, style = "inline" },
      },
    },
  },
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
      desc = "Flash: Jump",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function() require("flash").treesitter() end,
      desc = "Flash: Treesitter select",
    },
    {
      "r",
      mode = "o",
      function() require("flash").remote() end,
      desc = "Flash: Remote",
    },
    {
      "R",
      mode = { "o", "x" },
      function() require("flash").treesitter_search() end,
      desc = "Flash: Treesitter search",
    },
    {
      "<C-s>",
      mode = { "c" },
      function() require("flash").toggle() end,
      desc = "Flash: Toggle in search",
    },
  },
}
