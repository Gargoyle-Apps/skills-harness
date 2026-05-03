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

CANONICAL_URL_SUBSTR="Gargoyle-Apps/skills-harness"

APPLY=false
FORCE=false
REMOTE_NAME="skills-harness"
REMOTE_URL=""
REF="main"
PREFIX=".skills-harness"
ACCEPT_UPSTREAM=""    # comma-separated names whose drift should be overwritten with upstream
ACCEPT_DERIVED_URL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=true ;;
    --force) FORCE=true ;;
    --remote-name) REMOTE_NAME="$2"; shift ;;
    --remote-url) REMOTE_URL="$2"; shift ;;
    --ref) REF="$2"; shift ;;
    --prefix) PREFIX="$2"; shift ;;
    --accept-upstream) ACCEPT_UPSTREAM="$2"; shift ;;
    --accept-derived-url) ACCEPT_DERIVED_URL=true ;;
    -h|--help)
      sed -n '3,50p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "ERROR: unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

# Symlink-safe: derive paths from the script's invocation path without following
# symlinks (relevant after migration when .skills/_harness/ is a symlink into
# .skills-harness/.skills/_harness/). See gh issue #3, friction point 5.
script_src="${BASH_SOURCE[0]:-$0}"
script_dir="$(dirname "$script_src")"
HARNESS_DIR="${SKILLS_HARNESS_DIR:-$(cd "$script_dir" && pwd -L)}"
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
  # Filter the dirty-tree check so the user can drop this script directly into
  # .skills/_harness/migrate-to-subtree.sh and run from there. We ignore the
  # script itself plus any *.bak directories (which can only exist mid-migration).
  # See gh issue #3, friction point 2.
  script_basename="$(basename "$script_src")"
  dirty="$(git status --porcelain 2>/dev/null \
    | grep -v -E "(^|/)${script_basename}\$" \
    | grep -v -E '\.bak/?$' \
    || true)"
  if [[ -n "$dirty" ]]; then
    echo "ERROR: working tree has uncommitted changes (other than the script itself):" >&2
    echo "$dirty" >&2
    echo "Commit or stash before --apply." >&2
    exit 1
  fi
fi

REMOTE_URL_SOURCE="explicit --remote-url"
if [[ -z "$REMOTE_URL" && -f "$META_FILE" ]]; then
  raw="$(grep -E '^repo_url:' "$META_FILE" | head -1 | sed 's/^repo_url://' || true)"
  raw="$(trim "$raw")"
  raw="${raw#\"}"; raw="${raw%\"}"
  REMOTE_URL="$raw"
  REMOTE_URL_SOURCE="derived from .skills/_meta.yml repo_url"
fi
if [[ -z "$REMOTE_URL" ]]; then
  echo "ERROR: no upstream URL. Pass --remote-url or set repo_url in .skills/_meta.yml." >&2
  exit 1
fi

# Stale-install safety: if repo_url was derived from _meta.yml AND it doesn't
# point at the canonical Gargoyle-Apps/skills-harness, the consumer probably
# has a stale install pointing at an old fork. Refuse unless the user
# explicitly accepts. See gh issue #3, friction point 3.
if [[ "$REMOTE_URL_SOURCE" != "explicit --remote-url" ]]; then
  if [[ "$REMOTE_URL" != *"$CANONICAL_URL_SUBSTR"* ]] && ! $ACCEPT_DERIVED_URL; then
    echo "ERROR: derived repo_url does not look like the canonical kit upstream." >&2
    echo "  derived  : $REMOTE_URL ($REMOTE_URL_SOURCE)" >&2
    echo "  expected : a URL containing '$CANONICAL_URL_SUBSTR'" >&2
    echo "" >&2
    echo "Stale .skills/_meta.yml installations often have an outdated repo_url." >&2
    echo "Re-run with one of:" >&2
    echo "  --remote-url https://github.com/Gargoyle-Apps/skills-harness" >&2
    echo "  --accept-derived-url    (only if you really want to vendor the URL above)" >&2
    exit 1
  fi
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

  # Per-skill upstream acceptance via --accept-upstream (gh issue #3, friction point 4).
  # Comma-separated list of kit-skill names whose drift should be overwritten with
  # upstream. Cleaner than --force, which sledgehammers every drifted skill.
  accept_this=false
  if [[ -n "$ACCEPT_UPSTREAM" ]]; then
    saved_ifs="$IFS"; IFS=','
    for n in $ACCEPT_UPSTREAM; do
      n="$(trim "$n")"
      [[ "$n" == "$name" ]] && accept_this=true
    done
    IFS="$saved_ifs"
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
      if ($FORCE || $accept_this) && $APPLY; then
        reason="$($accept_this && echo "[--accept-upstream]" || echo "[--force]")"
        do_ "$reason backup local-modified $local_path -> $local_path.bak, then symlink"
        mv "$local_path" "$local_path.bak"
        ln -s "$target_rel" "$local_path"
      else
        warn "$name differs from upstream — kept local copy."
        warn "      Review with: diff -ru $local_path $SUBTREE_SKILLS/$name"
        warn "      To accept upstream for this skill only:  --accept-upstream $name --apply"
        warn "      To accept upstream for ALL drifted kit skills:  --force --apply"
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
  # Split repo dir name on '-', '_', and whitespace; take the first letter of
  # each non-empty lowercase segment; append '-'. Whitespace handling fixes
  # gh issue #3, friction point 9 (e.g. "Media Library" → "ml-", not "m-").
  local dir="$1" out="" seg ch
  # Normalize all separators to '-'.
  local norm="$(printf '%s' "$dir" | tr '_ \t' '---')"
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

# Optional: consumer_skills_dir hint. When the consumer keeps real skill bodies
# outside .skills/_skills/ (e.g. .cursor/skills/) and uses .skills/_skills/<name>/
# as a thin symlink shim, surface that during the audit so the user knows the
# script won't generate those symlinks (gh issue #3, friction point 8 — auto-
# symlinking from a foreign tree is deferred to a follow-up release).
CONSUMER_SKILLS_DIR=""
if [[ -f "$META_FILE" ]]; then
  raw_csd="$(grep -E '^consumer_skills_dir:' "$META_FILE" | head -1 | sed 's/^consumer_skills_dir://' || true)"
  raw_csd="$(trim "$raw_csd")"
  raw_csd="${raw_csd#\"}"; raw_csd="${raw_csd%\"}"
  raw_csd="${raw_csd#\'}"; raw_csd="${raw_csd%\'}"
  CONSUMER_SKILLS_DIR="$raw_csd"
fi

note "Step: audit consumer-authored skills"
note "  repo dir name    : $REPO_DIR_NAME"
note "  allowed prefixes : $ALLOWED_PREFIXES_DISPLAY  ($PREFIX_SOURCE)"
if [[ -n "$CONSUMER_SKILLS_DIR" ]]; then
  note "  consumer_skills_dir declared in _meta.yml: $CONSUMER_SKILLS_DIR"
  note "    (real skill bodies live there; .skills/_skills/<name>/ should be symlinks pointing at them)"
  note "    (auto-symlinking from this tree is not yet implemented — see harness-subtree skill)"
fi

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
