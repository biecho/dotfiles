# Neovim keybinding flashcards

Rich-HTML Anki cards for the Neovim shortcuts configured in this repo. Cards are
pushed into Anki over the local **AnkiConnect** API (there is no AnkiWeb API for
creating cards — AnkiWeb is only the sync server, so you sync from the desktop
app after importing).

- `cards.py` — the card data: `(category, action, key, mode, notes, source)`.
  The **action** is the prompt; the **key** is the answer, so you practice
  productive recall ("I want to do X — which keys?").
- `push.py` — thin entry point that calls the shared `../ankipush.py`, which
  creates the `nvim` deck (one subdeck per category), a styled `nvim-keybind`
  note type, and adds the cards. Stdlib only, idempotent. See `../README.md`.

## One-time setup

1. **Install AnkiConnect**: open Anki → `Tools > Add-ons > Get Add-ons…` →
   paste code **`2055492159`** → restart Anki.
   (First launch of Anki may take a moment — the launcher fetches the real Anki.)

## Push the cards

With Anki running:

```sh
python3 anki/nvim/push.py
```

You'll get a count of added vs. already-present cards. Open the **`nvim`** deck
to study; the desktop app syncs everything up to AnkiWeb on its next sync.

## Updating

- **Add/edit cards** → edit `cards.py` and re-run `push.py`. New cards are added;
  existing ones (matched on the *action* field) are skipped.
- **Restyle cards** → edit the `CSS`/templates in `push.py` and re-run; the note
  type's styling and template are refreshed in place.

## Notes

- Cards with `source = "config"` come from this repo's `nvim/` Lua config;
  `source = "lazyvim"` are LazyVim defaults you use but that aren't written in
  your config (tagged `src-lazyvim` in Anki).
- Re-running never duplicates: Anki dedupes on the action field within each deck.
