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

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$DOTFILES_DIR/extensions.txt"
BACKUP_SUFFIX="$(date +%Y%m%d_%H%M%S)"
VSCODE_USER_DIRS=()

case "$(uname -s)" in
    Darwin)
        VSCODE_USER_DIRS+=("$HOME/Library/Application Support/Code/User")
        [[ -d "$HOME/Library/Application Support/Code - OSS" ]] && VSCODE_USER_DIRS+=("$HOME/Library/Application Support/Code - OSS/User")
        [[ -d "$HOME/Library/Application Support/VSCodium" ]] && VSCODE_USER_DIRS+=("$HOME/Library/Application Support/VSCodium/User")
        ;;
    Linux)
        VSCODE_USER_DIRS+=("$HOME/.config/Code/User")
        [[ -d "$HOME/.vscode-server" ]] && VSCODE_USER_DIRS+=("$HOME/.vscode-server/data/User")
        [[ -d "$HOME/.local/share/code-server" || -d "$HOME/.config/code-server" ]] && VSCODE_USER_DIRS+=("$HOME/.local/share/code-server/User")
        [[ -d "$HOME/.config/Code - OSS" ]] && VSCODE_USER_DIRS+=("$HOME/.config/Code - OSS/User")
        [[ -d "$HOME/.config/VSCodium" ]] && VSCODE_USER_DIRS+=("$HOME/.config/VSCodium/User")
        ;;
    *)
        VSCODE_USER_DIRS+=("$HOME/.config/Code/User")
        ;;
esac

find_code_cli() {
    if command -v code &> /dev/null; then
        command -v code
    elif command -v codium &> /dev/null; then
        command -v codium
    elif command -v code-server &> /dev/null; then
        command -v code-server
    elif compgen -G "$HOME/.vscode-server/cli/servers/Stable-*/server/bin/code-server" > /dev/null; then
        printf '%s\n' "$HOME"/.vscode-server/cli/servers/Stable-*/server/bin/code-server | sort | tail -n 1
    elif compgen -G "$HOME/.vscode-server/bin/*/bin/code-server" > /dev/null; then
        printf '%s\n' "$HOME"/.vscode-server/bin/*/bin/code-server | sort | tail -n 1
    fi
}

link_config_file() {
    local source="$1"
    local target="$2"

    if [[ -f "$target" && ! -L "$target" ]]; then
        echo "Backing up existing $target to $target.backup.$BACKUP_SUFFIX"
        mv "$target" "$target.backup.$BACKUP_SUFFIX"
    fi

    ln -sf "$source" "$target"
    echo "  $target -> $source"
}

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

echo "Installing VSCode configuration (nvim-compatible)..."
echo ""

# Create symlinks
echo "Creating symlinks..."
for user_dir in "${VSCODE_USER_DIRS[@]}"; do
    mkdir -p "$user_dir"
    link_config_file "$DOTFILES_DIR/settings.json" "$user_dir/settings.json"
    link_config_file "$DOTFILES_DIR/keybindings.json" "$user_dir/keybindings.json"
done

# Install extensions
echo ""
CODE_CLI="$(find_code_cli || true)"

if [[ -n "$CODE_CLI" ]]; then
    echo "Installing VSCode extensions with $CODE_CLI..."
    while IFS= read -r ext || [[ -n "$ext" ]]; do
        ext="$(trim "${ext%%#*}")"
        [[ -z "$ext" ]] && continue
        echo "  Installing $ext..."
        "$CODE_CLI" --install-extension "$ext" --force 2>/dev/null || echo "    (may already be installed or failed)"
    done < "$EXTENSIONS_FILE"
else
    echo "Skipping VSCode extension install: no code, codium, or code-server CLI found in PATH."
fi

# Remove conflicting extensions
echo ""
conflicting=(
    "asvetliakov.vscode-neovim"  # Conflicts with vscodevim
)

if [[ -n "$CODE_CLI" ]]; then
    echo "Removing conflicting extensions..."
    for ext in "${conflicting[@]}"; do
        "$CODE_CLI" --uninstall-extension "$ext" 2>/dev/null && echo "  Removed $ext" || true
    done
fi

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
