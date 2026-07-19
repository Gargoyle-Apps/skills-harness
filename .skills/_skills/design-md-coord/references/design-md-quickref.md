# DESIGN.md quick reference

Condensed from [google-labs-code/design.md](https://github.com/google-labs-code/design.md). Format version: **alpha**.

## File shape

```text
---
name: <system name>
colors: { ... }
typography: { ... }
rounded: { ... }
spacing: { ... }
components: { ... }
---

## Overview
## Colors
## Typography
...
```

Tokens in front matter are normative. Prose explains *how* to apply them.

## Token types

| Type | Example |
|------|---------|
| Color | `"#1A1C1E"`, `oklch(62% 0.18 250)` |
| Dimension | `8px`, `1rem` |
| Token reference | `{colors.primary}` |
| Typography object | `fontFamily`, `fontSize`, `fontWeight`, `lineHeight`, … |

## Section order (when present)

Overview → Colors → Typography → Layout → Elevation & Depth → Shapes → Components → Do's and Don'ts

## Component tokens

```yaml
components:
  button-primary:
    backgroundColor: "{colors.tertiary}"
    textColor: "{colors.on-tertiary}"
    rounded: "{rounded.sm}"
    padding: 12px
```

Define companion tokens such as `on-tertiary` in `colors:` when referencing them. Valid properties: `backgroundColor`, `textColor`, `typography`, `rounded`, `padding`, `size`, `height`, `width`. Variants use separate keys (e.g. `button-primary-hover`).

## CLI (`@google/design.md`)

Install: `npm install @google/design.md` or use `npx` (no install).

**Prefer the `designmd` shim** (Windows-safe):

```bash
npx -y -p @google/design.md designmd lint DESIGN.md
npx -y -p @google/design.md designmd diff DESIGN.md DESIGN-v2.md
npx -y -p @google/design.md designmd export --format css-tailwind DESIGN.md
npx -y -p @google/design.md designmd spec --rules
```

Always include `-y` so `npx` never prompts (agents/CI).

| Command | Purpose |
|---------|---------|
| `lint` | Structural validation + WCAG contrast checks; JSON findings; exit 1 on errors |
| `diff` | Token-level compare; exit 1 on regression |
| `export` | `json-tailwind`, `css-tailwind`, `dtcg` |
| `spec` | Print format spec (optional `--rules`, `--format json`) |

## Lint rules (severity)

| Rule | Severity | Checks |
|------|----------|--------|
| `broken-ref` | error | Unresolved `{token}` references |
| `missing-primary` | warning | Colors without `primary` |
| `contrast-ratio` | warning | Component pairs below WCAG AA |
| `orphaned-tokens` | warning | Colors never used in components |
| `missing-typography` | warning | Colors but no typography |
| `section-order` | warning | `##` sections out of order |
| `unknown-key` | warning | Likely YAML typos (`colours:` → `colors:`) |

## Programmatic API

```typescript
import { lint } from '@google/design.md/linter';
const report = lint(markdownString);
```

## Links

- Repo: https://github.com/google-labs-code/design.md
- Spec: https://stitch.withgoogle.com/docs/design-md/specification
- npm: https://www.npmjs.com/package/@google/design.md
