-- Professional Python Development Configuration
-- Handles both ML/Data Science AND Software Engineering workflows

-- ╭─────────────────────────────────────────────────────────────╮
-- │ Helper Functions                                            │
-- ╰─────────────────────────────────────────────────────────────╯

--- Get the name of the active virtual environment
---@return string|nil venv_name The name of the active venv, or nil if none
local function get_venv_name()
  local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
  if venv then
    return vim.fn.fnamemodify(venv, ":t")
  end
  return nil
end

--- Check if a jupyter kernel exists by name
---@param kernel_name string The kernel name to check
---@return boolean exists Whether the kernel exists
local function kernel_exists(kernel_name)
  local result = vim.fn.system("jupyter kernelspec list --json 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return false
  end
  local ok, specs = pcall(vim.json.decode, result)
  if ok and specs and specs.kernelspecs then
    return specs.kernelspecs[kernel_name] ~= nil
  end
  return false
end

--- Initialize Molten with the appropriate kernel
--- Tries: 1) venv-matched kernel, 2) python3 fallback
local function molten_init_venv()
  local venv_name = get_venv_name()
  if venv_name and kernel_exists(venv_name) then
    vim.cmd("MoltenInit " .. venv_name)
    vim.notify("Molten: initialized with kernel '" .. venv_name .. "'", vim.log.levels.INFO)
  elseif kernel_exists("python3") then
    vim.cmd("MoltenInit python3")
    vim.notify("Molten: initialized with kernel 'python3'", vim.log.levels.INFO)
  else
    -- Fallback to interactive selection
    vim.cmd("MoltenInit")
  end
end

--- Navigate to next cell marker (# %%)
local function goto_next_cell()
  local found = vim.fn.search("^# %%", "W")
  if found == 0 then
    vim.notify("No more cells below", vim.log.levels.INFO)
  end
end

--- Navigate to previous cell marker (# %%)
local function goto_prev_cell()
  local found = vim.fn.search("^# %%", "bW")
  if found == 0 then
    vim.notify("No more cells above", vim.log.levels.INFO)
  end
end

--- Select current cell (visual mode)
local function select_cell()
  -- Go to start of current cell
  local start_line = vim.fn.search("^# %%", "bcnW")
  if start_line == 0 then
    start_line = 1
  end
  -- Find end of cell (next marker or EOF)
  local end_line = vim.fn.search("^# %%", "nW")
  if end_line == 0 then
    end_line = vim.fn.line("$")
  else
    end_line = end_line - 1
  end
  -- Select the range
  vim.cmd(string.format("normal! %dGV%dG", start_line, end_line))
end

--- Run current cell with Molten
local function run_cell()
  -- Save cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  -- Select cell and evaluate
  select_cell()
  vim.cmd("MoltenEvaluateVisual")
  -- Restore cursor
  vim.api.nvim_win_set_cursor(0, cursor)
  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

---@type LazySpec
return {
  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ LSP: basedpyright (stricter pyright fork)                   │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      servers = { "basedpyright" }, -- auto-install via mason
      config = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly", -- workspace or openFilesOnly
                -- Suppress missing stubs warnings (common in ML projects)
                diagnosticSeverityOverrides = {
                  reportMissingTypeStubs = "none",
                },
                -- Inlay hints (toggle with <leader>uH)
                inlayHints = {
                  callArgumentNames = "all",
                  functionReturnTypes = true,
                  variableTypes = true,
                  genericTypes = true,
                },
              },
            },
          },
        },
      },
      -- Disable pyright if basedpyright is active (avoid conflicts)
      handlers = {
        pyright = false,
      },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Formatting: ruff (format-on-save enabled)                   │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      formatting = {
        format_on_save = {
          enabled = true,
          allow_filetypes = {
            "python",
          },
        },
        -- Let ruff handle formatting, not basedpyright
        disabled = {
          "basedpyright",
          "pyright",
        },
      },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Testing: neotest-python with pytest                         │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "nvim-neotest/neotest-python" },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(
        opts.adapters,
        require("neotest-python")({
          dap = { justMyCode = false }, -- debug into library code
          runner = "pytest",
          args = { "-vv", "--tb=short" },
          pytest_discover_instances = true, -- experimental: parametrized tests
        })
      )
    end,
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Virtual Environment: venv-selector.nvim                     │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    cmd = { "VenvSelect", "VenvSelectCached" },
    opts = {
      settings = {
        search = {
          -- Search in common locations
          my_venvs = {
            command = "fd -H -I -a -t d '(venv|.venv|env|.env)$' . --max-depth 4",
          },
          -- Conda environments
          conda = {
            command = "fd -H -I -a -t d 'envs' ~/miniconda3 ~/anaconda3 --max-depth 1",
          },
        },
      },
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
      { "<leader>cV", "<cmd>VenvSelectCached<cr>", desc = "Select cached venv" },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ REPL: iron.nvim for interactive Python                      │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "Vigemus/iron.nvim",
    cmd = { "IronRepl", "IronSend", "IronReplHere" },
    keys = {
      { "<leader>rs", "<cmd>IronRepl<cr>", desc = "Start REPL" },
      { "<leader>rr", "<cmd>IronRestart<cr>", desc = "Restart REPL" },
      { "<leader>rf", "<cmd>IronFocus<cr>", desc = "Focus REPL" },
      { "<leader>rh", "<cmd>IronHide<cr>", desc = "Hide REPL" },
    },
    config = function()
      require("iron.core").setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = { "ipython", "--no-autoindent" },
              format = require("iron.fts.common").bracketed_paste_python,
            },
          },
          repl_open_cmd = require("iron.view").split.vertical.botright(0.4),
        },
        keymaps = {
          send_motion = "<leader>rc",
          visual_send = "<leader>rc",
          send_file = "<leader>rF",
          send_line = "<leader>rl",
          send_paragraph = "<leader>rp",
          send_until_cursor = "<leader>ru",
          cr = "<leader>r<cr>",
          interrupt = "<leader>ri",
          exit = "<leader>rq",
          clear = "<leader>rx",
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Jupyter Notebooks: molten.nvim                              │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    lazy = false, -- Remote plugins need to load early for commands to register
    init = function()
      -- Output window settings
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_output_show_more = true
      -- Virtual text for small outputs
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      -- Image rendering (disabled until ImageMagick is installed)
      vim.g.molten_image_provider = ""
      -- Wrap output
      vim.g.molten_wrap_output = true
      -- Cell marker
      vim.g.molten_cell_comment = "# %%"
      -- Save/restore cell outputs
      vim.g.molten_save_path = vim.fn.stdpath("data") .. "/molten"
    end,
    keys = {
      -- Initialization
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Initialize (select kernel)" },
      { "<leader>jI", molten_init_venv, desc = "Initialize (auto venv)" },
      -- Execution
      { "<leader>je", "<cmd>MoltenEvaluateOperator<cr>", desc = "Evaluate operator" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Evaluate line" },
      { "<leader>jc", run_cell, desc = "Run current cell" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Re-evaluate cell" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Evaluate visual" },
      -- Output management
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
      { "<leader>jO", ":noautocmd MoltenEnterOutput<cr>", desc = "Enter output window" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
      -- Cell management
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete cell output" },
      { "<leader>jD", "<cmd>MoltenDelete!<cr>", desc = "Delete all outputs" },
      { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Interrupt kernel" },
      -- Save/Load/Export
      { "<leader>js", "<cmd>MoltenSave<cr>", desc = "Save outputs" },
      { "<leader>jL", "<cmd>MoltenLoad<cr>", desc = "Load outputs" },
      { "<leader>jE", "<cmd>MoltenExportOutput!<cr>", desc = "Export to notebook" },
      { "<leader>jM", "<cmd>MoltenImportOutput<cr>", desc = "Import from notebook" },
      -- Cell navigation (]x/[x for "execute" - avoids conflict with ]c "current heading" in markdown)
      { "]x", goto_next_cell, ft = { "python", "markdown", "quarto" }, desc = "Next cell" },
      { "[x", goto_prev_cell, ft = { "python", "markdown", "quarto" }, desc = "Previous cell" },
      { "<leader>j]", goto_next_cell, desc = "Next cell" },
      { "<leader>j[", goto_prev_cell, desc = "Previous cell" },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Jupytext: Edit .ipynb as .py                                │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      style = "markdown", -- or "percent" for # %% style
      output_extension = "md", -- or "py"
      force_ft = "markdown", -- or "python"
    },
    -- Requires: pip install jupytext
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Quarto: Literate programming (.qmd files)                   │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim", -- LSP for embedded code
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    opts = {
      lspFeatures = {
        enabled = true,
        languages = { "python", "r", "julia", "bash" },
        chunks = "all",
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = { enabled = true },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten", -- or "iron" or "slime"
      },
    },
    keys = {
      -- Preview
      { "<leader>qp", "<cmd>QuartoPreview<cr>", desc = "Quarto preview" },
      { "<leader>qc", "<cmd>QuartoClosePreview<cr>", desc = "Close preview" },
      { "<leader>qa", "<cmd>QuartoActivate<cr>", desc = "Activate Quarto" },
      -- Code runner
      {
        "<leader>qr",
        function() require("quarto.runner").run_cell() end,
        ft = { "quarto", "markdown" },
        desc = "Run cell",
      },
      {
        "<leader>qR",
        function() require("quarto.runner").run_all() end,
        ft = { "quarto", "markdown" },
        desc = "Run all cells",
      },
      {
        "<leader>ql",
        function() require("quarto.runner").run_line() end,
        ft = { "quarto", "markdown" },
        desc = "Run line",
      },
      {
        "<leader>qA",
        function() require("quarto.runner").run_above() end,
        ft = { "quarto", "markdown" },
        desc = "Run all above",
      },
      {
        "<leader>qb",
        function() require("quarto.runner").run_below() end,
        ft = { "quarto", "markdown" },
        desc = "Run all below",
      },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Otter: LSP for code embedded in markdown/quarto             │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "jmbuhr/otter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Cell Text Objects: ih (inner cell) and ah (around cell)     │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "GCBallesteros/vim-textobj-hydrogen",
    dependencies = { "kana/vim-textobj-user" },
    ft = { "python", "markdown", "quarto" },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Mason: Ensure Python tools are installed                    │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- LSP
        "basedpyright",
        -- Linter/Formatter
        "ruff",
        -- Debugger
        "debugpy",
      },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Treesitter: Python parsers                                  │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
        "requirements", -- requirements.txt
        "toml", -- pyproject.toml
        "rst", -- docstrings
        "markdown", -- quarto/jupyter
        "markdown_inline",
      },
    },
  },

  -- ╭─────────────────────────────────────────────────────────────╮
  -- │ Which-key: Python-specific menu                             │
  -- ╰─────────────────────────────────────────────────────────────╯
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          -- Group labels (note: <leader>m is used by markdown.lua for Markdown group)
          ["<leader>j"] = { desc = " Jupyter/Molten" },
          ["<leader>r"] = { desc = " REPL" },
          ["<leader>q"] = { desc = " Quarto" },
          -- Quick pytest
          ["<leader>tp"] = { function() require("neotest").run.run() end, desc = "Run nearest test" },
          ["<leader>tP"] = { function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
          ["<leader>td"] = { function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
        },
      },
    },
  },
}
