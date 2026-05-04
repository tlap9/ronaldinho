#!/usr/bin/env bash
set -euo pipefail

# Links all skills in the repository to ~/.opencode/skills, so that they can be used by the opencode CLI.
REPO="$(cd "$(dirname "$0")/" && pwd)"
DEST="$HOME/.opencode/skills"

# If ~/.opencode/skills is a symlink that resolves into this repo, we'd end up
# writing the per-skill symlinks into the repo's own skills/ tree. Detecte
# and bail out instead of polluting the work copy.
if [ -L "$DEST" ]; then
    resolved="$(readlink -f "$DEST")"
    case "$resolved" in
        "$REPO"|"$REPO"/*)
            echo "Error: $DEST is a symlink that resolves into this repository. Please remove it and try again."
            echo "Remove it (rm $DEST) and run this script again to link the skills."
            exit 1
            ;;
    esac
fi

mkdir -p "$DEST"

find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -print0 |
while IFS= read -r -d '' skill_md; do
    src="$(dirname "$skill_md")"
    name="$(basename "$src")"
    target="$DEST/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    echo "linked $name to $target"

done