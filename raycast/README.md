# Raycast Configuration

## Installation

```bash
brew install --cask raycast
```

## Setup

### Initial Configuration

1. Open Raycast (default: `Cmd+Space` - you may need to disable Spotlight shortcut first)
2. Go to Preferences → General → Set as default launcher (optional)
3. Configure hotkey if not using `Cmd+Space`

### Custom Extensions

Full TypeScript extensions with rich UI are in `extensions/`:

#### Kitty Tabs Extension

A professional extension for searching and switching between Kitty terminal tabs.

**Features:**
- Interactive list UI with live search (like Chrome tabs)
- 🏠 Local tabs - shows working directory
- 🌍 Remote SSH tabs - shows hostname and remote directory
- Smart SSH detection - handles various SSH command formats
- Directory caching - remembers directories even when running vi/nvim
- Copy actions - copy directory or SSH host with Cmd+C

**Installation:**

The extension runs in development mode automatically. To use it:
1. Open Raycast
2. Type "Search Kitty Tabs"
3. Add an alias for quick access (recommended: `kt`)
4. **Optional:** Set up global hotkey:
   - In Raycast, find "Search Kitty Tabs"
   - Press `Cmd+K` → "Add Hotkey"
   - Set to `Cmd+P` (replaces old Kitty tab picker)

**Requirements:**
- Kitty with `allow_remote_control socket-only` enabled
- Extension auto-detects Kitty socket

**Note:** The extension handles both local and SSH sessions. For SSH sessions, it attempts to parse the remote directory from the window title. For best results with remote directories, configure shell integration on remote hosts.

### Custom Script Commands

The `scripts/` directory is available for simple bash scripts if needed.

#### Script Metadata

Scripts need specific metadata comments at the top:

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Script Title
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🚀
# @raycast.argument1 { "type": "text", "placeholder": "Argument name" }
# @raycast.packageName Category Name
```

### Recommended Extensions

Install from Raycast Store (Cmd+, → Extensions → Store):

- **Clipboard History** (built-in, enable in preferences)
- **Brew** - Search and install packages
- **GitHub** - Search repos, PRs, issues
- **Window Management** - Quick window switching
- **Calculator** (built-in)
- **Snippets** (built-in, configure in preferences)

### Settings Not in Version Control

These require manual configuration:

- Hotkey preferences
- Enabled extensions
- Clipboard history settings
- Custom quicklinks/aliases
- Snippets

## Usage Tips

- `Cmd+Space` - Open Raycast
- Type to search apps, files, commands
- `Cmd+K` - Show available actions for current result
- `Cmd+Shift+,` - Open preferences
- Define quicklinks in Preferences → Quicklinks for custom searches
