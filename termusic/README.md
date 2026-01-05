# Termusic Configuration

A professional configuration for **termusic** - a terminal music and podcast player written in Rust.

## Killer Features

### 🎵 Audio & Playback
- **Gapless Playback**: Seamless transitions between tracks
- **Speed Control**: Adjust playback speed without pitch changes (via SoundTouch)
- **Multiple Backends**: Choose between Symphonia (Rusty), GStreamer, or MPV
- **High-Quality Audio**: 48kHz output, optimized buffers
- **Extensive Format Support**: MP3, FLAC, OGG, WAV, M4A, AAC, and more

### 🎨 Visual Experience
- **Album Cover Display**: Works natively in Kitty and iTerm2 terminals
- **Customizable Themes**: 200+ built-in themes or create your own
- **Vim-style Navigation**: hjkl movement, g/G jumps, intuitive keybindings
- **Live Lyrics**: Synchronized lyrics with timing adjustments

### 🎧 Smart Features
- **Discord Rich Presence**: Show what you're listening to on Discord
- **Media Controls**: System-level play/pause (keyboard/headphones)
- **Position Memory**: Resume podcasts where you left off
- **Smart Seeking**: 5s for short tracks, 30s for long tracks

### 🌐 Online Integration
- **YouTube Search & Download**: Search and download music directly from YouTube
- **Podcast Support**: RSS feeds with automatic downloads
- **Database Management**: Organized music library with metadata

### ⚡ Workflow Optimization
- **Playlist Management**: Save, shuffle, reorder with vim-like commands
- **Tag Editor**: Built-in metadata editor
- **Multiple Root Dirs**: Organize music across different directories
- **Random Selection**: Add random tracks or entire albums

## Installation

```bash
cargo install termusic termusic-server --locked
```

## Setup

Link the configuration files:

```bash
# macOS
ln -sf ~/dotfiles/termusic/tui.toml ~/Library/Application\ Support/termusic/tui.toml
ln -sf ~/dotfiles/termusic/server.toml ~/Library/Application\ Support/termusic/server.toml

# Linux
ln -sf ~/dotfiles/termusic/tui.toml ~/.config/termusic/tui.toml
ln -sf ~/dotfiles/termusic/server.toml ~/.config/termusic/server.toml
```

## Essential Keybindings

### Navigation (Vim-style)
```
j/k         - Move down/up
h/l         - Collapse/expand or move left/right
g/G         - Jump to top/bottom
/           - Search
```

### Views
```
1           - Library view
2           - Database view
3           - Podcasts view
Shift+C     - Open config editor
Ctrl+h      - Show help
```

### Playback
```
Space       - Play/pause
n/N         - Next/previous track
+/-         - Volume up/down
f/b         - Seek forward/backward
Ctrl+f/b    - Speed up/down
m           - Cycle loop mode (single/playlist/random)
```

### Library Actions
```
l           - Load/play track
L           - Load entire directory
s           - YouTube search
t           - Tag editor
d           - Delete from library
y/p         - Yank/paste
```

### Playlist Management
```
l           - Play selected track
d/D         - Remove track/clear all
r           - Shuffle playlist
K/J         - Move track up/down
s/S         - Add random songs/album
Ctrl+s      - Save playlist
```

### Podcasts
```
s           - Search podcasts
r/R         - Refresh feed/all feeds
d           - Download episode
m/M         - Mark played/all played
x/X         - Delete feed/all feeds
```

## Configuration Tips

### Music Directories
Edit `server.toml`:
```toml
music_dirs = [
    "/Users/you/Music",
    "/Volumes/ExternalDrive/Music"
]
```

### Playback Backend
Choose based on your needs:
- **rusty** (default): Pure Rust, good compatibility, works everywhere
- **gstreamer**: More formats, better quality (requires gstreamer installed)
- **mpv**: Maximum format support (requires mpv installed)

```toml
backend = "rusty"  # or "gstreamer" or "mpv"
```

### Theme Customization
1. Browse built-in themes in `~/Library/Application Support/termusic/themes/`
2. Popular themes: Nord, Dracula, Gruvbox, Monokai, Solarized
3. Create custom themes in YAML format
4. Switch themes in config editor (Shift+C)

### Discord Integration
Already enabled by default:
```toml
set_discord_status = true
```

Shows "Listening to [Artist] - [Song]" on your Discord profile.

### Album Covers
Works automatically in Kitty and iTerm2. Adjust position/size:
```
Ctrl+Shift+Arrows  - Move cover
Ctrl+Shift+PgUp/Dn - Resize
Ctrl+Shift+End     - Toggle hide
```

## Workflow Examples

### Quick Start
```bash
termusic
# Press '1' for library
# Navigate with j/k
# Press 'l' to load a track
# Press Space to play
```

### YouTube Music Download
```bash
# In termusic:
# 1. Press 's' for YouTube search
# 2. Type song name, press Enter
# 3. Select result with j/k
# 4. Press 'l' to download and add to library
```

### Podcast Workflow
```bash
# In termusic:
# 1. Press '3' for podcasts
# 2. Press 's' to search for podcasts
# 3. Subscribe to feeds
# 4. Press 'd' to download episodes
# 5. Episodes save to ~/Music/podcast
```

### Playlist Building
```bash
# 1. Navigate library (press '1')
# 2. Press 'l' on tracks to add to playlist
# 3. Press 'L' on folders to add all
# 4. Or press 's' to add random songs
# 5. Press Ctrl+s to save playlist
```

## Performance Tuning

### Buffer Sizes (in `server.toml`)
```toml
file_buffer_size = "8.0 MiB"      # Larger = less stuttering, more memory
decoded_buffer_size = "1.5 MiB"   # Larger = smoother playback
```

### Sample Rate
```toml
output_sample_rate = 48000  # 48kHz (high quality)
# or 44100 for standard CD quality
# or 96000 for audiophile quality (if supported)
```

## Troubleshooting

### No Sound
1. Check volume with `+/-` keys
2. Try different backend: `backend = "mpv"` in server.toml
3. Restart termusic

### Album Covers Not Showing
- Kitty: Should work automatically
- iTerm2: Enable inline images in Preferences
- Other terminals: May need Sixel or Ueberzug support

### YouTube Download Fails
- Install yt-dlp: `brew install yt-dlp`
- Check internet connection
- Some videos may be region-locked

## Resources

- **GitHub**: https://github.com/tramhao/termusic
- **Themes**: 200+ included in installation
- **Shortcuts**: Press `Ctrl+h` in termusic for full list

## Tips & Tricks

1. **Speed Reading Podcasts**: Use `Ctrl+f` to increase speed to 1.5x or 2x
2. **Discover Music**: Use `s` (random songs) to explore your library
3. **Queue Management**: Build queue on the fly with `l` on individual tracks
4. **Multi-root Setup**: Add multiple music directories for organized collections
5. **Backup Playlists**: Saved to `~/Library/Application Support/termusic/playlist.log`
