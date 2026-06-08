#!/usr/bin/env python3
"""Push the Pop!_OS (COSMIC) keybinding deck into Anki via AnkiConnect.

Setup and behavior are documented in ../README.md and ./README.md. Run with
Anki open and the AnkiConnect add-on installed:  python3 anki/popos/push.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from ankipush import push_cards  # noqa: E402
from cards import CARDS  # noqa: E402

if __name__ == "__main__":
    push_cards(root_deck="popos", model="cosmic-keybind", cards=CARDS)
