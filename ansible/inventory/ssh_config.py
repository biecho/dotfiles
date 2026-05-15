#!/usr/bin/env python3
"""Ansible dynamic inventory from OpenSSH Host aliases.

This intentionally emits host aliases only. OpenSSH still resolves HostName,
User, Port, IdentityFile, ProxyJump, and other connection details from the
normal SSH config when Ansible opens the SSH connection.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import shlex
from pathlib import Path
from typing import Iterable


WILDCARD_CHARS = set("*?[]")


def split_config_line(line: str) -> list[str]:
    line = line.strip()
    if not line or line.startswith("#"):
        return []

    try:
        return shlex.split(line, comments=True, posix=True)
    except ValueError:
        return []


def is_concrete_host(pattern: str) -> bool:
    return (
        bool(pattern)
        and not pattern.startswith("!")
        and not any(char in pattern for char in WILDCARD_CHARS)
    )


def include_candidates(pattern: str, current_file: Path) -> Iterable[Path]:
    expanded = os.path.expandvars(os.path.expanduser(pattern))
    path = Path(expanded)
    if not path.is_absolute():
        path = current_file.parent / path

    for match in glob.glob(str(path)):
        candidate = Path(match)
        if candidate.is_file():
            yield candidate


def collect_hosts(config_file: Path, seen: set[Path] | None = None) -> set[str]:
    seen = seen or set()
    config_file = config_file.expanduser().resolve()
    if config_file in seen or not config_file.is_file():
        return set()

    seen.add(config_file)
    hosts: set[str] = set()

    for raw_line in config_file.read_text(encoding="utf-8", errors="ignore").splitlines():
        parts = split_config_line(raw_line)
        if not parts:
            continue

        keyword = parts[0].lower()
        values = parts[1:]

        if keyword == "include":
            for include_pattern in values:
                for include_file in include_candidates(include_pattern, config_file):
                    hosts.update(collect_hosts(include_file, seen))
        elif keyword == "host":
            hosts.update(pattern for pattern in values if is_concrete_host(pattern))

    return hosts


def build_inventory(config_path: Path) -> dict[str, object]:
    hosts = sorted(collect_hosts(config_path))
    return {
        "_meta": {
            "hostvars": {
                host: {
                    "ansible_host": host,
                }
                for host in hosts
            },
        },
        "ssh_config": {
            "hosts": hosts,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--list", action="store_true")
    parser.add_argument("--host")
    parser.add_argument(
        "--config",
        default=os.environ.get("SSH_CONFIG", "~/.ssh/config"),
        help="SSH config path. Defaults to SSH_CONFIG or ~/.ssh/config.",
    )
    args = parser.parse_args()

    if args.host:
        print(json.dumps({}))
        return

    print(json.dumps(build_inventory(Path(args.config)), indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
