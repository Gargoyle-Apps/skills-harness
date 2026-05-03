#!/usr/bin/env bash
set -euo pipefail

# migrate-to-subtree.sh
# Migrate an existing manual skills-harness install (file-copy or earlier kit
# version) to a git-subtree install at .skills-harness/. Safe by default:
#
#   * Reports planned actions; never destroys consumer-authored skills.
#   * Audits drift in kit-owned files (scripts, _rules.md, bundled skills),
#     consumer-skill prefix convention (per skill-author), and consumer-skill
#     frontmatter required fields.
#   * --apply flag actually performs reversible migrations:
#       - Adds the subtree at .skills-harness/ (one squash commit).
#       - Backs up the old .skills/_harness/ to .skills/_harness.bak/ and
#         replaces it with a symlink into the subtree.
#       - For each upstream-bundled kit skill: backs up the local copy to
#         .skills/_skills/<name>.bak/ and replaces with a symlink into the
#         subtree. Skips this replacement if the local copy has uncommitted
#         changes vs. the upstream copy AND --force is not set; reports the
#         drift instead so a human can review.
#       - Never touches consumer-authored skills, .skills/_index.md, or
#         .skills/_meta.yml — those are reconciled manually and the script
#         prints exact next steps.
#
# Compatibility: bash 3.2 (macOS /bin/bash), POSIX find/diff/git, no GNU-isms.
#
# Usage:
#   .skills/_harness/migrate-to-subtree.sh [--apply] [--force] \
#       [--remote-name <name>] [--remote-url <url>] [--ref <ref>] \
#       [--prefix <dir>]
#
# Defaults:
#   remote-name = skills-harness
#   remote-url  = repo_url from .skills/_meta.yml (required if not present)
#   ref         = main
#   prefix      = .skills-harness

APPLY=false
FORCE=false
REMOTE_NAME="skills-harness"
REMOTE_URL=""
REF="main"
PREFIX=".skills-harness"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=true ;;
    --force) FORCE=true ;;
    --remote-name) REMOTE_NAME="$2"; shift ;;
    --remote-url) REMOTE_URL="$2"; shift ;;
    --ref) REF="$2"; shift ;;
    --prefix) PREFIX="$2"; shift ;;
    -h|--help)
      sed -n '3,40p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "ERROR: unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

HARNESS_DIR="${SKILLS_HARNESS_DIR:-$(cd "$(dirname "$0")" && pwd)}"
SKILLS_DIR="${SKILLS_DIR:-$(dirname "$HARNESS_DIR")/_skills}"
REPO_ROOT="${SKILLS_REPO_ROOT:-$(dirname "$(dirname "$HARNESS_DIR")")}"
META_FILE="$(dirname "$HARNESS_DIR")/_meta.yml"

cd "$REPO_ROOT"

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

note() { printf '%s\n' "$*"; }
plan() { printf '  PLAN  %s\n' "$*"; }
do_  () { printf '  DO    %s\n' "$*"; }
warn () { printf '  WARN  %s\n' "$*" >&2; }
err  () { printf '  ERROR %s\n' "$*" >&2; ((++ERRORS)) || true; }

ERRORS=0

# --- Preconditions ---

if [[ ! -d ".git" ]]; then
  echo "ERROR: must be run from a git repository root (no .git/ here)." >&2
  exit 1
fi
if [[ ! -d ".skills" ]]; then
  echo "ERROR: no .skills/ directory found. There is nothing to migrate." >&2
  exit 1
fi
if [[ -e "$PREFIX" ]]; then
  echo "ERROR: $PREFIX already exists. Either you already migrated, or pass --prefix." >&2
  exit 1
fi
if $APPLY; then
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "ERROR: working tree is dirty. Commit or stash before --apply." >&2
    exit 1
  fi
fi

if [[ -z "$REMOTE_URL" && -f "$META_FILE" ]]; then
  raw="$(grep -E '^repo_url:' "$META_FILE" | head -1 | sed 's/^repo_url://' || true)"
  raw="$(trim "$raw")"
  raw="${raw#\"}"; raw="${raw%\"}"
  REMOTE_URL="$raw"
fi
if [[ -z "$REMOTE_URL" ]]; then
  echo "ERROR: no upstream URL. Pass --remote-url or set repo_url in .skills/_meta.yml." >&2
  exit 1
fi

note "skills-harness migrate-to-subtree"
note "  repo root  : $REPO_ROOT"
note "  upstream   : $REMOTE_URL ($REF)"
note "  subtree at : $PREFIX"
note "  mode       : $($APPLY && echo APPLY || echo dry-run)"
note ""

# --- Step 1: add subtree (apply only) -----------------------------------------

SUBTREE_SKILLS=""
add_subtree() {
  if ! git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
    do_ "git remote add $REMOTE_NAME $REMOTE_URL"
    git remote add "$REMOTE_NAME" "$REMOTE_URL"
  fi
  do_ "git fetch $REMOTE_NAME"
  git fetch "$REMOTE_NAME" --quiet
  do_ "git subtree add --prefix=$PREFIX $REMOTE_NAME $REF --squash"
  git subtree add --prefix="$PREFIX" "$REMOTE_NAME" "$REF" --squash --message "subtree: vendor skills-harness ($REF)" >/dev/null
}

if $APPLY; then
  add_subtree
  SUBTREE_SKILLS="$PREFIX/.skills/_skills"
else
  plan "git remote add $REMOTE_NAME $REMOTE_URL  (if missing)"
  plan "git fetch $REMOTE_NAME"
  plan "git subtree add --prefix=$PREFIX $REMOTE_NAME $REF --squash"
  note "  (dry-run cannot inspect upstream-bundled kit skills until --apply runs the subtree add;"
  note "   drift checks below use a built-in fallback list of known kit skills)"
  note ""
fi

# --- Step 2: determine the set of upstream-bundled kit skills -----------------

KIT_SKILL_NAMES=""
if [[ -n "$SUBTREE_SKILLS" && -d "$SUBTREE_SKILLS" ]]; then
  for d in "$SUBTREE_SKILLS"/*/; do
    [[ -d "$d" ]] || continue
    KIT_SKILL_NAMES="$KIT_SKILL_NAMES $(basename "$d")"
  done
else
  # Fallback for dry-run: known-bundled kit skills as of 0.6.0+.
  # Update this list when the upstream kit adds or removes bundled skills.
  KIT_SKILL_NAMES="harness-subtree harness-upgrade kit-release skill-author skill-template"
fi

is_kit_skill() {
  local name="$1" k
  for k in $KIT_SKILL_NAMES; do
    [[ "$k" == "$name" ]] && return 0
  done
  return 1
}

# --- Step 3: replace .skills/_harness/ with a symlink into the subtree --------

migrate_harness_dir() {
  local target_rel="../$PREFIX/.skills/_harness"
  local local_dir=".skills/_harness"
  if [[ -L "$local_dir" ]]; then
    note "  ok    .skills/_harness is already a symlink"
    return
  fi
  if [[ ! -d "$local_dir" ]]; then
    plan "create symlink $local_dir -> $target_rel"
    if $APPLY; then ln -s "$target_rel" "$local_dir"; do_ "linked $local_dir"; fi
    return
  fi
  if $APPLY; then
    do_ "backup $local_dir -> $local_dir.bak"
    mv "$local_dir" "$local_dir.bak"
    do_ "ln -s $target_rel $local_dir"
    ln -s "$target_rel" "$local_dir"
  else
    plan "backup .skills/_harness -> .skills/_harness.bak then symlink to $target_rel"
  fi
}

note "Step: kit-owned harness directory (.skills/_harness/)"
migrate_harness_dir
note ""

# --- Step 4: process each kit-bundled skill -----------------------------------

migrate_kit_skill() {
  local name="$1"
  local local_path=".skills/_skills/$name"
  local target_rel="../../$PREFIX/.skills/_skills/$name"

  if [[ -L "$local_path" ]]; then
    note "  ok    $name (already symlink)"
    return
  fi
  if [[ ! -d "$local_path" ]]; then
    plan "create symlink $local_path -> $target_rel"
    if $APPLY; then ln -s "$target_rel" "$local_path"; do_ "linked $local_path"; fi
    return
  fi

  # Compare to upstream copy if the subtree exists yet.
  if [[ -n "$SUBTREE_SKILLS" && -d "$SUBTREE_SKILLS/$name" ]]; then
    if diff -r -q "$local_path" "$SUBTREE_SKILLS/$name" >/dev/null 2>&1; then
      if $APPLY; then
        do_ "identical to upstream — backup $local_path -> $local_path.bak, then symlink"
        mv "$local_path" "$local_path.bak"
        ln -s "$target_rel" "$local_path"
      else
        plan "$name is identical to upstream → backup + symlink"
      fi
    else
      if $FORCE && $APPLY; then
        do_ "[--force] backup local-modified $local_path -> $local_path.bak, then symlink"
        mv "$local_path" "$local_path.bak"
        ln -s "$target_rel" "$local_path"
      else
        warn "$name differs from upstream — kept local copy."
        warn "      Review with: diff -ru $local_path $SUBTREE_SKILLS/$name"
        warn "      To accept upstream and discard local edits, re-run with --force --apply."
      fi
    fi
  else
    plan "$name is bundled by the kit — drift will be checked after --apply runs the subtree add"
  fi
}

note "Step: kit-bundled skills"
for name in $KIT_SKILL_NAMES; do
  migrate_kit_skill "$name"
done
note ""

# --- Step 5: audit consumer-authored skills (never modify) --------------------

derive_prefix() {
  # Split repo dir name on '-' and '_', take first letter of each lowercase segment, append '-'.
  local dir="$1" out="" seg ch
  # Replace _ with - for splitting via IFS.
  local norm="${dir//_/-}"
  local saved_ifs="$IFS"
  IFS='-'
  for seg in $norm; do
    [[ -z "$seg" ]] && continue
    ch="$(printf '%s' "$seg" | cut -c1 | tr '[:upper:]' '[:lower:]')"
    out="$out$ch"
  done
  IFS="$saved_ifs"
  printf '%s-' "$out"
}

REPO_DIR_NAME="$(basename "$REPO_ROOT")"
DERIVED_PREFIX="$(derive_prefix "$REPO_DIR_NAME")"

# Multi-prefix support: if .skills/_meta.yml declares `prefixes:`, parse it as
# a YAML list and use those instead of the auto-derived single prefix.
# Minimal parser — supports the canonical form documented in skill-author:
#
#   prefixes:
#     - bld-
#     - bin-
#
# Entries may be quoted with single or double quotes. Anything outside that
# shape (flow-style lists, anchors) is not supported; declare prefixes in the
# block-style form above.
DECLARED_PREFIXES=""
if [[ -f "$META_FILE" ]] && grep -q '^prefixes:' "$META_FILE"; then
  in_list=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^prefixes: ]]; then in_list=true; continue; fi
    if $in_list; then
      # Stop at the next top-level key (no leading whitespace, contains a colon)
      if [[ "$line" =~ ^[A-Za-z_] ]]; then break; fi
      # Match indented "- value" entries
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.*)$ ]]; then
        val="${BASH_REMATCH[1]}"
        val="$(trim "$val")"
        val="${val#\"}"; val="${val%\"}"
        val="${val#\'}"; val="${val%\'}"
        [[ -n "$val" ]] && DECLARED_PREFIXES="$DECLARED_PREFIXES $val"
      fi
    fi
  done < "$META_FILE"
fi

if [[ -n "$DECLARED_PREFIXES" ]]; then
  ALLOWED_PREFIXES="$DECLARED_PREFIXES"
  PREFIX_SOURCE="declared in .skills/_meta.yml"
else
  ALLOWED_PREFIXES=" $DERIVED_PREFIX"
  PREFIX_SOURCE="derived from repo dir name '$REPO_DIR_NAME'"
fi

# Trim leading space for display
ALLOWED_PREFIXES_DISPLAY="$(printf '%s' "$ALLOWED_PREFIXES" | sed 's/^ //; s/ /, /g')"

prefix_match() {
  # Returns 0 if $1 starts with any prefix in $ALLOWED_PREFIXES, else 1.
  local name="$1" p
  for p in $ALLOWED_PREFIXES; do
    [[ "$name" == "$p"* ]] && return 0
  done
  return 1
}

note "Step: audit consumer-authored skills"
note "  repo dir name    : $REPO_DIR_NAME"
note "  allowed prefixes : $ALLOWED_PREFIXES_DISPLAY  ($PREFIX_SOURCE)"

REQUIRED_FIELDS="name description triggers dependencies version"
prefix_violations=0
frontmatter_violations=0

if [[ -d ".skills/_skills" ]]; then
  for d in .skills/_skills/*/; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    [[ -L "${d%/}" ]] && continue
    if is_kit_skill "$name"; then continue; fi

    # Prefix audit (multi-prefix aware)
    if ! prefix_match "$name"; then
      if [[ -n "$DECLARED_PREFIXES" ]]; then
        warn "consumer skill '$name' does not start with any declared prefix ($ALLOWED_PREFIXES_DISPLAY)"
        warn "      → choose the family this skill belongs to and rename: <prefix>$name"
        warn "        (also update SKILL.md frontmatter 'name' and .skills/_index.md)"
      else
        warn "consumer skill '$name' is missing prefix '$DERIVED_PREFIX'"
        warn "      → suggested rename: $DERIVED_PREFIX$name (also update SKILL.md frontmatter 'name' and .skills/_index.md)"
      fi
      prefix_violations=$((prefix_violations + 1))
    fi

    # Frontmatter audit
    skill_md="${d}SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
      warn "consumer skill '$name' has no SKILL.md"
      continue
    fi

    in_fm=false; closed=false; seen="|"; fm_name=""
    while IFS= read -r line; do
      if [[ "$line" == "---" ]]; then
        if $in_fm; then closed=true; break; else in_fm=true; continue; fi
      fi
      $in_fm || continue
      key="$(trim "$(printf '%s' "$line" | cut -d: -f1)")"
      for f in $REQUIRED_FIELDS; do
        if [[ "$key" == "$f" ]]; then
          seen="${seen}${f}|"
          [[ "$f" == "name" ]] && fm_name="$(trim "$(printf '%s' "$line" | cut -d: -f2-)")"
        fi
      done
    done < "$skill_md"

    if ! $closed; then
      warn "consumer skill '$name': SKILL.md frontmatter is missing or unterminated"
      frontmatter_violations=$((frontmatter_violations + 1))
      continue
    fi
    for f in $REQUIRED_FIELDS; do
      if [[ "$seen" != *"|${f}|"* ]]; then
        warn "consumer skill '$name': frontmatter missing required field '$f'"
        frontmatter_violations=$((frontmatter_violations + 1))
      fi
    done
    if [[ -n "$fm_name" && "$fm_name" != "$name" ]]; then
      warn "consumer skill '$name': frontmatter name '$fm_name' does not match directory"
      frontmatter_violations=$((frontmatter_violations + 1))
    fi
  done
fi

note ""
note "Audit summary:"
note "  prefix violations      : $prefix_violations"
note "  frontmatter violations : $frontmatter_violations"

# --- Step 6: index/meta reconcile reminder ------------------------------------

note ""
note "Step: manual reconcile (the script never edits these for you)"
note "  1. .skills/_index.md  — merge any new kit-skill rows from $PREFIX/.skills/_index.md"
note "                         into your local index without dropping consumer rows."
note "  2. .skills/_meta.yml  — bump kit_version to match $PREFIX/.skills/_meta.yml"
note "                         (or stay pinned and document why)."
note "  3. Re-run native discovery if you use it:"
note "        .skills/_harness/link.sh .agents/skills    # or .claude/skills"
note "  4. Validate:"
note "        .skills/_harness/check.sh"

if (( ERRORS > 0 )); then
  echo ""
  echo "$ERRORS error(s) — see above."
  exit 1
fi

if ! $APPLY; then
  note ""
  note "(dry-run) Re-run with --apply to perform the planned actions."
fi
