# skills-harness

Zero-dependency, file-only **skills harness**: drop `.skills/` and `AGENTS.md` into any repository so your coding agent discovers skills from `.skills/_index.md` and loads each skill’s `SKILL.md` only when the task matches its triggers.

## Quick start

1. Copy this repository’s `AGENTS.md` and `.skills/` directory into your project root (or submodule / subtree).
2. Open `AGENTS.md` in your agent and follow the bootstrap table to the right **template** under `.skills/_harness/`.
3. Complete that template’s setup (strip the SETUP block, write the destination file, replace `AGENTS.md` with the harness or a pointer as instructed).

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

- **Skills manifest:** [`.skills/_index.md`](.skills/_index.md) — the single place to list skills.
- **Skill bodies:** `.skills/_skills/<name>/SKILL.md`
- **Harness:** root `AGENTS.md` (or a sidecar like `CLAUDE.md`, `.clinerules`, etc., depending on template) contains the **Rules** that tell the agent to read the index first and load skills on demand only.

Confirm the agent reads `.skills/_index.md` for non-trivial work and does not preload every `SKILL.md`.

## Adding a skill

1. Copy [`.skills/_skills/skill-template/SKILL.md`](.skills/_skills/skill-template/SKILL.md) to `.skills/_skills/<your-skill-name>/SKILL.md` and edit frontmatter + body.
2. Add a row to [`.skills/_index.md`](.skills/_index.md).
3. For detailed steps, load the **skill-author** skill (see index) after **skill-template** if you need the authoring checklist.

## Updating the kit

Merge or replace files from upstream **skills-harness**; keep your custom skills under `.skills/_skills/` and your index rows. Resolve conflicts in `AGENTS.md` / harness files the same way you would for any shared boilerplate.

## Optional: MCP (progressive loading)

If your client supports MCP and you want progressive skill loading outside this file-based flow, see **[skillport](https://github.com/gotalab/skillport)**. This repo does not ship a server; use skillport (or similar) with `.skills/_skills/` as documented there.

## Kit version

Optional metadata: [`.skills/_meta.yml`](.skills/_meta.yml).

## License

See [LICENSE](LICENSE).
