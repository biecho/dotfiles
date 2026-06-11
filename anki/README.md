# Anki flashcard decks

Rich-HTML Anki decks generated from this repo, pushed into Anki over the local
**AnkiConnect** API (AnkiWeb itself has no card-creation API — you sync from the
desktop app afterwards).

```
anki/
├── ankipush.py   # shared: AnkiConnect transport, <kbd> key rendering, note type, push_cards()
├── nvim/         # Neovim keybinding deck   (deck "nvim",  model "nvim-keybind")
│   ├── cards.py  #   (category, action, key, mode, notes, source) tuples
│   └── push.py   #   thin entry point → ankipush.push_cards(...)
├── tmux/         # tmux keybinding deck     (deck "tmux",  model "tmux-keybind")
│   ├── cards.py
│   └── push.py
└── popos/        # Pop!_OS / COSMIC deck    (deck "popos", model "cosmic-keybind")
    ├── cards.py
    └── push.py
```

Each card's **action** is the prompt (front); the **key** is the answer (back),
rendered as styled `<kbd>` tokens (`<leader>` → `Space`, `Super+Shift+Left` →
`Super Shift ←`). Cards land in `<deck>::<Category>` subdecks.

## One-time setup

Install the **AnkiConnect** add-on: Anki → `Tools > Add-ons > Get Add-ons…` →
code **`2055492159`** → restart Anki. (On a fresh machine, also install Anki —
see the repo root; the launcher fetches the real Anki on first run.)

AnkiConnect defaults to `127.0.0.1:8765`. On this machine that port is taken by
`tracegraph serve`, so AnkiConnect is configured to **8766** (its add-on config
→ `webBindPort`) and `zsh/.zshrc` exports `ANKI_CONNECT_URL=http://127.0.0.1:8766`,
which `ankipush.py` honors. To use a different port, change both.

## Push the decks

With Anki running:

```sh
python3 anki/nvim/push.py
python3 anki/popos/push.py
```

Each prints added vs. already-present counts. Both are **idempotent** (Anki
dedupes on the action field within the collection) and **self-healing** (cards
are placed into the right subdeck by id every run, working around an AnkiConnect
build that ignores per-note deck on add). Sync from the desktop app to push up
to AnkiWeb.

## Adding a deck

Create `anki/<name>/cards.py` with a `CARDS` list and an `anki/<name>/push.py`
that calls `push_cards(root_deck="<name>", model="<name>-keybind", cards=CARDS)`.
Keys may be vim notation (`<C-A-l>`, `[d`) or desktop notation (`Super+Y`,
`Alt+Tab`) — `render_key` handles both. Keep `cards.py` tables wrapped in
`# fmt: off` / `# fmt: on` so Black leaves the alignment alone.
