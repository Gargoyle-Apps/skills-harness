# Skills Harness — bootstrap (temporary)

This file is **`AGENTS_skills.md`** so dropping the kit into a repo **does not overwrite** an existing project **`AGENTS.md`**. It exists only until one-time setup is finished. After setup, **delete this file** (or replace it with a one-line pointer only if your template says so).

## Hard gate — declare a path before skills work

**Do not proceed** with skill authoring (create/rename/delete skills under `.skills/_skills/`, register rows in `.skills/_index.md`, refactor into skills, load full `SKILL.md` to author or restructure) until the user has chosen **one** of the paths below and you have completed the matching steps.

**Until then, you must not** do those skill tasks. You may still explain what the harness is or what to do next.

Reading `.skills/_index.md` only to describe the system is OK.

---

### Path A — Single ecosystem (runtime harness in *this* repo)

Use when this repository should install **one** tool’s harness so agents working *in this repo* load skills the same way (e.g. always Cursor, or always Claude Code).

1. **The user explicitly declares** which environment applies (one of: Cursor, Codex, GitHub Copilot, Claude Code, Cline, Windsurf, Gemini CLI, or Other / paste-only). Do not infer from filenames alone; if unclear, **ask**.
2. **Complete** the matching template under `.skills/_harness/` (SETUP removed, harness merged or written per that template). Remove **`AGENTS_skills.md`** when done.

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

**Note:** If the repo already has a project **`AGENTS.md`**, merge the **AGENTS** harness into it (prepend, append, or a dedicated section) — do not replace project instructions blindly. Same for pointers into an existing **`AGENTS.md`**.

---

### Path B — Agnostic / multi-ecosystem (skills only, no tool harness *in this repo*)

Use when this repository **maintains portable skills** (and may use this kit’s formats and bundled authoring skills) but **must stay neutral**: the same repo might be opened in Cursor, Claude, Windsurf, etc., and you **do not** want to commit **this** tree to a single ecosystem’s harness files.

1. **The user explicitly declares** agnostic mode — e.g. “agnostic”, “multi-ecosystem”, “skills only, no harness”, or equivalent. Do not assume; **ask** if unsure.
2. **Do not** paste **harness templates** from `.skills/_harness/*_template.md` into **`AGENTS.md`** or any tool-specific path **for this repo**. Those files are **reference** for *other* checkouts or consumers who run Path A (Cursor `[CURSOR]` blocks, `CLAUDE.md` harness body, etc.). Path B is **policy only**, not a runtime harness install.
3. **Existing `AGENTS.md`** (if any) stays the **project contract**. You may add a short **policy section** (see example below); do **not** replace or drown it with tool-specific harness markup from the templates.
4. **You may** create and edit skills under `.skills/_skills/`, update `.skills/_index.md`, and use **skill-template** / **skill-author** — the skills and index are **portable**.
5. **Record** Path B where agents and humans will see it. **Recommended:** add a section to root **`AGENTS.md`** (so agents that read it still have an authoring gate after **`AGENTS_skills.md`** is deleted). **Alternatively or additionally:** **README** or **CONTRIBUTING**. Say that `.skills/_harness/` is reference-only here unless this project later adopts Path A.
6. Remove **`AGENTS_skills.md`** once steps 1–5 are satisfied.

**Example — optional section to merge into root `AGENTS.md` (adapt wording):**

```markdown
## Skills (agnostic / multi-ecosystem)

This repo maintains portable skills under `.skills/` (manifest: `.skills/_index.md`). We do **not** install a tool-specific runtime harness from `.skills/_harness/*_template.md` in this tree; those files are **reference** for consumers who clone this repo and may run Path A in their own environment.

**Authoring:** Use bundled `skill-template` / `skill-author` and the index; do not paste ecosystem harness blocks into this file for this repository.
```

---

## One-time setup (Path A only — reference)

For Path A, open the template from the table, follow its **Setup instructions**, then remove **`AGENTS_skills.md`**.

Path B skips template installation; follow **Path B** above instead.
