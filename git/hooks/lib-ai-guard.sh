#!/bin/bash
# Shared vocabulary for the hooks that keep AI-assistant traces out of the
# history. Sourced by commit-msg and pre-push; each of them refuses to run if
# this file is missing, so a half-deployed dotfiles tree fails closed instead
# of waving everything through.
#
# Extend the pattern HERE, in one place. Keep every alternative long enough
# that it cannot collide with an ordinary word: a bare "ai" matches "gmail".

AI_PATTERN='claude|anthropic'

# Names that match the pattern but are ordinary things to write about. CLAUDE.md
# is a real file in several of these repos; a commit that edits it has to be
# able to say so.
AI_ALLOWED='CLAUDE\.md'

# The lines of a commit message that actually name an AI assistant, with the
# allowed names removed first. Empty output means the message is clean.
ai_guard_message_hits() {
    printf '%s\n' "$1" | sed -E "s/$AI_ALLOWED//g" | grep -iE "$AI_PATTERN"
}

# The "Name <mail>" pair git is about to record, as author and as committer.
# `git var` is what makes this worth checking: it honours --author and the
# GIT_AUTHOR_*/GIT_COMMITTER_* environment, neither of which ever passes
# through the commit message.
ai_guard_idents() {
    git var GIT_AUTHOR_IDENT    | sed 's/ [0-9][0-9]* [+-][0-9][0-9]*$//'
    git var GIT_COMMITTER_IDENT | sed 's/ [0-9][0-9]* [+-][0-9][0-9]*$//'
}
