---
name: skill-import
description: "Import or refresh a vendored skill from another git repo into .skills/_skills/ with upstream lineage and skill-reviewer validation."
triggers:
  - import skill
  - vendor skill
  - pull skill from repo
  - refresh imported skill
  - update vendored skill
dependencies:
  - skill-author
  - skill-reviewer
version: "1.0.0"
---

# Skill Import

Pull a skill from another repository into this one as a **vendored copy** with recorded upstream coordinates. Re-pull on demand; do not hand-edit vendored bodies for lasting fixes — fix upstream and re-import.

**Not for:** authoring a new local skill (**skill-author**) or publishing outward (**skill-export**).

## Lineage block

Imported skills carry optional frontmatter documenting the source (consumer repos may adopt this convention):

```yaml
upstream:
  repo: owner/repo
  ref: main
  path: path/to/skill-dir
  imported: 2026-07-21
  imported-commit: <sha>
```

Presence of `upstream:` signals: refresh via this skill, not casual edits.

## Prerequisites

- Git and network access to the source repository
- `gh` CLI or git clone for GitHub sources; adapt for other hosts
- Write access to `.skills/_skills/` in this repo
- Consumer prefix rules (**skill-author**) when the imported name lacks the repo prefix

## Steps

1. **Pin the source** — `repo`, `ref`, and `path` to the skill directory. Ask if any coordinate is missing.

2. **Freshness check** — if the skill exists, compare `imported-commit` to upstream HEAD for `path`. Stop if already current.

3. **Fetch files** — copy `SKILL.md` and any `scripts/`, `references/`, `assets/`, `evals/` into `.skills/_skills/<name>/`.

4. **Strip source-repo wiring** — remove catalog rows, plugin manifests, symlinks, and host-specific paths that do not apply here.

5. **Adapt to harness** — replace foreign frontmatter with harness fields (`triggers`, `dependencies`, `version`). Apply consumer prefix to `name` and directory when required.

6. **Stamp lineage** — add or update the `upstream:` block.

7. **Review** — run **skill-reviewer** on the imported copy. Resolve HIGH findings before wiring in.

8. **Wire in** — follow **skill-author**: `build-index.sh --write`, `link.sh` if needed, `check.sh`.

## Refreshing later

Re-run on an existing import: freshness check, re-pull if upstream moved, re-stamp commit, re-review if body changed.

## What not to do

- Don't hand-edit vendored bodies for bug fixes — upstream + re-import
- Don't skip security review on bundled scripts
- Don't commit tokens or credentials used for fetch

## References

See **skill-reviewer** Q3 for optional trigger-eval guidance.
