# Coordination roles: harness · AGENTS.md · DESIGN.md

## Why three files

Agents receive context from multiple sources. Without boundaries, design tokens drift into `AGENTS.md`, procedures land in `DESIGN.md`, and the harness index gets ignored. Each file answers a different question:

| Question | Answer in |
|----------|-----------|
| *What procedures exist and when should I load them?* | `.skills/_index.md` |
| *What are this repo's standing rules and where do I look?* | `AGENTS.md` |
| *What should the UI look like and which token values apply?* | `DESIGN.md` |

## Harness (`.skills/`)

- **Index** (`.skills/_index.md`) — lightweight routing table; read at the start of non-trivial work.
- **Skills** (`.skills/_skills/<name>/SKILL.md`) — full instructions loaded only when triggers match.
- **Harness scripts** (`.skills/_harness/`) — kit maintenance (`check.sh`, `link.sh`, …); not agent-facing procedures unless a skill points at them.

The harness Rules block (in `AGENTS.md` or tool config) tells the agent to use the index and avoid preemptive skill loads.

## AGENTS.md

Installed during skills-harness bootstrap (Single-Tool or Tool-Neutral). Permanent, always-on content:

- Skills harness Rules (read index, load on demand, keep index in sync)
- Project-wide conventions (naming, testing policy, security gates)
- **Pointers** — one-line directions to `DESIGN.md`, important skills, or external docs

AGENTS.md should stay small. If a section grows into a multi-step workflow, extract it to a skill. If it lists colors, fonts, or spacing values, move them to `DESIGN.md`.

## DESIGN.md

[DESIGN.md](https://github.com/google-labs-code/design.md) is a portable design-system file for coding agents:

1. **YAML front matter** — machine-readable tokens (`colors`, `typography`, `spacing`, `rounded`, `components`, …). Normative values.
2. **Markdown body** — human-readable rationale in ordered `##` sections (Overview, Colors, Typography, …). Application context.

Load `DESIGN.md` when the task touches UI, styling, layout, components, or brand. Do not load it for unrelated backend or infra work.

## Interaction flow

```text
Session start
    │
    ▼
AGENTS.md (always) ──► harness Rules ──► read .skills/_index.md
    │
    │                      trigger match ──► load SKILL.md (e.g. design-md-coord)
    │
    └──► "UI work?" ──yes──► read DESIGN.md (path from AGENTS.md or repo root)
```

## Conflict resolution

| Symptom | Fix |
|---------|-----|
| Same hex color in `AGENTS.md` and `DESIGN.md` | Remove from `AGENTS.md`; keep in `DESIGN.md` tokens |
| UI checklist in a skill and in `DESIGN.md` Do's/Don'ts | Keep checklist in `DESIGN.md`; skill only says "follow DESIGN.md" |
| Design export script in `AGENTS.md` | Move to a consumer skill or document `npx -y -p @google/design.md designmd export` in **design-md-coord** |
| Multiple `DESIGN.md` files without policy | Pick one canonical path; declare it in `AGENTS.md` |

## Tool-Neutral repos

Tool-Neutral installs have no committed IDE harness file — policy may live in `AGENTS.md`, `README`, or `CONTRIBUTING`. The same three-layer split applies: put the `DESIGN.md` pointer wherever the repo documents standing agent policy.
