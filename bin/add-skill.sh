#!/usr/bin/env bash
# Add a new skill to the marketplace as a git submodule.
#
# Usage:
#   bin/add-skill.sh <plugin-name> <skill-dir-name> <git-url>
#
# Example:
#   bin/add-skill.sh allegro Allegro git@github.com:nuschpl/AI-skills-auctions-Allegro.git
#
# What it does:
#   1. Adds the submodule at plugins/<plugin-name>/skills/<skill-dir-name>/
#   2. Creates plugins/<plugin-name>/.claude-plugin/plugin.json if missing
#   3. Appends an entry to .claude-plugin/marketplace.json
#   4. Prints next-step commit/push instructions
#
# Leaves everything staged but uncommitted so you review before committing.

set -euo pipefail

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <plugin-name> <skill-dir-name> <git-url>" >&2
    echo "Example: $0 allegro Allegro git@github.com:you/AI-skills-auctions-Allegro.git" >&2
    exit 1
fi

PLUGIN_NAME="$1"
SKILL_DIR="$2"
GIT_URL="$3"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

PLUGIN_PATH="plugins/${PLUGIN_NAME}"
SUBMODULE_PATH="${PLUGIN_PATH}/skills/${SKILL_DIR}"
MANIFEST=".claude-plugin/marketplace.json"

if [ -e "$SUBMODULE_PATH" ]; then
    echo "Error: $SUBMODULE_PATH already exists" >&2
    exit 1
fi

# Add submodule
git submodule add "$GIT_URL" "$SUBMODULE_PATH"

# Create plugin.json if absent
mkdir -p "${PLUGIN_PATH}/.claude-plugin"
PLUGIN_JSON="${PLUGIN_PATH}/.claude-plugin/plugin.json"
if [ ! -f "$PLUGIN_JSON" ]; then
    cat > "$PLUGIN_JSON" <<EOF
{
  "name": "${PLUGIN_NAME}",
  "description": "TODO: write one-line description",
  "version": "0.1.0"
}
EOF
    git add "$PLUGIN_JSON"
    echo "Created $PLUGIN_JSON — edit its description before committing."
fi

# Append to marketplace.json (uses python for reliable JSON editing)
python3 - "$MANIFEST" "$PLUGIN_NAME" "$PLUGIN_PATH" <<'PY'
import json, sys
path, name, source = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path) as f:
    data = json.load(f)
if any(p.get("name") == name for p in data.get("plugins", [])):
    sys.exit(0)
data.setdefault("plugins", []).append({
    "name": name,
    "source": f"./{source}",
    "description": "TODO: write one-line description"
})
with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
git add "$MANIFEST"

echo
echo "Submodule added and staged. Next:"
echo "  1. Edit $PLUGIN_JSON and $MANIFEST — set the real description."
echo "  2. git diff --cached"
echo "  3. git commit -m 'Add ${PLUGIN_NAME} plugin'"
echo "  4. git push"
