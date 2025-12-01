-- Professional Python Development Configuration
-- Handles both ML/Data Science AND Software Engineering workflows

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
    dependencies = { "3rd/image.nvim" }, -- you already have this!
    init = function()
      -- Output window settings
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_output_show_more = true
      -- Virtual text for small outputs
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      -- Image rendering
      vim.g.molten_image_provider = "image.nvim"
      -- Wrap output
      vim.g.molten_wrap_output = true
      -- Cell marker
      vim.g.molten_cell_comment = "# %%"
    end,
    cmd = {
      "MoltenInit",
      "MoltenEvaluateLine",
      "MoltenEvaluateVisual",
      "MoltenEvaluateOperator",
      "MoltenReevaluateCell",
      "MoltenDelete",
      "MoltenShowOutput",
      "MoltenHideOutput",
      "MoltenInterrupt",
    },
    keys = {
      { "<leader>mi", "<cmd>MoltenInit<cr>", desc = "Initialize Molten" },
      { "<leader>me", "<cmd>MoltenEvaluateOperator<cr>", desc = "Evaluate operator" },
      { "<leader>ml", "<cmd>MoltenEvaluateLine<cr>", desc = "Evaluate line" },
      { "<leader>mr", "<cmd>MoltenReevaluateCell<cr>", desc = "Re-evaluate cell" },
      { "<leader>mv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Evaluate visual" },
      { "<leader>mo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
      { "<leader>mh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
      { "<leader>md", "<cmd>MoltenDelete<cr>", desc = "Delete cell" },
      { "<leader>mx", "<cmd>MoltenInterrupt<cr>", desc = "Interrupt kernel" },
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
      { "<leader>qp", "<cmd>QuartoPreview<cr>", desc = "Quarto preview" },
      { "<leader>qc", "<cmd>QuartoClosePreview<cr>", desc = "Close preview" },
      { "<leader>qa", "<cmd>QuartoActivate<cr>", desc = "Activate Quarto" },
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
          -- Group labels
          ["<leader>m"] = { desc = " Molten/Jupyter" },
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
