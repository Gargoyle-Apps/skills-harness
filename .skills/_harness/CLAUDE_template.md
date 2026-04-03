<!-- SETUP — remove this entire section after setup is complete -->

## Setup instructions (Claude Code)

1. Copy the **Skills Harness** section below (from `# Skills Harness` through **Rules**) into a new file at the repository root named `CLAUDE.md`, **or** merge into an existing `CLAUDE.md` between `<!-- skills-harness start -->` and `<!-- skills-harness end -->`.
2. Delete this SETUP block from `CLAUDE.md` when done.
3. Replace root `AGENTS.md` with a pointer to `CLAUDE.md` (replace the bootstrap):

```markdown
# Skills harness

Skills: see [CLAUDE.md](./CLAUDE.md).
```

If you prefer a minimal file, a single line is enough: `Skills: see CLAUDE.md`.

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
