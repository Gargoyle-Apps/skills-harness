# Skills Harness — bootstrap (temporary)

This file is **`AGENTS_skills.md`** so dropping the kit into a repo **does not overwrite** an existing project **`AGENTS.md`**. It exists only until one-time harness setup is finished. After setup, **delete this file** (or replace it with a one-line pointer only if your template says so).

## Hard gate — environment must be declared first

**Do not proceed** with any skills work until all of the following are satisfied:

1. **The user has explicitly declared** which environment applies (one of: Cursor, Codex, GitHub Copilot, Claude Code, Cline, Windsurf, Gemini CLI, or Other / paste-only). Do not infer from filenames alone; if unclear, **ask** which row in the table below applies.
2. **Setup from the matching template** (under `.skills/_harness/`) has been completed: SETUP sections removed, harness installed per that template, and this **`AGENTS_skills.md`** removed or reduced as instructed.

**Until both are true, you must not:**

- Create, rename, or delete skills under `.skills/_skills/`
- Edit `.skills/_index.md` to register new skills
- Refactor existing rules or docs into skills
- Load full `SKILL.md` files to *author* or *restructure* skills (reading the index only to explain the process is OK)

You may still answer questions about what the harness is or what the next step is for the user.

## One-time setup

| Environment | Template |
|-------------|----------|
| Cursor | `.skills/_harness/AGENTS_template.md` |
| Codex | `.skills/_harness/AGENTS_template.md` |
| Copilot | `.skills/_harness/AGENTS_template.md` |
| Claude Code | `.skills/_harness/CLAUDE_template.md` |
| Cline | `.skills/_harness/CLINE_template.md` |
| Windsurf | `.skills/_harness/WINDSURF_template.md` |
| Gemini CLI | `.skills/_harness/GEMINI_template.md` |
| Other | `.skills/_harness/GENERIC_template.md` |

1. Open the corresponding template file.
2. Follow its **Setup instructions** exactly — especially how to merge with an **existing** `AGENTS.md` or sidecar file (see template).
3. Remove **`AGENTS_skills.md`** when setup is complete, unless the template specifies otherwise.

**Note:** If the repo already has a project **`AGENTS.md`** for Cursor/Codex/Copilot, the harness content from `AGENTS_template.md` must be **merged** into that file (prepend, append, or a dedicated section), not swapped in blindly. Same idea for pointers: merge into existing `AGENTS.md` when the file already exists.
