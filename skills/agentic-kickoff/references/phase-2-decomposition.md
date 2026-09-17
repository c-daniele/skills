# Phase 2 - Task decomposition

Phase 2 turns the approved roadmap into Backlog tasks that can be executed
without the kickoff conversation. It starts only after the user explicitly
chooses to continue beyond the documents-only checkpoint.

Keep resumable state in the dated decomposition directory described in
`SKILL.md`, rendered from `assets/templates/TASK-TREE.md.tmpl`. Update it after
each interview answer, proposal revision, approval and successful task creation.
Discover and resume exactly one existing state file before creating another;
validate its project identity against the board and masterplan.

## Discipline

- Follow the Phase 1 interview rules: one topic per message, reflect answers,
  challenge vagueness and expose uncertainty.
- Capture what must be true and why; do not create a speculative implementation
  plan. The worker researches the current code after activating the task.
- Every top-level task, epic and child needs at least one independently testable
  acceptance criterion before approval.
- Never create tasks from an unapproved tree.

## Step 1 - Read context and derive candidate work

Read the Manifesto, masterplan, Agent Guide and every approved domain spec that
applies. Run `backlog instructions overview` and
`backlog instructions task-creation`, then search existing tasks before creating
anything.

Map roadmap outcomes to work:

- Use an epic only when one outcome needs multiple focused tasks in one
  subsystem.
- Use independent top-level tasks joined by dependencies when work spans
  separate components or can be delivered independently.
- Do not create an empty parent merely to mirror a heading.

Present the candidate epic/top-level list with one-line outcomes and obtain
confirmation before interviewing each one.

## Step 2 - Interview each workstream

Cover one topic per message until the workstream is specific to this project:

1. **Actor and trigger** - who acts and what starts the behavior?
2. **Business rules** - what must hold, what is forbidden and which rule wins?
3. **Happy path** - what sequence produces the visible result?
4. **Failure behavior** - what can fail, what is shown and what must not be lost
   or duplicated?
5. **Relevant edge cases** - choose project-specific cases rather than copying a
   generic list.
6. **Data and trust boundaries** - what is stored, retained, disclosed and
   authorized?
7. **Verification** - what objective evidence proves the outcome?
8. **Dependencies and ordering** - what must precede it and what can run in
   parallel?
9. **Out of scope** - what belongs to another task or later outcome?

## Step 3 - Propose the complete task tree

Read the active board's allowed values from `backlog task create --help`. For
**every task, including epic parents**, present:

- title and one-line outcome;
- description explaining the user or project need;
- one or more testable, independent acceptance criteria;
- one type, priority and initial status from that board's configured values. The
  status must be accepted by `backlog task edit --help`; do not use the special
  `Draft` creation status, because drafts are outside the task-list verification
  workflow;
- priority, parent and dependencies;
- references or documentation paths when needed;
- `Assumption: ...` lines for every dependent temporary choice.

Adjust and re-present the complete tree after scope changes. Approval applies to
the exact tree shown, including parent acceptance criteria.

## Step 4 - Create and verify tasks

Persist the exact approved definitions in the current decomposition state file.
Before each create command, append an attempt marker with timestamp and exact
approved fields; after success, replace it with the returned ID. Create parent
tasks before their children. Across otherwise independent tasks, create in
**topological dependency order**, using approved priority only as the tie-break
between currently unblocked tasks:

```bash
backlog task create '<Epic title>' --type feature \
  -d '<approved outcome and why>' \
  --ac '<approved testable criterion>' \
  --priority '<approved priority>' \
  --status '<approved initial status>' --plain

backlog task create -p <EPIC-TASK-ID> '<Child title>' --type feature \
  -d '<approved outcome and why>' \
  --ac '<approved criterion>' \
  --priority '<approved priority>' \
  --status '<approved initial status>' \
  --ref '<path-or-url>' \
  --depends-on <TASK-ID> --plain
```

In the example, replace `feature` with the approved value from the active
board's configured types. Run every example as
`BACKLOG_CWD="<absolute-target-root>" backlog ...`. Do not assume default type,
priority or status names on a resumed/customized board, and do not use `Draft`.

Rules:

- Use `-p` only with an existing task ID.
- Do not pass `--plan` or `--notes` for future work.
- Use shell-safe arguments. Single quotes protect backticks and most shell
  metacharacters, but escape an embedded apostrophe as `'\''` or construct the
  command through a language/API that passes an argument array without shell
  interpolation.
- Create tasks in topological dependency order; among unblocked top-level tasks,
  use approved priority order.
- Do not make a child depend on its own parent merely to express containment;
  `-p` already records that relationship.

After creation, use `backlog task list --json` and
`backlog task view <ID> --json` to verify every title, type, priority, status,
parent, dependency, reference and acceptance criterion against the approved
proposal.
If interrupted, verify each recorded ID against its approved entry. For an
unresolved attempt, search by its exact title and creation-time window, then
compare every approved field. Adopt exactly one exact match; retry only when no
match exists; stop on multiple or partial matches. Delete decomposition state
only after every approved task passes verification.

## Assumptions and open questions

- A deferred question with no dependent choice is recorded only as a masterplan
  open question.
- A temporary choice that could affect design is recorded **both** as a
  masterplan open question and as `Assumption: ...` in every dependent task.
- A wording clarification that cannot affect implementation may remain local to
  the task description.

Report all recorded assumptions and their related open questions.

## Exit criteria

- The user approved the exact task tree.
- Every approved task exists and matches its proposal.
- Every task, including parents, has at least one acceptance criterion.
- Parentage, dependencies and references resolve.
- No implementation plan was invented for future work.
- Every design-affecting assumption has a corresponding masterplan question.
