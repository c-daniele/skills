---
name: live-testing
description: "Collaborate with the user during live application testing using Playwright. Use when the user asks to test an app together, inspect UI behavior, explain what is on screen, or collect bugs and improvement feedback during a live walkthrough. Keep a persistent scratchbook and convert approved feedback into new tasks only after the user's explicit end-of-session approval. Not for autonomous test-suite development or immediate bug fixing."
license: Apache-2.0
compatibility: "Requires access to a Playwright browser tool for live inspection. Uses the target project's existing task workflow; does not require a specific task manager."
---

# Live Testing

Act as the user's testing partner. Use Playwright to inspect the application,
answer questions about what they see, and record their feedback. During the
walkthrough, collect and investigate; do not implement changes or create tasks.

## Session setup

1. Read the target project's agent instructions and identify its task workflow
   and any conventions for scratch notes. Do not initialize a new task manager.
2. Confirm the application URL, environment, and browser access if they are not
   already known. Use available Playwright tools; if none are available, explain
   the limitation and ask whether to proceed with user-provided evidence. Never
   claim to have inspected a browser you cannot access.
3. Reuse an explicitly identified session scratchbook when resuming. Otherwise,
   create a new one using [the template](assets/SCRATCHBOOK.md) in the project's
   scratch-note location. If there is no convention, use
   `docs/live-testing/<YYYY-MM-DD-HHmm>-scratchbook.md`. Avoid filename collisions
   and never overwrite unrelated notes. Tell the user the path.
4. Record the URL/environment without credentials, the session scope, and any
   testing restrictions. Start in `collecting` state.

Keep the conversation in the user's language. Follow the project's language
policy for records and tasks; default to English when none is defined.

## During the walkthrough

- Let the user guide the session. Navigate, inspect, and reproduce through
  Playwright as needed; do not launch a broad autonomous audit unless requested.
- Use current page evidence before making claims: visible text, DOM, screenshots,
  or relevant browser errors. Investigate source code read-only when an explanation
  requires it. Separate observed behavior from a suspected cause.
- Answer clarification questions directly. A question such as “Why does this box
  say that?” is not automatically a change request. Record the question and answer;
  ask whether a change is wanted only when the intent is ambiguous.
- Capture every user feedback item promptly, including bugs, improvements,
  corrections, withdrawals, and unresolved questions. Assign stable IDs such as
  `LT-001`. Preserve the user's meaning and distinguish their feedback from your
  own suggestions; agent suggestions are not approved requirements.
- For actionable items, record the page/component, actual behavior, desired
  behavior, reproduction steps when known, and evidence references when useful.
  Mark missing details as unknown rather than inventing requirements or causes.
- Keep updates brief: acknowledge the recorded ID, answer the question, and ask
  at most the clarification needed to continue. Do not repeatedly ask permission
  to create tasks while the user is still testing.
- Link related or duplicate items while retaining their IDs and history. Update
  the scratchbook after each substantive exchange so the session can resume
  without relying on chat history.

## Boundaries

- Before final approval, the scratchbook and explicitly requested evidence are
  the only repository writes. No product-code changes, fixes, refactors, task
  creation, or task-board updates, even for an obvious or small bug.
- Browser interactions can mutate application data. Confirm before destructive
  actions, purchases, sending messages, or other externally visible effects.
  For routine test-data writes, establish the allowed scope first. Do not assume
  a URL is a safe test environment, bypass authentication, or install tooling
  without permission.
- Never put passwords, tokens, or unnecessary personal data in the scratchbook,
  evidence, or tasks. Prefer redacted observations to sensitive screenshots.
- “This needs fixing” is feedback, not permission to implement. “OK” in response
  to an explanation is not approval to create tasks. If the user explicitly asks
  to switch to immediate implementation, confirm that workflow change first.

## Close and convert to tasks

1. When the user ends the walkthrough or asks for a recap, set the session to
   `reviewing`. Present a concise candidate task list mapped to feedback IDs,
   with unanswered questions and excluded items. Exclude explanation-only,
   withdrawn, and unaccepted agent suggestions. Do not silently drop feedback.
2. Wait for explicit approval to create tasks for the final batch or a specified
   subset. Ending the session alone is not approval. If the user has already
   clearly approved a defined set, proceed without a redundant approval gate.
3. Use the project's existing task tool and conventions. Check for existing
   matching tasks to avoid duplicates; report matches rather than editing them
   without permission. If no task workflow exists, ask where to create the tasks
   instead of installing or initializing one.
4. Create only approved new tasks. Include source feedback IDs and scratchbook
   path, observed and desired behavior, available reproduction/evidence, and
   testable acceptance criteria. Group items only when they share one coherent
   outcome. Do not invent priorities, solutions, or answers to open questions.
5. Record each returned task ID/link immediately. If interrupted or creation
   fails, reconcile recorded IDs and uncertain attempts with the task system
   before retrying; never blindly recreate the batch.
6. Keep unresolved or unapproved items in the scratchbook. Mark the session
   `closed` once every approved item has a recorded disposition, and report new
   task IDs, existing matches, remaining questions, and the scratchbook path.
   Preserve the scratchbook as the session record; do not delete it.

Approval to create tasks does not authorize implementation. Stop after the
handoff unless the user separately requests further work.
