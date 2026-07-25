---
name: toon-export
description: "When encoding agent-facing structured data as TOON from JSON, YAML, CSV, or emitters — normalize to JSON, encode via official CLI, strict-decode, and run mistake checks. One skill; no per-format siblings."
triggers:
  - toon export
  - encode toon
  - validate toon
  - json to toon
  - yaml to toon
  - csv to toon
  - toon format
  - write a .toon file
  - check toon
  - token efficient structured data
dependencies: []
version: "1.1.0"
---

# toon-export

Produce and validate **TOON** ([toonformat.dev](https://toonformat.dev)) for agent-consumed structured data. TOON is a **view** — YAML/JSON/Markdown/CSV stay authoritative sources when humans edit them.

**Model:** one skill, format-agnostic ingest → **JSON hub** → official encode → strict-decode. Do **not** add sibling skills (`yaml-to-toon`, `csv-to-toon`).

## When to use this skill

- Writing or updating any `*.toon` file in a repo
- Converting YAML, JSON, CSV, or script output into TOON for an agent turn
- Adding `--format toon` (or a TOON emitter) to a script
- After regenerating TOON from any source — must re-validate before commit

## When not to use

- Human-edited sources that should stay YAML/JSON/Markdown (`*.yaml`, `AGENTS.md`, `SKILL.md`, prose dashboards)
- Public REST APIs that already speak JSON
- Prose docs — do not "convert the README to TOON"
- Creating a second TOON skill for a single input format — extend this skill's adapters instead

## Hard rules (non-negotiable)

1. **Never hand-author TOON as the source of truth.** Normalize to a JSON object first; encode with the official CLI.
2. **Strict-decode every `.toon` before commit.** Fail closed.
3. **Stdout = TOON only.** Notes, headers, and explanations go to **stderr** or a sidecar `.md`.
4. **No `#` comment lines in `.toon` files.** `@toon-format/cli` v2.3.x rejects them even though some docs mention comments.
5. **Missing values = `null`.** Never use em dash `—`, empty cells, or `—` placeholders.
6. **Primitive arrays are inline:** `tags[3]: a,b,c` — not one value per line under the header.
7. Match encoder style: no decorative blank lines between root keys; do not over-quote (`1.5.0` stays unquoted).

## Instructions

### A. Pipeline (always)

```text
source (YAML | JSON | CSV | emitter)
        ↓  ingest adapter
      JSON object / array
        ↓  @toon-format/cli
      .toon
        ↓  -d --strict
      OK / fail closed
```

1. **Ingest** — get a JSON document (see [Ingest adapters](#b-ingest-adapters)).
2. **Encode** with the official CLI:

```bash
pnpm dlx @toon-format/cli path/to/data.json -o path/to/out.toon
# or
.skills/_skills/toon-export/scripts/encode-from-json.sh path/to/data.json path/to/out.toon
```

3. **Validate** (required):

```bash
.skills/_skills/toon-export/scripts/validate-toon.sh path/to/out.toon
```

### B. Ingest adapters

Adapters are **steps inside this skill**, not separate skills. Prefer existing repo export scripts when they already normalize to JSON.

| Source | How to reach JSON | Notes |
|--------|-------------------|-------|
| **JSON** | Use as-is | Preferred hub; matches TOON data model |
| **YAML** | Parse → JSON (e.g. `yq -o=json`, `uv run --with pyyaml`) | Nested maps OK; comments drop on parse |
| **CSV** | Header row → array of objects → JSON | Require explicit fields; empty cell → `null`; choose a named tabular root (`rows[N]{…}:`) |
| **Emitter** | Script builds JSON, then pipes through CLI | Prefer JSON in the script over hand-formatting TOON strings |

**CSV caution:** decide columns, nulls, and whether the root is a named table (`rows[N]{…}:`) before encoding. If the schema is unclear, stop and ask — do not invent columns.

**YAML caution:** deeply nested or comment-heavy authoring files stay YAML on disk; only export the **agent slice** you need.

Helper for CSV → JSON:

```bash
.skills/_skills/toon-export/scripts/csv-to-json.sh data.csv /tmp/data.json
.skills/_skills/toon-export/scripts/encode-from-json.sh /tmp/data.json data.toon
```

### C. Hand-edit only as last resort

If you must edit TOON by hand:

1. Apply the [mistakes checklist](references/mistakes-checklist.md) line by line
2. Run `validate-toon.sh` — **do not skip**
3. Prefer regenerating from JSON if validation fails twice

### D. Emitters (scripts)

When writing a shell/Python emitter:

| Requirement | Detail |
|-------------|--------|
| Clean stdout | Only TOON body |
| Notes | `>&2` or a `*_notes.md` |
| Counts | `[N]` must equal actual row/element count |
| Delimiter | Default comma; quote cells that contain `,` |
| Paths with spaces | Allowed unquoted (inner spaces) |
| Trailing hyphens / pipes | `ph-`, `mm-|mc-` OK inside comma-delimited cells |

Prefer: build JSON in the script, then pipe through `@toon-format/cli`, rather than hand-formatting TOON strings.

### E. Fit check (before encoding)

Ask: is the primary reader an **agent in the same turn**, and is the data a **uniform table** (or small nested JSON)?

| Fit | Examples |
|-----|----------|
| High | Repo scan results, registry tables, SQL/CSV result sets, uniform API payloads |
| Skip | Authoring YAML, skills markdown, human dashboards, deeply irregular JSON |

## Mistake gate (must pass)

Before finishing, confirm **all** of:

- [ ] Normalized to JSON (or used an emitter that you then strict-decoded)
- [ ] Encoded via `@toon-format/cli` (or `encode-from-json.sh`)
- [ ] `pnpm dlx @toon-format/cli -d --strict <file>` exits 0
- [ ] No line whose first non-space char is `#`
- [ ] No `—` placeholders
- [ ] Primitive arrays are single-line after the header
- [ ] Tabular `[N]` matches row count; field count per row matches `{fields}`
- [ ] Notes not on stdout (emitters)

Full checklist: [references/mistakes-checklist.md](references/mistakes-checklist.md)  
Encode/decode cheatsheet: [references/encode-decode.md](references/encode-decode.md)

## Examples

**Good — JSON hub then validate:**

```bash
.skills/_skills/toon-export/scripts/encode-from-json.sh /tmp/users.json exports/users.toon
```

**Good — YAML agent slice:**

```bash
yq -o=json config/slice.yaml > /tmp/slice.json
.skills/_skills/toon-export/scripts/encode-from-json.sh /tmp/slice.json /tmp/slice.toon
```

**Good — CSV via helper:**

```bash
.skills/_skills/toon-export/scripts/csv-to-json.sh exports/rows.csv /tmp/rows.json
.skills/_skills/toon-export/scripts/encode-from-json.sh /tmp/rows.json exports/rows.toon
```

**Bad — invent TOON by eye:**

```text
# User snapshot              ← REJECT: comment
tags[3]:
  api                        ← REJECT: multiline primitive array
  …
  admin,—,—                   ← REJECT: em dash placeholders
```

**Good — emitter stdout through strict decode:**

```bash
your-emitter --format toon "$REPO" 2>/tmp/notes.txt \
  | pnpm dlx @toon-format/cli -d --strict -
```

## Failure modes

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `Top-level document must start with a key-value…` | `#` comment or prose before first key | Remove comments; start with `key:` or `[N]:` |
| Strict decode fails | Wrong `[N]`, bad quoting, multiline primitive array | Regenerate from JSON; see mistakes checklist |
| CSV columns ambiguous | Header missing or ragged rows | Stop and ask; define schema before ingest |
| `pnpm dlx` not found | Missing Node/pnpm | Install via mise or use `npx @toon-format/cli` |

## Notes

- CLI package: `@toon-format/cli` (pin via whatever version `pnpm dlx` resolves; re-run validate after CLI major bumps).
- Spec: [Format overview](https://toonformat.dev/guide/format-overview). Prefer CLI behavior over docs when they disagree (e.g. comments).
- Consumer repos may wrap this skill with repo-specific paths and export scripts (e.g. `cj-toon-export` in Conventional Johnson) via `dependencies:` — still one JSON hub, no per-format sibling skills.
