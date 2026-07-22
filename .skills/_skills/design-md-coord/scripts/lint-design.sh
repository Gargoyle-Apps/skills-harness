#!/usr/bin/env bash
set -euo pipefail

# Lint a DESIGN.md file via @google/design.md (Google Labs).
# Pinned: @google/design.md@0.3.0 — bump here and in SKILL.md/quickref when upgrading.
# Usage: lint-design.sh [path/to/DESIGN.md]
# Default path: DESIGN.md in the current working directory.

FILE="${1:-DESIGN.md}"

if [[ ! -f "$FILE" ]]; then
  echo "ERROR: file not found: $FILE" >&2
  exit 2
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "ERROR: npx not found — install Node.js to run @google/design.md linter" >&2
  exit 2
fi

# designmd shim avoids Windows Markdown file-association issues with design.md bin name.
# -y: non-interactive (agents/CI); never prompt to install the package.
exec npx -y -p @google/design.md@0.3.0 designmd lint "$FILE"
