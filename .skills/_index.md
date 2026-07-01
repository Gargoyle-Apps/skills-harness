# Skills Index

Kit version: see `.skills/_meta.yml` (optional metadata only). Human-facing copies also appear in root `README.md` and `AGENTS_skills.md`; bump them with the **kit-release** skill and validate with `check.sh`.

Load a skill only when the task clearly requires it.
Read the full `SKILL.md` only at that point — never preemptively.

| name | description | triggers |
|------|-------------|----------|
| caveman-commit | Generate ultra-terse Conventional Commits messages (subject <=50 chars, why over what) with no fluff. | write a commit, commit message, generate commit, caveman commit, /commit, /caveman-commit |
| caveman-review | Write ultra-compressed one-line code review comments (location, problem, fix) with optional severity prefixes. | review this PR, code review, review the diff, caveman review, /review, /caveman-review |
| caveman | Ultra-compressed caveman communication mode that cuts ~75% of output tokens while preserving full technical accuracy; supports lite/full/ultra/wenyan intensity levels. | caveman mode, talk like caveman, use caveman, less tokens, be brief, compress output, /caveman |
| harness-subtree | Install or update the skills-harness kit in a consumer repository as a git subtree at .skills-harness/. | deploy harness as subtree, install harness as subtree, vendor skills-harness, update vendored harness, subtree pull skills-harness, skills harness subtree, add skills-harness subtree, migrate manual install to subtree, convert harness install to subtree |
| harness-upgrade | Upgrade a skills-harness installation to the latest version with native IDE discovery. | upgrade harness, update harness, migrate harness, add native discovery, enable IDE symlinks, update skills system |
| kit-release | Bump the skills-harness kit semver and keep CHANGELOG, README, AGENTS_skills.md, and _meta.yml in sync. | bump kit version, bump harness version, release skills harness, cut a harness release, skills-harness version, kit release |
| skill-author | How to write a new SKILL.md from scratch and register it in the index. | write a skill, author a skill, new skill, add a skill |
| skill-conflicts | Detect conflicts between repo-managed skills and same-named skills or slash-commands in the user's IDE config. | detect skill conflicts, skill conflict, conflicting skills, skill name collision, check skill conflicts, does my config conflict with repo skills |
| skill-template | Canonical SKILL.md format with authoring notes and refactor guide. | new skill, skill format, create skill, reformat skill, convert rule |

Add a row here whenever a new skill is added to `.skills/_skills/`.
