# Pop!_OS (COSMIC) keybinding deck

Flashcards for the COSMIC desktop shortcuts on this machine — emphasis on
tiling/window management. See `../README.md` for setup and the shared pusher.

```sh
python3 anki/popos/push.py    # Anki running + AnkiConnect installed
```

Deck `popos`, note type `cosmic-keybind`, subdecks: Tiling & Layout, Focus &
Move Windows, Workspaces & Monitors, Apps & System, My Customizations.

## Accuracy

`cards.py` is grounded in the authoritative COSMIC config, not generic lore:

- Defaults: `/usr/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1/defaults`
- Overrides: `~/.config/cosmic/.../v1/custom` (tracked in this repo under `cosmic/`)

Cards tagged `src-cosmic` are COSMIC defaults **active** on this setup. Cards
tagged `src-custom` are this repo's overrides — keys disabled (freed for kitty's
Super/Cmd bindings) or remapped — so the deck teaches what differs from stock
Pop!_OS (e.g. `Super+T`/`Super+W`/`Super+1..9` disabled, `Super+Space` →
Launcher, bare `Super` does nothing).

If you change the COSMIC shortcuts, update `cards.py` and re-run `push.py`.
