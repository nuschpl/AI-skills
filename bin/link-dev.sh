#!/usr/bin/env bash
# Point ~/.claude/skills/<skill-dir-name> at the submodule checkout inside
# this marketplace repo, so edits you make here are live in every Claude
# Code session user-wide.
#
# Usage:
#   bin/link-dev.sh <skill-dir-name>
#
# Example:
#   bin/link-dev.sh OLX
#
# Removes any existing entry at ~/.claude/skills/<skill-dir-name> only if it
# is already a symlink; refuses to overwrite a real directory.

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <skill-dir-name>" >&2
    exit 1
fi

SKILL_DIR="$1"
ROOT="$(git rev-parse --show-toplevel)"

# Find the submodule path matching this skill name (first hit wins).
TARGET="$(find "$ROOT/plugins" -type d -name "$SKILL_DIR" -path "*/skills/*" | head -n1)"
if [ -z "$TARGET" ] || [ ! -d "$TARGET" ]; then
    echo "Error: no skills/$SKILL_DIR/ submodule found under $ROOT/plugins/" >&2
    echo "Did you forget 'git submodule update --init'?" >&2
    exit 1
fi

LINK="$HOME/.claude/skills/$SKILL_DIR"
mkdir -p "$HOME/.claude/skills"

if [ -L "$LINK" ]; then
    rm "$LINK"
elif [ -e "$LINK" ]; then
    echo "Error: $LINK exists and is not a symlink — refusing to overwrite." >&2
    echo "Remove or back it up manually, then re-run." >&2
    exit 1
fi

ln -s "$TARGET" "$LINK"
echo "Linked $LINK -> $TARGET"
