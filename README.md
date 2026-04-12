# skills-harness

A zero-dependency, file-only kit that teaches coding agents how to discover and load skills on demand. Drop `.skills/` and `AGENTS_skills.md` into any repo — the agent sets itself up, reads the index, and loads each `SKILL.md` only when the task matches its triggers.

## Quick start

1. Copy `AGENTS_skills.md` and `.skills/` into your project root.
2. Open `AGENTS_skills.md` in your agent. It will ask which environment you use, then walk through setup automatically.
3. After setup, `AGENTS_skills.md` is deleted. The harness lives in `AGENTS.md` or a sidecar file, depending on your IDE.

For repos that need to stay **IDE-neutral** (used across Cursor, Claude Code, Windsurf, etc. by different people), follow **Path B** in `AGENTS_skills.md` — skills stay portable under `.skills/` without committing to a single tool's config files.

## How it works

| Role | What it does | Implemented by |
|------|-------------|----------------|
| **User** | Sets goals, chooses the IDE, resolves conflicts | The human |
| **Agent** | Reads the index, loads skills on demand, manages files | The AI in your IDE |
| **Index** | Routes — declares what skills exist and when to trigger them | `.skills/_index.md` |
| **Skills** | Execute — step-by-step instructions for a specific task | `.skills/_skills/<name>/SKILL.md` |

The agent reads the index at the start of non-trivial work. When a task matches a skill's triggers, the agent loads that `SKILL.md` — never preemptively. If a skill lists dependencies, those are loaded first. Skills cannot override user intent or agent core behavior; they only provide domain-specific procedures.

## Supported tools

| Environment | Template |
|-------------|----------|
| Cursor | [CURSOR_template.md](.skills/_harness/CURSOR_template.md) |
| Codex | [CODEX_template.md](.skills/_harness/CODEX_template.md) |
| GitHub Copilot | [COPILOT_template.md](.skills/_harness/COPILOT_template.md) |
| Claude Code | [CLAUDE_template.md](.skills/_harness/CLAUDE_template.md) |
| Cline | [CLINE_template.md](.skills/_harness/CLINE_template.md) |
| Windsurf | [WINDSURF_template.md](.skills/_harness/WINDSURF_template.md) |
| Gemini CLI | [GEMINI_template.md](.skills/_harness/GEMINI_template.md) |
| Roo Code | [ROO_template.md](.skills/_harness/ROO_template.md) |
| OpenCode | [OPENCODE_template.md](.skills/_harness/OPENCODE_template.md) |
| Other / paste-only | [GENERIC_template.md](.skills/_harness/GENERIC_template.md) |

## Skill format

Each `SKILL.md` opens with YAML frontmatter. See [skill-template](.skills/_skills/skill-template/SKILL.md) for a complete example.

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | yes | Must match directory name (kebab-case, 1–64 chars) |
| `description` | yes | One sentence for index and IDE matching (1–1024 chars) |
| `triggers` | yes | Phrases that should cause this skill to load |
| `dependencies` | yes | Other skill names to load first (`[]` if none) |
| `version` | yes | Semver string (e.g. `1.0.0`) |

These fields follow the [agentskills.io specification](https://agentskills.io/specification). IDEs that support native skill discovery use `name` and `description`; the harness adds `triggers`, `dependencies`, and `version` on top.

## Native IDE discovery

Most IDEs auto-discover skills from standard directories. After setup, run the symlink helper to enable native features (`@skill-name` mentions, auto-invocation, skill panels):

```bash
# Most IDEs (Cursor, Codex, Copilot, Windsurf, Gemini CLI, Roo Code, OpenCode)
.skills/_harness/link.sh .agents/skills

# Claude Code and Cline
.skills/_harness/link.sh .claude/skills
```

Symlinks point from the cross-agent discovery path back to `.skills/_skills/`. Add the target directory to `.gitignore` — symlinks are machine-local, not committed.

The harness index and native discovery work side by side: native gives IDE integration, the index gives trigger keywords and dependency chains.

### Swapping IDEs

Skills stay in `.skills/_skills/` regardless of IDE. To switch:

1. Follow the new IDE's template to install harness rules.
2. Run `link.sh` with the appropriate target if not already done.
3. `.agents/skills/` and `.claude/skills/` symlinks can coexist.

For upgrading from an older harness version, use the bundled **harness-upgrade** skill.

## Adding a skill

1. Copy [skill-template](.skills/_skills/skill-template/SKILL.md) to `.skills/_skills/<name>/SKILL.md` and edit.
2. Add a row to [`.skills/_index.md`](.skills/_index.md).
3. Re-run `.skills/_harness/link.sh` if native discovery symlinks are set up.
4. For the full checklist, load the **skill-author** skill.

## Updating the kit

Merge or replace `.skills/_harness/` and bundled skills from upstream. Keep your custom skills under `.skills/_skills/` and your index rows. See the **harness-upgrade** skill for guided migration.

## Validation

Run `.skills/_harness/check.sh` to verify index/directory consistency, frontmatter, template sync, and symlink integrity.

## Optional: MCP

For progressive skill loading via MCP, see [skillport](https://github.com/gotalab/skillport). This kit does not ship a server.

## Kit version

**Current release:** `0.4.1`

- **Canonical:** [`kit_version` in `.skills/_meta.yml`](.skills/_meta.yml)
- **History:** [CHANGELOG.md](CHANGELOG.md)
- **Bootstrap:** [`AGENTS_skills.md`](AGENTS_skills.md) shows the same release for agents during setup

When bumping the kit in this repository, load the **kit-release** skill and update the changelog, `_meta.yml`, this section, and `AGENTS_skills.md` together, then run `.skills/_harness/check.sh`. See [CONTRIBUTING.md — Versioning](CONTRIBUTING.md#versioning).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE).
