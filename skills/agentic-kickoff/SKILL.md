---
name: agentic-kickoff
description: "Bootstrap or resume a greenfield project kickoff, or adopt a specification workflow in an existing brownfield repository. Use when the user asks to scope a new project, write its initial masterplan, make a repository ready for coding agents, continue an interrupted kickoff, or introduce OpenSpec specifications with Backlog.md task management. Produces project context and an agent agreement, with optional plain specs or a lean OpenSpec + Backlog workflow, explicit roles and optional independent review. Supports documents-only completion, incremental brownfield baselines and optional task decomposition. Not for ordinary implementation tasks in an already configured project."
license: Apache-2.0
compatibility: "Runtime requires Bash and Backlog.md >=1.50.1 and <2.0.0. The optional hybrid profile uses OpenSpec project-local schemas (smoke-tested with 1.4.0); inspect and validate the installed CLI. Git is optional. Installing CLIs requires a supported Node.js LTS release and npm. Writes only inside the target project directory."
metadata:
  author: sch
  version: "1.3.0"
---

# Agentic Kickoff

Set up a new project or introduce a specification workflow into an existing one.
Give humans and coding agents clear owners for intent, behavior, design and
execution. Backlog.md remains the only task board.

## Choose the entry route

- **New project or interrupted kickoff:** follow Phases 0-3 below.
- **Existing project adopting SDD, including a completed kickoff:** follow
  [brownfield adoption](references/brownfield-adoption.md) before any setup
  mutation. Reuse existing context and task configuration; interview only gaps.
- **Specification profile:** keep no-specs and plain Markdown modes available.
  When the user asks for structured SDD, recommend
  [OpenSpec + Backlog](references/spec-driven-workflow.md): direct tasks for
  contract-preserving work, `backlog-lean` for behavior changes, and
  `backlog-design` when technical decisions need a design artifact.

The kickoff/adoption can finish with approved documents and zero tasks. This
skill installs the working agreement; ordinary execution follows that agreement.

## What this skill produces

| Artifact | Purpose |
| --- | --- |
| `MANIFESTO.md` | Project constitution; wins on conflict with any other document. |
| `.backlog/masterplan/MASTERPLAN.md` | Always-current state, roadmap, decisions, open questions. |
| `AGENTS.md` | Agent entry point and working agreement. |
| `docs/agent-roles.md` | Optional role contracts, bounded delegation and review-result handling. |
| `docs/coding-standards.md` | Per-language rules, when the user wants them now. |
| `.backlog/` | Backlog.md board: tasks, docs (journal), decisions. |
| `docs/specs/` | Optional plain-spec profile. |
| `docs/spec-workflow.md` | Optional hybrid profile: source map, depth policy, handoff and closure. |
| `openspec/config.yaml`, `openspec/schemas/` | Optional project-local `backlog-lean` and `backlog-design` workflows. |
| `openspec/specs/`, `openspec/changes/` | Optional approved baselines and scoped behavioral changes. |

In brownfield adoption, use the discovered board directory and existing document
owners instead of assuming the greenfield `.backlog/` layout.

## Hard rules

1. **One topic at a time.** Ask, then wait for the answer. Never batch questions.
2. **Never invent a business answer.** If the user defers, offer two or three
   candidate answers to choose from; if they still defer, record an open
   question and mark any dependent guess `Assumption: ...`.
3. **Approval before durable writes.** Propose, get approval, then write.
   `backlog init` and directory creation are setup, not proposals.
4. **Specs are opt-in.** Select no specs, plain specs or OpenSpec + Backlog.
   Without the selected profile, strip its generated links and conditional
   blocks. Never create two normative owners for the same requirement.
5. **English kickoff records.** The conversation may be in another language;
   files produced directly by this kickoff are English. Product copy, code
   comments and future documentation follow the approved language policy in
   `AGENTS.md`.
6. **No dangling links.** Every relative link in a written file must resolve.
7. **Backlog files are CLI-only.** Never hand-edit the board's tasks, documents
   or milestones (under `.backlog/` in a fresh kickoff). Decision bodies are the
   sole exception: after `backlog decision create`, fill the generated decision
   file because Backlog.md has no decision-content update command.
8. **A long opening description is input, not an interview.** Still walk the
   checklist; extract what was said and ask about the rest.
9. **Ask before acting on the machine** when installing software or creating a
   git repository.
10. **Separate behavior, design and execution.** Requirements state observable
    contracts, design explains mechanisms, Backlog owns tasks and evidence.
    Never mirror task status in OpenSpec. Artifact readiness is not completion.
11. **Delegation is explicit and bounded.** Role names do not authorize agent
    calls. Follow the approved delegation policy and runtime restrictions; keep
    one writer per shared artifact and distinguish independent from self-review.

## Roles and optional delegation

Read [references/delegation.md](references/delegation.md) when defining the working
agreement or adopting roles. Keep scoping and planning with the primary agent;
recommend an on-demand read-only reviewer as the first delegate. An explorer can
answer bounded brownfield questions when authorized. Separate planning or
implementation agents require explicit permission and a bounded assignment.

Record the approved policy in the agent guide, including a single-agent choice.
When selected, generate role contracts independently of the spec profile. Use
the existing review points; adding roles creates no new approval gates. Kickoff
and Phase 2 remain advisory/document/task work, never implicit implementation.

## Phase 0 - Preconditions

Run every Backlog command from the target project root with `BACKLOG_CWD`
explicitly set to that absolute root (for example,
`BACKLOG_CWD="$PWD" backlog ...`). Never inherit an unrelated `BACKLOG_CWD`;
before any mutation, confirm `backlog config get projectName` identifies the
target project once a board exists.

1. Before writing anything, collect and confirm Phase 1 topic 1: project name,
   repository slug and one-line description. Use the approved project name for
   `backlog init`; never guess it.
2. Before classifying the repository, run `backlog config list`. If it succeeds,
   an existing Backlog project is already discoverable here (including a root
   config or custom board directory), so this is not a fresh default-layout
   kickoff. Continue only when it is this skill's resumable or completed state,
   or route an explicit adoption request to the brownfield reference. Otherwise
   stop rather than reinitialize or relocate it.
3. Inventory the exact core and optional output paths: `.backlog/config.yml`,
   `MANIFESTO.md`, `AGENTS.md`, `.backlog/masterplan/MASTERPLAN.md`,
   `docs/coding-standards.md`, `docs/agent-roles.md`, `docs/specs/`,
   `docs/spec-workflow.md` and `openspec/` (config, schemas, specs and changes).
   Preserve this initial inventory
   in the kickoff brief; an unselected pre-existing optional path is left alone.
   A root-level `MASTERPLAN.md` alone is not one of this skill's targets.
4. Classify the repository without guessing. At every branch, compare identity
   only with stores that exist: approved project name versus Backlog
   `projectName`; name and slug versus the kickoff brief when present; name and
   slug versus the masterplan when present. Stop on any available mismatch:
   - No `.backlog/`, core document or existing OpenSpec setup is a fresh kickoff;
     continue below. Existing project context can instead require adoption.
   - A board config with no core documents and no kickoff brief is an interrupted
     post-initialization state. Resume only if its project name matches the
     approved identity and its task board is empty; create the brief immediately.
   - Exactly one `.backlog/brainstorming/*.Kickoff/KICKOFF-BRIEF.md` means a
     resumable kickoff. Its status and selected-output manifest decide whether to
     resume the interview, staged installation or verification. Existing partial
     outputs must byte-match their files under that kickoff's `approved/` tree;
     otherwise stop and report the conflict.
   - All three core documents plus the board config, with no kickoff brief, mean
     document kickoff is complete. Do not overwrite them. Continue into Phase 2
     only when explicitly requested.
   - Multiple kickoff briefs, a nonempty untracked board, or any state not covered
     above is ambiguous. Stop and list the conflicting paths.
5. For a fresh kickoff, run `git rev-parse --is-inside-work-tree`. If false, ask
   once whether to run `git init` or scaffold without git. Without git, add
   `--no-git` to `backlog init`.
6. Backlog CLI: from the skill root (the directory holding this `SKILL.md`), run
   `bash scripts/ensure-backlog.sh`. Handle its result once: exit 3 means ask
   permission to install, then run
   `AGENTIC_KICKOFF_INSTALL=1 bash scripts/ensure-backlog.sh`; exits 4-7 are
   blockers whose emitted message must be reported without retrying.
7. For a fresh kickoff, initialise the board:

   ```bash
   BACKLOG_CWD="$PWD" backlog init "<approved project name>" --defaults \
     --integration-mode none \
     --backlog-dir .backlog --config-location folder [--no-git]
   ```

   `--integration-mode none` is required: this skill writes the complete
   `AGENTS.md`, so Backlog.md must not inject generic instructions. Do not
   combine it with `--agent-instructions`; current Backlog.md rejects that pair.
8. Create the directories Backlog.md does not:
   `mkdir -p .backlog/masterplan .backlog/brainstorming`. Create
   `.backlog/docs/journal` later only when the approved working agreement uses a
   journal.
9. Immediately create exactly one dated kickoff brief from
   `assets/templates/KICKOFF-BRIEF.md.tmpl`. Set its status to `interviewing`,
   record identity and the initial path inventory, and mark every unanswered
   section `Incomplete`. This closes the post-initialization interruption window.

## Phase 1 - Scoping interview

Read [references/phase-1-scoping.md](references/phase-1-scoping.md) and work its
coverage checklist **one topic per message**, in order, beginning with topic 2
because identity was approved in Phase 0. Challenge vague answers before moving
on, and propose non-goals and risks the user may not have considered.

Capture each answer in the existing
`.backlog/brainstorming/<YYYY-MM-DD>.Kickoff/KICKOFF-BRIEF.md`. This is resumable
interview state, not an approved source of truth. Update it after each answer;
never create a second kickoff brief.

When the checklist is complete, derive and **propose** the documents from the
brief, following [references/artifacts.md](references/artifacts.md):

- `MANIFESTO.md` from `assets/templates/MANIFESTO.md.tmpl`
- `.backlog/masterplan/MASTERPLAN.md` from `assets/templates/MASTERPLAN.md.tmpl`
- `AGENTS.md` from `assets/templates/AGENTS.md.tmpl`
- `docs/agent-roles.md` from `assets/templates/agent-roles.md.tmpl`, only when
  selected; fill the actual policy-owning guide link and delegation policy
- `docs/coding-standards.md` from `assets/templates/coding-standards.md.tmpl`,
  only if the user wants project-wide standards now
- `docs/specs/README.md` from `assets/templates/specs-README.md.tmpl`, only if
  the user selected the plain-spec profile
- `docs/specs/<approved-domain>.md` from `assets/templates/SPEC.md.tmpl`, one
  per domain whose plain-spec content the user approved now
- For OpenSpec + Backlog, follow
  [the hybrid profile](references/spec-driven-workflow.md) to stage the workflow,
  config, schemas and any approved initial change artifacts. Future greenfield
  behavior is a change delta, not an already implemented baseline.

Decide **every** conditional label independently using the table in
`references/artifacts.md`. Keep applicable content and remove its marker lines;
delete each inapplicable block including its markers. Do not infer setup/test
commands, language rules, Git policy, journaling or ADR policy.

Present the complete rendered proposals, open questions and assumptions. Before
writing, recheck every selected destination and stop rather than overwrite a
path absent from the initial inventory but created during the interview. On
approval:

1. Render the exact approved proposal into `<Kickoff>/approved/`, mirroring final
   project-relative paths. Verify the staged tree, then atomically record status
   `artifacts-approved`, the selected destination list and a checksum for every
   staged file. Never re-render an approved staged tree during recovery; a
   missing file or checksum mismatch requires renewed approval.
2. Set status `writing` immediately before installing staged files. Install each
   destination atomically: create its parent, write or copy to a temporary file
   in that same directory, verify its checksum, then rename it to the absent
   destination. Never stream directly into a final path.
3. Install only selected destinations that are absent, or that already
   byte-match their staged counterpart after an interrupted install. Never
   overwrite different content. Set status `verifying` after installation.
4. Run the document checks in Phase 3. Delete the entire kickoff directory only
   after they pass.

This is a valid completion point. Report the approved documents, unresolved
questions and assumptions, then ask one topic only: whether to continue into
task decomposition. If the user asked only for scoping or initial documents,
stop without creating tasks.

## Phase 2 - Task decomposition

Read [references/phase-2-decomposition.md](references/phase-2-decomposition.md).
In the hybrid profile, start from the next approved change and its scenarios;
otherwise confirm the epic list from the masterplan roadmap. Interview unresolved
scope one topic per message. Emit a proposed task tree (titles, outcomes,
acceptance criteria, dependencies, specification references) and wait for
approval before creating anything.

For brownfield adoption, substitute the discovered board directory in all paths
below and use the source map when no kickoff masterplan exists. Compare identity
only against identity records that actually exist.

Before starting Phase 2, search
`.backlog/brainstorming/*.Decomposition/TASK-TREE.md`. Exactly one means resume
it after validating project identity; more than one is a conflict. If none
exists, create one dated directory immediately with status `interviewing`.
Persist the interview and exact proposed tree in
`.backlog/brainstorming/<YYYY-MM-DD>.Decomposition/TASK-TREE.md`, starting from
`assets/templates/TASK-TREE.md.tmpl`. On approval, mark it `approved`. Append an
attempt marker immediately before each create command, then replace it with the
returned task ID immediately after success. On interruption, reconcile recorded
IDs and unresolved attempts against exact task fields and creation time. Adopt
exactly one exact match; zero matches means retry, while multiple or partial
matches are a conflict. Never infer remaining work from conversation history.

On approval create parents first, then children with `-p <TASK-ID>`, per the
Backlog task-creation guide. Derive valid types, priorities and statuses from
`backlog task create --help` for the active board; never assume the default
configuration. Include the approved initial status explicitly on every creation
command; it must be a normal task status shown by `backlog task edit --help`,
not the special `Draft` creation status. A design-affecting temporary choice must
appear both as an open question in the masterplan (or brownfield question owner) and an
explicit `Assumption:` line in each dependent task. A deferred question with no
dependent choice needs only the question entry.

## Phase 3 - Verify and report

### Document checkpoint

1. Build an explicit file list containing the three core documents plus only
   the optional files actually selected. Brownfield uses its selected-output
   manifest instead of requiring the greenfield core. Do not pass a nonexistent
   `docs/` directory to verification commands.
2. For every file in that list, verify no `{{`, `<!-- BEGIN:`, `<!-- END:` or
   `guidance:` remains and every relative Markdown link resolves.
3. Verify every selected file exists, every unselected optional file is absent,
   unless it was present in the initial inventory, and every spec-index domain
   link resolves. Never remove or reject an unselected pre-existing path.
4. For the hybrid profile, validate both project-local schemas and every selected
   change/baseline with OpenSpec. Check source ownership and stable IDs; require
   no internal task-tracking artifact. Runtime schema templates remain templates.
5. Verify any delegation policy collected in this run has its guide owner,
   optional role links resolve, and review evidence identifies actual provenance,
   snapshot and gaps.
   Installing role contracts is not evidence that independent review occurred.
6. Confirm every populated kickoff-brief section has its durable owner, then
   remove only the current `.Kickoff/` directory and confirm it is gone.

### Task checkpoint, when Phase 2 ran

1. Use `backlog task list --json` to inventory created IDs.
2. Inspect every created task with `backlog task view <ID> --json` and compare
   title, type, priority, status, labels, parent, dependencies, references,
   description and acceptance criteria with the approved tree.
3. Confirm every task, including epic parents, has at least one acceptance
   criterion and every design-affecting assumption has a question in its
   designated owner.
   In the hybrid profile, also verify the change label, requirement/scenario
   coverage and references; Backlog owns all execution state and evidence.
4. Remove the current `.Decomposition/` directory only after all approved tasks
   exist and match. Preserve unrelated brainstorming directories.

Report created files, task IDs when any, verification evidence, open questions
and assumptions. A documents-only run succeeds without any tasks.

## References

- [Phase 1 - scoping interview](references/phase-1-scoping.md)
- [Phase 2 - task decomposition](references/phase-2-decomposition.md)
- [Artifacts, placeholders and rendering](references/artifacts.md)
- [OpenSpec + Backlog methodology and setup](references/spec-driven-workflow.md)
- [Brownfield adoption](references/brownfield-adoption.md)
- [Roles and optional delegation](references/delegation.md)
- Templates: `assets/templates/`
- OpenSpec schemas and runtime templates: `assets/openspec/`
- Backlog bootstrap: [scripts/ensure-backlog.sh](scripts/ensure-backlog.sh)
- Skill verification: [scripts/verify-skill.sh](scripts/verify-skill.sh)
