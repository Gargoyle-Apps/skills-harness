---
name: design-md-coord
description: "Coordinate skills-harness, AGENTS.md, and Google DESIGN.md for UI work without duplicating policy or design tokens."
triggers:
  - wire up design.md
  - add design.md
  - create design.md
  - lint design.md
  - coordinate agents and design
  - design.md and agents.md
  - google design.md format
  - move tokens out of agents.md
dependencies: []
version: "1.0.1"
---

# DESIGN.md Coordination

Coordinate three agent-facing surfaces so each owns one job: **harness** (on-demand procedures), **AGENTS.md** (always-on project policy), **DESIGN.md** ([Google Labs format](https://github.com/google-labs-code/design.md)) (visual identity).

## When to use this skill

Load when the user is:

- Adding or wiring `DESIGN.md` in a repo that already uses skills-harness
- Updating `AGENTS.md` to reference design tokens without inlining them
- Creating, linting, diffing, or exporting a `DESIGN.md` file
- Resolving overlap between harness skills, `AGENTS.md` prose, and design-system content

Do **not** load for generic UI tweaks when no `DESIGN.md` exists and the user did not ask to introduce one.

## Three-layer model

Read `references/coordination-roles.md` for the full role split. Summary:

| Layer | Location | Loaded | Owns |
|-------|----------|--------|------|
| **Harness** | `.skills/_index.md` + `.skills/_skills/` | On trigger match | Multi-step workflows (deploy, release, skill authoring, …) |
| **AGENTS.md** | Repo root (or tool sidecar) | Every session via harness rules | Project policy, conventions, *pointers* to skills and `DESIGN.md` |
| **DESIGN.md** | Repo root (default) or path declared in `AGENTS.md` | UI / visual / component work | Design tokens (YAML front matter) + design rationale (markdown) |

**Normative rule:** tokens live in `DESIGN.md` front matter; *why* they exist lives in `DESIGN.md` body. Neither belongs in `AGENTS.md` or skill files.

## Instructions

### 1. Confirm harness is bootstrapped

- If `AGENTS_skills.md` exists at repo root, finish Single-Tool or Tool-Neutral setup first (see that file). Do not add `DESIGN.md` wiring until bootstrap is done and `AGENTS_skills.md` is removed.
- Verify `.skills/_index.md` is present and the harness Rules block is installed (root `AGENTS.md`, tool config, or Tool-Neutral policy note).

### 2. Locate or create DESIGN.md

**Default path:** `DESIGN.md` at repository root (uppercase — matches the [spec](https://github.com/google-labs-code/design.md)).

If the file must live elsewhere (monorepo app package, `docs/design/DESIGN.md`), record the path once in `AGENTS.md` so every agent session resolves the same file.

**New file:** copy `assets/DESIGN.md.template` to the chosen path and edit tokens + prose. For schema and CLI details, read `references/design-md-quickref.md`.

### 3. Wire AGENTS.md (minimal pointer)

Add a short **Design system** block to root `AGENTS.md` (or the repo's Tool-Neutral policy file). Merge with existing harness content — do not replace the harness Rules block.

```markdown
## Design system

For UI, styling, components, and visual identity, read `DESIGN.md` at the repo root before implementing.
Use token values from its YAML front matter; use `##` sections for application context.
Validate with `.skills/_skills/design-md-coord/scripts/lint-design.sh` (or `npx -y -p @google/design.md designmd lint DESIGN.md`).
Do not duplicate design tokens or color/type scales in this file.
```

Adjust the `DESIGN.md` path if it is not at root. Keep this block under ~5 lines.

### 4. Validate DESIGN.md

Run the official linter (requires Node.js / `npx`):

```bash
npx -y -p @google/design.md designmd lint DESIGN.md
```

Or, when this skill is present in the repo:

```bash
.skills/_skills/design-md-coord/scripts/lint-design.sh [path/to/DESIGN.md]
```

- Exit `0` — proceed; warnings are informational unless the user asked for zero warnings.
- Exit `1` — fix `errors` in the JSON output before shipping UI that depends on broken token refs.

Other useful commands (see quickref): `diff`, `export`, `spec`.

### 5. Keep boundaries clean

| Do | Don't |
|----|-------|
| Put deploy/release/skill workflows in harness skills | Put those procedures in `DESIGN.md` |
| Point `AGENTS.md` at `DESIGN.md` for visual work | Paste hex codes or font stacks into `AGENTS.md` |
| Load **design-md-coord** for wiring and format questions | Preload this skill for non-UI backend tasks |
| Update `DESIGN.md` tokens when the design system changes | Mirror tokens into `SKILL.md` files |

### 6. Consumer repos with prefixes

Consumer-authored skills about design (e.g. `uxpm-brand-review`) follow **skill-author** prefix rules. Kit skill **design-md-coord** stays unprefixed when vendored from skills-harness.

## Examples

- "We use skills-harness — add DESIGN.md for our app" → copy template, lint, add AGENTS.md pointer block.
- "Lint our design file" → run `scripts/lint-design.sh` or `designmd lint`; report `summary.errors` first.
- "AGENTS.md has our color palette — move it to DESIGN.md" → extract tokens to YAML front matter, prose to `## Colors`, replace AGENTS block with pointer from step 3.

## Notes

- DESIGN.md format is **alpha**; expect schema drift. Pin `@google/design.md` in `package.json` for reproducible lint/export in CI.
- Spec: [github.com/google-labs-code/design.md](https://github.com/google-labs-code/design.md) · [stitch.withgoogle.com/docs/design-md/specification](https://stitch.withgoogle.com/docs/design-md/specification)
- Windows: use the `designmd` shim (`npx -y -p @google/design.md designmd …`) — see quickref. Always pass `-y` so agents/CI never hang on an install prompt.
