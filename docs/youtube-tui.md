# YouTube TUI - Terminal YouTube Browser

A terminal-based YouTube client with thumbnail previews and in-terminal video playback using Kitty's graphics protocol.

## Quick Start

```bash
ytv              # Launch YouTube TUI (recommended - auto-kills mpv on exit)
youtube-tui      # Launch directly (mpv may continue after exit)
```

## Installation

youtube-tui requires Rust to compile. Dependencies: `mpv`, `yt-dlp`, `libsixel`.

```bash
# Install dependencies
brew install mpv yt-dlp libsixel

# Set Rust default toolchain (if not already)
rustup default stable

# Install youtube-tui (needs library paths for linking)
LIBRARY_PATH="$(brew --prefix libsixel)/lib:$(brew --prefix mpv)/lib:$LIBRARY_PATH" \
  cargo install youtube-tui
```

## Video Playback Modes

### In-Terminal Video (Kitty)

Videos play directly in the terminal using Kitty's graphics protocol:

```yaml
# ~/.config/youtube-tui/main.yml
env:
  video-player: mpv --vo=kitty --vo-kitty-use-shm=yes
```

**Note:** `--vo-kitty-use-shm=yes` uses shared memory for better performance (local only, won't work over SSH).

### Regular mpv Window

For a standard video window:

```yaml
env:
  video-player: mpv
```

## Navigation

| Key | Action |
|-----|--------|
| `j` / `k` | Move down/up |
| `h` / `l` | Previous/next page |
| `Enter` | Select/play |
| `/` | Search |
| `q` | Quit |
| `?` | Help |

## Thumbnail Previews

Thumbnails display in the terminal using Sixels. Kitty auto-detects and uses its native protocol via the `viuer` library.

```yaml
images: Sixels
```

## YouTube Tools

This dotfiles setup includes several YouTube-related commands:

| Command | Description |
|---------|-------------|
| `ytv` | Launch YouTube TUI with mpv cleanup on exit |
| `ytq <url>` | Queue URL for audio download |
| `ytd` | Download all queued audio (mp3) |
| `ytls` | Show download queue |

### The `ytv` Wrapper

The `ytv` script (in `~/dotfiles/scripts/`) wraps youtube-tui to automatically kill mpv processes when you quit:

```bash
#!/bin/bash
# Records mpv PIDs before starting, kills new ones on exit
before_pids=$(pgrep mpv 2>/dev/null || true)
youtube-tui "$@"
# ... cleanup logic
```

Without this wrapper, mpv continues playing audio/video after quitting the TUI.

## Configuration

Located in `~/.config/youtube-tui/` (main.yml symlinked from `~/dotfiles/youtube-tui/`):

| File | Purpose |
|------|---------|
| `main.yml` | Main configuration (video player, images, provider) |
| `keybindings.yml` | Key mappings |
| `appearance.yml` | Colors and styling |
| `commands.yml` | Custom commands |

### Key Settings (main.yml)

```yaml
mouse_support: true
images: Sixels
provider: YouTube
search_provider: RustyPipe
invidious_instance: https://invidious.f5.si

env:
  video-player: mpv --vo=kitty --vo-kitty-use-shm=yes
  youtube-downloader: yt-dlp
  browser: open
  terminal-emulator: kitty -e

limits:
  watch_history: 50
  search_history: 75
```

## Troubleshooting

### Build Fails: "library 'sixel' not found"

Set library paths when installing:

```bash
LIBRARY_PATH="$(brew --prefix libsixel)/lib:$(brew --prefix mpv)/lib" cargo install youtube-tui
```

### mpv Keeps Playing After Quit

Use `ytv` instead of `youtube-tui` directly, or manually kill:

```bash
pkill mpv
```

### No Thumbnails

Ensure your terminal supports Sixels or the Kitty graphics protocol. In Kitty, this should work automatically.

### Video Playback Issues in Terminal

If in-terminal video is choppy or glitchy, switch to regular mpv window:

```yaml
env:
  video-player: mpv
```

## Resources

- [YouTube TUI GitHub](https://github.com/Siriusmart/youtube-tui)
- [YouTube TUI Docs](https://tui.siri.ws/youtube/)
- [Kitty Graphics Protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/)
- [mpv --vo=kitty](https://mpv.io/manual/master/#video-output-drivers-kitty)
