# Produce the workplan

Deliver `WORKPLAN.md` at the project root for every new kickoff. It is ordinary
Markdown: readers can follow a task or draft link without running a command.
The only maintenance artifact is a project-local Ruby script (standard library,
no gems). It reads the board's checked-in records without writing to Backlog.

## Prepare the proposal

1. Confirm the actual config path, board identity and status meanings with the
   working agreement. Run `backlog config get statuses` against the target root.
   Use a status for `ready` only if the project reserves it for **authorized**
   tasks. Map a mixed intake column conservatively to `proposal`; agree how an
   approved item moves into a ready or active state. A draft or `proposal` label
   always denotes a proposal. Never infer authorization from column order, a
   cleared dependency, an approved document or a CLI readiness flag.
2. Render [the generator](../assets/templates/workplan.rb.tmpl) with one JSON
   object after `__END__` (use a JSON serializer; these values are data).
   Example for a board that **reserves To Do for approved work**:

   ```json
   {"project":"Loan Desk","intro":"Loan Desk helps librarians lend equipment and record its return.","config":".backlog/config.yml","masterplan":".backlog/masterplan/MASTERPLAN.md","view":"WORKPLAN.md","statuses":{"To Do":"ready","In Progress":"active","Done":"done"}}
   ```

   The approved English `intro` names the product, audience and purpose. The
   status keys must exactly match the config. Other meanings are `waiting`,
   `proposal` and `inactive` (e.g. cancelled, which cannot satisfy a dependency).
   Only `done` denotes successful completion. The helper discovers the record
   directory from that config. Use the real relative paths on adoption, including
   a nested view if one already owns this concern. Adjust guide commands and
   links for the approved destinations. No per-task data goes into the helper.
3. **Preview before approval:** from the real project root run `ruby
   <preview-script-path> --stdout` with the rendered helper in scratch space.
   This reads the actual board and does not need the masterplan installed yet.
   Show both plan texts, the helper/settings and the guide. Include both plans
   and helper in the initial inventory and approved checksum manifest. Install
   the exact approved bytes by the normal staged-write procedure. On resume,
   compare staged and installed bytes before running `--check`; never use
   `--write` to resolve an installation conflict. Do not change older approvals.

## What the records say

The title names the action. The view uses the existing filename for its ID link
and shows the real status. Drafts, proposed tasks, approved work, waits and
completed records are distinct. If no work has been defined, leave the board
empty. Do not turn roadmap milestones or OpenSpec changes into placeholder tasks.

- In the **description**, use `Effort: 2–4 hours` only for an agreed estimate of
  active person-hours. If unknown, omit the line; the view prints “Not estimated
  yet”. Do not convert waiting for approval into effort or invent a due date.
- Record task dependencies with Backlog's dependency field. For other holds,
  add a one-line `Waiting for:` per missing input, naming the responsible party
  if known. Example: `Waiting for: The service owner must approve the spending
  limit before the first paid test.` Remove the line when the hold is resolved.
- In implementation notes or the final summary, use a one-line `Verified:` with
  the check, its observed result and any important limit. Keep detailed evidence
  alongside it. Future checks in the description are not results. Neither a
  checked criterion nor a terminal status establishes what was tested.
- On adoption inspect the actual descriptions, approval conventions and evidence
  before proposing a view. If the board already records these facts differently,
  adapt the reader to those fields or agree a targeted CLI update to the records.
  Do not show existing work as approved, unestimated or unverified merely because
  its project uses different words.
- The view shows the next active/approved action in board order, names pending
  prerequisites and shows when independent actions can overlap. This describes
  dependencies, not staffing or permission to delegate. The overview limits rows
  per group and recent evidence; additional activities expand on the same page.

After creating, editing, promoting, moving or closing records, the agent who
owns the change runs `ruby scripts/workplan.rb --write`, then `ruby
scripts/workplan.rb --check` before handoff. `--check` recomputes and compares
bytes without writing (nonzero means stale, conflicting or unreadable). A
manually edited page is a conflict; reconcile it instead of overwriting it.
Check the generated links in their **final** locations. A change in daily status
alone never requires editing the masterplan.
