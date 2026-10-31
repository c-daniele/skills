# Skills

Personal collection of agent skills. Small, composable, and owned — not a fork of anyone else's repo.

Structure is loosely inspired by [mattpocock/skills](https://github.com/mattpocock/skills) (flat layout here instead of categorized, minimal tooling until needed).

## Skills

| Skill | What it does |
| --- | --- |
| [agentic-kickoff](skills/agentic-kickoff/SKILL.md) | Kick off greenfield projects or adopt SDD in brownfield repositories: project context, agent agreement, optional OpenSpec specifications, explicit roles with optional independent review, and Backlog.md as the sole task board. |
| [live-testing](skills/live-testing/SKILL.md) | Collaborate on live tests with Playwright, answer UI questions, and collect feedback in a persistent scratchbook. Create new tasks only after explicit final approval; do not implement changes. |

### Agentic kickoff profiles

- Project context and Backlog.md, with optional plain Markdown specifications.
- [OpenSpec + Backlog](skills/agentic-kickoff/references/spec-driven-workflow.md):
  direct tasks for contract-preserving work, lean behavior specs, and a design
  artifact only when technical decisions need it.
- [Brownfield adoption](skills/agentic-kickoff/references/brownfield-adoption.md):
  reuse existing documents and tasks, baseline the first touched capability and
  introduce the workflow incrementally. Documents-only completion is supported.
- [Roles and optional delegation](skills/agentic-kickoff/references/delegation.md):
  keep scoping/planning with the primary agent, enable a read-only reviewer on
  approved triggers, and use bounded artifact-based handoffs. Available with any
  specification profile; the project guide owns the actual delegation policy.

## Installation

### Claude Code (plugin)

Install the whole set as a managed bundle, straight from GitHub:

```text
/plugin install cdaniele-skills --marketplace c-daniele/skills
```

Or from a shell:

```bash
claude plugin marketplace add c-daniele/skills
claude plugin install cdaniele-skills@cdaniele-skills
```

Components are namespaced under the plugin name (`cdaniele-skills:agentic-kickoff`). Users receive updates when `version` in `.claude-plugin/plugin.json` changes.

### Other agents (skills.sh)

Copy editable files into your project with [skills.sh](https://skills.sh):

```bash
npx skills@latest add c-daniele/skills --skill agentic-kickoff
```

Add `-g` for a user-level install, or `--copy` to get real files instead of symlinks.

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
  marketplace.json  # catalog that lets Claude Code install the plugin
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
