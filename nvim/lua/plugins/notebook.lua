-- Jupyter notebook editing in Neovim
-- Opens .ipynb as markdown for nice editing, run in browser
--
-- PREREQUISITES:
--   1. Install jupytext CLI (for .ipynb <-> markdown conversion):
--        pip install jupytext
--
--   2. Install Jupyter Lab (for running notebooks in browser):
--        pip install jupyterlab
--
--   3. Register a kernel for your project environment:
--        conda activate your-env
--        pip install ipykernel
--        python -m ipykernel install --user --name=your-env
--
--   4. (Optional) Enable vim mode in Jupyter Lab:
--        pip install jupyterlab-vim
--      Or use built-in: Settings → Settings Editor → Editor Mode → "vim"
--
-- WORKFLOW:
--   1. Open .ipynb in nvim     -> auto-converts to markdown
--   2. Edit with full LSP      -> completion, diagnostics in code blocks
--   3. Navigate: ]j / [j       -> next/prev cell
--   4. Select: vij / vaj       -> inner/around cell
--   5. Save :w                 -> auto-converts back to .ipynb
--   6. <leader>jo              -> open in Jupyter Lab to run cells
--
-- KEYBINDINGS:
--   ]j / [j       Next/prev code cell
--   ij / aj       Select inner/around cell (with d, y, c, v, etc.)
--   <leader>jo    Open notebook in Jupyter Lab

return {
  -- Jupytext: converts .ipynb <-> markdown for editing
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },

  -- Otter: LSP features (completion, diagnostics) inside code blocks
  {
    "jmbuhr/otter.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      buffers = {
        set_filetype = true, -- use language filetype for embedded buffers
      },
    },
    config = function(_, opts)
      local otter = require("otter")
      otter.setup(opts)

      -- Auto-activate otter for markdown files with code blocks
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown" },
        callback = function()
          -- Activate otter with Python (and other languages if present)
          otter.activate({ "python", "r", "julia", "bash", "lua" })
        end,
      })
    end,
  },

  -- Keybinding to open notebook in Jupyter
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          "<leader>jo",
          function()
            -- Save first to ensure .ipynb is up to date
            vim.cmd("silent write")
            local file = vim.fn.expand("%:p")
            -- Handle both .ipynb and converted files
            if not file:match("%.ipynb$") then
              file = file:gsub("%.md$", ".ipynb")
            end
            if vim.fn.filereadable(file) == 1 then
              vim.fn.jobstart({ "jupyter", "lab", file }, { detach = true })
              vim.notify("Opening in Jupyter Lab: " .. vim.fn.fnamemodify(file, ":t"), vim.log.levels.INFO)
            else
              vim.notify("Notebook not found: " .. file, vim.log.levels.ERROR)
            end
          end,
          desc = "Open in Jupyter",
        },
      },
    },
  },
}
