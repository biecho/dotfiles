# tmux keybinding flashcards

Rich-HTML Anki cards for the tmux shortcuts configured in this repo
(`tmux/tmux.conf`). Cards are pushed into Anki over the local **AnkiConnect**
API (there is no AnkiWeb API for creating cards — AnkiWeb is only the sync
server, so you sync from the desktop app after importing).

- `cards.py` — the card data: `(category, action, key, mode, notes, source)`.
  The **action** is the prompt; the **key** is the answer, so you practice
  productive recall ("I want to do X — which keys?"). The prefix is **Ctrl+a**,
  and answers render the full chord (e.g. `Ctrl+a  h`).
- `push.py` — thin entry point that calls the shared `../ankipush.py`, which
  creates the `tmux` deck (one subdeck per category), a styled `tmux-keybind`
  note type, and adds the cards. Stdlib only, idempotent. See `../README.md`.

Deck `tmux`, note type `tmux-keybind`, subdecks: Prefix & Sessions, Splitting
Panes, Navigating Panes, Resizing & Zoom, Moving & Swapping Panes, Windows,
Copy Mode.

## One-time setup

1. **Install AnkiConnect**: open Anki → `Tools > Add-ons > Get Add-ons…` →
   paste code **`2055492159`** → restart Anki.
   (First launch of Anki may take a moment — the launcher fetches the real Anki.)

## Push the cards

With Anki running:

```sh
python3 anki/tmux/push.py
```

You'll get a count of added vs. already-present cards. Open the **`tmux`** deck
to study; the desktop app syncs everything up to AnkiWeb on its next sync.

## Notes

- Cards tagged `src-config` come from this repo's `tmux/tmux.conf`; cards tagged
  `src-builtin` are stock tmux defaults this config leaves in place (detach,
  copy mode, next/previous window, break-pane, the command prompt, …).
- The `mode` badge is the context: **Prefix** (press Ctrl+a first), **Copy mode**
  (pressed inside copy mode), or **Core** (the prefix key itself).
- Re-running never duplicates: Anki dedupes on the action field within the
  collection. Edit `cards.py` and re-run `push.py` to add or restyle cards.
