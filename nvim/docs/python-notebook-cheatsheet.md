# Python & Notebook Shortcuts Cheatsheet

## Prerequisites

```bash
# Install required Python packages
pip install jupytext ipykernel pynvim

# Register your venv as a Jupyter kernel (for auto-init)
python -m ipykernel install --user --name my_venv_name

# Verify kernel is available
jupyter kernelspec list
```

## Jupyter/Molten (`<leader>j`)

Molten-nvim provides Jupyter kernel integration for running code cells.

### Initialization

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>ji` | Initialize kernel (select)       |
| `<leader>jI` | Initialize kernel (auto venv)    |

### Execution

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>jc` | Run current cell                 |
| `<leader>jl` | Evaluate line                    |
| `<leader>je` | Evaluate operator (motion)       |
| `<leader>jr` | Re-evaluate cell                 |
| `<leader>jv` | Evaluate visual (visual mode)    |

### Output Management

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>jo` | Show output                      |
| `<leader>jO` | Enter output window              |
| `<leader>jh` | Hide output                      |
| `<leader>jd` | Delete cell output               |
| `<leader>jD` | Delete all outputs               |
| `<leader>jx` | Interrupt kernel                 |

### Save/Load/Export

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>js` | Save outputs                     |
| `<leader>jL` | Load outputs                     |
| `<leader>jE` | Export to .ipynb                 |
| `<leader>jM` | Import from .ipynb               |

### Cell Navigation

| Key          | Action                           |
|--------------|----------------------------------|
| `]x`         | Next cell                        |
| `[x`         | Previous cell                    |
| `<leader>j]` | Next cell (alternative)          |
| `<leader>j[` | Previous cell (alternative)      |

## Cell Text Objects (vim-textobj-hydrogen)

Use with operators like `d`, `y`, `c`, `v`:

| Text Object | Action                           |
|-------------|----------------------------------|
| `ih`        | Inner cell (between # %%)        |
| `ah`        | Around cell (including marker)   |

### Examples

| Command | Action                           |
|---------|----------------------------------|
| `dih`   | Delete inner cell                |
| `yih`   | Yank inner cell                  |
| `cih`   | Change inner cell                |
| `vih`   | Select inner cell                |
| `vah`   | Select around cell               |

## REPL (`<leader>r`) - iron.nvim

Interactive Python REPL using IPython.

### Control

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>rs` | Start REPL                       |
| `<leader>rr` | Restart REPL                     |
| `<leader>rf` | Focus REPL                       |
| `<leader>rh` | Hide REPL                        |
| `<leader>rq` | Quit REPL                        |
| `<leader>ri` | Interrupt                        |
| `<leader>rx` | Clear screen                     |

### Send Code

| Key            | Action                         |
|----------------|--------------------------------|
| `<leader>rc`   | Send motion/visual             |
| `<leader>rl`   | Send line                      |
| `<leader>rp`   | Send paragraph                 |
| `<leader>rF`   | Send file                      |
| `<leader>ru`   | Send until cursor              |
| `<leader>r<cr>`| Send and execute               |

## Quarto (`<leader>q`)

Literate programming with `.qmd` files.

### Preview

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>qp` | Quarto preview                   |
| `<leader>qc` | Close preview                    |
| `<leader>qa` | Activate Quarto LSP              |

### Code Runner

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>qr` | Run cell                         |
| `<leader>qR` | Run all cells                    |
| `<leader>ql` | Run line                         |
| `<leader>qA` | Run all above                    |
| `<leader>qb` | Run all below                    |

## Testing (`<leader>t`) - neotest

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>tp` | Run nearest test                 |
| `<leader>tP` | Run file tests                   |
| `<leader>td` | Debug nearest test               |

## Virtual Environment (`<leader>c`)

| Key          | Action                           |
|--------------|----------------------------------|
| `<leader>cv` | Select venv                      |
| `<leader>cV` | Select cached venv               |

## Typical Workflow

### Notebook-style Development

```
1. Activate venv:     source .venv/bin/activate
2. Open .py file:     nvim script.py
3. Init kernel:       <leader>jI  (auto-detects venv)
4. Navigate cells:    ]x / [x
5. Run cell:          <leader>jc
6. Show output:       <leader>jo
7. Edit cell:         cih (change inner cell)
8. Save outputs:      <leader>js
```

### Working with .ipynb Files

```
1. Open notebook:     nvim notebook.ipynb
   (jupytext auto-converts to markdown/python)
2. Import outputs:    <leader>jM
3. Edit and run:      <leader>jc
4. Export back:       <leader>jE
```

### Exploratory REPL

```
1. Start REPL:        <leader>rs
2. Send line:         <leader>rl
3. Send selection:    (visual) <leader>rc
4. Send paragraph:    <leader>rp
```

## Cell Markers

Cells are defined by `# %%` comments:

```python
# %% [markdown]
# # My Notebook Title

# %%
import numpy as np
import matplotlib.pyplot as plt

# %%
x = np.linspace(0, 10, 100)
y = np.sin(x)

# %%
plt.plot(x, y)
plt.show()
```

## Plugins

| Plugin               | Purpose                          |
|----------------------|----------------------------------|
| molten-nvim          | Jupyter kernel integration       |
| jupytext.nvim        | Edit .ipynb as .py/.md           |
| quarto-nvim          | Literate programming             |
| otter.nvim           | LSP in code blocks               |
| iron.nvim            | Interactive REPL                 |
| vim-textobj-hydrogen | Cell text objects (ih/ah)        |
| image.nvim           | Inline image rendering           |
| neotest-python       | Pytest integration               |
| venv-selector.nvim   | Virtual environment switching    |
| basedpyright         | Python LSP (type checking)       |
| ruff                 | Linting & formatting             |
