# Roles and optional delegation

Use explicit roles to focus the primary agent's work. Recommend an independent
reviewer as the first optional delegate; keep scoping and planning in the primary
conversation. Role names describe responsibilities, not installed agent IDs.

The project agent guide owns the approved delegation policy. The optional
`docs/agent-roles.md` owns role contracts, handoff format and result handling.
Neither document creates a runtime or grants permissions beyond the host's rules.

## Collect the policy

During working-agreement topic 12, read existing policy and ask only for missing
choices, one topic per turn. Record the answers in `DELEGATION_POLICY`:

1. **Activation:** one primary agent only, or bounded optional delegation?
   Recommend the primary agent plus an on-demand read-only reviewer. A user
   request or an explicitly approved trigger authorizes a call; installing the
   role document alone does not. Keep delegation disabled while this is deferred.
2. **Review checkpoints:** what may trigger a reviewer, and is an independent
   review required or advisory? Reuse existing scope and delivery review points;
   do not invent additional approval gates. Record which results must be resolved
   before dependent work can proceed, consistent with the existing review policy.
3. **Other roles and limits:** optionally authorize a read-only explorer for
   bounded brownfield evidence questions. Keep scoper/planner in the primary
   conversation and implementation delegation off unless explicitly enabled.
   Propose at most one active delegate at a time and one bounded response per
   assignment. Further review rounds need a concrete change or unresolved finding.
4. **Unavailable runtime:** record whether a disclosed self-review is acceptable.
   If independent review is required, an unavailable delegate leaves that
   checkpoint pending; the user can choose another reviewer or revise the policy.

These are policy choices, not a fixed multi-agent pipeline. The allowed roles,
triggers, concurrency and fallback must be explicit in the rendered policy. A
general request to configure roles is not permission to launch implementation.

### Relationship to specification depth

| Work route | Suggested use of roles |
| --- | --- |
| Direct Backlog | Primary agent; reviewer only on request or an approved specific trigger |
| `backlog-lean` | Primary agent scopes, plans and implements; bounded reviewer for an explicit uncertainty or request |
| `backlog-design` | Recommend independent specification/design and delivery reviews at the project's existing review points |
| Brownfield discovery | Optional explorer for one code/contract/test question, with source evidence |

Approve those triggers before enabling them. A schema selection by itself never
authorizes a delegate. In the no-specs or plain-spec profiles, bind review to
the existing product context, task criteria and applicable project review points.

## Install the smallest useful contract

- Always preserve the approved policy, including an explicit single-agent
  decision, in the project agent guide. It is separate from human approval rules.
- When role contracts are selected, render
  [agent-roles.md.tmpl](../assets/templates/agent-roles.md.tmpl) to
  `docs/agent-roles.md` and enable the `delegation` conditional. This option is
  independent of the specification profile.
- For brownfield guides, propose a targeted addition/update using
  [AGENTS-delegation.md.tmpl](../assets/templates/AGENTS-delegation.md.tmpl).
  Preserve existing policy and reconcile conflicts before changing it. Link to
  the actual policy-owning guide, adjusting paths for nested guides.
- The [handoff](../assets/templates/DELEGATION-HANDOFF.md.tmpl) and
  [review result](../assets/templates/REVIEW-RESULT.md.tmpl) templates are message
  formats, not required per-change files. The generated role document also
  describes these formats so ordinary execution does not depend on this skill.
- Include selected artifacts and guide updates in the normal staged-write
  manifest. No provider-specific agent files, model selection or packages are
  needed for these portable contracts.

When resuming an already approved kickoff/adoption, preserve its staged bytes and
original selected-output manifest. Do not inject a new delegation policy during
recovery; adding roles to that completed setup is a subsequent approved adoption.

## Use during kickoff and decomposition

The primary agent keeps the interview, approvals and resumable state. Delegates
return options, evidence or findings to the primary; they do not interview the
user, invent product answers or approve scope on the user's behalf.

During kickoff, authorized scoper/explorer/reviewer work is advisory. During
Phase 2, an explicitly authorized planner may propose bounded decomposition;
the primary still obtains approval and creates/reconciles tasks using the
existing procedure. Never launch an implementer as part of a documents-only
or task-decomposition run.

For a specification review, give the reviewer the exact proposed/staged content,
the owning product constraints and its input snapshot, not future paths that
have not been created. A review of one draft does not cover later edits to that
draft. Resolve findings in the existing owners and recheck affected scope when
it changes; do not restart the entire interview.

## Actual delegation and handoff

1. Confirm the approved trigger and select an available runtime delegation
   capability. Check its documented tools/permissions; do not invent agent IDs,
   tool calls or model names. If the runtime cannot provide an independent
   context or technical access controls explicitly required by policy, apply
   the approved fallback.
2. Send the relevant role contract, applicable guide/policy, one bounded
   objective, source paths and snapshot, allowed operations, output contract and
   stop conditions. If files are inaccessible to the delegate, provide the
   scoped content. Do not pass the entire conversation by default.
3. A reviewer/explorer has no authority to edit repository files or Backlog,
   commit, archive changes or spawn more delegates. Use runtime permission
   controls when available; role prose alone is not a technical sandbox.
4. Consume the response against its scope and snapshot. The primary verifies
   findings, records dispositions and continues under the existing review policy.
   Stop repeated review when no new change or unresolved finding justifies it.

For any explicitly enabled implementation delegation, assign one existing
eligible Backlog task and a non-overlapping write set. The primary retains
ownership of shared specs, roadmap and change closure. Do not duplicate Backlog
work in a separate assignment board. Parallel execution requires its own explicit
authorization and a concrete integration owner; it is not part of the default.

## Evidence and useful feedback

An independent reviewer is a separate execution context from the author. Asking
the author to change role is self-review; a second opinion from the same model
does not guarantee different failure modes. Report actual provenance and scope.

Record actionable findings and their disposition in the existing task through
the Backlog CLI, or in the applicable proposal/decision/review record before
tasks exist. The primary can use the current kickoff/decomposition brief while
working; transfer lasting questions and decisions to their owners before deleting
it. For workflow-only setup, include review provenance and remaining gaps in the
handover instead of creating a task solely to store a report.

Only the designated owner makes changes. A reviewer conclusion is neither a test
result nor user approval. Uninspected behavior and unrun checks remain explicit.
After a few real changes, reassess the policy using useful defects found,
rework avoided and total turnaround; retain delegates that earn their overhead.
