# Contributing to skills-harness

This kit is file-only with no runtime, so contributions are documentation and template changes. Here's how to work on each area.

## Changing the Rules block

The canonical Rules text lives in **`.skills/_harness/_rules.md`**. All templates reference this same set of rules, but each template embeds its own copy (so templates remain self-contained for copy-paste workflows).

When you change `_rules.md`:

1. Edit `.skills/_harness/_rules.md` with the new wording.
2. Copy the updated `## Rules` section into every `*_template.md` under `.skills/_harness/`, replacing the existing Rules block in each.
3. Run `.skills/_harness/check.sh` to verify all templates match the canonical source.

## Adding a new environment template

When a new tool gains a standard project-local config file:

1. Create `.skills/_harness/TOOLNAME_template.md` with the standard SETUP + harness body structure. Use an existing template as reference.
2. Copy the Rules block from `.skills/_harness/_rules.md` into the new template's `## Rules` section.
3. Add a row to the bootstrap table in `AGENTS_skills.md`.
4. Add a row to the **Supported tools** table in `README.md`.
5. If the tool uses special markup (like Cursor's YAML frontmatter), isolate it in that template — do not fork the Rules text.
6. Run `.skills/_harness/check.sh` to validate.

## Adding or editing a skill

Follow the bundled **skill-author** skill (`.skills/_skills/skill-author/SKILL.md`). In short:

1. Create `.skills/_skills/<name>/SKILL.md` using `skill-template` as a starting point.
2. Fill in YAML frontmatter (`name`, `description`, `triggers`, `dependencies`, `version`).
3. Add a row to `.skills/_index.md`.
4. Run `.skills/_harness/check.sh` to verify index-to-directory consistency.

## Testing

There is no automated CI. Use the validation script and manual smoke testing:

- **`check.sh`** — run `.skills/_harness/check.sh` from the repo root. It checks:
  - Every index row has a matching skill directory (and vice versa)
  - Every `SKILL.md` has required frontmatter fields
  - Frontmatter `name` matches directory name
  - Rules blocks in all templates match `_rules.md`

- **Manual smoke test** (before a release):
  1. Create a fresh temp directory; copy `AGENTS_skills.md` and `.skills/` into it.
  2. For at least one AGENTS-based and one sidecar template: follow SETUP; confirm destination file has no SETUP block and contains the harness.
  3. Verify the agent reads `.skills/_index.md` without preloading every `SKILL.md`.
  4. Verify the agent can follow `skill-author` to add a trivial skill.

## Versioning

- **Kit version** in `.skills/_meta.yml` — bump on template, index, or structural changes.
- **Per-skill version** in each `SKILL.md` frontmatter — bump when behaviour changes.
- **`CHANGELOG.md`** — add an entry for every release, following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Style guidelines

- Templates use **append with `## Skills Harness` heading** as the standard merge strategy.
- SETUP blocks are ephemeral; harness content is permanent. Keep them clearly separated with `<!-- SETUP -->` / `<!-- END SETUP -->` comments.
- Skills use kebab-case directory names, one-sentence descriptions, and phrase-based triggers.
