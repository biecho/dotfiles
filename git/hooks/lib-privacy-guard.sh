#!/bin/bash
# Patterns for what must not enter a public repo: credentials, and paths that
# name the machine a file was written on.
#
# Sourced by pre-commit, which refuses to run without it. This is the sibling
# of lib-ai-guard.sh and deliberately separate: that one guards who a commit
# claims to come from, this one guards what is inside it.

# Credentials in the shapes their issuers actually emit. A generic
# "password=" match is left out on purpose: it fires on documentation and on
# example config, and a hook that cries wolf teaches people to pass
# --no-verify, which costs more than it saves.
PRIVACY_SECRET_RE='-----BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{30,}|xox[baprs]-[0-9A-Za-z-]{10,}|sk-ant-[A-Za-z0-9_-]{20,}|glpat-[A-Za-z0-9_-]{18,}|AIza[0-9A-Za-z_-]{35}|ya29\.[A-Za-z0-9_-]{20,}'

# Absolute home directories, which carry a login name, and the macOS per-user
# temp directory, whose container id pins the machine down more precisely than
# a login name does. Both reached the public history before anyone noticed.
PRIVACY_PATH_RE='/(Users|home)/[A-Za-z0-9._-]+|/var/folders/[A-Za-z0-9_+-]+/[A-Za-z0-9_+-]+'

# Home directories that are placeholders rather than an account. The repo's
# own documentation writes "you".
PRIVACY_ALLOWED_RE='^/(Users|home)/(you|user|username|runner|root)$'

# The offending fragments of one line, placeholders removed. Empty means clean.
privacy_guard_hits() {
    local line="$1"
    local frag

    # -e is required, not stylistic: the private-key pattern starts with a
    # dash, which grep would otherwise read as an option and abort on.
    printf '%s\n' "$line" | grep -oE -e "$PRIVACY_SECRET_RE"

    printf '%s\n' "$line" | grep -oE -e "$PRIVACY_PATH_RE" | while read -r frag; do
        if ! printf '%s\n' "$frag" | grep -qE -e "$PRIVACY_ALLOWED_RE"; then
            printf '%s\n' "$frag"
        fi
    done
}
