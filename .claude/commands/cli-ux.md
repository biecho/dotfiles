---
description: Audit and improve CLI user experience — help text, error messages, output design, flag conventions, progress feedback, and composition
argument-hint: [--audit-only] [--category <category>] [path-or-module]
allowed-tools: [Read, Bash, Edit, Write, Agent]
---

# /cli-ux — CLI User Experience Audit & Refactor

Analyze the current project's command-line interface against proven UX patterns from
well-regarded tools (ripgrep, cargo, gh, uv, docker, kubectl) and apply improvements.

If `$ARGUMENTS` contains a path or module, scope analysis to that file/directory.
Otherwise auto-discover CLI entry points from the project root.

If `$ARGUMENTS` contains `--audit-only`, produce findings without applying fixes.
If `$ARGUMENTS` contains `--category`, focus on a single category (see categories below).

---

## Phase 1 — Discovery

Identify the CLI framework and entry points:

1. Check `pyproject.toml`, `setup.py`, `setup.cfg`, `Cargo.toml`, `package.json`,
   `go.mod` for declared CLI entry points (`[project.scripts]`, `[[bin]]`, `"bin"`, etc.)
2. Search for CLI framework imports: `argparse`, `click`, `typer`, `clap`, `cobra`,
   `commander`, `yargs`, `structopt`, `argh`
3. Locate the `main()` function or entry point module
4. Map the subcommand tree if any (parsers, groups, subcommands)
5. Identify output/rendering code (Rich, colorama, chalk, termcolor, ansi_term)

Report what was found: framework, entry file(s), subcommand count, estimated CLI
surface area (flags, subcommands, output modes).

---

## Phase 2 — Audit

Analyze each category below. For every issue found, record a finding with:
- **ID**: `CU-{category_prefix}-{N}` (e.g. `CU-HELP-1`)
- **Severity**: Critical / High / Medium / Low
- **File:line**: Where the issue lives
- **Pattern**: Which best-practice pattern is violated
- **Current**: What the code does now (quote the code)
- **Recommended**: What it should do instead (concrete code or description)

### Categories and Checklist

#### HELP — Help Text & Self-Documentation
- [ ] `--help` produces a short description, usage line, and grouped flags
- [ ] Subcommands have their own help with usage examples
- [ ] Help text includes at least one concrete example per subcommand
- [ ] Flag descriptions are specific, not generic ("Emit JSON to stdout" not "Output format")
- [ ] Mutually exclusive flags are documented or enforced by the parser
- [ ] Default values are shown in help text (e.g. `[default: 8]`)
- [ ] `prog` name matches the installed entry point (not `__main__.py`)
- [ ] Version flag (`--version` / `-V`) is present
- [ ] Usage line reads as a grammar with variants (ripgrep pattern):
  ```
  USAGE:
      tool [OPTIONS] PATTERN [PATH ...]
      command | tool [OPTIONS] PATTERN
  ```
- [ ] Shell completions are generatable (`tool --completions bash/zsh/fish`)
- [ ] Subcommands are grouped by frequency/domain, not just alphabetical

#### ERR — Error Messages & Exit Codes
- [ ] Errors print to stderr, not stdout
- [ ] Error messages include context: what failed, why, and what to try
  ```
  BAD:  "Error: invalid input"
  GOOD: "error: --max-depth must be a non-negative integer, got '-3'"
  ```
- [ ] Parser errors suggest the closest valid flag (did-you-mean)
- [ ] Exit codes follow convention: 0=success, 1=runtime error, 2=usage error
- [ ] Exceptions are caught and translated to human messages (no raw tracebacks to users)
- [ ] File-not-found errors show the resolved path that was tried
- [ ] When a required tool/dependency is missing, name it and suggest how to install
- [ ] Distinct exit codes for "no results" (1) vs "error" (2) where applicable
  (ripgrep: 0=matches found, 1=no matches, 2=error)

#### OUTPUT — Output Design & Formatting
- [ ] Machine-readable output available via `--json` or `--format json`
- [ ] `--json` with no value lists available fields (self-documenting, gh pattern)
- [ ] JSON goes to stdout; progress/status goes to stderr
- [ ] Human output uses color when attached to a terminal, plain when piped
  (check `sys.stdout.isatty()` or Rich's `Console(force_terminal=...)`)
- [ ] Tables align columns and truncate/wrap long values
- [ ] Large output is paginated or streamable (not buffered then dumped)
- [ ] Empty results produce a clear message, not silent exit
- [ ] Counts and summaries appear at the end for scannable output
- [ ] Long output auto-pages via `$PAGER` when connected to a tty
- [ ] `NO_COLOR` and `FORCE_COLOR` environment variables are respected
- [ ] `TERM=dumb` disables all formatting (not just color)

#### FLAGS — Flag & Argument Conventions
- [ ] Short flags exist for frequently-used options (`-v`, `-q`, `-o`, `-n`)
- [ ] Long flags use `--kebab-case` (not `--snake_case` or `--camelCase`)
- [ ] Boolean flags don't require a value (`--verbose`, not `--verbose=true`)
- [ ] Boolean flags support `--no-` negation (`--[no-]color`) for config overrides
- [ ] `--` separates flags from positional arguments
- [ ] Conflicting flags are caught early with clear errors
- [ ] Env var overrides exist for flags that users set repeatedly
  (document them in `--help`: `[env: PYBINMAP_MAX_DEPTH=]`)
- [ ] Config file support for complex flag sets (XDG Base Directory: `~/.config/<tool>/`)

#### PROGRESS — Progress & Feedback
- [ ] Long operations (>1s) show a spinner, progress bar, or status line
- [ ] Progress output goes to stderr so stdout stays clean for piping
- [ ] Spinners/bars are suppressed when not attached to a terminal
- [ ] ETA or completion percentage is shown when total is knowable
- [ ] Phase transitions are visible (e.g. "Scanning... → Analyzing... → Done")
- [ ] `--quiet` / `-q` suppresses progress; `--verbose` / `-v` adds detail
- [ ] Ctrl+C produces a clean exit with partial results if applicable

#### COMPOSE — Composition & Pipeline Friendliness
- [ ] stdout contains only the primary output (data, results)
- [ ] stderr contains diagnostics, progress, warnings
- [ ] Exit codes are meaningful and documented
- [ ] stdin is accepted where it makes sense (e.g. reading a file list)
- [ ] `--quiet` mode exists for scripting (suppress non-essential output)
- [ ] Output is line-oriented or structured (JSON) for downstream parsing
- [ ] Tool works correctly when stdout is not a terminal (no ANSI in pipes)

#### ARCH — CLI Architecture (Clean Architecture patterns)
- [ ] CLI entry point is thin: parse args → call domain logic → render output
- [ ] Presentation (rendering/formatting) is separated from business logic
- [ ] I/O (network, filesystem) is extracted behind interfaces/callbacks
- [ ] Progress reporting uses dependency injection (Humble Object pattern)
- [ ] No duplicated utility functions across modules
- [ ] Domain logic is testable without the CLI layer

---

## Phase 3 — Report

Write findings to a structured summary. Group by category, sorted by severity.
Include:

1. **Scorecard**: Count of findings per category and severity
2. **Findings table**: ID, severity, file:line, one-line description
3. **Architecture diagram**: If ARCH findings exist, show current vs recommended
   module structure (ASCII box diagram)

Print the scorecard and top 5 findings to the console. If `--audit-only` was
specified, stop here.

Example scorecard format:
```
CLI UX Audit — 12 findings across 5 categories

  HELP     ██░░  2 findings (1 High, 1 Med)
  ERR      ████  4 findings (2 High, 2 Med)
  OUTPUT   █░░░  1 finding  (1 Low)
  FLAGS    ██░░  2 findings (1 Med, 1 Low)
  PROGRESS ███░  3 findings (1 Critical, 1 High, 1 Med)
  COMPOSE  ░░░░  0 findings
  ARCH     ░░░░  0 findings
```

---

## Phase 4 — Fix

Apply fixes in priority order: Critical → High → Medium. Skip Low unless
the user opts in.

For each fix:
1. State the finding ID and what will change
2. Apply the edit
3. Verify: if the change affects argument parsing or output, run the CLI
   with `--help` or a smoke test to confirm it still works

Group related fixes into logical commits if the user requests a commit.

### Fix Patterns by Category

**HELP fixes**: Add `epilog` with examples, add `%(default)s` to help strings,
add `--version` action, improve `metavar` names.

**ERR fixes**: Wrap `main()` in try/except that catches domain exceptions and
prints to stderr with context. Add `sys.exit(1)` for errors, `sys.exit(2)` for
usage. Use `parser.error()` for argument validation.

**OUTPUT fixes**: Add `--json` flag with `json.dump()` to stdout. Use
`Console(stderr=True)` for status. Add `isatty()` checks or let Rich handle it
via `Console(force_terminal=None)`.

**FLAGS fixes**: Rename `--snake_case` to `--kebab-case` (add deprecated aliases
for backward compat). Add short flags for common options. Add
`add_mutually_exclusive_group()` for conflicting flags.

**PROGRESS fixes**: Extract progress into a Humble Object pattern (see pybinmap's
`InspectProgress` and `InstallEtaEstimator`). Use `Rich.Progress` with
`SpinnerColumn + TextColumn + TimeElapsedColumn`. Print to stderr via
`Console(stderr=True)`.

**COMPOSE fixes**: Ensure `Console()` for data output and `Console(stderr=True)`
for diagnostics. Add `--quiet` flag. Respect `NO_COLOR`.

**ARCH fixes**: Follow the pybinmap Clean Architecture pattern:
- Extract rendering into `render.py` (all Rich/formatting code)
- Extract I/O clients into dedicated modules (`*_client.py`)
- Extract progress/ETA into Humble Objects (`eta.py`)
- Use dependency injection (callbacks) for side-effecting operations
- Consolidate duplicated helpers into domain modules
- Target: CLI entry point under 400 lines, focused on parse → orchestrate → output

---

## Phase 5 — Verify

After fixes are applied:
1. Run `--help` for every subcommand and verify output looks correct
2. Run with `--json` if added, verify valid JSON output
3. Run with `2>/dev/null` to verify stdout/stderr separation
4. If tests exist, run the test suite
5. Report the final state: how many findings were fixed, any remaining

---

## Reference: Exemplary CLI Patterns

### Startup Performance (Python-specific)
- Use lazy imports inside subcommand handlers, not at module top
- Avoid importing heavy libraries (Rich, requests) until needed
- Replace `pkg_resources` with `importlib.metadata` (~200ms savings)
- Consider `__main__.py` with `if __name__ == "__main__"` for `-m` invocation
- Profile startup with `python -X importtime -m tool 2>import.log`

### Error Message Quality (from rustc/cargo/elm)
```
error: unknown flag '--verbos'

  Did you mean '--verbose'?

  For more information, try '--help'
```

### Help Text with Examples (from ripgrep/gh)
```
EXAMPLES:
    pybinmap scan --package numpy --checksec
        Scan numpy and show ELF hardening details

    pybinmap inspect "cryptography>=42" --vulns --json | jq '.nodes[] | select(.vulns)'
        Inspect cryptography and filter vulnerable nodes
```

### Progress to stderr (from cargo/uv)
Progress, spinners, and status lines always go to stderr so that:
```bash
pybinmap inspect numpy --json > graph.json    # progress visible, JSON clean
pybinmap inspect numpy --json 2>/dev/null      # silence progress
pybinmap inspect numpy --json | jq .           # piping works correctly
```

### NO_COLOR Support
```python
import os
force_color = None  # let Rich auto-detect
if os.environ.get("NO_COLOR") is not None:
    force_color = False
if os.environ.get("FORCE_COLOR"):
    force_color = True
console = Console(force_terminal=force_color)
```

### Config File Location (XDG compliant)
```python
from pathlib import Path
import os
config_dir = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "tool"
cache_dir = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "tool"
```

### Precedence Ladder
Flags > env vars > config file > defaults — always. Document this in `--help`.
