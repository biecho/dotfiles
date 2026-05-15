#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec ansible-playbook "$DOTFILES_DIR/ansible/playbook.yml" "$@"
