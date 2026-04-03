# skills-harness

Zero-dependency, file-only **skills harness**: drop `.skills/` and **`AGENTS_skills.md`** into any repository so your coding agent discovers skills from `.skills/_index.md` and loads each skill’s `SKILL.md` only when the task matches its triggers.

The bootstrap is intentionally named **`AGENTS_skills.md`** (not `AGENTS.md`) so it **never overwrites** an existing project **`AGENTS.md`**. After one-time setup, **`AGENTS_skills.md` is removed**; the long-lived harness lives in **`AGENTS.md`** (Cursor / Codex / Copilot) or in a sidecar file (e.g. `CLAUDE.md`), per the template you use.

## Quick start

1. Copy this repository’s **`AGENTS_skills.md`** and **`.skills/`** directory into your project root (or submodule / subtree).
2. Open **`AGENTS_skills.md`** in your agent. Follow the **hard gate** there: the user must **declare the environment** before any skill authoring or refactor work. Then open the matching template under **`.skills/_harness/`**.
3. Complete that template’s **Setup** (strip the SETUP block, install the harness). For **Cursor / Codex / Copilot**, merge the harness into **`AGENTS.md`** if that file already exists — do not blindly replace project instructions. Remove **`AGENTS_skills.md`** when done.

## Supported tools

| Environment | Template file |
|-------------|----------------|
| Cursor | [`.skills/_harness/AGENTS_template.md`](.skills/_harness/AGENTS_template.md) |
| Codex | [`.skills/_harness/AGENTS_template.md`](.skills/_harness/AGENTS_template.md) |
| GitHub Copilot (VS Code / similar) | [`.skills/_harness/AGENTS_template.md`](.skills/_harness/AGENTS_template.md) |
| Claude Code | [`.skills/_harness/CLAUDE_template.md`](.skills/_harness/CLAUDE_template.md) |
| Cline | [`.skills/_harness/CLINE_template.md`](.skills/_harness/CLINE_template.md) |
| Windsurf | [`.skills/_harness/WINDSURF_template.md`](.skills/_harness/WINDSURF_template.md) |
| Gemini CLI | [`.skills/_harness/GEMINI_template.md`](.skills/_harness/GEMINI_template.md) |
| Other / paste-only | [`.skills/_harness/GENERIC_template.md`](.skills/_harness/GENERIC_template.md) |

## After setup

- **Bootstrap:** `AGENTS_skills.md` should be **gone** after setup (unless a template explicitly says otherwise).
- **Skills manifest:** [`.skills/_index.md`](.skills/_index.md) — the single place to list skills.
- **Skill bodies:** `.skills/_skills/<name>/SKILL.md` — each file opens with **YAML front matter** (between `---` lines) so the index and harness can discover metadata cheaply before loading the full body.

### YAML front matter for each `SKILL.md`

Every skill should use this shape (see [`.skills/_skills/skill-template/SKILL.md`](.skills/_skills/skill-template/SKILL.md) for a filled-in example):

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | yes | Must match the directory name exactly (kebab-case, e.g. `my-skill`). |
| `description` | yes | One sentence; used in the index and for relevance matching. |
| `triggers` | yes | List of phrases or keywords that should cause this skill to load. |
| `dependencies` | yes | Other skill `name`s to load first; use `[]` if none. |
| `version` | yes | Semver string for humans (e.g. `1.0.0`). |

The Markdown **body** starts after the closing `---`. Keeping **all** skills in this format— including ones you are porting from ad-hoc rules, plain markdown, or older layouts—is **strongly recommended**: the harness and index stay consistent, the agent can resolve dependencies and triggers the same way everywhere, and you avoid mixed conventions in `.skills/_skills/`.

- **Harness:** root **`AGENTS.md`** (or a sidecar like `CLAUDE.md`, `.clinerules`, etc., depending on template) contains the **Rules** that tell the agent to read the index first and load skills on demand only. If **`AGENTS_skills.md`** is still present, setup is incomplete and the Rules in templates tell the agent **not** to create or refactor skills yet.

Confirm the agent reads `.skills/_index.md` for non-trivial work and does not preload every `SKILL.md`.

## Adding a skill

Only after **`AGENTS_skills.md`** has been removed and harness setup is complete:

1. Copy [`.skills/_skills/skill-template/SKILL.md`](.skills/_skills/skill-template/SKILL.md) to `.skills/_skills/<your-skill-name>/SKILL.md` and edit frontmatter + body.
2. Add a row to [`.skills/_index.md`](.skills/_index.md).
3. For detailed steps, load the **skill-author** skill (see index) after **skill-template** if you need the authoring checklist.

## Updating the kit

Merge or replace files from upstream **skills-harness**; keep your custom skills under `.skills/_skills/` and your index rows. Resolve conflicts in **`AGENTS.md`**, sidecar harness files, and **`AGENTS_skills.md`** the same way you would for any shared boilerplate.

## Optional: MCP (progressive loading)

If your client supports MCP and you want progressive skill loading outside this file-based flow, see **[skillport](https://github.com/gotalab/skillport)**. This repo does not ship a server; use skillport (or similar) with `.skills/_skills/` as documented there.

## Kit version

Optional metadata: [`.skills/_meta.yml`](.skills/_meta.yml).

## License

See [LICENSE](LICENSE).
