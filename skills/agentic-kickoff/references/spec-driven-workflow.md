# OpenSpec + Backlog.md

Use this profile when the user asks for specification-driven development. It is
an opt-in alternative to the original plain `docs/specs/` profile. Markdown
remains the format; explicit ownership and small change contracts provide the
structure.

## One owner per concern

| Question | Owner | Keep out |
| --- | --- | --- |
| Why does the project exist? | Constitution / existing product brief | Feature checklists, implementation choices |
| Which outcomes matter next? | Masterplan / existing roadmap | Task status, copied requirements |
| Why this change, for whom, within which boundaries? | Change `proposal.md` | Class names, implementation steps |
| What observable behavior must hold? | Capability `spec.md` | Framework choices, work assignments |
| How will it work, and why this approach? | Change `design.md`, when needed | A second requirement catalog or task board |
| Which decision outlives the change? | Existing ADR store, when enabled | Repeated design narrative |
| Who does what next, and what proves it works? | Backlog tasks and their evidence | A mirrored OpenSpec `tasks.md` |

Keep business outcomes in the product context, project constraints in their
existing owner, and implementation mechanisms in design. The masterplan may
summarize the current stack and link its decisions; their rationale stays in
design/ADRs. A required public API,
file format or compatibility promise is observable behavior: a spec may link to
an authoritative machine-readable contract. An internal helper signature is a
design detail.

Security and quality are dimensions of these concerns, not a parallel duplicate
specification. For example:

- Proposal: prevent one customer's exports being disclosed to another.
- Spec `EXP-SEC-001`: the system SHALL reject access to another customer's
  export, including a concrete denied-access scenario.
- Design: where authorization is enforced and why that mechanism was chosen.
- Backlog acceptance criterion: prove `EXP-SEC-001` with the stated adversarial
  request; record the result when executed.

Keep capability-specific security, privacy, accessibility, reliability and
performance requirements alongside that capability. Extract a shared capability
only when the same approved rule is reused; link to it instead of copying it.
Do not invent compliance obligations, numeric targets or mandatory controls.

## Proportional depth

Propose these defaults and let the user adjust the thresholds in the working
agreement. Size is determined by behavior and uncertainty, not lines of code.

| Route | Typical case | Planning artifacts |
| --- | --- | --- |
| Direct Backlog | Mechanical edit; refactor preserving a known contract; bug restoring approved behavior | Task when the agreed task threshold requires it; references to the existing contract |
| `backlog-lean` | Small, understood behavior change using existing design patterns | Proposal + capability delta specs |
| `backlog-design` | New architecture; changed trust boundary; data migration; nontrivial integration or operational trade-off | Proposal + delta specs + design |

A small authorization or data-loss change can require design. A large mechanical
rename can use direct Backlog. A discovery spike may start in Backlog when the
behavior is still unknown; do not manufacture a requirement to unblock it.
Upgrade a lean change to `backlog-design` if a design question appears: preserve
its ID and artifacts, update its `.openspec.yaml` schema selection explicitly,
then complete and review design before dependent implementation.

There is no mandatory PRD, threat-model document, ADR, verification report or
epic for every change. Add one only when the approved scope needs it. The normal
lean unit is one short proposal, one or a few capability files, and Backlog work.

## Roles at the existing review points

Follow [delegation.md](delegation.md) when the user selects role contracts. The
primary agent handles scoping/planning and normal execution. An independent
reviewer is an optional delegate under the approved guide policy, not an OpenSpec
artifact or a second task system. `backlog-design` is a useful candidate for
specification/design review before implementation and delivery review before
closure; approve those triggers instead of treating schema selection as consent.
Read-only exploration can establish bounded brownfield evidence. Keep actual
review provenance, findings and coverage gaps in existing task/proposal/review
owners. No additional schema artifacts or progress checklist are introduced.

## Greenfield and brownfield

**Greenfield:** establish purpose, outcomes, boundaries and capability names.
Specify the first vertical slice, keeping later outcomes on the roadmap. Future
behavior lives in `openspec/changes/<id>/specs/` as ADDED requirements until it is
implemented and accepted. An empty `openspec/specs/` is an honest initial state.

**Brownfield:** follow [brownfield-adoption.md](brownfield-adoption.md). Inspect
only the first change's neighborhood. Distinguish observed behavior (with code,
test or runtime evidence), approved baseline, intended change and uncertainty.
Tests can demonstrate what the system does without proving that it should do
it. Establish a baseline only for the touched capability; do not document the
whole repository before delivering a change.

An existing approved OpenSpec spec is the baseline. If it disagrees with code,
resolve whether this is a bug or an intended contract change. Never replace the
spec with a description of the code just to make them agree.

## Kickoff interview additions

During topic 13, confirm one topic per turn:

1. Profile: no specs, plain Markdown, or OpenSpec + Backlog. Recommend the hybrid
   when the user asks for SDD, structured specs or lighter OpenSpec task handling.
2. Authority: existing owners, capability scope, stable requirement IDs and any
   migration from another spec location. No two normative owners for one rule.
3. Depth: direct/lean/design thresholds and the project's existing review policy.
4. Initial content: workflow setup only, or the first approved change's complete
   proposal, capability deltas and design if required. A docs-only run may stop
   here, with zero Backlog tasks and an active, unimplemented change.

Record the profile, source map, policy, exact destinations and complete initial
drafts in the kickoff/adoption brief. Keep assumptions outside normative SHALL
statements. A blocking unknown may remain in a draft but must be resolved before
the dependent implementation starts.

## Installing the project-local kit

The kit targets repository-local OpenSpec schemas, not external stores. Inspect
the installed CLI before use. The integration test exercises OpenSpec 1.4.0;
the schema contract is also documented in current OpenSpec. Do not assume an
untested version's additional configuration fields are supported.

The tested layout uses one-level capability folders. OpenSpec 1.4.0's static
archiver only scans that level. For an existing nested capability layout, verify
archive support in the installed version before using this kit's closure command;
preserve the existing paths rather than silently flattening them.

1. Check `openspec --version`. If missing, request permission before installing
   it. Inspect `openspec schema --help`, `openspec instructions --help` and
   `openspec archive --help` for the installed version. Use the existing Backlog
   preflight. Installation and upgrades are separate from authoring templates.
2. Render `assets/templates/spec-workflow.md.tmpl` to `docs/spec-workflow.md`,
   filling the actual source map, board directory and approved workflow policy.
3. Copy the two complete schema directories under `assets/openspec/` to
   `openspec/schemas/`. These are original, ready-to-use schema assets. Preserve
   their runtime template comments; they are not kickoff rendering markers.
4. Render `assets/templates/openspec-config.yaml.tmpl` to `openspec/config.yaml`
   when absent. On adoption, propose a targeted merge into the existing `.yaml`
   or `.yml` file instead. Keep unrelated context and settings. Select
   `backlog-lean` as the default only when approved; each new change can also
   select its schema explicitly.
5. Create `openspec/specs/` and `openspec/changes/`. This file-based setup is
   sufficient for the documented CLI workflow; it needs no generated assistant
   command pack. Existing integrations remain subject to the project's agent
   agreement. Use that agreement's execution/closure procedure.
6. Include the `openspec` conditional in a fresh Agent Guide and masterplan.
   For an existing guide, propose the small block from
   `assets/templates/AGENTS-spec-workflow.md.tmpl` at the appropriate scope.
   If role contracts are selected, also stage `docs/agent-roles.md` and the
   delegation policy through its own conditional/addition. Otherwise strip the
   role links from the generated specification workflow.
7. Validate each installed schema and any selected change/spec with the CLI.

Use the kickoff's staged-write procedure for all these files. For initial
changes, assemble the kit in the staging root first, run
`openspec new change <id> --schema <selected-schema>` **from that staging root**,
and add the approved proposal/spec/design content. Include the CLI-generated
`.openspec.yaml` in the staged manifest. Install its bytes with the other files;
do not rerun `new change` against an already staged/installed change directory.
Never run `openspec init` over a config that the kickoff has already staged.

The schema assets are reusable templates, not approved project requirements.
Validate them as schemas. Apply the no-unrendered-tokens check to rendered
project records and initial change artifacts, not to future-use skeleton text
such as `<requirement-id>` inside a schema template.

## Handoff and closure

The generated [workflow template](../assets/templates/spec-workflow.md.tmpl)
defines the ongoing procedure. Task descriptions use
[BACKLOG-SPEC-TASK.md.tmpl](../assets/templates/BACKLOG-SPEC-TASK.md.tmpl).
Phase 2 proposes and approves executable slices of the approved change, rather
than eliciting a second, independent set of business rules. Clarifications that
change behavior go back into the change spec before task approval.

Traceability uses an immutable change ID, a `change-<id>` Backlog label, stable
requirement IDs, scenario names, and actual spec-file references. The Backlog
task remains the only owner of assignment, dependencies, plan, status and test
evidence. No synchronization daemon or second checkbox list is required.

**Integration boundary:** `apply.tracks` is deliberately omitted. OpenSpec reads
neither Backlog tasks nor their completion. Its `ready` state reports planning
artifact existence; an empty `tasks` array or `0/0` progress is not delivery
evidence. `openspec archive` can run with no internal task file. The project
workflow must check the linked Backlog work and scenario evidence before calling
it. This is an agent working agreement, not a native CLI enforcement hook.

## References and compatibility evidence

- [Custom schemas](https://openspec.dev/docs/customize-schemas): project-local
  schemas, templates and validation.
- [schema.yaml](https://openspec.dev/docs/schemas/schema-yaml): artifact
  dependencies, optional `apply.tracks` and change-relative tracking paths.
- [Specification format](https://openspec.dev/docs/schemas/spec-driven): delta
  operations, normative requirements and scenario headings.
- [OpenSpec CLI](https://openspec.dev/docs/cli): status, instructions, validation
  and archive behavior.
- [Backlog CLI](https://github.com/MrLesk/Backlog.md/blob/main/CLI-INSTRUCTIONS.md):
  task references, labels, acceptance criteria and evidence updates.

The bundled smoke test validates both schemas, readiness without a task file,
and ADDED/MODIFIED delta archival on the locally installed CLI. It does not prove
that an agent has honored the external Backlog closure agreement.
