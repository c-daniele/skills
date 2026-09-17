# Artifacts, placeholders and rendering

This reference defines how approved interview content becomes project files.

## Rendering algorithm

For each selected template:

1. Replace every `{{PLACEHOLDER}}` in selected content with approved content.
   Unknown values become masterplan open questions; use an `Assumption:` only
   when the rendered file truly requires a temporary choice. A placeholder in
   a block that will be deleted does not require a value.
   Preserve the template's indentation on every line of multiline values. In
   particular, indent every `{{TEST_COMMANDS}}` line by four spaces so its fenced
   block remains nested under the ordered workflow item.
2. Decide each conditional label independently.
   - If applicable, retain its content and delete the `BEGIN` and `END` marker
     lines without leaving extra blank lines that break Markdown structures.
   - If inapplicable, delete the complete block, including both marker lines.
3. Delete every complete `<!-- guidance: ... -->` comment.
4. Verify that no `{{`, `<!-- BEGIN:`, `<!-- END:` or `guidance:` remains.

Conditional markers are rendering syntax and never appear in generated files.

## Placeholder contract

Templates may use only the placeholders below.

| Placeholder | Meaning | Used by |
| --- | --- | --- |
| `{{PROJECT_NAME}}` | Human-readable project name | all document templates |
| `{{PROJECT_SLUG}}` | Repository or directory slug | kickoff brief, masterplan |
| `{{ONE_LINER}}` | One-sentence project description | brief, Manifesto, Agent Guide |
| `{{DATE}}` | Rendering date in `YYYY-MM-DD` | kickoff brief |
| `{{KICKOFF_STATUS}}` | Current artifact workflow state | kickoff brief |
| `{{INITIAL_PATH_INVENTORY}}` | Paths present before kickoff setup | kickoff brief |
| `{{SELECTED_OUTPUTS}}` | Exact approved project-relative outputs | kickoff brief |
| `{{PROBLEM}}` | Problem, motivation, timing and cost of inaction | brief, Manifesto |
| `{{USERS_AND_JOBS}}` | Primary/secondary users and their jobs | brief, Manifesto |
| `{{PRIORITY_RULE}}` | Approved tie-break rule | brief, Manifesto |
| `{{CORE_LOOP}}` | Repeating 3-7 actor-owned steps | brief, Manifesto |
| `{{SURFACES}}` | Multiple interfaces in approved priority order | brief, Manifesto |
| `{{DESIGN_PRINCIPLES}}` | Project-specific trade-off rules | brief, Manifesto |
| `{{BOUNDARIES}}` | Non-goals, exclusions and unsupported modes | brief, Manifesto |
| `{{RISKS}}` | Accepted risks with mitigation or revisit trigger | brief, Manifesto |
| `{{ARCHITECTURE_TRUTH}}` | Owner of covered and uncovered architecture behavior | Manifesto |
| `{{WHERE_WE_ARE}}` | Current-state paragraph | kickoff brief, masterplan |
| `{{GOALS}}` | Ordered measurable outcomes | brief, masterplan |
| `{{SUCCESS_CRITERIA}}` | Review and pivot signals | brief, masterplan |
| `{{CONSTRAINTS}}` | Fixed stack and operating constraints | brief, masterplan |
| `{{ROADMAP}}` | Ordered outcomes/epics, not task-level status | kickoff brief, masterplan |
| `{{GLOSSARY}}` | Domain terms and winning definitions | brief, masterplan |
| `{{OPEN_QUESTIONS}}` | Deferred questions with context | brief, masterplan |
| `{{DECISIONS_INDEX}}` | Decision links, or an approved empty-state sentence | masterplan |
| `{{JOURNAL_INDEX}}` | Journal links, or an approved empty-state sentence | masterplan |
| `{{WORKING_AGREEMENT}}` | Approved task, communication and collaboration rules | brief, Agent Guide |
| `{{REVIEW_POLICY}}` | Approved review and approval rules | Agent Guide |
| `{{GIT_POLICY}}` | Approved branch, merge and commit rules | Agent Guide |
| `{{JOURNAL_POLICY}}` | When and how journal entries are created | Agent Guide |
| `{{DECISION_POLICY}}` | When and how durable decisions are recorded | Agent Guide |
| `{{DEV_SETUP_COMMANDS}}` | Verified or explicitly approved setup commands | Agent Guide |
| `{{TEST_COMMANDS}}` | Verified or explicitly approved project checks | Agent Guide |
| `{{GENERAL_CODING_RULES}}` | Approved cross-language rules | coding standards |
| `{{PYTHON_STANDARDS}}` | Approved Python rules and commands | coding standards |
| `{{NODE_STANDARDS}}` | Approved Node.js/TypeScript rules and commands | coding standards |
| `{{BASH_STANDARDS}}` | Approved Bash rules and commands | coding standards |
| `{{OTHER_STANDARDS}}` | Approved rules for other stacks | coding standards |
| `{{SPECS_DECISION}}` | No specs, empty index or named domains | kickoff brief |
| `{{SPEC_DRAFTS}}` | Complete repeatable drafts for approved initial domains, or an explicit none state | kickoff brief |
| `{{SPEC_DOMAINS}}` | Links to created domain specs, or explicit empty state | specs index |
| `{{DOMAIN_NAME}}`, `{{DOMAIN_PURPOSE}}`, `{{SPEC_STATUS}}`, `{{SPEC_SCOPE}}`, `{{SPEC_REQUIREMENTS}}`, `{{SPEC_BEHAVIOR}}`, `{{SPEC_INVARIANTS}}`, `{{SPEC_REFERENCES}}` | Approved domain-spec content | domain spec |
| `{{ASSUMPTIONS}}` | Agent assumptions required by deferred inputs | kickoff brief |
| `{{DECOMPOSITION_STATUS}}` | Current task-decomposition workflow state | task-tree state |
| `{{TARGET_PROJECT_ROOT}}` | Absolute root used as `BACKLOG_CWD` | task-tree state |
| `{{WORKSTREAM_NOTES}}` | Resumable workstream interview notes | task-tree state |
| `{{TASK_TREE}}` | Exact proposed or approved task definitions | task-tree state |
| `{{CREATED_TASKS}}` | Created IDs mapped to approved task entries | task-tree state |

## Conditional labels

Every marker occupies a complete line, and each label is decided independently.

| Label | Keep when |
| --- | --- |
| `specs` | `docs/specs/README.md` is created |
| `standards` | `docs/coding-standards.md` is created |
| `surfaces` | More than one interface has an approved hierarchy |
| `journal` | The working agreement uses a journal |
| `decisions` | The working agreement uses durable decision records |
| `git` | The project uses Git and has an approved Git policy |
| `setup` | At least one exact setup command is approved |
| `tests` | At least one exact verification command is approved |
| `python`, `node`, `bash`, `other` | That stack has approved coding rules |

## Durable ownership

| Fact | Owner |
| --- | --- |
| Purpose, users, priority, core loop, principles, boundaries and risks | `MANIFESTO.md` |
| Current state, goals, success criteria, constraints, roadmap, glossary and open questions | `.backlog/masterplan/MASTERPLAN.md` |
| Executable work and status | `.backlog/tasks/` through the CLI |
| Working, review and Git agreements | `AGENTS.md` |
| Project-wide coding rules | `docs/coding-standards.md`, when created |
| Behavior explicitly covered by a domain spec | that file under `docs/specs/` |
| Decisions that outlive one task | `.backlog/decisions/`, when enabled |
| Completed-work history | `.backlog/docs/journal/`, when enabled |

`docs/specs/` does not own uncovered behavior. Without a domain spec, the
Manifesto and masterplan remain the approved product and architecture context.
Render `{{ARCHITECTURE_TRUTH}}` accordingly:

- no specs: “this Manifesto and `.backlog/masterplan/MASTERPLAN.md`”;
- specs present: “the applicable domain spec under `docs/specs/` for covered
  behavior; otherwise this Manifesto and the masterplan”.

## Generated layout

```text
<project>/
├── MANIFESTO.md
├── AGENTS.md
├── docs/                              # only when an optional doc is selected
│   ├── coding-standards.md            # optional
│   └── specs/                         # optional
│       ├── README.md
│       └── <domain>.md                # each approved domain, optional
└── .backlog/
    ├── config.yml
    ├── tasks/                         # CLI-only
    ├── decisions/                     # decision body exception only
    ├── docs/
    │   └── journal/                   # only when journal policy is enabled
    ├── masterplan/
    │   └── MASTERPLAN.md
    └── brainstorming/                 # temporary, never authoritative
```

## Before deleting the kickoff brief

1. Compare every populated brief section with the durable-ownership table.
2. Confirm selected optional paths did not already exist before writing.
3. Confirm every spec-index link resolves to a domain file created in the same
   approved operation.
4. Run the artifact verification in `SKILL.md`.
5. Delete only that kickoff's directory after all checks pass; preserve any
   unrelated brainstorming directories.

## Recovering staged artifact writes

After approval, mirror the exact approved proposal under the kickoff directory's
`approved/` subtree. Only after staging is complete and verified, atomically
record `artifacts-approved`, the destination list and staged-file checksums. The
transaction manifest then means:

- `artifacts-approved`: verify the staged tree against recorded checksums; never
  re-render it without renewed approval;
- `writing`: copy absent destinations; accept an existing destination only when
  it byte-matches the staged file;
- `verifying`: require every destination to match its staged file, then run link
  and token checks.

Never delete or overwrite different content while recovering. A mismatch is a
conflict to report, not permission to restart or regenerate approved content.
Install each absent destination atomically: copy to a temporary file in the same
parent directory, verify its staged checksum, then rename it into place. Never
stream or truncate a final destination.

## Backlog mutation boundaries

- Use Backlog CLI commands for tasks, drafts, documents and milestones.
- Create journal entries with `backlog doc create` and fill them with
  `backlog doc update`; never edit their Markdown directly.
- Create a durable decision with `backlog decision create`. Because current
  Backlog.md has no decision-content update command, filling Context, Decision
  and Consequences in that newly generated file is the sole direct-edit
  exception.
- Do not move completed tasks or rename task files by hand during normal work.
  If archival maintenance is required, report it as a separate operation rather
  than presenting it as part of the CLI-only workflow.
