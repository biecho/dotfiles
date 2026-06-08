"""Shared AnkiConnect helpers for the keybinding decks in this folder.

Each deck folder (nvim/, popos/, …) has a `cards.py` with a CARDS list of
`(category, action, key, mode, notes, source)` tuples and a thin `push.py` that
calls `push_cards(...)` here. The action is the prompt (front); the key is the
answer (back), rendered as styled <kbd> tokens.

Prerequisites: AnkiConnect add-on (code 2055492159) installed and Anki running
(serves a local API on 127.0.0.1:8765). Stdlib only; idempotent.
"""

import json
import re
import sys
import urllib.error
import urllib.request
from collections import defaultdict

ANKI_URL = "http://127.0.0.1:8765"

# ---------------------------------------------------------------------------
# AnkiConnect transport
# ---------------------------------------------------------------------------


def invoke(action, **params):
    payload = json.dumps({"action": action, "version": 6, "params": params}).encode()
    req = urllib.request.Request(
        ANKI_URL, payload, {"Content-Type": "application/json"}
    )
    try:
        resp = json.load(urllib.request.urlopen(req, timeout=15))
    except urllib.error.URLError as exc:
        sys.exit(
            f"\n✗ Cannot reach AnkiConnect at {ANKI_URL}.\n"
            f"  Is Anki running with the AnkiConnect add-on (code 2055492159)?\n"
            f"  Details: {exc}\n"
        )
    if resp.get("error") is not None:
        raise RuntimeError(f"AnkiConnect error for '{action}': {resp['error']}")
    return resp["result"]


# ---------------------------------------------------------------------------
# Key rendering: turn a key spec into a row of <kbd> tokens.
#   - vim notation (contains '<'):  "<leader>sg", "<C-A-l>", "[d"
#   - desktop notation (otherwise): chords split on spaces, mods on '+':
#       "Super+Y", "Super+Shift+Left", "Alt+Tab", "Print"
# ---------------------------------------------------------------------------

_MODS = {"C": "Ctrl", "A": "Alt", "M": "Alt", "S": "Shift", "D": "Cmd"}
_KEYS = {
    "cr": "Enter",
    "up": "↑",
    "down": "↓",
    "left": "←",
    "right": "→",
    "space": "Space",
    "tab": "Tab",
    "esc": "Esc",
    "bs": "Backspace",
}


def _vim_token_to_chord(token):
    """Map one vim token, e.g. '<C-A-h>' -> [Ctrl, Alt, h]."""
    if token == "<leader>":
        return ["Space"]
    if token.startswith("<") and token.endswith(">"):
        *mods, key = token[1:-1].split("-")
        labels = [_MODS.get(m.upper(), m) for m in mods]
        labels.append(_KEYS.get(key.lower(), key))
        return labels
    return [token]


def render_key(spec):
    if "<" in spec:  # vim notation
        chords = [_vim_token_to_chord(t) for t in re.findall(r"<[^>]+>|.", spec)]
    else:  # desktop notation
        chords = [
            [_KEYS.get(t.lower(), t) for t in chord.split("+")]
            for chord in spec.split(" ")
        ]
    return " ".join("+".join(f"<kbd>{c}</kbd>" for c in chord) for chord in chords)


# ---------------------------------------------------------------------------
# Note type: rich HTML templates + CSS (light & Anki night mode)
# ---------------------------------------------------------------------------

FRONT = """
<div class="card-wrap">
  <div class="badges">
    <span class="badge cat">{{Category}}</span>
    <span class="badge mode">{{Mode}}</span>
  </div>
  <div class="prompt">{{Action}}</div>
  <div class="cue">Which keys?</div>
</div>
"""

BACK = """
<div class="card-wrap">
  <div class="badges">
    <span class="badge cat">{{Category}}</span>
    <span class="badge mode">{{Mode}}</span>
  </div>
  <div class="prompt small">{{Action}}</div>
  <hr id="answer">
  <div class="keys">{{Key}}</div>
  {{#Notes}}<div class="notes">{{Notes}}</div>{{/Notes}}
</div>
"""

CSS = """
.card {
  font-family: -apple-system, "Segoe UI", Roboto, sans-serif;
  background: #faf4ed;
  color: #575279;
  padding: 18px;
}
.nightMode.card { background: #191724; color: #e0def4; }

.card-wrap { max-width: 640px; margin: 0 auto; text-align: center; }

.badges { display: flex; gap: 8px; justify-content: center; margin-bottom: 14px; }
.badge {
  font-size: 12px; font-weight: 600; letter-spacing: .03em;
  padding: 3px 10px; border-radius: 999px; text-transform: uppercase;
}
.badge.cat  { background: #d7827e; color: #fff; }
.badge.mode { background: #56949f; color: #fff; }

.prompt { font-size: 22px; font-weight: 600; line-height: 1.35; }
.prompt.small { font-size: 17px; font-weight: 500; opacity: .8; }
.cue { margin-top: 12px; font-size: 14px; font-style: italic; opacity: .55; }

hr#answer { border: none; border-top: 1px dashed #908caa55; margin: 18px 0; }

.keys { display: flex; gap: 6px; justify-content: center; flex-wrap: wrap; font-size: 22px; }
kbd {
  font-family: "JetBrainsMono Nerd Font", ui-monospace, monospace;
  font-size: 18px; line-height: 1;
  padding: 8px 12px; min-width: 16px;
  background: #fffaf3; color: #575279;
  border: 1px solid #cecacd;
  border-bottom-width: 3px;
  border-radius: 7px;
  box-shadow: 0 1px 0 #cecacd;
}
.nightMode kbd {
  background: #26233a; color: #e0def4;
  border-color: #403d52; box-shadow: 0 1px 0 #403d52;
}

.notes { margin-top: 16px; font-size: 14px; opacity: .7; }
"""


def ensure_deck_tree(root_deck, categories):
    invoke("createDeck", deck=root_deck)
    for cat in categories:
        invoke("createDeck", deck=f"{root_deck}::{cat}")


def ensure_model(model):
    fields = ["Action", "Key", "Mode", "Category", "Notes"]
    template = {"Name": "Recall key", "Front": FRONT, "Back": BACK}
    if model in invoke("modelNames"):
        # Refresh styling + template so design edits here apply on re-run.
        invoke("updateModelStyling", model={"name": model, "css": CSS})
        invoke(
            "updateModelTemplates",
            model={
                "name": model,
                "templates": {template["Name"]: {"Front": FRONT, "Back": BACK}},
            },
        )
        return
    invoke(
        "createModel",
        modelName=model,
        inOrderFields=fields,
        css=CSS,
        isCloze=False,
        cardTemplates=[template],
    )


def _tag(category):
    return category.lower().replace(" / ", "-").replace(" & ", "-").replace(" ", "-")


def _place_cards_in_subdecks(root_deck, model):
    """Move every card of `model` into root_deck::<Category>.

    AnkiConnect's addNotes ignores per-note deckName on some Anki builds (cards
    land in the GUI's selected deck), so we place them authoritatively by id.
    Reading the target from each note's Category field is idempotent on re-runs.
    """
    note_ids = invoke("findNotes", query=f"note:{model}")
    if not note_ids:
        return 0
    by_deck = defaultdict(list)
    for info in invoke("notesInfo", notes=note_ids):
        category = info["fields"]["Category"]["value"]
        by_deck[f"{root_deck}::{category}"].extend(info["cards"])
    for deck, cards in by_deck.items():
        invoke("changeDeck", cards=cards, deck=deck)
    return sum(len(c) for c in by_deck.values())


def push_cards(root_deck, model, cards):
    print(f"AnkiConnect v{invoke('version')} reachable ✓")

    categories = sorted({c[0] for c in cards})
    ensure_deck_tree(root_deck, categories)
    ensure_model(model)

    notes = []
    for category, action, key, mode, notes_txt, source in cards:
        notes.append(
            {
                "deckName": f"{root_deck}::{category}",
                "modelName": model,
                "fields": {
                    "Action": action,
                    "Key": render_key(key),
                    "Mode": mode,
                    "Category": category,
                    "Notes": notes_txt,
                },
                "tags": [root_deck, "keybindings", _tag(category), f"src-{source}"],
                # Collection-wide dedupe: addNotes ignores deckName on some builds
                # (we fix placement below), so a per-deck scope would let re-runs
                # create duplicates.
                "options": {"allowDuplicate": False, "duplicateScope": "collection"},
            }
        )

    addable = invoke("canAddNotes", notes=notes)
    new_notes = [n for n, ok in zip(notes, addable) if ok]
    if new_notes:
        invoke("addNotes", notes=new_notes)

    moved = _place_cards_in_subdecks(root_deck, model)

    print(
        f"Total cards: {len(notes)}  |  added: {len(new_notes)}  |  already present: {len(notes) - len(new_notes)}"
    )
    print(
        f"Deck: '{root_deck}' (subdecks: {', '.join(categories)})  |  cards placed: {moved}"
    )
    print("Tip: sync from the Anki desktop app to push these up to AnkiWeb.")
