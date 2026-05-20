#!/usr/bin/env bash
# Mirror Claude Code session transcripts (raw JSONL) to ~/claude-traces/.
# Runnable directly from a shell or via the /export-traces skill.

set -euo pipefail

OUT_DIR="${HOME}/claude-traces"
PROJECTS_DIR="${HOME}/.claude/projects"
SCOPE="current"
LATEST_N=""
SESSION_UUID=""

usage() {
  cat <<'EOF'
Usage: export.sh [--all | --latest N | --session UUID] [--out DIR]

  (default)         Export sessions for the current working directory's project.
  --all             Export every project under ~/.claude/projects/.
  --latest N        Export only the N most recently modified sessions (across all projects).
  --session UUID    Export a single session by UUID.
  --out DIR         Destination directory (default: ~/claude-traces).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)     SCOPE="all"; shift ;;
    --latest)  SCOPE="latest"; LATEST_N="${2:?--latest requires a count}"; shift 2 ;;
    --session) SCOPE="session"; SESSION_UUID="${2:?--session requires a UUID}"; shift 2 ;;
    --out)     OUT_DIR="${2:?--out requires a path}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -d "$PROJECTS_DIR" ]] || { echo "No projects directory at $PROJECTS_DIR" >&2; exit 1; }
mkdir -p "$OUT_DIR"

slugify() { printf '%s' "$1" | sed 's|/|-|g'; }

# Copy a single session by (project-encoded-dir, uuid). Pulls both the
# top-level <uuid>.jsonl and the sibling <uuid>/ directory if present
# (the latter holds subagent transcripts).
copy_session() {
  local proj="$1" uuid="$2"
  local src_jsonl="$PROJECTS_DIR/$proj/$uuid.jsonl"
  local src_subdir="$PROJECTS_DIR/$proj/$uuid"
  local dst="$OUT_DIR/$proj"
  mkdir -p "$dst"
  if [[ -f "$src_jsonl" ]]; then cp -p "$src_jsonl" "$dst/"; fi
  if [[ -d "$src_subdir" ]]; then cp -rp "$src_subdir" "$dst/"; fi
}

count=0
case "$SCOPE" in
  current)
    slug="$(slugify "$PWD")"
    src="$PROJECTS_DIR/$slug"
    if [[ ! -d "$src" ]]; then
      echo "No transcripts for project: $PWD" >&2
      echo "  (looked for: $src)" >&2
      exit 1
    fi
    mkdir -p "$OUT_DIR/$slug"
    cp -rp "$src/." "$OUT_DIR/$slug/"
    count=$(find "$src" -maxdepth 1 -name '*.jsonl' | wc -l)
    ;;
  all)
    cp -rp "$PROJECTS_DIR/." "$OUT_DIR/"
    count=$(find "$PROJECTS_DIR" -maxdepth 2 -name '*.jsonl' | wc -l)
    ;;
  latest)
    while IFS= read -r f; do
      proj_name="$(basename "$(dirname "$f")")"
      uuid="$(basename "$f" .jsonl)"
      copy_session "$proj_name" "$uuid"
      count=$((count + 1))
    done < <(find "$PROJECTS_DIR" -maxdepth 2 -name '*.jsonl' -printf '%T@ %p\n' \
             | sort -nr | head -n "$LATEST_N" | cut -d' ' -f2-)
    ;;
  session)
    found=0
    for f in "$PROJECTS_DIR"/*/"$SESSION_UUID.jsonl"; do
      [[ -f "$f" ]] || continue
      proj_name="$(basename "$(dirname "$f")")"
      copy_session "$proj_name" "$SESSION_UUID"
      found=1; count=1
      break
    done
    [[ "$found" -eq 1 ]] || { echo "Session not found: $SESSION_UUID" >&2; exit 1; }
    ;;
esac

# Write a small manifest at the destination root so the export is self-describing.
{
  printf 'exported_at: %s\n' "$(date -Iseconds)"
  printf 'source: %s\n'      "$PROJECTS_DIR"
  printf 'scope: %s\n'       "$SCOPE"
  printf 'sessions: %s\n'    "$count"
  if [[ -n "$LATEST_N"     ]]; then printf 'latest_n: %s\n' "$LATEST_N"; fi
  if [[ -n "$SESSION_UUID" ]]; then printf 'session_uuid: %s\n' "$SESSION_UUID"; fi
} > "$OUT_DIR/.export-manifest"

size=$(du -sh "$OUT_DIR" 2>/dev/null | cut -f1)
echo "Exported $count session(s) to: $OUT_DIR"
echo "Total size on disk: $size"
