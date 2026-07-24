# Superbeads Workflow and Skill Optimisation Design

> Date: 2026-07-15
> Status: Approved and stress-tested
> Brainstorming bead: `beads-superpowers-wcv`
> Research: [`2026-07-15-superbeads-skill-usage-workflow-review.md`](../research/2026-07-15-superbeads-skill-usage-workflow-review.md)

## Summary

Superbeads will be restructured as a layered contract pipeline: product truth is established once, solution design consumes it, planning decomposes it into vertical Slice Contracts, and execution proves both task quality and integrated outcomes. The redesign reduces context by assigning each meaning one owner, keeping the primary skill path short, and progressively disclosing branch-specific reference material.

The change is not a documentation-only rewrite. Mechanically checkable requirements will move into graph, context, scheduling, and evidence validators. Behavioral judgment will be tested with a small opt-in RED/GREEN micro-test runner. Quality, security, and independent review remain hard constraints; lower token use is accepted only when matched behavior is equal or better.

## Problem Statement

The research found two coupled failure modes:

1. **Technical closure can occur without product closure.** Product vocabulary, actors, lifecycle, authority, source precedence, and executable acceptance evidence are often established late or reconstructed during recovery work.
2. **Subagent context is large but semantically incomplete.** In the audited Claude corpus, technical requirements and verification were common, but stable acceptance IDs and shared-resource declarations were absent from all 220 scored packets. In the named Codex epic, all 22 SDD workers began in isolated contexts, yet one implementer was later reused across five task identities and accumulated eleven compactions.

The skills compound these problems through overlapping ownership, repeated policy blocks, long primary bodies, horizontal plan examples, batch scheduling, unbounded correction loops, and phrase-presence tests that do not enforce behavior.

The solution is not to remove review or indiscriminately shorten prompts. It is to increase semantic density, make lifecycle rules executable, and remove text that is duplicated, stale, branch-specific, or behaviorally inert.

## Goals

- Establish product and domain truth before solution architecture when the work requires it.
- Preserve stable outcome IDs from product contract through spec, task, test, review, evidence, and closure.
- Make every planned task a demonstrable vertical slice or an immediately consumed enabling probe.
- Give each worker a small, immutable, versioned context contract.
- Enforce one task identity per agent context and bounded correction loops.
- Replace ready-task batch barriers with rolling, resource-aware scheduling.
- Improve brainstorming and stress-test coverage while reducing unnecessary serial user turns.
- Reduce the common invoked token path and rendered bootstrap without reducing acceptance, security, or required-skill adherence.
- Make deterministic requirements executable and behavioral requirements testable.
- Preserve cross-platform behavior without claiming unsupported model or isolation controls.

## Non-Goals

- Installing or integrating `affaan-m/ecc`.
- Building a general-purpose orchestration daemon or replacing the host agent runtime.
- Changing the Beads database schema.
- Automatically inferring missing product decisions from implementation code.
- Starting true dependent work from unreviewed task branches by default.
- Removing independent task, code, security, or outcome review to improve speed.
- Running token-costing LLM evaluations automatically in `just check`, hooks, or CI.
- Restoring the deprecated LLM suites unchanged.
- Implementing the skill changes as part of this design document.

## Design Principles

1. **Predictable process, variable output.** Skills should make agents follow the same decision process, not force identical prose.
2. **One source of truth.** Each product fact, workflow rule, and evidence rule has one owner. Specifications and tasks reference product outcome IDs and revisions rather than restating product truth.
3. **Governing facts, not full history.** Workers receive every fact that governs their branch, plus references and revisions; they do not receive entire plans or conversations.
4. **Progressive disclosure.** Inline what every branch needs. Move examples, question banks, platform notes, and conditional references behind precise pointers.
5. **Checkable completion.** Every skill step ends in an observable completion criterion.
6. **Positive contracts before prohibitions.** Describe the required output shape. Retain prohibitions only for hard safety or lifecycle guardrails and pair them with the correct action.
7. **Mechanics in validators, judgment in skills.** A parser should enforce required fields, hashes, graph invariants, and resource conflicts; prose should teach product and engineering judgment.
8. **Quality is the floor.** Token and clock-time reductions are rejected if matched scenarios show worse product acceptance, security, verification, or review behavior.

These principles adopt the relevant information-hierarchy, single-source, completion-criterion, no-op, sediment, and progressive-disclosure concepts from [Writing Great Skills](https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/productivity/writing-great-skills/SKILL.md) and its [glossary](https://raw.githubusercontent.com/mattpocock/skills/refs/heads/main/skills/productivity/writing-great-skills/GLOSSARY.md).

## Product Outcome Contract

The user is a maintainer or product engineer who begins with a request, research finding, or accepted requirement and needs to reach a verified change without losing product meaning or spending hours in avoidable orchestration tails. The durable objects are the product contract, design spec, graph plan, task/review evidence, and acceptance record.

| Acceptance ID | Starting interface | Action and durable result | Required failure behavior | Evidence class |
|---|---|---|---|---|
| `SWF-PRODUCT-CONTRACT` | Substantial product-affecting work lacks an adequate approved product contract | `product-definition` creates or normalizes an approved standalone contract with source precedence, actors, vocabulary, lifecycle, invariants, examples, non-goals, and stable outcome IDs; an adequate existing contract is reused without invoking the skill | Architecture cannot begin while required cells are unresolved unless a named decision owner is recorded; mechanical internal work may use an explicit reasoned bypass | Behavioral scenario plus contract validator |
| `SWF-VERTICAL-SLICE` | Planner receives an approved product contract and design | The graph contains independently demonstrable slices or enabling probes consumed immediately by named slices | Horizontal foundation chains with no early live seam fail validation | Graph fixtures plus behavioral planning scenario |
| `SWF-CONTEXT-MANIFEST` | Controller dispatches a task | Worker receives a versioned runtime manifest and reads one authoritative task bead | Missing or conflicting governing facts produce `NEEDS_CONTEXT` before edits | Manifest validator plus transcript evidence |
| `SWF-FRESH-CONTEXT` | Controller creates or follows up an implementer/reviewer | One agent context remains bound to one task ID, contract hash, base, and worktree | Cross-task or cross-worktree follow-up is refused; after two failed reviews the task is diagnosed and split/re-planned | Scheduler/controller fixtures plus transcript evidence |
| `SWF-ROLLING-FLOW` | Multiple tasks are ready or running | Reviews overlap independent implementation; each approved merge releases resources and recomputes readiness | True dependents wait for reviewed-and-merged dependencies; resource conflicts never run concurrently | Deterministic state-machine fixtures |
| `SWF-EVIDENCE-GATE` | Task or epic approaches closure | Every acceptance ID has the required evidence on the named commit/environment/fixture | `FAIL`, `BLOCKED`, `UNTESTED`, stale, or substituted evidence keeps the gate open | Evidence-manifest fixtures plus outcome-review scenario |
| `SWF-TOKEN-BUDGET` | A skill or prompt is edited | Common invoked paths and rendered bootstrap become smaller while behavioral results remain equal or better | A smaller candidate with lower acceptance/security/skill adherence is rejected | Byte/word telemetry plus A/B micro-tests |
| `SWF-CROSS-PLATFORM` | Claude, Codex, OpenCode, or another supported host dispatches work | The record distinguishes requested, effective, inherited, and unavailable controls | The workflow never claims a model/fork control the host cannot provide and never accepts an incapable effective model | Platform fixtures and adapter scenarios |
| `SWF-ADVERSARIAL-COVERAGE` | Brainstorming or stress-test examines a product/design/plan | Relevant product, domain, lifecycle, migration, integration, failure, operations, security, accessibility, and evidence branches are resolved with concrete counterexamples | The workflow cannot finish by paraphrasing the artifact or skipping applicable matrix cells | Behavioral coverage and novelty scoring |

Every acceptance ID remains stable through implementation. A later scope cut must name the affected IDs and record explicit user approval.

## Target Workflow

```text
research / repository ground truth
  -> conditional product-definition
  -> approved product contract
  -> brainstorming / solution design
  -> adversarial stress test
  -> writing-plans / vertical Slice Contracts
  -> contract validation
  -> rolling SDD implementation + task review
  -> integration checkpoints
  -> independent code review + outcome review
  -> evidence-aware finishing
```

### Stage ownership

| Stage | Owner | Owns | Does not own |
|---|---|---|---|
| Product definition | New `product-definition` skill | Product intent, source precedence, actors, domain model, journeys, lifecycle, outcome IDs | Technical architecture or implementation decomposition |
| Solution design | `brainstorming` | Repository ground truth, approaches, architecture, trade-offs, design approval | Reconstructing an approved product contract |
| Adversarial review | `stress-test` | Applicable decision branches, counterexamples, assumptions, risk and evidence gaps | Creating the initial design or implementation verification |
| Planning | `writing-plans` | Outcome trace, vertical Slice Contracts, graph dependencies, integration checkpoints | Rewriting routine implementation as full code |
| Execution | `subagent-driven-development` or `executing-plans` | Context lifecycle, scheduling, review, integration, durable progress | Product reinterpretation or plan recreation |
| Evidence | `verification-before-completion`, task reviewer, outcome reviewer | Fresh proof, evidence classes, non-substitution, acceptance state | Quiet scope cuts or inferred waivers |

## New `product-definition` Skill

### Trigger

The skill is model-invoked with a narrow description. It applies when substantial product-affecting work lacks an adequate approved product contract, or when an existing contract is incomplete, conflicting, or requires product discovery. It creates a new contract or normalizes already-complete requirements without re-interrogating the user. It is not invoked when an adequate contract already exists, for small work that does not warrant a formal specification or plan, or for a deterministic internal refactor with no externally observable behavior change.

For substantial product-affecting specifications and plans, the contract artifact is required; use of this skill is conditional. The contract is the sole source of product truth until superseded. Designs, plans, and task beads reference its stable outcome IDs and revision instead of restating requirements.

### Output

The canonical artifact is:

`docs/product/YYYY-MM-DD-<topic>-product-contract.md`

The skill body contains the execution spine; a sibling template/reference contains the full artifact schema and optional question prompts. The output includes:

- Goal, measurable success signal, and current workaround.
- Source ledger and precedence: original request, existing behavior, research, clarification, newly requested, or deferred.
- Actors, roles, permissions, authority grants, and decision owners.
- Canonical vocabulary, synonyms to reject, domain entities, and ownership.
- State transitions, business invariants, transaction boundaries, and side effects.
- Journeys from real entry point through durable result and find-again/use path.
- Empty, loading, invalid, denied, conflict, offline, recovery, undo/archive, and narrow-screen states where applicable.
- Concrete examples and falsifying counterexamples.
- Stable outcome IDs with evidence classes.
- Non-goals, deferred outcomes, and unresolved decisions.
- Assumptions in verified/recalled/assumed bins.

Independent questions may be batched up to three. Questions whose answers change later branches remain serial. The skill ends only when every applicable cell is resolved, explicitly deferred with approval, or assigned to a named decision owner.

### Bypass

Internal mechanical work may bypass with:

`Product contract: Not applicable — <observed reason no externally visible or durable behavior changes>.`

The bypass is testable and cannot be used merely because the change appears small. It is valid only when the work changes no user-visible behavior, durable business rule, workflow, terminology, or external interface. Task review rejects an unsupported bypass.

## Information Architecture and Pruning

### Primary skill shape

Each primary `SKILL.md` contains only:

1. Trigger and non-trigger boundary.
2. Required inputs.
3. Ordered steps.
4. Checkable completion criteria.
5. Escalation/routing decisions.
6. Conditional pointers to owned reference material.

Reference material is co-located with its owner. A pointer states the exact condition under which it must be read. Required common-path rules remain inline; optional examples and branch-specific material move out.

### Single ownership

| Meaning | Canonical owner |
|---|---|
| Product/domain contract and artifact template | `product-definition` |
| Design process and approval gate | `brainstorming` |
| Slice Contract and graph plan | `writing-plans` |
| Runtime Context Manifest and agent lifecycle | SDD |
| Worktree creation/removal | `using-git-worktrees` |
| Generic parallel investigation pattern | `dispatching-parallel-agents` |
| Task review prompt | SDD `task-reviewer-prompt.md` |
| Whole-branch/ad hoc code review | `requesting-code-review` |
| Product outcome review | SDD `outcome-reviewer-prompt.md` |
| Evidence/non-substitution | `verification-before-completion` |
| Beads/capture/memory session policy | `using-superpowers` references |

### Concrete pruning decisions

- Replace copied capture, memory, and Beads-frugality blocks with concise references to their owner; change the convention guard from synchronizing copies to rejecting copied policy blocks.
- Remove repeated workflow renderings when checklist, flowchart, prose, walkthrough, and key-principle sections encode the same sequence.
- Replace brainstorming's permanent procedural step children with one durable session bead; create extra beads only for deliverables, unresolved work, blockers, or decisions.
- Move brainstorming visual guidance, question banks, examples, and anti-pattern catalogues behind conditional pointers.
- Replace stress-test's loose decision-tree inventory and fully serial questioning with an applicability matrix and dependency-aware batching.
- Remove mandatory 2–5 minute plan steps and routine full-code snippets. Retain exact novel public contracts, subtle algorithms, migrations, commands, and expected evidence.
- Remove SDD's duplicated parallel tutorial, worktree commands, example workflow, advantages/cost narrative, and repeated red-flag statements when an executable state or owned reference covers them.
- Remove the SDD integration tutorial and dated narrative example from `dispatching-parallel-agents`; keep only generic independent-domain dispatch.
- Make `executing-plans` validate and consume an existing graph rather than recreating epic/task beads from prose.
- Reduce verification to an executable claim/evidence/state gate; disclose examples and rationalization catalogues conditionally.
- Split research completion criteria by repository-only, external, and mixed research modes so a repository-only task does not require URL sources.
- Narrow broad descriptions to one trigger per distinct branch and remove workflow summaries that encourage agents to skip bodies.

### Implementer prompt pruning

The implementer prompt becomes a role contract rather than a second workflow skill. Remove:

- Subagent Beads claim/update instructions; the controller owns Beads mutation.
- Unconditional loading of systematic debugging; invoke it only on an unexpected failure.
- Universal LSP requirements for every function and test; require blast-radius analysis for shared/public symbols and high-risk call paths.
- Repeated TDD, verification, self-review, code-organization, and escalation prose already owned by skills or the Slice Contract.
- Generic encouragement and narrative explanations that do not alter behavior.

Retain:

- Task identity and runtime Context Manifest.
- `CONTRACT_READY`/`NEEDS_CONTEXT` preflight.
- Task-local scope and production-grade/security floor.
- Required task-specific skills by name and trigger.
- Report path, typed evidence, commit range, and final status.

## Slice Contract

Every graph task description uses a compact, lintable contract:

```markdown
## Context
- Product contract: <path + revision> | Not applicable — <reason>
- Spec: <path + revision>
- Outcome IDs: <stable IDs>
- Why this slice exists: <user/system outcome or immediate enabling probe>
- Non-goals: <explicit boundary>
- Open decisions: None | <decision + owner>

## Outcome
- Actor / entry interface: <who starts where>
- Action: <what they do>
- Observable result: <what can be seen>
- Durable result / find-again path: <state and later use>
- Denied/failure/recovery result: <negative behavior>

## Domain Contract
- Vocabulary: <canonical terms>
- Invariants: <business, authority, lifecycle, concurrency>
- Counterexamples: <falsifying cases>

## Files and Resources
- Allowed write set: <paths>
- Prohibited paths: <paths>
- Exclusive resources: <locks or None>
- Capacity resources: <resource + units or None>

## Interfaces
- Consumes: <reviewed contracts>
- Produces: <contracts and immediate consumer>

## Acceptance Criteria
- <AC-ID>: Given/When/Then; procedure; evidence class; expected result

## Integration Checkpoint
- <earliest real seam, environment, cleanup>

## Implementation Notes
- <only novel contract, algorithm, migration, or observed local pattern>
```

A task is valid when a reviewer could reject it independently and its completion creates either an independently demonstrable product behavior or an independently operable platform capability exercised by its first real consumer in the same task. Setup, schema, interface, test-only scaffolding, and documentation are folded into the slice that first consumes them. An exception requires a concrete integration-risk reason, explicit downstream acceptance linkage, a named immediate consumer, and an early integration checkpoint.

### Dependency semantics

- Beads `blocks` edges remain execution dependencies.
- Acceptance dependencies are declared inside the Slice Contract and checked by the plan validator.
- Write/resource conflicts are scheduler constraints, not fake execution dependencies.
- True dependents become ready only after prerequisite review and merge.

## Runtime Context Manifest

The controller constructs this small dynamic envelope at dispatch:

```text
task_id
contract_hash
governing_artifacts: <trusted path@revision list>
outcome_ids
base_commit
reviewed_dependency_commits
worktree
allocated_resources
model_requested
model_effective
model_control: explicit | inherited | unavailable
capability_tier
context_mode: isolated | host-limited
report_path
```

The worker reads the authoritative bead for static requirements. The controller does not paste the full graph, product contract, design, parent conversation, or supporting history. Supporting material remains pull-based and is read only when a manifest or task field names the governing need. The manifest is fixed to identity, governing revisions, boundaries, dependencies, resources, verification, and known conflicts.

### Contract preflight

Before editing, the worker emits:

```text
CONTRACT_READY
- task_id / contract_hash / base / worktree
- interpreted outcome and acceptance IDs
- fixed invariants and counterexamples
- consumed/produced interfaces
- open decisions: none
```

This is non-blocking: the worker may continue without controller acknowledgment when all fields agree.

If information is missing or conflicting, it emits and stops:

```text
NEEDS_CONTEXT
- missing/conflicting field
- evidence and source conflict
- affected implementation choices
- requested source or decision owner
```

Clarifications update the authoritative task contract and contract hash before redispatch. They are not left only in chat history.

## SDD Lifecycle and Scheduling

### Immutable agent identity

- One task ID, contract hash, base commit, and worktree per agent context.
- Initial implementation and review use isolated context where the host supports it.
- Follow-ups may address only the same task and contract lineage.
- A cross-task/worktree follow-up is refused and freshly dispatched.
- The same implementer may handle at most two correction rounds for its task.
- Every review round uses a fresh reviewer.

### Typed correction delta

Each review finding has:

- Finding ID and severity.
- Acceptance IDs affected.
- Classification: contract gap, implementation defect, evidence gap, integration defect, or reviewer disagreement.
- File/line or execution evidence.
- Invalidated assumption or contract section.
- Required correction and counterexample.
- Contract hash and review round.

After two failed reviews, the controller stops normal correction and runs a diagnostic gate. It must amend/re-version the contract, split an oversized slice, resolve a product/design decision, or adjudicate reviewer disagreement before further implementation.

### Rolling resource-aware scheduler

A task is dispatchable only when:

- All execution dependencies are reviewed and merged.
- Its contract hash matches the current graph/task state.
- Its write set does not conflict with active work.
- Exclusive and capacity resources are available.
- A worker slot is available without consuming reserved review/integration capacity.

Reviews may run while unrelated implementers continue. Each approved task merges immediately, resources are released, and readiness is recomputed. True dependents do not start from unreviewed branches by default. The controller alone rebases, merges, and pushes.

Speculative dependent execution is an explicit plan opt-in, never an inferred optimization. It requires a frozen consumed interface, non-overlapping write/resources, and a declared bounded discard or rebase cost. Otherwise true dependents wait for reviewed-and-merged prerequisites.

No-ready-task is not treated as completion. Completion requires zero open required tasks plus passing acceptance gates; ready may be empty because work is blocked, deferred, in progress, human-gated, or cyclic.

### Verification economy

- Focused RED/GREEN checks run during implementation and correction.
- Affected suites and required real seams run before task review.
- Broad evidence is keyed by commit, environment, fixture version, and acceptance ID.
- Unchanged evidence may be reused; invalidated evidence is rerun.
- Full integration/final gates run at declared checkpoints rather than after every arbitrary batch.
- Final code review and outcome review may run concurrently when they are read-only and do not contend for the same environment.

## Review and Evidence Contracts

Task review remains diff-scoped and skeptical. It receives the task bead, runtime manifest, implementation report, `BASE..HEAD` review package, and relevant product/domain capsule. It reports:

| Acceptance ID | Local result | Evidence | Finding ID / integration dependency |
|---|---|---|---|

An unverifiable required criterion is not silently approved. The controller must either attach decisive existing evidence or leave the criterion open for the named integration checkpoint.

Review ownership is explicit:

- SDD task review: `task-reviewer-prompt.md` only.
- Whole-branch/final/ad hoc code review: `requesting-code-review`.
- Integrated product acceptance: `outcome-reviewer-prompt.md`.

Only `PASS` satisfies a required outcome ID. CI, unit tests, direct API calls, browser/live evidence, persistence, security, rollback, and agent-off checks are distinct when the product contract names them. The controller refuses the task or epic `complete` transition unless the evidence ledger contains passing results for every required acceptance ID at the current commit, contract revision, environment, and fixture version. Skill invocation is guidance; the state transition is the hard gate.

## Brainstorming and Stress-Test Quality

### Brainstorming

Brainstorming reads the approved product contract and does not ask the user to repeat resolved product facts. It still verifies repository ground truth and discrepancies. Questions are selected from unresolved architectural choices and implementation constraints.

Independent questions may be batched up to three. Decision-dependent branches stay serial. Every question cites observed evidence, explains why the decision matters, and includes a recommended option when the answer space is discrete.

### Stress test

The stress test maps applicable branches across:

- Product/user outcome.
- Domain model, authority, and invariants.
- Data/state migration.
- Integration and dependency contracts.
- Failure, recovery, cancellation, and rollback.
- Operations, observability, rollout, and cleanup.
- Security, privacy, accessibility, and abuse cases.
- Evidence quality, assumptions, and negative examples.

It must produce at least one concrete falsifying example for every high-risk invariant. Novelty is measured: repeating an existing requirement is not a newly surfaced complication. Independent low-risk questions may be batched; answers that reshape later branches remain serial.

## Testing Strategy

### RED–GREEN–REFACTOR for each skill

Before editing an individual skill:

1. Run a fresh-context control scenario without the candidate guidance.
2. Confirm the targeted failure occurs.
3. Make the smallest skill/validator change addressing that failure.
4. Run the same scenario with the candidate.
5. Use at least five samples per wording variant when micro-testing prompt shape.
6. Read every flagged transcript and measure variance.
7. Refactor only while the behavior remains green.
8. Complete that skill's checks before editing the next skill.

### Opt-in micro-test runner

The repository gains a small local runner for skill-edit development. It is not part of `just check`, hooks, or CI. It supports:

- Scenario files with control/candidate prompt and scoring rubric.
- Required ordered candidate-skill paths constrained lexically and canonically to non-symlink Markdown artifacts beneath the trusted `skills/` root; evidence hashes canonical paths plus the actual skill bytes, never only prompt text.
- Fresh-context provider adapters for locally available Claude and Codex CLIs.
- Five-or-more repetitions, raw transcript paths, and aggregate shape/variance output.
- Explicit cost confirmation, maximum-run cap, and a conservative pre-execution reservation of USD 1.00 per scheduled live call; the evidence states that this is not a provider hard cap.
- Secret/path redaction.
- Fixed adapter command construction; scenario data is never executed as shell.
- Human adjudication of ambiguous results.

Each provider call uses an ephemeral OS temporary cwd outside the checkout. Persistent raw transcripts use a separate OS-temporary 0700 directory with 0600 files; only redacted evidence may persist under the repository-local evaluation directory.

The runner is distinct from the deprecated broad suites and from ECC. Heavy continuous model evaluation remains an external concern.

### Deterministic validators

Repository checks cover:

- Graph JSON syntax, unique keys, parent/edge validity, DAG status, and edge direction.
- Required Slice Contract sections, stable IDs, no placeholders, outcome ownership, and early integration seam.
- Context Manifest fields, contract hashes, model-effective status, and isolated/host-limited context status.
- Scheduler transitions, review reservation, resource conflicts, dependency merge gates, and one-task identity.
- Review round limits, finding IDs, acceptance matrices, and evidence states.
- Rendered SessionStart payload size by startup/resume/clear/compact event.
- Skill descriptions and copied-policy-block regressions.
- Installer/manifests and documentation for the new skill.

### Behavioral campaigns

- Ambiguous multi-role product work versus legitimate internal bypass.
- Product/domain complications found before architecture.
- Brainstorming consumes, rather than repeats, the product contract.
- Vertical slicing versus heading-compliant horizontal decomposition.
- `CONTRACT_READY` and useful `NEEDS_CONTEXT` behavior.
- Cross-task follow-up refusal.
- Rolling implementation/review scheduling.
- Two-failed-review diagnosis and split/re-plan.
- Stress-test novelty and counterexample quality.
- Evidence non-substitution and strict closure.
- Pruned versus existing common-path behavior and token measurements.

## Token and Clock-Time Measurement

Measure runtime paths, not only individual files:

- Rendered bootstrap bytes by lifecycle event.
- Plugin-owned skill-description catalogue bytes.
- Words/bytes loaded for product definition, brainstorming, planning, implementation, task review, and completion paths.
- Task prompt versus total first-turn context.
- Time to first material repository action.
- RED, GREEN, verification, review, correction, merge, blocked, user-wait, and external-wait durations.
- Follow-ups, task identities, worktree switches, and compactions per agent.
- Review rounds and finding class/severity.
- Acceptance result and escaped product defects.

Runtime-path membership is versioned in `tests/fixtures/workflow-metrics/paths.json`; it is data, not an implicit list inside the measurement script. The baseline paths are:

- `accepted_contract` and `matched_legacy`: `using-superpowers`, `brainstorming`, `stress-test`, `writing-plans`, the SDD spine, implementer prompt, verification, task reviewer, outcome reviewer, and branch finishing. The observed baseline is 20,598 words.
- `product_discovery`: the accepted-contract path plus every `product-definition` file actually loaded during discovery. Before that skill exists, its baseline equals `accepted_contract`; the final incremental product-definition cost is `product_discovery - accepted_contract`.
- `internal_bypass`: `using-superpowers`, `writing-plans`, the SDD spine, implementer prompt, verification, task reviewer, and branch finishing. It excludes product discovery, brainstorming/stress testing, and outcome-contract review; the observed baseline is 14,648 words.

Task 1 creates the baseline manifest and snapshot. Task 10 updates the manifest to the final candidate's actually loaded files before taking the candidate snapshot. Missing, escaping, or duplicate manifest entries fail measurement rather than being silently ignored.

Initial acceptance targets:

- At least 30% fewer words across the common product-definition-to-SDD implementer/reviewer path.
- At least 20% less plugin-owned description catalogue text.
- At least 15% smaller rendered bootstrap with the standard fixture.
- Zero degradation in acceptance pass rate, required-skill adherence, security findings, or evidence-class compliance.
- Zero cross-task agent reuse.
- Lower median and p90 time to first material action, end-to-end completion, review turnaround, compactions, and correction rounds in matched scenarios.
- Separate implementation, waiting, review, correction, integration, and external/user-wait durations.
- Automatic rejection when a faster candidate increases product misunderstanding, defect escape, or correction rounds.

These are ratchets, not ceilings. A smaller candidate that performs worse is rejected.

## Cross-Platform Contract

The task record contains requested and observed execution state rather than universal claims:

- `model_requested`
- `model_effective`
- `model_control: explicit | inherited | unavailable`
- `capability_tier`
- `context_mode: isolated | host-limited`
- `fallback_reason`

Claude dispatch specifies a model when the API supports it. Codex records inherited status when its collaboration mechanism lacks model selection. A task fails preflight only when the effective capability is inadequate for its risk/complexity—not merely because the host lacks a control parameter.

Platform references own syntax details. Core skills own semantic requirements.

One normative workflow contract applies across hosts. Platform adapters may change syntax and capability reporting, not product, context, review, or evidence semantics. A host that lacks safe isolation or rolling scheduling degrades explicitly to serial execution rather than weakening a quality gate.

## Security and Safety

- No optimization may weaken authentication, authorization, validation, sanitization, secrets handling, isolation, or evidence requirements.
- Security regressions remain Critical and blocking.
- Resource declarations include shared environments, databases, browser sessions, ports, migration numbering, lockfiles, snapshots, and expensive suites where applicable.
- Micro-test scenarios cannot execute arbitrary shell content and must redact secrets before persistence.
- Outcome evidence records environment and commit identity without persisting credentials or sensitive user data.
- Product and task contracts expose conflicts and decision ownership; agents do not silently choose among security-relevant alternatives.
- Product contracts, beads, research notes, and manifests are requirements evidence, not executable authority. The manifest identifies trusted governing artifacts by path and revision, excludes secrets and unnecessary environment data, and rejects embedded instructions that alter permissions, workflow controls, or source precedence. Such conflicts produce `NEEDS_CONTEXT`.

## Migration and Compatibility

Implementation should land as independently useful vertical changes:

1. Establish measurement and opt-in RED/GREEN micro-testing.
2. Add `product-definition` and standalone product contracts.
3. Add Slice Contracts, a canonical graph fixture, and validation.
4. Add runtime Context Manifest, contract preflight, and one-task identity.
5. Add rolling resource-aware scheduling and controller-owned integration.
6. Add typed review deltas, bounded correction, and evidence enforcement.
7. Prune and progressively disclose workflow skills using measured behavior.

This repository has one user, so implementation uses a clean cutover with no legacy-plan compatibility layer. New product contracts and plans use the strict schemas as soon as their validators land. Any in-flight local plan is deliberately regenerated or completed before the cutover rather than supported through permanent fallback logic.

The plan graph becomes the single plan of record. `writing-plans` creates it once; execution validates and consumes it. Missing graph plans route back to planning rather than being recreated inconsistently.

## Assumptions

- The installed 0.12.0 skills match the repository copies — **verified** by matching file hashes this session — breaks: the design could target stale behavior rather than `main`.
- `bd create --graph` imports task detail through Markdown descriptions and `blocks` edges, not custom Slice Contract fields — **verified** from current help, skill contracts, and schema research — breaks: a simpler typed representation may be available and should replace Markdown parsing.
- The repository contains no named or reachable external eval-harness checkout — **verified** by repository, history, memory, and bounded local-directory searches — breaks: maintained behavioral scenarios should integrate with that harness instead of duplicating an adapter.
- ECC is not the unnamed Superbeads eval harness — **verified** from the absence of any ECC reference in the governing decision and ECC's published broad harness scope — breaks: an existing approved ECC integration should be evaluated before building local tooling.
- Codex's observed collaboration API cannot select a child model while Claude's observed dispatch can — **verified** from the audited conversation corpus — breaks: platform adapters should use newly available controls and update the compatibility matrix.
- A Markdown Slice Contract can be parsed reliably enough for deterministic validation — **assumed** — breaks: adopt a generated sidecar JSON manifest while retaining human-readable task descriptions.
- The initial 30%/20%/15% reduction targets are achievable without quality loss — **assumed**, based on measured duplication and long common paths — breaks: retain quality-bearing content and record the measured lower reduction rather than forcing the target.
- This repository currently has one user and does not require legacy-plan compatibility — **verified** by the user's stress-test decision — breaks: a future multi-user release needs an explicit migration policy before enforcing a new artifact schema.
- No commit or push is permitted in this session — **verified** from the user's instruction — breaks: none; written artifacts remain uncommitted for review.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Product definition adds ceremony to trivial work | Narrow trigger and evidence-backed internal bypass |
| Progressive disclosure hides a must-have rule | Precise context pointer, behavioral tests, and inline fallback when retrieval remains unreliable |
| Markdown contract parsing is brittle | Canonical fixture, parser tests, normalized headings, sidecar JSON fallback if needed |
| Contract preflight adds latency | `CONTRACT_READY` is non-blocking; only genuine `NEEDS_CONTEXT` stops |
| Reserved review capacity underutilizes workers | Capacity policy is platform-aware and measured against critical-path throughput |
| Rolling merges create integration churn | Controller-only integration, reviewed dependency gate, write/resource locks |
| Bounded review loops stop legitimate difficult work | Diagnostic gate does not abandon work; it classifies and changes task/contract strategy |
| Token targets incentivize destructive pruning | Behavioral non-regression and security/evidence floors override size targets |
| Local micro-tests spend money or leak data | Explicit opt-in/cap, redaction, fixed adapters, no automatic execution |
| Clean cutover interrupts in-flight local work | Complete or deliberately regenerate the known local plan before enabling blocking validation |

## Acceptance Evidence Plan

| Acceptance ID | Earliest owning slice | Final evidence |
|---|---|---|
| `SWF-PRODUCT-CONTRACT` | New skill and contract validator | Ambiguous and bypass behavioral scenarios plus valid artifact |
| `SWF-VERTICAL-SLICE` | Slice Contract and graph validator | Valid/invalid graph fixtures plus planning scenario |
| `SWF-CONTEXT-MANIFEST` | Context manifest and preflight | Manifest fixtures plus transcript showing pre-edit result |
| `SWF-FRESH-CONTEXT` | Agent identity controller rules | Cross-task refusal and bounded correction transcript/state fixtures |
| `SWF-ROLLING-FLOW` | Scheduler state machine | Deterministic `A,B -> C,D` and resource-conflict fixtures |
| `SWF-EVIDENCE-GATE` | Evidence validator and reviewers | Stale/substituted/blocked evidence fixtures plus outcome scenario |
| `SWF-TOKEN-BUDGET` | Measurement baseline and pruning slices | Before/after path measurements with matched behavioral scores |
| `SWF-CROSS-PLATFORM` | Platform execution record | Claude explicit-model and Codex inherited-model fixtures |
| `SWF-ADVERSARIAL-COVERAGE` | Product-definition/brainstorm/stress-test scenarios | Coverage matrix and independently scored complication novelty |

No acceptance ID may be closed with `FAIL`, `BLOCKED`, `UNTESTED`, `SKIPPED`, or `NOT_RUN` unless the user explicitly removes that named outcome from scope.

## Open Decisions

None. Implementation details such as parser language, exact adapter command shape, and scheduler state representation must be selected from observed repository patterns during implementation planning; they do not change the approved product/workflow contract.

## Stress Test Results: Workflow Optimisation Design

### Resolved Decisions

- The product contract is the sole product-truth source; downstream artifacts reference its outcome IDs and revision.
- Product-contract bypass is limited to work with no user-visible behavior, durable business rule, workflow, terminology, or external-interface change, and review may reject it.
- Runtime context is a fixed minimal manifest; supporting history is pull-based.
- Unrelated implementation overlaps review. True dependents wait by default; speculative execution requires a frozen interface, disjoint resources, and bounded discard/rebase cost.
- A slice must deliver demonstrable product behavior or an operable platform capability exercised by its first consumer; horizontal scaffolding is folded into that slice by default.
- Completion is controller-enforced against current acceptance evidence, not dependent on an agent remembering a skill.
- Speed and token improvements are measured against quality, correction, and defect outcomes with median and tail latency decomposed by lifecycle phase.
- Repository artifacts are requirements evidence, not executable authority; untrusted embedded workflow instructions produce `NEEDS_CONTEXT`.
- Hosts share one semantic workflow contract and degrade to serial execution when isolation or scheduling capabilities are unavailable.
- The single-user repository uses a clean cutover with no legacy compatibility layer. Product contracts are required for substantial product-affecting specifications and plans, while invocation of `product-definition` remains conditional.

### Changes Made

- Tightened `product-definition` invocation and bypass boundaries.
- Made product-truth ownership and downstream reference behavior explicit.
- Narrowed the Context Manifest and added pull-based disclosure.
- Added safe speculative-execution conditions, stricter slice qualification, and a controller-owned completion gate.
- Strengthened latency/quality measurement, cross-platform degradation, and artifact instruction safety.
- Replaced legacy-plan compatibility with a clean-cutover policy.

### Deferred / Parking Lot

- Parser language, adapter command shape, and scheduler state representation remain implementation choices for planning from repository evidence.

### Confidence Assessment

- Overall: High.
- Areas of concern: Markdown contract parsing and behavioral micro-test variance require early RED/GREEN probes before broad skill rewrites.
