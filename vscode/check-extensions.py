#!/usr/bin/env python3
"""Fails if settings.json's remote.SSH.defaultExtensions drifts from extensions.txt.

extensions.txt is the source of truth; every entry not marked `# ui` is a
workspace extension and must be auto-installed on Remote-SSH hosts.
"""
import json
import re
import sys
from pathlib import Path

here = Path(__file__).parent

wanted = set()
for line in (here / "extensions.txt").read_text().splitlines():
    ext, _, comment = line.partition("#")
    ext = ext.strip()
    if ext and "ui" not in comment.split():
        wanted.add(ext)

# ponytail: settings.json is JSONC; strip line comments and trailing commas
# instead of adding a json5 dependency. Breaks on a `//` inside a string value.
raw = (here / "settings.json").read_text()
raw = re.sub(r"^\s*//.*$", "", raw, flags=re.M)
raw = re.sub(r",(\s*[}\]])", r"\1", raw)
have = set(json.loads(raw)["remote.SSH.defaultExtensions"])

missing = sorted(wanted - have)
extra = sorted(have - wanted)

for ext in missing:
    print(f"missing from remote.SSH.defaultExtensions: {ext}")
for ext in extra:
    print(f"not in extensions.txt (or marked `# ui`): {ext}")

sys.exit(1 if missing or extra else 0)
