<!-- SETUP — remove this entire section after setup is complete -->

## Setup instructions (Cursor, Codex, or Copilot)

1. Identify your environment: **Cursor**, **Codex**, or **GitHub Copilot** (VS Code / similar).
2. Keep **only** one environment block: `<!-- [CURSOR] -->` … `<!-- END CURSOR -->`, or `<!-- [CODEX] -->` … `<!-- END CODEX -->`, or `<!-- [COPILOT] -->` … `<!-- END COPILOT -->`. Delete the other two blocks completely.
3. Delete this SETUP section (from the opening comment through `<!-- END SETUP -->` inclusive).
4. Install the harness into root **`AGENTS.md`**:
   - **If `AGENTS.md` does not exist:** create it containing only the processed harness (the one environment block you kept).
   - **If `AGENTS.md` already exists** with project content: **do not replace the whole file.** Merge the harness in by **prepending**, **appending**, or adding a clear section (e.g. `## Skills harness`) so existing instructions stay intact.
5. Delete **`AGENTS_skills.md`** from the repository root (the temporary bootstrap file).

**Verify:** exactly one `[CURSOR]` / `[CODEX]` / `[COPILOT]` section remains in the merged `AGENTS.md`; this SETUP block is gone; `AGENTS_skills.md` is removed.

**Optional:** if merging is awkward, you may rename the existing file to `AGENTS.user.md` and import it from a new `AGENTS.md` — but never drop project instructions silently.

<!-- END SETUP -->

---

<!-- [CURSOR] -->
---
description: Skills harness for Cursor
alwaysApply: true
---

# Skills Harness (Cursor)

Skills are in `.skills/_skills/`. The index is at `.skills/_index.md`.

## Rules

- Read `.skills/_index.md` at the start of any non-trivial task.
- Load a skill's full `SKILL.md` only when the task matches its triggers in the index.
- Never load skills preemptively.
- If a skill lists `dependencies`, load those skills before proceeding.
- Add new skills to the index when you create them.
- If `.skills/` is missing from the repo, warn the user and do not invent skill content.
- If `AGENTS_skills.md` exists at the repository root, skills harness setup is incomplete: do not create or refactor skills or change `.skills/_index.md` for new skills until the user has declared their environment and `AGENTS_skills.md` is removed per bootstrap instructions.

<!-- END CURSOR -->

<!-- [CODEX] -->

# Skills Harness (Codex)

Skills are in `.skills/_skills/`. The index is at `.skills/_index.md`.

## Rules

- Read `.skills/_index.md` at the start of any non-trivial task.
- Load a skill's full `SKILL.md` only when the task matches its triggers in the index.
- Never load skills preemptively.
- If a skill lists `dependencies`, load those skills before proceeding.
- Add new skills to the index when you create them.
- If `.skills/` is missing from the repo, warn the user and do not invent skill content.
- If `AGENTS_skills.md` exists at the repository root, skills harness setup is incomplete: do not create or refactor skills or change `.skills/_index.md` for new skills until the user has declared their environment and `AGENTS_skills.md` is removed per bootstrap instructions.

<!-- END CODEX -->

<!-- [COPILOT] -->

# Skills Harness (Copilot)

Skills are in `.skills/_skills/`. The index is at `.skills/_index.md`.

## Rules

- Read `.skills/_index.md` at the start of any non-trivial task.
- Load a skill's full `SKILL.md` only when the task matches its triggers in the index.
- Never load skills preemptively.
- If a skill lists `dependencies`, load those skills before proceeding.
- Add new skills to the index when you create them.
- If `.skills/` is missing from the repo, warn the user and do not invent skill content.
- If `AGENTS_skills.md` exists at the repository root, skills harness setup is incomplete: do not create or refactor skills or change `.skills/_index.md` for new skills until the user has declared their environment and `AGENTS_skills.md` is removed per bootstrap instructions.

<!-- END COPILOT -->
