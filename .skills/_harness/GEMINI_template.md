<!-- SETUP — remove this entire section after setup is complete -->

## Setup instructions (Gemini CLI)

1. Copy the **Skills Harness** section below (from `# Skills Harness` through **Rules**) into a new file at the repository root named `GEMINI.md`, **or** merge into an existing `GEMINI.md` between `<!-- skills-harness start -->` and `<!-- skills-harness end -->`.
2. Delete this SETUP block from `GEMINI.md` when done.
3. **Project `AGENTS.md`:** add a pointer to `GEMINI.md`. If `AGENTS.md` does not exist, create it with the block below. If it already exists, **merge** the pointer — do not erase existing content.

```markdown
# Skills harness

Skills: see [GEMINI.md](./GEMINI.md).
```

Minimal one-liner: `Skills: see GEMINI.md`.

4. Delete **`AGENTS_skills.md`** from the repository root.

<!-- END SETUP -->

---

# Skills Harness

Skills are in `.skills/_skills/`. The index is at `.skills/_index.md`.

## Rules

- Read `.skills/_index.md` at the start of any non-trivial task.
- Load a skill's full `SKILL.md` only when the task matches its triggers in the index.
- Never load skills preemptively.
- If a skill lists `dependencies`, load those skills before proceeding.
- Add new skills to the index when you create them.
- If `.skills/` is missing from the repo, warn the user and do not invent skill content.
- If `AGENTS_skills.md` exists at the repository root, skills harness setup is incomplete: do not create or refactor skills or change `.skills/_index.md` for new skills until the user has declared their environment and `AGENTS_skills.md` is removed per bootstrap instructions.
