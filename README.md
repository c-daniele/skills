# Skills

Personal collection of agent skills. Small, composable, and owned — not a fork of anyone else's repo.

Structure is loosely inspired by [mattpocock/skills](https://github.com/mattpocock/skills) (flat layout here instead of categorized, minimal tooling until needed).

## Skills

| Skill | What it does |
| --- | --- |
| [agentic-kickoff](skills/agentic-kickoff/SKILL.md) | Bootstrap or resume a greenfield project kickoff: constitution, masterplan, agent guide, coding standards/specs, and a Backlog.md board. |

## Installation

Copy editable files into your project with [skills.sh](https://skills.sh):

```bash
npx skills@latest add <your-github-user>/skills
```

Or, for Claude Code, install this repo as a plugin (see `.claude-plugin/plugin.json`). It ships the whole set as a managed bundle.

## Repo layout

```text
skills/
  <skill-name>/
    SKILL.md        # required: frontmatter (name, description) + instructions
    references/     # optional: detailed docs linked from SKILL.md
    assets/         # optional: templates, static files
    scripts/        # optional: helper/verification scripts
.claude-plugin/
  plugin.json       # plugin manifest listing each skill
scripts/
  verify-skills.sh  # checks every skill has a valid SKILL.md
AGENTS.md             # working agreement for agents in this repo
```

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter:

   ```markdown
   ---
   name: <skill-name>
   description: "What it does and when to use it."
   ---

   # <Title>
   ...
   ```

2. Keep `SKILL.md` lean. Move long-form detail into `references/`, templates into `assets/`, automation into `scripts/`.
3. Register it in `.claude-plugin/plugin.json` under `skills`.
4. Add a row to the Skills table above.
5. Run `./scripts/verify-skills.sh`.

## License

Apache-2.0 — see [LICENSE](LICENSE). Individual skills may carry their own `license:` frontmatter field; that field governs the skill content.
