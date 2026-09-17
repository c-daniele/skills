# Phase 1 - Scoping interview

This phase collects enough approved information to write the project's
constitution, current plan and working agreement without inventing policy.

## Discipline

- **One topic per message.** Ask one topic's related questions, wait, reflect the
  answer in one or two sentences, then continue. Never dump the full bank.
- **Reuse supplied input.** A long opening description may answer several
  topics. Reflect those answers at the relevant topic and ask only for missing
  or ambiguous information.
- **Challenge vague language.** Replace words such as “fast” or “simple” with a
  measurable outcome, an observable event or an explicit decision not to
  measure it.
- **Propose, do not assume.** If the user has not considered a boundary, risk or
  policy, offer two or three plausible choices. Do not select one for them.
- **One deferral is allowed.** After one unanswered candidate round, record an
  open question. If any document depends on a temporary choice, record the same
  choice as `Assumption: ...` beside that dependency.
- **Preserve disagreement.** Record the user's approved intent, not a smoothed
  version of the agent's recommendation.

## Coverage and durable ownership

A topic is complete when every required output has an approved answer or an
explicit open question. The destination column is mandatory: before deleting
the brief, every answer must appear in its owner.

The brief header also records workflow state, the initial path inventory and
the exact selected output list. These are operational facts, not interview
topics; update them at each transition described in `SKILL.md`.

| # | Topic | Must produce | Durable owner |
| --- | --- | --- | --- |
| 1 | Identity | name, slug, one-line description | core documents; slug in masterplan |
| 2 | Problem and motivation | problem, why now, cost of inaction | Manifesto |
| 3 | Users and priorities | jobs, primary/secondary users, tie-break rule | Manifesto |
| 4 | Core loop and interfaces | 3-7 actor steps; interfaces and their priority when multiple | Manifesto |
| 5 | Goals, current state and roadmap | at most five measurable outcomes; present state; ordered delivery outcomes | Masterplan |
| 6 | Design principles | project-specific rules that resolve design trade-offs | Manifesto |
| 7 | Non-goals and boundaries | explicit “will not” list | Manifesto |
| 8 | Risks | accepted risk, mitigation or trigger for each | Manifesto |
| 9 | Success criteria | observable review and pivot signals | Masterplan |
| 10 | Constraints, stack and commands | fixed constraints; known setup and verification commands | Masterplan, Agent Guide, optional standards |
| 11 | Glossary | ambiguous domain terms and winning meanings | Masterplan |
| 12 | Working agreement | task threshold, language, journal/ADR, Git and review policies, optional approved standards | Agent Guide, optional standards |
| 13 | Specifications | no specs, an empty index, or named approved domain-spec drafts | optional `docs/specs/` |

## Topics

### 1. Identity

This topic is collected during Phase 0 before `backlog init`.

Ask:

- What is the project called, and what repository slug should represent it?
- In one sentence, what is it?

Do not initialize Backlog until all three values are approved.

### 2. Problem and motivation

Ask:

- What problem does this solve, and who experiences it?
- Why is it worth solving now?
- What happens if it is not built?
- What existing approach is closest, and why is it insufficient?

Reject solutions disguised as problems and problems with no affected actor.

### 3. Users and priorities

Ask:

- Who is the primary user, in what context and at what skill level?
- What job are they doing today, and what makes it painful?
- Which secondary users or operators interact with the result?
- When their needs conflict, whose outcome wins and by what rule?

Finish with a tie-break sentence that can be applied to a real trade-off.

### 4. Core loop and interfaces

Ask:

- Walk through the repeating behavior from trigger to visible result. Who owns
  each step, and what ends the loop?
- Which interfaces exist or are planned: library, API, CLI, UI, events or
  another surface?
- If there is more than one interface, which is authoritative and in what
  priority order?

The loop should have 3-7 actor-owned steps. Keep the `surfaces` conditional only
when multiple interfaces have an approved hierarchy.

### 5. Goals, current state and roadmap

Ask:

- What outcomes must be true at the first meaningful horizons for this to be
  worthwhile?
- What number or observable event demonstrates each outcome?
- Which outcome is first and which are explicitly later?
- What exists at kickoff: empty repository, prototype, research or another
  starting state?
- What ordered delivery outcomes connect the current state to those goals?

Limit the top-level list to five outcomes. Activities such as “build X” belong
in the roadmap, not in goals. Capture separate `Where we are` and `Roadmap`
content in the brief so an interrupted kickoff can reproduce the masterplan.

### 6. Design principles

Ask:

- Which project-specific principles should decide architecture or product
  trade-offs?
- For each principle, what plausible alternative does it rule out?

Avoid generic slogans. Each principle must change at least one likely decision.

### 7. Non-goals and boundaries

Ask:

- What related capability will the project deliberately not provide?
- What might a reasonable reader incorrectly assume is in scope?
- What is excluded from the first version?
- Which platforms, dependencies or operating models are explicitly unsupported?

An empty boundary list is not acceptable for a greenfield project.

### 8. Risks

Ask about technical, cost, security, privacy, operational and maintainership
failure. For each accepted risk, record at least one of:

- a mitigation;
- an observable trigger for revisiting it;
- an explicit reason it is accepted without mitigation.

Always cover cost, data exposure and bus factor when the project runs services
or handles data.

### 9. Success criteria

Ask:

- What evidence at the first 30-, 90- or project-appropriate review point says
  the project is working?
- What result causes a pause, rollback or change in direction?

At least one criterion must be objectively observable.

### 10. Constraints, stack and commands

Ask:

- Which languages, runtimes, platforms, services and licences are fixed, and
  which remain open?
- What budget, compliance, data residency, accessibility, performance, team or
  time constraints apply?
- Are exact environment-setup and project-verification commands known now?
- For every language included in coding standards, what formatter, linter, type
  check and test commands are approved?

Never invent commands in a greenfield repository. If no executable setup or
verification command exists yet, omit the corresponding `setup` or `tests`
block from `AGENTS.md` and add an open question to establish it. The same rule
applies to language sections in coding standards.

### 11. Glossary

Ask which domain words, acronyms or component names could be read more than one
way and which meaning wins. Include only terms that could affect a decision or
task; do not define everyday words.

### 12. Working agreement

Ask and record each policy separately:

- What work requires a Backlog task, and what qualifies as a mechanical change?
- Which language applies to project records, code comments, documentation and
  product copy? Do not assume product copy is English.
- Should every completed task create a journal entry, only significant work, or
  no journal? If used, define its required contents.
- Should durable decisions use ADRs, and what qualifies as durable?
- If Git is used, what branch, merge and commit-message policy applies?
- What review or approval is required before implementation, documentation and
  merge?
- Should project-wide coding standards be written now? If yes, collect the
  actual general and language-specific rules rather than accepting the generic
  template wording by default.

The rendered `AGENTS.md` must reflect these answers exactly. Omit `journal`,
`decisions` or `git` blocks when the corresponding practice is declined or not
applicable.

### 13. Specifications

Ask whether normative behavior should be written now. Default to later. If yes,
ask which option the user approves:

1. create only `docs/specs/README.md`, explicitly stating that no domain specs
   are approved yet; or
2. name each initial domain, approve its filename and content, and render it
   from `assets/templates/SPEC.md.tmpl` in the same write.

The index may link only to domain files created in the same approved operation.
Its existence does not make it authoritative for behavior it does not cover.
For each named domain, preserve a complete draft in the kickoff brief: name,
purpose, filename, status, scope, requirements, behavior, invariants and
cross-references. Do not rely on conversation history to reconstruct it.

## Exit criteria

- Every checklist output has an approved answer or explicit open question.
- Every placeholder required by the selected templates has approved content.
- Optional blocks have an explicit keep/drop decision.
- The proposed rendered artifacts preserve every durable brief fact in its
  designated owner.
- The user approved the complete rendered proposal before files are written.

## Handling deferrals

For every deferred answer:

1. Add the question with context to the masterplan's `Open questions` section.
2. If a selected document depends on a temporary answer, put
   `Assumption: <choice and reason>` next to the dependency as well.
3. If no temporary answer is needed, do not invent one.
4. List all recorded assumptions when proposing and reporting artifacts.
