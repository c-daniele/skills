# Artifacts, placeholders and rendering

This reference defines how approved interview content becomes project files.
The OpenSpec profile adds the kit described in
[spec-driven-workflow.md](spec-driven-workflow.md). Existing repositories follow
[brownfield-adoption.md](brownfield-adoption.md) for approved in-place patches.
Role contracts and delegation policy follow [delegation.md](delegation.md) and
can be selected with any specification profile.

## Rendering algorithm

For each selected template:

1. Replace every `{{PLACEHOLDER}}` in selected content with approved content.
   Unknown values become questions in the masterplan or the brownfield source
   map's question owner; use an `Assumption:` only when the rendered file truly
   requires a temporary choice. A placeholder in a block that will be deleted
   does not require a value.
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
The `assets/openspec/` trees are different: copy these runtime schema/template
assets intact. Their comments and angle-bracket skeletons are instructions for
future change authoring, not unrendered kickoff content.

## Placeholder contract

Templates may use only the placeholders below.

| Placeholder | Meaning | Used by |
| --- | --- | --- |
| `{{PROJECT_NAME}}` | Human-readable project name | all document templates |
| `{{PROJECT_SLUG}}` | Repository or directory slug | kickoff brief, masterplan |
| `{{ONE_LINER}}` | One-sentence project description | brief, Manifesto, Agent Guide |
| `{{DATE}}` | Rendering date in `YYYY-MM-DD` | kickoff brief |
| `{{KICKOFF_STATUS}}` | Current artifact workflow state | kickoff/adoption brief |
| `{{INITIAL_PATH_INVENTORY}}` | Paths present before setup | kickoff/adoption brief |
| `{{SELECTED_OUTPUTS}}` | Exact approved outputs and checksums; adoption also records create/update and preimages | kickoff/adoption brief |
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
| `{{DELEGATION_POLICY}}` | Approved allowed roles, triggers, required/advisory review, limits and fallback; includes explicit single-agent decisions | kickoff/adoption brief, Agent Guide, guide addition |
| `{{AGENT_GUIDE_LINK}}` | Markdown link from the role document to the actual policy-owning guide, adjusted for its location | role contracts |
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
| `{{SPECS_DECISION}}` | None, plain Markdown or OpenSpec + Backlog, with selected initial scope | kickoff/adoption brief |
| `{{SPEC_DRAFTS}}` | Complete approved domain/baseline/change drafts with paths and schema selection, or explicit none | kickoff/adoption brief |
| `{{SPEC_DOMAINS}}` | Links to created domain specs, or explicit empty state | specs index |
| `{{DOMAIN_NAME}}`, `{{DOMAIN_PURPOSE}}`, `{{SPEC_STATUS}}`, `{{SPEC_SCOPE}}`, `{{SPEC_REQUIREMENTS}}`, `{{SPEC_BEHAVIOR}}`, `{{SPEC_INVARIANTS}}`, `{{SPEC_REFERENCES}}` | Approved domain-spec content | domain spec |
| `{{ASSUMPTIONS}}` | Agent assumptions required by deferred inputs | kickoff brief |
| `{{DECOMPOSITION_STATUS}}` | Current task-decomposition workflow state | task-tree state |
| `{{TARGET_PROJECT_ROOT}}` | Absolute root used as `BACKLOG_CWD` | task-tree/adoption state, delegation handoff |
| `{{WORKSTREAM_NOTES}}` | Resumable workstream interview notes | task-tree state |
| `{{TASK_TREE}}` | Exact proposed or approved task definitions | task-tree state |
| `{{CREATED_TASKS}}` | Created IDs mapped to approved task entries | task-tree state |
| `{{BACKLOG_DIR}}` | Actual repository-relative board directory, `.backlog` for a fresh kickoff | hybrid workflow, adoption brief, agent-guide addition |
| `{{SPEC_SOURCE_MAP}}` | Approved concern-to-owner map; adjust relative links to the rendered file's location | kickoff/adoption brief, hybrid workflow |
| `{{SPEC_POLICY}}` | Approved direct/lean/design thresholds and review points; link to the guide's approval/delegation policies instead of copying them | kickoff/adoption brief, hybrid workflow |
| `{{ADOPTION_NOTES}}` | Adoption boundary, observations, evidence and unresolved ownership/migration choices | adoption brief |
| `{{BASELINE_EVIDENCE}}` | Inspected source/test/runtime evidence, revision and approval for current behavior | OpenSpec baseline |
| `{{CHANGE_ID}}` | Immutable kebab-case OpenSpec change ID | task description, task-tree state |
| `{{REQUIREMENT_IDS}}` | Covered requirement IDs (or exact legacy headings) and scenario names | task description, task-tree state |
| `{{TASK_OUTCOME}}`, `{{TASK_SCOPE}}`, `{{TASK_VERIFICATION}}` | Approved task outcome, bounded scope and expected evidence; actual results are recorded later | Backlog task description input |
| `{{DELEGATE_ROLE}}` | Assigned responsibility, not a runtime agent/model ID | delegation handoff |
| `{{DELEGATION_OBJECTIVE}}` | One bounded question/work unit and the approved trigger authorizing this call | delegation handoff |
| `{{DELEGATION_INPUTS}}` | Relevant role/policy, source paths or scoped content, task/requirement IDs and exact input snapshot | delegation handoff |
| `{{DELEGATION_BOUNDARIES}}` | Allowed operations/checks, write set and owner; no writes for reviewer/explorer | delegation handoff |
| `{{DELEGATION_DELIVERABLE}}` | Concrete expected response, evidence and completion condition | delegation handoff |
| `{{DELEGATION_LIMITS}}` | Approved concurrency/round budget, stop conditions and questions to return to the primary | delegation handoff |
| `{{REVIEW_SCOPE}}` | Actual independent/self-review provenance, reviewer identity when known, objective, snapshot and inspected scope | review result |
| `{{REVIEW_FINDINGS}}` | Findings with impact, contract reference and evidence, or an explicit no-findings-in-scope statement | review result |
| `{{REVIEW_EVIDENCE}}` | Checks actually run and results, distinguished from supplied evidence only inspected | review result |
| `{{REVIEW_GAPS}}` | Unreviewed areas, unavailable inputs and unrun checks | review result |

## Conditional labels

Every marker occupies a complete line, and each label is decided independently.

| Label | Keep when |
| --- | --- |
| `specs` | The plain-spec profile creates `docs/specs/README.md` |
| `openspec` | The hybrid profile creates `docs/spec-workflow.md` and its OpenSpec kit |
| `delegation` | `docs/agent-roles.md` is selected; this renders contracts, not authorization to spawn agents |
| `standards` | `docs/coding-standards.md` is created |
| `surfaces` | More than one interface has an approved hierarchy |
| `journal` | The working agreement uses a journal |
| `decisions` | The working agreement uses durable decision records |
| `git` | The project uses Git and has an approved Git policy |
| `setup` | At least one exact setup command is approved |
| `tests` | At least one exact verification command is approved |
| `python`, `node`, `bash`, `other` | That stack has approved coding rules |

`specs` and `openspec` are alternative generated profiles. Select at most one;
pre-existing specifications in another location are handled by the source map,
not silently deleted or copied. Each other conditional remains independent.
In particular, `delegation` works with no specs, plain specs or OpenSpec. Always
render the approved `DELEGATION_POLICY` in the guide, even when the role document
is declined or the user permits only one primary agent. Retain the `openspec`
block inside role contracts only when that workflow is selected too.

## Durable ownership

| Fact | Owner |
| --- | --- |
| Purpose, users, priority, core loop, principles, boundaries and risks | `MANIFESTO.md` |
| Current state, goals, success criteria, constraints, roadmap, glossary and open questions | `.backlog/masterplan/MASTERPLAN.md` |
| Executable work and status | `.backlog/tasks/` through the CLI |
| Working, review and Git agreements | `AGENTS.md` |
| Approved delegation policy and required/advisory review choices | applicable project agent guide |
| Role responsibilities, handoff and review-result contracts | `docs/agent-roles.md`, when selected |
| Project-wide coding rules | `docs/coding-standards.md`, when created |
| Behavior explicitly covered by a domain spec | that file under `docs/specs/` |
| Hybrid specification ownership, depth policy and closure procedure | `docs/spec-workflow.md` |
| Approved current behavior in the hybrid profile | applicable `openspec/specs/<capability>/spec.md`, or an explicitly mapped external contract |
| Intended behavioral change | approved delta in `openspec/changes/<id>/specs/`; drafts are not normative |
| Change intent and scope | change `proposal.md` |
| Change mechanisms and trade-offs | change `design.md` when needed; link durable ADRs |
| Decisions that outlive one task | `.backlog/decisions/`, when enabled |
| Completed-work history | `.backlog/docs/journal/`, when enabled |

`docs/specs/` does not own uncovered behavior. Without a domain spec, the
Manifesto and masterplan remain the approved product and architecture context.
Render `{{ARCHITECTURE_TRUTH}}` accordingly:

- no specs: “this Manifesto and `.backlog/masterplan/MASTERPLAN.md`”;
- specs present: “the applicable domain spec under `docs/specs/` for covered
  behavior; otherwise this Manifesto and the masterplan”;
- hybrid profile: link to `docs/spec-workflow.md` as the source map, distinguishing
  current behavioral contracts, approved change deltas and technical design.

For a fresh hybrid kickoff, the source map names the Manifesto (constitution),
masterplan (outcomes, constraints, roadmap and open questions), OpenSpec baseline
and change paths, Backlog tasks (execution/evidence), and the actual decision
owner when enabled. Code is observed evidence, not an automatic normative owner.
For brownfield, render the actual existing owners and actual board path. Do not
link to missing greenfield core files. The map locates facts; it does not repeat
their content.

## Generated layout

```text
<project>/
├── MANIFESTO.md
├── AGENTS.md
├── docs/                              # only when an optional doc is selected
│   ├── coding-standards.md            # optional
│   ├── agent-roles.md                 # optional, independent of spec profile
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

For the hybrid profile, replace generated `docs/specs/` with:

```text
docs/spec-workflow.md
openspec/
├── config.yaml
├── schemas/
│   ├── backlog-lean/                   # schema.yaml + proposal/spec templates
│   └── backlog-design/                 # adds the design artifact/template
├── specs/
│   └── <capability>/spec.md             # approved current baseline, when present
└── changes/
    ├── <change-id>/                    # initial/future behavior, when selected
    │   ├── .openspec.yaml
    │   ├── proposal.md
    │   ├── specs/<capability>/spec.md
    │   └── design.md                   # only for backlog-design
    └── archive/                        # delivered change history
```

This is a layout, not an instruction to create sample capabilities or changes.
An empty baseline and zero changes are valid for workflow-only setup. Initial
greenfield specifications use changes; one-time brownfield baselines use
`OPENSPEC-BASELINE.md.tmpl`. Tasks use `BACKLOG-SPEC-TASK.md.tmpl` as CLI input,
not as a separately installed or hand-edited board file.

`DELEGATION-HANDOFF.md.tmpl` and `REVIEW-RESULT.md.tmpl` are message templates,
not required installed project records. Lasting findings/dispositions go to the
existing task/proposal/review owner; they do not create a second execution log.
When adopting into a nested agent guide, adjust links in both the guide addition
and `AGENT_GUIDE_LINK` so they point to the actual selected owners.

## Before deleting the kickoff brief

1. Compare every populated brief section with the durable-ownership table.
2. Confirm selected optional paths did not already exist before writing.
3. Confirm every spec-index link resolves to a domain file created in the same
   approved operation.
4. Run the artifact verification in `SKILL.md`.
5. Delete only that kickoff's directory after all checks pass; preserve any
   unrelated brainstorming directories.

For hybrid runs, validate both schemas and every selected change/baseline. Check
that all approved initial drafts and lasting baseline evidence have durable
owners; never delete a brief containing the only copy of an initial change.

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
