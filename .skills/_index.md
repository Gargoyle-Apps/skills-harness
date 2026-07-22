# Skills Index

Kit version: see `.skills/_meta.yml` (optional metadata only). Human-facing copies also appear in root `README.md` and `AGENTS_skills.md`; bump them with the **kit-release** skill and validate with `check.sh`.

Load a skill only when the task clearly requires it.
Read the full `SKILL.md` only at that point — never preemptively.

| name | description | triggers |
|------|-------------|----------|
| caveman-commit | When the user wants to write or generate a git commit message — ultra-terse Conventional Commits (subject ≤50 chars, why over what). | write a commit, commit message, generate commit, caveman commit, /commit, /caveman-commit |
| caveman-review | When the user wants a code or PR review — ultra-compressed one-line comments (location, problem, fix) with optional severity prefixes. | review this PR, code review, review the diff, caveman review, /review, /caveman-review |
| caveman | When the user wants terse or compressed replies without losing technical accuracy — ultra-compressed caveman output mode with lite/full/ultra/wenyan levels (~75% fewer tokens). | caveman mode, talk like caveman, use caveman, less tokens, be brief, compress output, /caveman |
| design-md-coord | Coordinate skills-harness, AGENTS.md, and Google DESIGN.md for UI work without duplicating policy or design tokens. | wire up design.md, add design.md, create design.md, lint design.md, coordinate agents and design, design.md and agents.md, google design.md format, move tokens out of agents.md |
| harness-subtree | Install or update the skills-harness kit in a consumer repo as a git subtree at .skills-harness/. | deploy harness as subtree, install harness as subtree, vendor skills-harness, update vendored harness, subtree pull skills-harness, skills harness subtree, add skills-harness subtree, migrate manual install to subtree, convert harness install to subtree |
| harness-upgrade | Upgrade a skills-harness install to the latest version with native IDE discovery. | upgrade harness, update harness, migrate harness, add native discovery, enable IDE symlinks, update skills system |
| kit-release | Bump skills-harness kit semver; keep CHANGELOG, README, AGENTS_skills.md, _meta.yml in sync. | bump kit version, bump harness version, release skills harness, cut a harness release, skills-harness version, kit release |
| skill-author | Creates a new SKILL.md from scratch and registers it in the harness index. Load when the user wants to author, add, or register a new skill. | write a skill, author a skill, new skill, add a skill |
| skill-catalog-maintainer | Audit skills under .skills/_skills/ for overlap, trigger collisions, size, and index drift; may edit skills with dry-run and confirmation. | skill inventory, catalog health, duplicate skill triggers, skill overlap, split this skill, skill catalog audit |
| skill-conflicts | Detect conflicts between repo-managed skills and same-named skills/slash-commands in the user's IDE config. | detect skill conflicts, skill conflict, conflicting skills, skill name collision, check skill conflicts, does my config conflict with repo skills |
| skill-export | Publish a skill from this repo to another repository via branch and PR; stamps upstream lineage on the target only. Never modifies this repo. | export skill, publish skill, share skill to another repo, push skill downstream |
| skill-import | Import or refresh a vendored skill from another git repo into .skills/_skills/ with upstream lineage and skill-reviewer validation. | import skill, vendor skill, pull skill from repo, refresh imported skill, update vendored skill |
| skill-reviewer | Review skill changes (SKILL.md, scripts/, references/, assets/) for quality, security, and harness layout. Use when a PR touches a skill or the user requests a skill review. | review skill, skill review, audit SKILL.md, review skill changes, skill security review, review this skill |
| skill-template | Documents the canonical SKILL.md layout and refactor guide for converting rules or docs into skills. Load when the user needs format guidance, reformatting, or conversion — not when authoring a new skill from scratch. | skill format, reformat skill, convert rule, skill layout, refactor to skill |

Add a row here whenever a new skill is added to `.skills/_skills/`.
