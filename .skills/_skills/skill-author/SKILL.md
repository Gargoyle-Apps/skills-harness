---
name: skill-author
description: "Creates a new SKILL.md from scratch and registers it in the harness index. Load when the user wants to author, add, or register a new skill."
triggers:
  - write a skill
  - author a skill
  - new skill
  - add a skill
dependencies:
  - skill-template
  - skill-reviewer
version: "2.0.0"
---

# Skill Author

## Prerequisites

Skill authoring must not be blocked after the temporary bootstrap file is removed.

1. **If `AGENTS_skills.md` exists** at the repository root — bootstrap is **not** finished. Do not follow these steps until the **`AGENTS_skills.md`** Single-Tool or Tool-Neutral setup is completed and that file is removed (see **`AGENTS_skills.md`**).

2. **If `AGENTS_skills.md` does not exist** — the repo has finished bootstrap. Proceed **unless** the project’s own docs forbid it: check root **`AGENTS.md`**, **README**, or **CONTRIBUTING** for a Tool-Neutral “skills / authoring” policy or any project-specific gate. Tool-Neutral repos usually record policy in **`AGENTS.md`** so agents still see the rules without relying on a deleted bootstrap file.

Do **not** treat “`AGENTS_skills.md` missing” as an error — it is expected after setup. Rely on **`AGENTS_skills.md`** only while it is present.

Load `skill-template` first if you need the canonical layout and refactor notes.

## Naming convention

Skills authored in a **consumer repo** (any repository that has installed this kit) **must** be prefixed with the consumer repo's initials, followed by `-`. Skills shipped as part of the **skills-harness kit itself** (the upstream repo, directory named `skills-harness`) are **unprefixed**.

**Deriving the prefix from the repo's root directory name:**

- Split on `-`, `_`, and whitespace (consecutive separators are collapsed)
- Take the first letter of each non-empty segment, lowercase
- Append `-`

Examples:

| Repo directory      | Prefix   |
|---------------------|----------|
| `ux-package-management` | `uxpm-` |
| `eng-package-management` | `epm-` |
| `git-minder`        | `gm-`    |
| `warehouse`         | `w-`     |
| `ware_house`        | `wh-`    |
| `Media Library`     | `ml-`    |
| `skills-harness`    | *(none — kit itself)* |

**Why:** When the kit is installed into a consumer repo, prefixes make it obvious which skills came from the kit vs. were added by the consumer, and avoid name collisions across repos that happen to share initials with the kit (`skills-harness` and `so-high` would both yield `sh-`, so the kit deliberately stays unprefixed).

**How to apply:** Before creating `.skills/_skills/<name>/`, derive the prefix from the current repo's root directory name and prepend it to `<name>`. The frontmatter `name` field and the index row use the prefixed form. Renames of pre-existing unprefixed consumer skills are out of scope unless the user asks.

### Multiple prefixes (per-repo override)

Some consumer repos host **multiple distinct skill families** that should be namespaced separately — e.g. a build-pipeline repo with a `bld-` family for build steps and a `bin-` family for binary-publishing steps. The single auto-derived prefix is too coarse for those repos.

To support this, a consumer repo may **declare an explicit list of allowed prefixes** in **`.skills/_meta.yml`**:

```yaml
kit_version: "1.0.0"
repo_url: "https://github.com/example/build-tools"
prefixes:
  - bld-
  - bin-
```

Rules when `prefixes:` is present:

- Every consumer-authored skill **must** start with one of the listed prefixes. Choose the prefix that matches the family the skill belongs to.
- The auto-derived single prefix is **not** required and **not** preferred — the explicit list is the source of truth.
- Each prefix entry must end with `-` and contain only lowercase alphanumerics and hyphens (same character set as `name`).
- Kit-bundled skills (`skill-author`, `harness-subtree`, `kit-release`, etc.) remain **unprefixed** regardless of what the consumer declares; the list applies only to consumer-authored skills.

Rules when `prefixes:` is absent (default / single-family repos):

- Use the single auto-derived prefix from the repo directory name (rules in the section above).
- This is the right choice for the vast majority of repos. Only declare `prefixes:` when one prefix genuinely cannot describe the families in the repo.

**Overriding the auto-derived prefix on a single-family repo:** if the auto-derivation gives the wrong answer for your repo (e.g. you want `ml-` but the dir name `media` derives `m-`, or you've informally settled on a different prefix), declare a single-entry list:

```yaml
prefixes:
  - ml-
```

That makes the override explicit and machine-readable for the audit, instead of relying on contributors to remember the unwritten convention.

**Authoring against a multi-prefix repo:** before creating a new skill, read `.skills/_meta.yml`. If `prefixes:` is present, ask the user (or pick from context) which family the new skill belongs to and use that prefix. If absent, derive the single prefix as before. `.skills/_harness/migrate-to-subtree.sh` reads the same list and accepts any of the declared prefixes.

## Steps

1. Create directory: `.skills/_skills/<prefix><name>/` (see **Naming convention** above; the kit itself uses no prefix)
2. Copy `.skills/_skills/skill-template/SKILL.md` as your starting point
3. Fill in frontmatter — `name` must match directory name exactly (including any prefix)
4. Write the body as agent-facing instructions, not human documentation (see **Body structure** and **Writing style** below)
5. Choose triggers carefully — these are what cause the skill to be loaded (see **Description quality**)
5b. **Trigger smoke-test.** After drafting `description` and `triggers`, propose one realistic user phrase. If that phrase would not obviously load this skill from the index, tighten the *when* half and try again.
6. **Bundled resources (Level 3):** if the skill needs scripts, extra docs, or static files, use the standard subfolders (see **skill-template** → *Skill directory layout*):
   - `scripts/` — shell/Python/JS helpers the agent runs (reference as `scripts/<file>` in `SKILL.md`)
   - `references/` — supplementary markdown the agent reads on demand
   - `assets/` — templates, schemas, images, data files
   Keep `SKILL.md` lean; reference bundled paths with relative URLs so `check.sh` can verify they exist. Do not leave scripts or extra `.md` files at the skill root.
7. Run `.skills/_harness/build-index.sh --write` to regenerate `.skills/_index.md` from frontmatter — the index is the source of truth at runtime and must always be in sync with `.skills/_skills/`
8. If this skill depends on another, list it in `dependencies`
9. If native discovery symlinks are configured, re-run `.skills/_harness/link.sh` with the appropriate target (e.g. `.agents/skills`), or `.skills/_harness/check.sh --link` to sync all existing native dirs and validate
10. Run `.skills/_harness/check.sh` to validate index, frontmatter, and resource layout (if your environment supports script execution)
11. For new or substantially changed skills, run **skill-reviewer** (or request a human review) before merge

## Description quality

`description` is used by native IDE matching; `triggers` are used by the harness index. Both should state *what* the skill does and *when* to load it.

Before committing, check:

- [ ] Third person in `description` — no "I", no "you can use this"
- [ ] States *what* (action) and *when* (trigger contexts)
- [ ] `triggers` lists natural phrases users actually say
- [ ] Slightly assertive on the *when* — agents tend to **under**-trigger; passive fit descriptions miss loads
- [ ] Under 1024 characters for `description`
- [ ] Does not duplicate the full body — complements it

See [optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) for more detail. Optional eval cases: `references/trigger-evals.json`.

## Body structure

Order sections for an agent that just loaded the file:

1. **When to use this skill** — concrete situations (and optional anti-triggers)
2. **Instructions** — numbered steps when order matters; point at `scripts/`, `references/`, `assets/` when bundled
3. **Examples** — concrete input/output when helpful
4. **Failure modes / verification** — what to do when a step fails
5. **Notes** — edge cases

Optional scaffolds from **skill-template**: Prerequisites, Failure modes table, What not to do.

## Writing style

- **Imperative voice** — "Run X", not "This skill runs X"
- **Brief why** — one clause when the reason is non-obvious
- **One default per concept** — avoid option menus unless alternatives are genuinely needed
- **Token discipline** — cut paragraphs that do not change agent behavior

## What not to do

- Don't paste secrets, tokens, or customer data into skills
- Don't duplicate another skill's workflow — reference it instead
- Don't put design tokens in skills — use `DESIGN.md` (**design-md-coord**)
- Don't skip **skill-reviewer** for skills that bundle scripts or instruct network/shell use

## Renaming or deleting a skill

When renaming or removing an existing skill, keep the directory and index in sync:

- **Rename:** update the directory name and the frontmatter `name` field together, then run `.skills/_harness/build-index.sh --write`.
- **Delete:** remove the directory, then run `.skills/_harness/build-index.sh --write`.

Never hand-edit `.skills/_index.md` — regenerate it from frontmatter.

## Frontmatter checklist

- [ ] `name` matches directory name
- [ ] `description` states what + when (see **Description quality**)
- [ ] `triggers` covers the natural language phrases that should invoke this skill
- [ ] `dependencies` is present (empty list `[]` if none)
- [ ] `version` is set

## Bundled resources checklist

Only when the skill ships files beyond `SKILL.md`:

- [ ] Scripts live under `scripts/`, not the skill root
- [ ] Extra markdown lives under `references/`, not the skill root
- [ ] Templates/data/images live under `assets/`
- [ ] Every bundled path appears in `SKILL.md` with a relative reference (e.g. `scripts/<name>.sh`, `references/<name>.md`)
- [ ] `check.sh` passes (missing references are errors; loose root scripts/markdown are warnings)

## What makes a good trigger

Triggers should match how a user would naturally ask for the task, not internal jargon. Prefer phrases over single words. Agents often under-trigger — when in doubt, add another concrete phrase rather than a single broad keyword.

## Circular dependencies

Avoid cycles in `dependencies`. If you detect a cycle, load skills in alphabetical order by `name` and stop after one full pass — then tell the user to fix the dependency graph.
