---
name: skill-catalog-maintainer
description: "Audit skills under .skills/_skills/ for overlap, trigger collisions, size, and index drift; may edit skills with dry-run and confirmation."
triggers:
  - skill inventory
  - catalog health
  - duplicate skill triggers
  - skill overlap
  - split this skill
  - skill catalog audit
dependencies:
  - skill-author
version: "1.0.0"
---

# Skill Catalog Maintainer

Audit every skill in `.skills/_skills/`, cluster by `triggers` and by intent in each `description`, and report overlap, redundancy, or oversize skills. May edit other skills' frontmatter and bodies — dry-run and explicit confirmation required.

## Edit authority (the exception)

By default, skills describe workflows; they do not edit sibling skills. **This skill is the exception** for catalog upkeep — with guardrails.

**Permitted edits** (after confirmation):

- Other skills' `SKILL.md` — frontmatter (`description`, `triggers`, `dependencies`, `version`) and body
- `.skills/_index.md` — via `build-index.sh --write` after frontmatter changes
- Root `AGENTS.md` — Skills / harness policy sections when catalog conventions change

**Required guardrails:**

1. **Dry-run first** — produce the report (steps 1–6) with a `### Planned edits` section: numbered bullets, fenced before/after per file. Do not write yet.
2. **Explicit confirmation** — wait for approval ("apply all", "apply 1 and 3", or revisions). Ambiguity means stop.
3. **Version bumps** — any non-typo skill edit bumps `version` in frontmatter; mention in `CHANGELOG.md` when cutting a kit release.
4. **Index sync** — run `.skills/_harness/build-index.sh --write` after frontmatter edits.

**Refuse without maintainer action:** rename skill directories, delete skills, bulk retag more than ~3 skills in one pass.

## When to use

- Inventory or health check of the skill catalog
- Suspected duplicate triggers or redundant workflows
- Split candidates for oversized skills
- Governance housekeeping before a large refactor

## Steps

### 1. Enumerate skills

```bash
find .skills/_skills -name SKILL.md
```

Skip `_`-prefixed harness internals. Exclude `skill-template` from overlap analysis (starter artifact) but list it under authoring aids.

Confirm each directory `name` matches frontmatter `name`; flag drift. Run `.skills/_harness/check.sh` for index ↔ directory consistency.

### 2. Capture metadata and size

Per skill: `name`, `version`, `description`, `triggers`, line count of `SKILL.md`, presence of `references/` / `scripts/` / `assets/`.

### 3. Cluster by triggers

Build **trigger phrase → [skills]**. Flag phrases shared by two or more runtime skills. Note overly generic triggers that appear on many skills.

### 4. Cluster by intent

Derive a 5–8 word intent label from each `description`. Group skills with overlapping user outcomes. Classify: **complementary**, **redundant**, or **unclear boundary** (recommend boundary sentences in descriptions).

### 5. Size bands

| Band | `SKILL.md` lines | Guidance |
|------|------------------|----------|
| Comfortable | under ~180 | No action on length alone |
| Large | ~180–350 | Move prose to `references/` |
| Split candidate | over ~350 | Consider split or reference extraction |

If most prose already lives in `references/`, say so.

### 6. Deliver the report

Sections: **Trigger clusters**, **Intent collisions**, **Size / structure**, **Recommended next actions**. Include planned edits only when the user may want this skill to apply fixes.

## What not to do

- No silent edits
- No rename or delete
- Don't dump every skill body into chat — summarize and link paths
