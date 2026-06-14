#!/usr/bin/env python3
"""Push the Neovim keybinding deck into Anki via AnkiConnect.

Setup and behavior are documented in ../README.md and ./README.md. Run with
Anki open and the AnkiConnect add-on installed:  python3 anki/nvim/push.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from ankipush import push_cards  # noqa: E402
from cards import CARDS  # noqa: E402

if __name__ == "__main__":
    # Flat layout: one "nvim" deck. Category survives as a tag and on-card badge.
    push_cards(root_deck="nvim", model="nvim-keybind", cards=CARDS, subdecks=False)
