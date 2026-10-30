# Adopt the specification workflow in an existing project

Use this route for an explicit request to introduce the hybrid workflow into an
existing repository, including a project already bootstrapped by this skill.
It is an additive adoption, not a second greenfield interview. The existing
constitution, roadmap, agent guides, decisions and task board retain their roles.

## 1. Orient and bind to the right project

1. Confirm project identity and the intended adoption scope with the user. Reuse
   supplied answers; ask only for missing information, one topic at a time.
2. Run the Backlog preflight and all Backlog commands from the target root with
   `BACKLOG_CWD` set to that absolute root. Inspect `backlog config list` and the
   discovered configuration location. Confirm `backlog config get projectName`
   matches the approved identity before any mutation. Find the actual board
   directory, including root-config and custom-directory layouts; record it as
   `BACKLOG_DIR`. Never infer it from the `.backlog/` default.
3. If no board exists, confirm identity and follow Phase 0's CLI/git/init steps
   to create one. Existing product documents are not a reason to replace them.
   If a discovered board belongs to another project, stop and report its path.
4. Inventory the applicable `AGENTS.md` files, product context, roadmap, existing
   specifications and contracts, ADR store, OpenSpec config/schemas/changes and
   relevant existing Backlog tasks, including any role/delegation policy and
   `docs/agent-roles.md`. Confirm the first capability/change boundary.
   An external OpenSpec store or ambiguous multi-root setup requires an explicit
   adoption plan; do not silently create a second repository-local spec store.
5. Look for unfinished `.Kickoff/`, `.Decomposition/` or `.Spec-Adoption/` state
   under the actual board's brainstorming directory. Resume the matching one;
   report conflicting concurrent setup state instead of starting a second run.

Create exactly one `<board>/brainstorming/<YYYY-MM-DD>.Spec-Adoption/` record from
`assets/templates/ADOPTION-BRIEF.md.tmpl`. This is resumable interview state.
Capture exact project identity, root, board location, initial inventory, source
map and selected outputs. Keep status `interviewing` until the proposal is
approved. An existing nonempty board is valid on this route.

## 2. Establish only the needed baseline

Read [spec-driven-workflow.md](spec-driven-workflow.md). Reuse known policies;
interview only unresolved adoption choices and the first change's behavior.
When adding role contracts, follow [delegation.md](delegation.md): preserve the
existing review policy and explicitly agree on allowed delegates, triggers and
fallback. Scope/implementation reviews use the existing checkpoints. On a
role-policy-only update to a configured project, skip baseline/change work and
OpenSpec setup; record the retained spec profile rather than generating one.

For each touched capability, record:

| Category | Required evidence or decision |
| --- | --- |
| Observed | Source/test/contract path and inspected revision or runtime observation |
| Approved | The current behavior the owner agrees to preserve |
| Intended | The behavior this change should introduce, modify or remove |
| Unknown / conflict | Missing evidence, implementation/spec disagreement, or an open product decision |

Keep observations and uncertainty in the adoption brief while investigating.
Transfer lasting evidence to the approved baseline's evidence section, an
existing architecture record, or the first change's proposal/design before
deleting the brief. Unaccepted behavior is never promoted to a SHALL requirement.

- Existing OpenSpec baseline: preserve capability paths and requirement names.
- Existing normative specs elsewhere: propose either continued ownership there,
  with links, or an explicit capability-by-capability move to OpenSpec. Mark the
  old owner superseded only as part of an approved migration; check inbound
  references. Retained capabilities follow their existing spec workflow; migrate
  their baseline before using OpenSpec deltas for those same rules. An external
  machine-readable API/data contract can remain authoritative by reference.
  Do not maintain two copies of the same contract.
- No baseline: render the approved current behavior from
  `assets/templates/OPENSPEC-BASELINE.md.tmpl` into
  `openspec/specs/<capability>/spec.md`. This one-time adoption is separate from
  the intended behavior delta. Unknown behavior remains an open question, and a
  characterization/discovery task can precede the change.

Existing requirement headings without IDs are valid. Preserve them as exact
identifiers until an explicitly reviewed naming change; adding an ID to a
MODIFIED heading implicitly renames it and breaks delta matching.

## 3. Propose the smallest useful adoption

Normally select only:

- `docs/spec-workflow.md`, with the actual source-of-truth map and board path;
- the two project-local schemas and a targeted OpenSpec config addition;
- a small addition to the applicable agent guide;
- an approved baseline and/or first change, only when requested.

When roles are selected, add `docs/agent-roles.md` and the policy addition from
`assets/templates/AGENTS-delegation.md.tmpl`. Point the role document back to the
actual policy-owning guide, including a nested guide when appropriate. A
role-policy-only update selects just these files/patches and any required link
addition to an existing workflow. It does not need new specification artifacts.

The greenfield core documents are optional here. Create a missing one only when
the user wants that artifact. Map an existing product brief or roadmap instead
of generating a duplicate. Reuse the existing ADR store; do not add a second one.
Replace obsolete task-mirroring instructions in an agent guide only through the
same approved patch. Explain unresolved ownership conflicts before execution.

Present the complete new files and exact patches to existing files. Record each
selected destination as `create` or `update`, its preimage checksum (or `absent`)
and approved postimage checksum. Include setup files and any initial change
metadata generated by the CLI in the manifest.

## 4. Apply and resume approved patches

Stage exact approved postimages under the adoption directory's `approved/` tree
and the original bytes of updated files under `before/`. Validate the staged
kit, then record status `artifacts-approved`. Recheck all selected destinations
immediately before writing:

- `create`: absent, or already byte-identical to the approved postimage;
- `update`: still identical to the recorded preimage, or already identical to
  the postimage after an interrupted run.

Any other content is a conflict. Never reconstruct a patch from conversation
history or overwrite concurrent edits. Record `writing`, install each postimage
atomically in its destination directory, and record `verifying`. Resume from the
manifest and snapshots; missing snapshots/checksum mismatches require renewed
approval. This route permits only the explicitly approved in-place updates;
the greenfield route remains create-only.

## 5. Verify and hand over

Check selected files, rendered tokens, relative links, source ownership, schema
validation and any selected spec/change validation. Compare installed files to
approved postimages. Confirm existing tasks and unrelated configuration were
preserved. For initial task decomposition, reuse Phase 2 under the actual board
path and bind tasks to the selected change rather than re-planning the roadmap.
Validate role/delegation choices and actual review provenance when applicable;
document creation must not be reported as an executed independent review.

Delete only this adoption directory after its facts have durable owners and
verification succeeds. Report the adoption scope, evidence, remaining unknowns
and any unrun checks. Workflow-only or documents-only adoption is complete
without generating tasks or archiving an unimplemented change.
