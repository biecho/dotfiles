# Kitty Tabs Extension for Raycast

Search and switch between Kitty terminal tabs with an interactive list UI, similar to Chrome's tab search.

## Features

- **Live Search**: Filter tabs as you type
- **Quick Switch**: Press Enter to instantly switch to a tab
- **Visual Indicators**: See which tab is currently focused
- **Working Directory**: View and copy the working directory of each tab
- **Keyboard Shortcuts**: `Cmd+C` to copy working directory

## Installation

From this directory:

```bash
npm install
npm run dev
```

This will build and install the extension in development mode.

## Requirements

- Kitty terminal with remote control enabled
- `allow_remote_control socket-only` in kitty.conf
- `listen_on unix:/tmp/kitty` in kitty.conf

## Usage

1. Open Raycast (`Cmd+Space`)
2. Type "Search Kitty Tabs"
3. Start typing to filter tabs
4. Press Enter to switch to selected tab

## Actions

- **Enter**: Switch to tab
- **Cmd+C**: Copy working directory to clipboard
