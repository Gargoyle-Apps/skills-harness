#!/usr/bin/env bash
set -euo pipefail

# Deploy the caveman skill trio (caveman, caveman-commit, caveman-review) to an
# IDE config location so it is available across all your projects — not just this repo.
#
# Repo harness skills load on-demand (trigger match). A config-level skill is
# available everywhere but is still on-demand. To get the always-on token savings
# (caveman on EVERY response), pass --always-on, which also writes a rule/memory
# entry the IDE injects each turn.
#
# Usage:
#   deploy.sh <target> [--always-on [DIR]] [--level LVL] [--copy] [--uninstall] [--dry-run]
#
# Targets:
#   cursor   Symlink trio into ~/.cursor/skills/   (override: CURSOR_SKILLS_DIR)
#   claude   Symlink trio into ~/.claude/skills/   (override: CLAUDE_SKILLS_DIR)
#
# Options:
#   --always-on [DIR]  Also install an always-on directive.
#                        cursor: writes <DIR>/.cursor/rules/caveman.mdc (alwaysApply);
#                                DIR defaults to the current directory (per-project).
#                        claude: appends a marker block to ~/.claude/CLAUDE.md (global).
#   --level LVL        Default intensity baked into the always-on rule. One of:
#                        lite | full | ultra | wenyan-lite | wenyan-full | wenyan-ultra.
#                        Only meaningful with --always-on. Omit for caveman's default (full).
#   --copy             Copy files instead of symlinking (self-contained; survives repo deletion).
#   --uninstall        Remove the trio (and any always-on artifacts) for the target.
#                        For cursor, pass the project DIR to also remove its rule:
#                        deploy.sh cursor --uninstall <DIR>  (DIR defaults to cwd).
#   --dry-run          Print actions without touching the filesystem.
#   -h, --help         Show this help.
#
# Notes:
#   - Symlinks point back to this repo, so edits here propagate to the deployed copy.
#   - Cursor global user rules are UI-only and cannot be scripted; --always-on for
#     cursor is therefore per-project (.cursor/rules). Claude Code supports true
#     global always-on via ~/.claude/CLAUDE.md.
#   - Idempotent: safe to re-run. Marker block is not duplicated.

TRIO=(caveman caveman-commit caveman-review)
BEGIN_MARKER="<!-- caveman-begin -->"
END_MARKER="<!-- caveman-end -->"
CAVEMAN_LEVELS="lite full ultra wenyan-lite wenyan-full wenyan-ultra"

# Always-on rule body, mirroring caveman's own src/rules/caveman-activate.md
# (MIT, JuliusBrussee/caveman). Emits an optional leading "Start in <level>" line
# when LEVEL is set. Shared verbatim by the Cursor rule file and the Claude memory block.
rule_body() {
  if [[ -n "${LEVEL:-}" ]]; then
    printf 'Start in %s mode (as if the user ran /caveman %s).\n\n' "$LEVEL" "$LEVEL"
  fi
  cat <<'BODY'
Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:
- Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
- Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
- Pattern: [thing] [action] [reason]. [next step].
- Not: "Sure! I'd be happy to help you with that."
- Yes: "Bug in auth middleware. Fix:"

Switch level: /caveman lite|full|ultra|wenyan
Stop: "stop caveman" or "normal mode"

Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

Boundaries: code/commits/PRs written normal.
BODY
}

# Print the leading comment header as help (stops at first non-comment line).
usage() { awk '/^#!/||/^set /{next} /^#/{sub(/^# ?/,"");print;h=1;next} h{exit}' "$0"; }

# --- Resolve this repo's _skills root (two levels up from this script) ---
script_src="${BASH_SOURCE[0]:-$0}"
script_dir="$(cd "$(dirname "$script_src")" && pwd -P)"
SKILLS_ROOT="$(cd "$script_dir/.." && pwd -P)"

for name in "${TRIO[@]}"; do
  if [[ ! -f "$SKILLS_ROOT/$name/SKILL.md" ]]; then
    echo "ERROR: expected skill not found: $SKILLS_ROOT/$name/SKILL.md" >&2
    exit 1
  fi
done

# --- Parse args ---
TARGET=""
ALWAYS_ON=false
ALWAYS_ON_DIR=""
LEVEL=""
DO_COPY=false
UNINSTALL=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    cursor|claude) TARGET="$1"; shift ;;
    --always-on)
      ALWAYS_ON=true; shift
      if [[ $# -gt 0 && "$1" != --* && "$1" != "cursor" && "$1" != "claude" ]]; then
        ALWAYS_ON_DIR="$1"; shift
      fi
      ;;
    --level)
      shift
      [[ $# -gt 0 ]] || { echo "ERROR: --level needs a value ($CAVEMAN_LEVELS)" >&2; exit 1; }
      LEVEL="$1"; shift
      ;;
    --copy) DO_COPY=true; shift ;;
    --uninstall) UNINSTALL=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      # Bare path after the target = the project dir (e.g. for --uninstall's rule cleanup).
      if [[ -n "$TARGET" && -z "$ALWAYS_ON_DIR" && "$1" != -* ]]; then
        ALWAYS_ON_DIR="$1"; shift
      else
        echo "Unknown argument: $1" >&2; echo "Run with --help." >&2; exit 1
      fi
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "ERROR: no target given (cursor|claude). Run with --help." >&2
  exit 1
fi

if [[ -n "$LEVEL" ]]; then
  level_ok=false
  for l in $CAVEMAN_LEVELS; do [[ "$l" == "$LEVEL" ]] && level_ok=true && break; done
  if ! $level_ok; then
    echo "ERROR: invalid --level '$LEVEL' (allowed: $CAVEMAN_LEVELS)" >&2
    exit 1
  fi
  if ! $ALWAYS_ON && ! $UNINSTALL; then
    echo "WARN:  --level only affects the always-on rule; add --always-on to apply it." >&2
  fi
fi

case "$TARGET" in
  cursor) SKILLS_DIR="${CURSOR_SKILLS_DIR:-$HOME/.cursor/skills}" ;;
  claude) SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}" ;;
esac

run() {
  if $DRY_RUN; then
    echo "  [dry-run] $*"
  else
    eval "$*"
  fi
}

# --- Uninstall ---
if $UNINSTALL; then
  echo "Uninstalling caveman trio from $TARGET ($SKILLS_DIR)"
  for name in "${TRIO[@]}"; do
    dest="$SKILLS_DIR/$name"
    if [[ -e "$dest" || -L "$dest" ]]; then
      run "rm -rf \"$dest\""
      echo "  removed $dest"
    fi
  done

  if [[ "$TARGET" == "cursor" ]]; then
    rule_dir="${ALWAYS_ON_DIR:-$PWD}/.cursor/rules"
    rule_file="$rule_dir/caveman.mdc"
    if [[ -f "$rule_file" ]]; then
      run "rm -f \"$rule_file\""
      echo "  removed always-on rule $rule_file"
    fi
  else
    mem="$HOME/.claude/CLAUDE.md"
    if [[ -f "$mem" ]] && grep -qF "$BEGIN_MARKER" "$mem"; then
      run "sed -i.bak '/$BEGIN_MARKER/,/$END_MARKER/d' \"$mem\" && rm -f \"$mem.bak\""
      echo "  removed always-on block from $mem"
    fi
  fi
  echo "Done."
  exit 0
fi

# --- Install skills ---
echo "Deploying caveman trio to $TARGET ($SKILLS_DIR)"
run "mkdir -p \"$SKILLS_DIR\""

for name in "${TRIO[@]}"; do
  src="$SKILLS_ROOT/$name"
  dest="$SKILLS_DIR/$name"

  # Clear any prior entry so re-runs are clean.
  if [[ -e "$dest" || -L "$dest" ]]; then
    run "rm -rf \"$dest\""
  fi

  if $DO_COPY; then
    run "cp -R \"$src\" \"$dest\""
    echo "  copied  $name -> $dest"
  else
    run "ln -s \"$src\" \"$dest\""
    echo "  linked  $name -> $dest"
  fi
done

# --- Always-on ---
if $ALWAYS_ON; then
  if [[ "$TARGET" == "cursor" ]]; then
    proj="${ALWAYS_ON_DIR:-$PWD}"
    rule_dir="$proj/.cursor/rules"
    rule_file="$rule_dir/caveman.mdc"
    echo "Writing always-on rule: $rule_file (per-project${LEVEL:+, level=$LEVEL})"
    run "mkdir -p \"$rule_dir\""
    if $DRY_RUN; then
      echo "  [dry-run] write $rule_file"
    else
      {
        printf -- '---\n'
        printf 'description: Always-on caveman compression%s\n' "${LEVEL:+ ($LEVEL)}"
        printf 'alwaysApply: true\n'
        printf -- '---\n\n'
        rule_body
      } > "$rule_file"
    fi
    echo "  note: Cursor global user rules are UI-only; this rule applies to $proj only."
  else
    mem="$HOME/.claude/CLAUDE.md"
    echo "Adding always-on block to global memory: $mem${LEVEL:+ (level=$LEVEL)}"
    run "mkdir -p \"$(dirname "$mem")\""
    if [[ -f "$mem" ]] && grep -qF "$BEGIN_MARKER" "$mem"; then
      echo "  block already present; skipping (idempotent). Re-run --uninstall then --always-on to change level."
    elif $DRY_RUN; then
      echo "  [dry-run] append caveman block to $mem"
    else
      {
        printf '\n%s\n' "$BEGIN_MARKER"
        rule_body
        printf '%s\n' "$END_MARKER"
      } >> "$mem"
      echo "  appended block."
    fi
  fi
else
  echo "Skills installed on-demand (trigger match). Re-run with --always-on for every-response savings."
fi

echo "Done."
