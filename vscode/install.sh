#!/bin/bash
# =============================================================================
# VSCode Configuration Install Script
# =============================================================================
# This script symlinks the VSCode config files and installs required extensions.
# Run with: ~/dotfiles/vscode/install.sh
#
# Matches nvim dotfiles features:
# - lspsaga.nvim       → Built-in LSP + keybindings
# - flash.nvim         → vim.easymotion + vim.sneak
# - which-key.nvim     → vim.whichkeyTimeout
# - diffview.nvim      → GitLens + Git Graph
# - gitsigns.nvim      → GitLens inline blame
# - refactoring.nvim   → VSCode refactor commands
# - telescope.nvim     → Quick Open + Find in Files
# - todo-comments.nvim → Todo Tree
# - yanky.nvim         → vim.highlightedyank
# - treesitter         → Built-in syntax + bracket matching
# - conform.nvim       → Format on save
# - colorschemes       → Tokyo Night, Gruvbox, Catppuccin, etc.
# =============================================================================

set -e

DOTFILES_DIR="$HOME/dotfiles/vscode"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

echo "Installing VSCode configuration (nvim-compatible)..."
echo ""

# Create VSCode User directory if it doesn't exist
mkdir -p "$VSCODE_USER_DIR"

# Backup existing files if they exist and aren't symlinks
for file in settings.json keybindings.json; do
    target="$VSCODE_USER_DIR/$file"
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $file to $file.backup"
        mv "$target" "$target.backup"
    fi
done

# Create symlinks
echo "Creating symlinks..."
ln -sf "$DOTFILES_DIR/settings.json" "$VSCODE_USER_DIR/settings.json"
ln -sf "$DOTFILES_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"

echo "  $VSCODE_USER_DIR/settings.json -> $DOTFILES_DIR/settings.json"
echo "  $VSCODE_USER_DIR/keybindings.json -> $DOTFILES_DIR/keybindings.json"

# Install extensions
echo ""
echo "Installing VSCode extensions..."

extensions=(
    # =========================================================================
    # CORE: Vim keybindings (essential - replaces neovim)
    # =========================================================================
    "vscodevim.vim"

    # =========================================================================
    # PYTHON: Language support (matches LazyVim lang.python extra)
    # =========================================================================
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-python.debugpy"

    # =========================================================================
    # JUPYTER: Notebook support (matches jupytext.nvim + otter.nvim)
    # =========================================================================
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.jupyter-renderers"

    # =========================================================================
    # GIT: Version control (matches diffview.nvim + gitsigns.nvim)
    # =========================================================================
    "eamodio.gitlens"           # Inline blame, file history, etc.
    "mhutchie.git-graph"        # Visual git log (matches diffview repo history)

    # =========================================================================
    # NAVIGATION: File management (matches yazi.nvim + telescope.nvim)
    # =========================================================================
    "patbenatar.advanced-new-file"  # Quick file creation

    # =========================================================================
    # CODE QUALITY: Linting and formatting (matches conform.nvim + nvim-lint)
    # =========================================================================
    "esbenp.prettier-vscode"    # Formatter for JS/JSON/etc.
    "ms-python.black-formatter" # Python formatter

    # =========================================================================
    # TODO COMMENTS (matches todo-comments.nvim)
    # =========================================================================
    "gruntfuggly.todo-tree"

    # =========================================================================
    # COLORSCHEMES (matches nvim colorschemes.lua)
    # =========================================================================
    "enkia.tokyo-night"         # Default theme (tokyonight.nvim)
    "sainnhe.gruvbox-material"  # gruvbox.nvim
    "catppuccin.catppuccin-vsc" # catppuccin
    "mvllow.rose-pine"          # rose-pine
    "sainnhe.everforest"        # everforest
    "github.github-vscode-theme" # github-nvim-theme

    # =========================================================================
    # MARKDOWN (matches render-markdown.nvim + markdown-preview.nvim)
    # =========================================================================
    "yzhang.markdown-all-in-one"
    "bierner.markdown-mermaid"  # Mermaid diagram support
    "bierner.markdown-preview-github-styles"

    # =========================================================================
    # UTILITIES
    # =========================================================================
    "streetsidesoftware.code-spell-checker"  # Spell checking
    "editorconfig.editorconfig"              # EditorConfig support
    "usernamehw.errorlens"                   # Inline error display (like lspsaga)
)

for ext in "${extensions[@]}"; do
    # Skip comments
    [[ "$ext" =~ ^#.* ]] && continue
    echo "  Installing $ext..."
    code --install-extension "$ext" --force 2>/dev/null || echo "    (may already be installed or failed)"
done

# Remove conflicting extensions
echo ""
echo "Removing conflicting extensions..."
conflicting=(
    "asvetliakov.vscode-neovim"  # Conflicts with vscodevim
)

for ext in "${conflicting[@]}"; do
    code --uninstall-extension "$ext" 2>/dev/null && echo "  Removed $ext" || true
done

echo ""
echo "============================================================================="
echo "Installation complete!"
echo "============================================================================="
echo ""
echo "KEYBINDINGS REFERENCE (matches nvim dotfiles)"
echo ""
echo "LSP/Code Navigation (lspsaga.nvim):"
echo "  K             Hover documentation"
echo "  gd            Go to definition"
echo "  gp            Peek definition (floating)"
echo "  gy            Go to type definition"
echo "  gP            Peek type definition"
echo "  gr            Find references"
echo "  gI            Go to implementation"
echo "  [d / ]d       Previous/next diagnostic"
echo "  <Space>ca     Code actions"
echo "  <Space>cr     Rename symbol"
echo "  <Space>cR     Replace in files (project rename)"
echo "  <Space>cd     Show diagnostic"
echo "  <Space>cD     All diagnostics (problems panel)"
echo "  <Space>ci     Incoming calls"
echo "  <Space>co     Outgoing calls"
echo "  <Space>cs     Document symbols"
echo "  <Space>cS     Workspace symbols"
echo ""
echo "Refactoring (refactoring.nvim):"
echo "  <Space>rs     Refactor menu"
echo "  <Space>rf     Extract function/method"
echo "  <Space>rx     Extract variable"
echo "  <Space>ri     Inline variable"
echo ""
echo "Git (diffview.nvim + gitsigns.nvim):"
echo "  <Space>gg     Git panel (SCM view)"
echo "  <Space>gb     Toggle file blame"
echo "  <Space>gB     Toggle line blame"
echo "  <Space>gv     View changes (diff)"
echo "  <Space>gF     File history"
echo "  <Space>gR     Repo history (git graph)"
echo "  <Space>gd     Diff with previous"
echo "  <Space>gh     Quick file history"
echo "  [c / ]c       Previous/next hunk"
echo "  <Space>hs     Stage hunk"
echo "  <Space>hr     Revert hunk"
echo ""
echo "File Operations (yazi.nvim + telescope.nvim):"
echo "  <Space>e      File explorer"
echo "  <Space>.      Reveal file in explorer"
echo "  <Space>ff     Find files (quick open)"
echo "  <Space>fg     Find in files (grep)"
echo "  <Space>/      Find in files"
echo "  <Space>fr     Recent files"
echo "  <Space>fb     Open buffers"
echo "  <Space>:      Command palette"
echo "  <Space><Space> Quick open"
echo ""
echo "Buffer/Tab Navigation:"
echo "  H / L         Previous/next tab"
echo "  [b / ]b       Previous/next tab"
echo "  <Space>bd     Close buffer"
echo "  <Space>bD     Close other buffers"
echo "  <Space>bb     Buffer list"
echo "  <Space>\`      Last buffer"
echo ""
echo "Windows/Splits (smart-splits.nvim):"
echo "  Ctrl+h/j/k/l  Focus left/down/up/right split"
echo "  <Space>wv     Vertical split"
echo "  <Space>ws     Horizontal split"
echo "  <Space>wd     Close split"
echo "  <Space>-      Horizontal split"
echo "  <Space>|      Vertical split"
echo ""
echo "Navigation (flash.nvim):"
echo "  s             EasyMotion 2-char search forward"
echo "  S             EasyMotion 2-char search backward"
echo "  <Space><Space>w  EasyMotion word"
echo "  <Space><Space>j  EasyMotion line down"
echo "  <Space><Space>k  EasyMotion line up"
echo ""
echo "UI Toggles:"
echo "  <Space>uw     Toggle word wrap"
echo "  <Space>un     Toggle sidebar"
echo "  <Space>uz     Toggle zen mode"
echo "  <Space>uf     Toggle fullscreen"
echo "  <Space>um     Toggle minimap"
echo ""
echo "TODO Comments (todo-comments.nvim):"
echo "  <Space>xt     Show TODO tree"
echo "  [t / ]t       Previous/next TODO"
echo ""
echo "Copy Paths (keymaps.lua):"
echo "  <Space>yf     Copy relative path"
echo "  <Space>yF     Copy absolute path"
echo "  <Space>yn     Copy filename"
echo ""
echo "Other:"
echo "  <Space>mp     Markdown preview"
echo "  <Space>ft     Toggle terminal"
echo "  q             Disabled (no accidental macros)"
echo "  Q             Record macro"
echo "  jk            Escape (insert mode)"
echo "  Ctrl+Space    Trigger autocomplete (manual)"
echo ""
echo "Notebook Keybindings:"
echo "  Ctrl+j/k      Navigate cells"
echo "  Shift+Enter   Execute and move down"
echo "  Ctrl+Enter    Execute cell"
echo "  a / b         Add cell above/below"
echo "  m / y         Change to markdown/code"
echo "  dd            Delete cell"
echo ""
echo "============================================================================="
echo "Restart VSCode to apply all settings."
echo "============================================================================="
