# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.1] - 2026-04-12

### Added

- **`kit-release` skill (v1.0.0):** procedure to bump kit semver while keeping `CHANGELOG.md`, `.skills/_meta.yml`, `README.md`, and `AGENTS_skills.md` aligned; validated by `check.sh`.

### Changed

- **`README.md`**, **`AGENTS_skills.md`:** surface **Current release** / **Kit version** matching the changelog and `_meta.yml`.
- **`check.sh`:** verifies kit version consistency across `_meta.yml`, top `CHANGELOG` release, `README`, and `AGENTS_skills.md`.
- **`CONTRIBUTING.md`:** versioning section references **kit-release** and the shared surfaces.

## [0.4.0] - 2026-04-07

### Added

- **`link.sh`:** symlink helper script that creates symlinks from native IDE discovery paths (`.agents/skills/`, `.claude/skills/`) into `.skills/_skills/`, enabling auto-invocation, `@skill-name` mentions, and skill panels across 9 IDEs.
- **`ROO_template.md`:** Roo Code environment template.
- **`OPENCODE_template.md`:** OpenCode environment template.
- **`harness-upgrade` skill (v1.0.0):** guides upgrading older harness installations to v0.4.0+ with native IDE discovery; includes IDE swap instructions.
- **`.gitignore`:** `.agents/skills/` and `.claude/skills/` entries for generated symlink directories.

### Changed

- **All templates:** SETUP sections now include a "Native discovery" step calling `link.sh` with the IDE-appropriate target directory.
- **`check.sh`:** added optional symlink validation for `.agents/skills/` and `.claude/skills/` directories.
- **`skill-template` v1.1.0:** added [agentskills.io](https://agentskills.io/specification) frontmatter constraints (`name` length/format, `description` length) to authoring instructions.
- **`skill-author` v1.2.0:** added step to re-run `link.sh` after creating a new skill.
- **`link.sh`:** stale symlink detection (auto-updates wrong targets), `_`-prefixed directory filter, flexible `--clean` arg position.
- **`AGENTS_skills.md`:** bootstrap table now includes Roo Code and OpenCode rows.
- **`README.md`:** added native IDE discovery section with `link.sh` usage and IDE swap guide; updated supported tools table.
- **`CONTRIBUTING.md`:** added frontmatter compatibility requirements and symlink helper guidance.

## [0.3.2] - 2026-04-04

### Changed

- **Rules:** replaced "Add new skills to the index when you create them" with a stronger obligation — `.skills/_index.md` is the source of truth; agents must update it on create, rename, or delete, and never leave it out of sync.
- **`skill-author` v1.1.0:** added "Renaming or deleting a skill" section reinforcing index sync on all lifecycle operations.
- **Index:** removed stale `ghost` placeholder row.

## [0.3.1] - 2026-04-03

### Fixed

- **`check.sh`:** `err()` no longer aborts on the first failure under `set -e` (use pre-increment for the error counter). Replaced bash 4 associative arrays with a portable marker string so the script runs on macOS `/bin/bash` 3.2.

## [0.3.0] - 2026-04-03

### Added

- **`_rules.md`:** canonical Rules block as a single source of truth under `.skills/_harness/`. All templates embed a copy; `_rules.md` is the maintainer reference.
- **`check.sh`:** validation script that verifies index-to-directory consistency, frontmatter completeness, `name` field matching, and Rules block sync across all templates.
- **`CONTRIBUTING.md`:** contributor guidance covering Rules changes, new templates, skill authoring, testing, and versioning.
- **`_meta.yml` `repo_url`:** added `repo_url` so embedded kits can trace their origin.

### Changed

- **Split `AGENTS_template.md`** into three separate files: `CURSOR_template.md`, `CODEX_template.md`, `COPILOT_template.md`. Each template is self-contained — no more stripping unused environment blocks.
- **Standardized merge guidance:** all templates now use "append under a `## Skills Harness` heading" as the default merge strategy instead of listing multiple options.
- **Template SETUP blocks:** each now ends with a **Verify** checklist for post-setup confirmation.
- **Bootstrap table (`AGENTS_skills.md`):** updated to reference the new split template filenames.
- **README:** updated supported tools table for split templates; added **Validation** and **Contributing** sections.
- **`ref/skills-harness-plan.md`:** updated to reflect current state — `AGENTS_skills.md` naming, split templates, `_rules.md`, `check.sh`, corrected frontmatter examples, and marked as historical design reference.

### Removed

- **`AGENTS_template.md`:** replaced by `CURSOR_template.md`, `CODEX_template.md`, `COPILOT_template.md`.
- **`.gitignore` `!.env.example`:** removed stale exception for a file that does not exist.

## [0.2.2] - 2026-04-02

### Changed

- **Path B (`AGENTS_skills.md`):** Clarify no harness-template paste into `AGENTS.md`; existing `AGENTS.md` stays the project contract; optional **Skills (agnostic)** section example; `_harness/` is reference-only for Path B.
- **`skill-author`:** Prerequisites no longer imply a permanent dependency on `AGENTS_skills.md`; after bootstrap removal, check root **`AGENTS.md`** / README for Path B policy.
- **Harness templates:** Rules bullet rewritten so the bootstrap gate applies **only while** `AGENTS_skills.md` exists; Path B may record policy in `AGENTS.md`.

## [0.2.1] - 2026-04-02

### Added

- **`AGENTS_skills.md` Path B — agnostic / multi-ecosystem:** author portable skills under `.skills/` without installing a tool-specific harness in the repo; document in README/CONTRIBUTING and remove bootstrap.
- **README:** subsection for agnostic repositories and downstream harness usage.

### Changed

- **`skill-author` prerequisites:** allow completion via Path A or Path B (`AGENTS_skills.md`).

## [0.2.0] - 2026-04-02

### Changed

- **Bootstrap renamed to `AGENTS_skills.md`** so it does not overwrite an existing project `AGENTS.md`. It is removed after setup.
- **AGENTS-based harness:** templates now require **merging** into existing `AGENTS.md` when that file already exists; sidecar templates merge pointers into `AGENTS.md` the same way.
- **`AGENTS_skills.md` gate:** explicit rules that the user must **declare the environment** before any skill creation, refactor, or index registration; runtime harness rules repeat this while the bootstrap file is present.
- **skill-author:** prerequisites section pointing at the bootstrap gate.

## [0.1.0] - 2026-04-02

### Added

- Bootstrap `AGENTS.md` and `.skills/` layout: index, bundled skills (`skill-template`, `skill-author`), and environment templates under `.skills/_harness/`.
- Human-facing `README` with quick start, supported tools, and optional MCP pointer.
