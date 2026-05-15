#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

has_limit=false
for arg in "$@"; do
    case "$arg" in
        -l|--limit|--limit=*)
            has_limit=true
            break
            ;;
    esac
done

if "$has_limit"; then
    exec ansible-playbook "$DOTFILES_DIR/ansible/playbook.yml" "$@"
else
    exec ansible-playbook "$DOTFILES_DIR/ansible/playbook.yml" --limit local "$@"
fi
