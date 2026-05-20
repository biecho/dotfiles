---
description: Export Claude Code session transcripts (raw JSONL) to ~/claude-traces/
argument-hint: [--all] [--latest N] [--session UUID] [--out DIR]
allowed-tools: [Bash]
---

# /export-traces — Mirror Claude Code transcripts to disk

Copies session JSONL transcripts (and their subagent transcripts) from
`~/.claude/projects/` to `~/claude-traces/`. Format is preserved exactly
as Claude Code wrote it — no transformation, no redaction. Re-running
overwrites prior exports for the same session, so an export run is always
a current snapshot.

## Defaults

- Destination: `~/claude-traces/<project-slug>/`
- Scope: the current working directory's project only
  (`pwd` with `/` replaced by `-`)

## Flags

| Flag | Effect |
|---|---|
| (none) | Export the current project's sessions |
| `--all` | Export every project under `~/.claude/projects/` |
| `--latest N` | Only the N most recently modified sessions (across all projects) |
| `--session UUID` | A single specific session |
| `--out DIR` | Override the destination directory |

## What to do when invoked

Run this single command, passing arguments through unchanged. Then print
**only** the two summary lines from its stdout to the user; do not call
any other tools.

```bash
bash "$HOME/.dotfiles/.claude/commands/export-traces/export.sh" $ARGUMENTS
```

If the script exits non-zero, surface its stderr verbatim to the user.

## Running it without Claude Code

The same script is callable directly from a shell:

```bash
bash ~/.dotfiles/.claude/commands/export-traces/export.sh --latest 5
```
