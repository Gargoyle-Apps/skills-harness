<!-- SETUP — remove this entire section after setup is complete -->

## Setup instructions (Cursor, Codex, or Copilot)

1. Identify your environment: **Cursor**, **Codex**, or **GitHub Copilot** (VS Code / similar).
2. Keep **only** one environment block: `<!-- [CURSOR] -->` … `<!-- END CURSOR -->`, or `<!-- [CODEX] -->` … `<!-- END CODEX -->`, or `<!-- [COPILOT] -->` … `<!-- END COPILOT -->`. Delete the other two blocks completely.
3. Delete this SETUP section (from the opening comment through `<!-- END SETUP -->` inclusive).
4. Copy the remaining content to the repository root as `AGENTS.md`, replacing the bootstrap `AGENTS.md`.

**If `AGENTS.md` already has non-bootstrap content:** do not overwrite without a backup. Rename the existing file to `AGENTS.user.md`, merge your content with the harness **Rules**, or combine files deliberately.

**Verify:** exactly one `[CURSOR]` / `[CODEX]` / `[COPILOT]` section remains; this SETUP block is gone.

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

<!-- END COPILOT -->
