#!/usr/bin/env bash
# Sync every submodule to the tip of its default branch.
#
# Leaves the marketplace repo with staged submodule-pointer bumps so you can
# review the diff before committing.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

git submodule update --init --remote --merge

echo
echo "Submodule pointers after update:"
git submodule status

echo
echo "Staged changes:"
git add -A
git diff --cached --stat

cat <<'EOF'

Next:
  git diff --cached       # review which skills moved forward
  git commit -m 'Bump submodules'
  git push
EOF
