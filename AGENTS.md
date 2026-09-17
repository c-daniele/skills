# AGENTS.md

Personal skills repo. Flat layout: one directory per skill under `skills/`.

## Rules

- Each skill lives in `skills/<skill-name>/` with a required `SKILL.md` (frontmatter: `name`, `description`).
- `name` in frontmatter must match the directory name exactly.
- Keep `SKILL.md` lean; put detail in `references/`, templates in `assets/`, automation in `scripts/`.
- Never commit a nested `.git/` inside a skill directory.
- After adding or renaming a skill, update `README.md` (Skills table), `.claude-plugin/plugin.json` (`skills` array), and run `./scripts/verify-skills.sh`.
- Do not copy content from other skills repos. Original work only; the mattpocock repo is a structural reference, not a source.
