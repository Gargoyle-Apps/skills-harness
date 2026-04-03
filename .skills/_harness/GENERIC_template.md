<!-- SETUP — remove this entire section after setup is complete -->

## Setup instructions (any other tool / paste-only)

1. Open your tool's **system**, **project**, or **custom instructions** field (or a pinned note the agent always reads).
2. Paste the **Skills Harness** section below (from `# Skills Harness` through **Rules**) into that field.
3. Delete this SETUP block from what you paste — only the harness content should remain in the tool.
4. **Project `AGENTS.md` (optional):** if you use one, merge in a pointer such as `Skills: see .skills/_harness/GENERIC_template.md` (after stripping SETUP there) instead of overwriting existing instructions.
5. Delete **`AGENTS_skills.md`** from the repository root.

**Limitation:** with paste-only setup there is no automatic progressive loading; keep `.skills/_index.md` small. For MCP-based progressive loading, see the README **Optional: MCP** section.

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
