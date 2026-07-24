# Superbeads Skill Usage and Workflow Review

> Date: 2026-07-15
> Beads: `beads-superpowers-4sl` (original review), `beads-superpowers-psr` (subagent-context follow-up)
> Status: Complete research; implementation not started

## Summary

The dominant clock-time problem is not that subagents are uniformly slow. It is a long-tail problem created by oversized horizontal tasks, late product feedback, repeated broad verification, review/fix loops, long-lived agent contexts, batch barriers, and integration/environmental overhead; the named 26h44m Codex epic contained about 18h30m of active planning/execution and an 8h11m host-resource pause. [S1][S2]

The dominant accuracy problem is that Superbeads historically optimized technical closure more strongly than product closure. The 2026-07-14 product-outcome additions materially improve this, but product definition, domain vocabulary, business rules, executable acceptance evidence, rolling scheduling, and behavioral enforcement remain incomplete. [S3][S4]

A follow-up audit of the actual SDD worker packets found that technical context was usually detailed, while product/domain truth, stable acceptance IDs, shared-resource declarations, and context-lifecycle controls were weak or absent. The context problem is therefore **semantically incomplete context inside a large ambient context**, compounded by stale cross-task agent reuse—not a general shortage of prompt text. [S11][S12]

## Scope and Method

Review window: 2026-07-02 through 2026-07-15, Australia/Brisbane date boundary.

The review combined:

- 80 top-level local Codex task records, of which 42 prior tasks had subagent dispatch/follow-up activity;
- deep traces of Codex tasks `019f5e29-3da5-7bf2-9096-e26c8b52e1c5` and `019f5f29-9558-7d90-85ea-0c3a86ed60be`, plus six related planning, execution, and acceptance traces;
- 18 top-level Claude records with explicit historical Superbeads skill calls, grouped into 13 logical workflows, plus 271 nested subagent records;
- the current repository skills, prompts, tests, and relevant git history; and
- primary external guidance on multi-agent orchestration, long-running agent harnesses, evaluation, context engineering, and small-batch delivery. [S1-S10]

The follow-up context audit examined 111 Claude implementer/fix dispatches, 109 Claude task-review/re-review dispatches, and 150 Codex implementation/integration/review/fix spawns across five deep SDD workflows. It scored the observable packet and handoff lifecycle for product outcome, acceptance, domain rules, task boundary, authority/source, files/interfaces, dependency/base/worktree, write/shared resources, verification, model/skills, unresolved decisions, inheritance, reuse, and follow-up deltas. [S11][S12]

Limitations:

- Log-record span is not active model time. It includes user waits, queued capacity, external blockers, and idle time after an agent first reports completion.
- Summed subagent duration double-counts concurrency and therefore is workload, not critical-path duration.
- Some Codex reasoning and inter-agent payloads are encrypted; observable events, prompts, results, waits, compactions, and timestamps remain available.
- Codex collaboration message bodies are encrypted in local rollouts. Fork mode, model/effort, injected baseline, task/bead content, first actions, clarifications, follow-ups, and outcomes are observable, but exact Codex task-prompt field counts are not.
- Automated skill attribution is imperfect because skill catalogues occur in context. Explicit invocations and recognizable workflow events were used.
- The strongest product-outcome gates landed in commit `d6eb16b` on 2026-07-14, near the end of the review period. Most historical failures predate those changes, so this report separates historical behavior from current design.

## Overall Diagnosis

### 1. Long execution time is a tail and rework problem

**Confidence: High.**

Claude's seven canonical execution workflows contained about 58.2 summed subagent-hours, but their per-agent medians were only about 3.4-6.8 minutes; p90 durations were about 26.5-44.5 minutes. The named Codex epic shows the same shape: small exploration agents completed in minutes, while a few subsystem-sized implementation and review contexts ran for hours, accumulated many follow-ups, and compacted repeatedly. [S1][S2]

In `019f5e29...`, the 26h44m record decomposes into approximately:

| Phase | Elapsed time |
|---|---:|
| Research, brainstorming, stress test, and planning | 3h06m |
| Execution through Task 10 | 11h18m |
| External file-descriptor blocker/user pause | 8h11m |
| Resumed Task 11/12 work | 4h06m |

The active time is still far too high. The important correction is that "23+ hours" should not be interpreted as "subagents spent 23+ hours implementing." [S1]

The largest active-time drivers were:

1. Horizontal task decomposition deferred the useful end-to-end behavior until Tasks 11-13.
2. Several tasks were subsystem-sized. Review packages reached roughly 72 KB, 108 KB, and 238 KB plus remediation diffs.
3. Reviews found real security, concurrency, persistence, recovery, and interaction defects, forcing multiple correction rounds.
4. A single implementer and reviewer were reused across multiple nominal tasks, accumulating 11 and 8 compactions respectively and violating the current fresh-agent-per-task rule.
5. Full or broad gates were repeated during remediation instead of reusing commit/environment-keyed evidence and escalating from focused to broad tests.
6. Implementer-owned pull/rebase behavior rewrote prerequisite ancestry and created controller repair work.
7. Moving plugin-cache paths, stale report paths, shared host limits, and resource contention added non-product work. [S1][S3]

The Claude execution sample contained 109 implementation/fix agents and 130 review/re-review/verification agents, including at least 16 explicitly labeled re-reviews. Review workload was therefore at least as large as implementation workload. [S2]

The conclusion is not "remove review." Review caught defects serious enough that skipping it would improve clock time by accepting lower quality. The higher-leverage intervention is to move product/contract feedback earlier, reduce task and diff size, review continuously, and stop/re-plan after repeated failed review rounds. [S1][S5]

### 2. Context is abundant, but the wrong context is sometimes missing

**Confidence: High.**

The slow workers generally received substantial technical context: bead descriptions, accepted interfaces, repository maps, skill instructions, and controller guidance. They were not primarily blocked by a lack of codebase text. [S1]

They were frequently missing or inheriting unstable versions of:

- a bounded product outcome;
- canonical domain vocabulary;
- stable cross-task contracts;
- explicit role/permission and lifecycle rules;
- executable acceptance fixtures and evidence classes; and
- a clear statement of which decisions were fixed versus still negotiable.

In the named epic, the agent invented `automation` as a distinct source until the user corrected it as an umbrella for cron and watcher. The same thread later stated that the epic had no stable acceptance IDs and used seven broad success criteria as the outcome contract. These are product/domain-definition gaps, not repository-context gaps. [S1]

### 3. Product fidelity improved on 2026-07-14, but product discovery remains incomplete

**Confidence: High.**

Commit `d6eb16b` added product journeys, real entry routes, durable-object lifecycle, acceptance-ID traceability, strict evidence states, and independent outcome review to the core workflow. Those are substantial corrections and should be retained. [S3]

The current brainstorming product contract still does not require:

- business value or a measurable success signal;
- the actor's current workaround;
- source precedence and prioritization;
- a role/permission matrix;
- canonical domain vocabulary;
- business rules and invariants; or
- concrete examples and counterexamples.

The previous workflow audit in `019f5f29...` reached the same diagnosis from a larger product corpus: phases could close without proving their product outcomes, and technical specs decomposed subsystems rather than complete journeys and object lifecycles. The recovery then required manually created capability/page, journey, durable-object, acceptance, and audit ledgers outside the normal workflow. [S4]

## Follow-up: SDD Subagent Context Audit

### Context completeness is not prompt length

**Confidence: High for the sampled workflows.** Claude prompts are plaintext and were scored directly; Codex lifecycle/inheritance evidence is explicit even though collaboration prompt bodies are encrypted. [S11][S12]

The audit separates six failure classes that are often collapsed into “the subagent needed more context”:

| Failure class | Meaning | Evidence in the sample |
|---|---|---|
| Delivery omission | A governing fact existed upstream but was not put in the worker's task contract | Product/domain facts and cross-task invariants were inconsistently copied into task packets |
| Upstream definition gap | The project had not established the correct product/domain rule | `automation` vocabulary correction; missing grant scope/minting decisions; late live-seam defects |
| Ambient overload | Unrelated baseline, skill catalogue, or full history competes with task context | Claude skill catalogue averaged about 6x the task prompt's character count; fork-all Codex children started with more input context |
| Lifecycle staleness | An initially correct context is reused after task/base/contract changes | One Codex implementer crossed Tasks 3 and 7-10 and compacted 11 times |
| Authority ambiguity | Spec, plan, bead, code, or reviewer feedback disagree without precedence | Current task contract has references but no source-precedence or decision-revision field |
| Horizon mismatch | A task reviewer is intentionally too narrow to prove an integrated/product outcome | Diff-scoped review correctly returns ⚠️ for cross-task claims; a separate outcome review is required |

Adding more repository prose only addresses the first class, and can worsen the third. Product definition, task slicing, context freshness, and reviewer role boundaries address the others.

### Claude: technically rich, product-thin, and ambient-heavy

The 220 scored Claude task packets were generally strong at handing off technical implementation. [S11]

| Observable packet signal | Implementer/fix (n=111) | Task review/re-review (n=109) |
|---|---:|---:|
| Verification/test language | 111 (100%) | 109 (100%) |
| Explicit AC/requirements section | 84 (76%) | 55 (50%) |
| Authoritative bead/spec/brief | 99 (89%) | 93 (85%) |
| File or interface cues | 91 (82%) | 92 (84%) |
| Worktree/base/dependency cues | 96 (86%) | 68 (62%) |
| Explicit model | 97 (87%) | 109 (100%) |
| Explicit skills | 108 (97%) | Not applicable to reviewer role |
| Explicit task boundary/non-goal | 107 (96%) | 109 (100%) |
| Vocabulary/rule/invariant signal | 91 (82%) | 39 (36%) |
| Product/persona/entry-route terms | 30 (27%) | 19 (17%) |
| Stable acceptance-ID syntax | 0 | 0 |
| Explicit write set/shared-resource lock | 0 | 0 |
| Any initial carry-forward/prior-review delta | 16 (14%) | 11 (10%) |
| Structured carry-forward delta | 0 | 0 |

The term-based product and domain counts are lower-bound proxies, not proof that every other packet had no user value or invariant. The zero counts for stable acceptance IDs, shared resources, and structured deltas are direct. Most sampled workflows used pre-2026-07-14 skills, before stable outcome tracing was added. [S3][S11]

A representative strong Spec 7 implementer packet named the authoritative bead, exact exported interfaces, downstream consumers, three code precedents, worktree, acceptance commands, and report contract. It said, for example, “Tasks 5–14 consume these by exact name — do NOT rename them.” Yet its context framed a shared state architecture rather than a persona, real entry route, durable outcome, domain rules, or stable product acceptance ID. [S11]

The corresponding task-review packets were equally detailed about exact props, debounce behavior, routes, accessibility, tests, base/head, and named risks. That made them good task reviewers; it did not make them product-outcome reviewers. The missing product seam later appeared when live UI-to-kernel-to-database testing found identity and persistence failures after task-local gates were green. [S2][S11]

The harness also contributes substantial ambient context before a worker opens the repository:

- average Claude task prompt: about 4,733 characters;
- average implementer skill catalogue: about 28,746 characters, with 65-150 listed skills and mean 91;
- average reviewer task prompt/catalogue: about 3,851/27,061 characters; and
- average first-turn input context: about 27.1k tokens for both implementers and reviewers, counting normal input plus cache creation/read fields. [S11]

In one representative child, a 3,651-character task prompt arrived beside a 94-skill listing; the first request recorded 10,997 ordinary input tokens, 7,971 cache-creation tokens, and 12,047 cache-read tokens. Cached input changes cost/latency characteristics, but it still demonstrates that the task prompt is a minority of the model-visible context. [S11]

This supports two separate actions: improve the semantic task contract inside Superbeads, and reduce irrelevant globally injected skill/tool context at the harness/plugin layer where possible. Do not try to solve ambient overload by making the task prompt even larger.

Claude's follow-up lifecycle was much healthier than the Codex cross-task reuse: 25 of 108 observable implementer contexts and 4 of 109 reviewers received a coordinator follow-up; each received exactly one, generally task-local follow-up, and re-reviews usually used fresh reviewer contexts. Same-task state is useful for one correction round. [S11]

Strong task packets still exposed two distinct semantic gaps:

- A Juno lifecycle/concurrency packet was about 5.1k characters and explicitly required bounded shutdown, yet its well-behaved fixtures missed the counterexample “two components in the same reverse layer both ignore cancellation.” Review found the resulting unbounded join plus rollback/locking defects. More repository context would not have supplied that falsification case. [S11]
- A Seraphim SummonBar packet named the real `cmdk` precedent and product behavior, but the implementation test replaced `cmdk` with plain HTML. Native Enter behavior was therefore never exercised. The missing contract was “prove the production adapter/event path,” not another filename or interface. [S11]

Horizontal context can also be locally excellent and globally insufficient. One hook-only packet explicitly excluded the later surface binding, completed in about seven minutes, and passed a roughly one-minute task review. The later product survival test found that Keep never rendered, issued no execution query, and produced blank cells. The implementer followed its context correctly; the plan deferred the value-producing seam. [S11]

### Codex: spawn isolation was often correct; context lifecycle was not

The Codex sample shows substantial version/controller variance in context inheritance. Across 150 implementation/review/fix spawns in five deep workflows: 75 used `fork_turns: none`, 69 used `all`, and 6 used the last three turns. [S12]

The named `019f5e29...` epic was better than the aggregate: all 22 SDD implementation/review/fix spawns used `fork_turns: none`; its four `fork_turns: all` spawns were exploration/ground-truth agents. A second Juno execution used `none` for all 23 SDD spawns. Older/different controllers were inconsistent: one small Juno workflow used `all` for all four, while the deep Seraphim workflow mixed 65 `all`, 27 `none`, and 6 last-three spawns. [S12]

Isolation did not make the child context small. Named-epic `none` children began around 20.1-20.6k input tokens from system/developer/skills/project baseline plus the task packet. Observed `all` examples began around 25.5-32.1k and additionally copied parent history. Fork-all is plausible overhead, but the sample does not isolate a causal performance effect. [S12]

All named-epic workers inherited `gpt-5.6-sol` with high reasoning. Their collaboration dispatch arguments contained only task name, fork mode, and message; the observed Codex collaboration API exposes no model field. The repository's universal “always specify the model” rule is therefore implementable in Claude but not through this Codex mechanism. Codex guidance must record `model: inherited`, avoid claiming a cheaper selection, and use a model-capable dispatch mechanism or appropriately configured parent when model routing matters. [S3][S12]

The named 13-task graph confirms that technical detail was not sparse:

| Task-contract field | Coverage |
|---|---:|
| Context, Files, Interfaces, Acceptance Criteria, Skills, Steps/commands | 13/13 each |
| Stable acceptance/outcome IDs | 0/13 |
| Explicit persona/actor language | 2/13 |
| Explicit real entry point | 0/13 |
| Write/shared-resource declaration | 0/13 |
| Unresolved decisions and decision owner | 0/13 |
| Explicit model or inherited-model status | 0/13 |

This is high-volume technical context with weak contract-state metadata. [S12]

The clearest context failure occurred *after* correct isolated spawn:

1. `impl_capability_broker` began as the Task 3 implementer with `fork_turns: none`.
2. It was then continued through follow-ups for Tasks 7, 8, 9, and 10.
3. The context accumulated 11 compactions, moving bases, multiple task contracts, reviews, and verification histories.
4. Its paired reviewer similarly crossed task boundaries and accumulated eight compactions. [S12]

This directly violates “fresh subagent per task.” A fresh context is a lifecycle invariant, not just a spawn setting.

There was one explicit early context miss: the capability-broker implementer returned `NEEDS_CONTEXT` because grant source/subject scope and prompt/request/minting behavior were unspecified. The controller supplied the decisions within about a minute. This is healthy escalation, but those are authority/domain decisions that should have been resolved in the task contract. [S12]

Fresh contexts were not a complete cure. Tasks 11 and 12 used fresh `none`-fork implementers and fresh reviewers, yet required roughly five and four review rounds respectively. Their remaining problem was task breadth and volatile security/concurrency contracts, not inherited history. [S1][S12]

Task 12 also shows the difference between a missing requirement and a non-falsifiable one. The task required “interactive confirmation” and an “exact active session,” but did not give counterexamples. Review found that piped `yes` counted as interactive and that released/replaced runtime callbacks remained usable. The better context is not another paragraph of architecture; it is executable negative examples such as “piped input must fail without `--yes`” and “a callback from a released/replaced activation must fail.” [S12]

A bounded Juno comparison used `fork_turns: none` and kept each agent on one task. Representative implementers/reviewers ran about 7-37 minutes with zero compactions rather than developing a multi-hour, multi-task tail. This is consistent with task size and context lifetime mattering more than raw packet length, though it is not a controlled causal experiment. [S12]

### Current repository contract: good technical retrieval, weak semantic manifest

The current design correctly says workers should not inherit session history and should read one authoritative task bead. Writing-plans now requires a task summary, stable outcome IDs, spec/external references, why the task exists, constraints, files, interfaces, acceptance criteria, skills, and exact steps. [S3]

The handoff still has structural gaps:

| Context field | Current source | Current status |
|---|---|---|
| Authoritative task | Task bead via `bd show` | Required |
| Files/interfaces/test commands | Task bead from writing-plans | Required upstream |
| Stable outcome IDs | Task bead from writing-plans | Added 2026-07-14; historical packets predate it |
| Product slice/persona/entry/result | Epic outcome trace, not mandatory in worker prompt | Indirect/fragile |
| Domain vocabulary/rules/invariants | Free-form relevant constraints | Not structurally required |
| In-scope/non-goals | General minimal-change rules | No task-specific field |
| Source precedence/decision revision | Spec and external references | Absent |
| Dependency commits/base revision | Free-form Context; reviewer gets base/head | Not required for implementer |
| Write set/shared or exclusive resources | None | Absent |
| Evidence class/fixture/environment | Acceptance criteria and commands | Partly required; environment identity not structured |
| Explicit model | SDD prose requires it; implementer template/example omit it; observed Codex collaboration API has no model field | Contradictory and platform-dependent |
| Codex fork mode | SDD says isolated; Codex reference/example does not require `none` | Unenforced |
| Fresh agent per task | SDD prose requires it | Unenforced; violated in named epic |
| Clarification persistence | Controller answers and re-dispatches | Answer need not update the bead/manifest |
| Context budget/reference policy | “Share full context, not summaries” | Ambiguous and expansion-prone |

The phrase “share full context, not summaries” should become: **share every governing fact, not every document or conversation turn**. Copy exact binding invariants and decisions; reference large artifacts by stable path/revision and let the worker retrieve only what the task requires.

### Recommended minimum-sufficient Context Manifest

Do not create a second full plan or a new mandatory skill. Extend the existing task bead/SDD handoff with a small, mechanically checkable manifest:

```text
Task/revision: <bead-id> @ <task-revision>
Base/dependencies: <base SHA>; <approved dependency SHAs/contracts>
Outcome: <acceptance IDs>; <actor/entry/action/observable durable result>
Domain contract: <canonical terms>; <authority/rules/invariants relevant to this slice>
Boundary: <in scope>; <non-goals>; <allowed write set>; <shared/exclusive resources>
Interfaces: <consumes>; <produces>; <frozen vs provisional>
Evidence: <fixture/environment>; <focused commands>; <integration/outcome evidence class>
Decisions: <source precedence>; <unresolved items, or explicitly None>
Execution: <worktree>; <model/effort or inherited status>; <report path>; <context mode: isolated>
```

Rules:

1. The manifest contains task-relevant governing facts, not the raw epic plan or full parent history.
2. Large specs, diffs, and reports remain referenced artifacts with revision/commit identity.
3. Any clarification that changes a governing fact updates the task bead/manifest before work resumes; it is not left only in transient chat.
4. Codex implementation/review spawns use `fork_turns: none`; exploration may inherit a bounded history when justified.
5. A fresh agent owns exactly one task. The same implementer may handle review fixes for that task only.
6. After two failed review rounds, stop and classify: incomplete/wrong contract, oversized task, or implementation defect. Re-plan or start a fresh recovery context rather than extending an indefinitely compacted agent.
7. Review feedback is supplied as a structured delta: findings, affected acceptance/invariant IDs, changed files/contracts, new base/head, and required focused evidence.
8. Each high-risk invariant includes at least one falsifying counterexample, especially for concurrency, authority, lifecycle, recovery, and denied states.
9. When mocks replace a router, component library, HTTP adapter, persistence layer, authorization boundary, or event stream, the evidence plan names a separate production-seam check.
10. The task reviewer receives the same relevant outcome/AC/domain manifest, but labels each conclusion `local proof` or `integration proof`; this improves task judgment without pretending task review is outcome review.

This manifest is a compiler boundary between product/plan truth and execution. It cannot manufacture missing product truth; unresolved product/domain cells must return upstream to product-definition or brainstorming.

For high-risk tasks, add a short pre-RED readiness handshake:

```text
CONTRACT_READY
- interpreted acceptance IDs
- fixed invariants and linearization points
- intended interfaces
- negative/counterexample cases
- unresolved decisions: none
```

Otherwise return `NEEDS_CONTEXT` with the missing decision, conflicting evidence, affected implementation choices, and recommended options. Task 3 followed this pattern successfully. By contrast, the fresh Task 11 worker said it had “resolved the API shape” itself; the first reviewer then found six issues around authority lifetime, runtime identity, deny requestability, truth labels, payload bounds, and cancellation. [S12]

## Answers to the Requested Questions

### Why do subagents take so long?

They usually do not. Most complete in minutes; a small number dominate critical path because the workflow gives them large, cross-cutting tasks and discovers important requirements only after a large implementation exists. Long-lived reused contexts, broad verification, review queues, history repair, and environmental blockers compound the tail. [S1][S2]

The best predictor of delay in this sample was not prompt length alone. It was the combination of task breadth, contract volatility, shared-state risk, and number of review/fix cycles.

### Do they need more context or better acceptance criteria?

They need **less ambient context and more precise contracts**.

Every task should receive a compact, immutable task packet:

- stable product outcome and acceptance IDs;
- actor, starting state, and real entry point;
- expected observable and durable result;
- negative, denied, and recovery behavior;
- relevant domain vocabulary and invariants;
- consumed and produced interfaces;
- base commit and allowed write set/shared resources;
- focused and integration evidence commands; and
- unresolved decisions that require escalation rather than invention.

This aligns with Anthropic's finding that effective multi-agent delegation needs a clear objective, output format, tool/boundary guidance, and scaled effort. Better tool descriptions and ergonomics reduced completion time in their research system by 40%, though their workload is more parallel than coding. [S5]

### Do we need a new product-oriented skill?

**Yes: add one conditional `product-definition` skill.** It should replace overlapping product questioning in brainstorming, not become another mandatory serial ceremony.

Trigger it for ambiguous business requirements, multiple actors/permission levels, user-facing journeys, durable product objects, migrations, or conflicting sources of truth. Internal/mechanical work should explicitly bypass it with a reason.

Its minimum artifact should contain:

1. actor, job, current workaround, and business outcome/measure;
2. source precedence, scope, non-goals, and unresolved decisions;
3. canonical vocabulary and lightweight domain model;
4. roles, authority, lifecycle states, commands/events, rules, and invariants;
5. primary journey plus negative/recovery journeys;
6. stable product acceptance IDs and required evidence classes; and
7. examples/counterexamples sufficient to expose ambiguous rules.

Brainstorming should then choose a solution against that product baseline. It should not rediscover the baseline while already discussing architecture.

### How should domain modelling fit?

Domain modelling should be product-facing and lightweight, not a mandatory class diagram or a second architecture document.

For each important durable noun, record:

- identity and ownership;
- allowed states and transitions;
- commands, events, and side effects;
- invariants and authorization rules;
- lifecycle entry, find/reopen/use, edit, archive/delete, rollback, and recovery paths; and
- cross-object transaction or consistency boundaries.

Map each journey step to the relevant command/state/event. If this model cannot explain the user's vocabulary or a find-again/use path, the feature is not ready for technical decomposition.

### How should plans enforce vertical slices?

Vertical slicing must become a semantic requirement, not "where practical." DORA recommends independent, valuable, small, and testable changes; Basecamp's vertical-slice guidance makes the same point operationally: integrate one tangible piece before building horizontal layers that are individually complete but do not work together. [S8][S9]

Every non-foundation task should have a **Slice Contract**:

- acceptance IDs;
- real entry route/interface;
- observable working result;
- durable state transition where applicable;
- failure/denied/recovery result;
- deterministic demo or verification;
- consumed and produced contracts;
- write set and shared/exclusive resources; and
- cleanup/restoration requirements.

A foundation-only task is an exception. It must name its immediate consuming slice and integration deadline; if it can be folded into that slice, it should be.

### Can dependent work start while predecessor review runs?

The safe default is **rolling review and merge, not speculative dependency execution**.

Use this state model:

```text
IMPLEMENTING -> REVIEWING -> REVIEWED -> MERGED -> INTEGRATION_PROVEN
```

When one implementer finishes, immediately use capacity for its reviewer while other independent implementers continue. Merge an approved task independently, run its unlock/integration proof, and recompute readiness. A successor starts when all of *its* prerequisites are `INTEGRATION_PROVEN`; it need not wait for unrelated tasks or reviews.

For `1,2 <- 3,4`, reviewers for 1 and 2 can run while unrelated implementation continues. Tasks 3 and 4 should normally wait until both 1 and 2 are reviewed, merged, and integration-proven.

Speculative downstream work during predecessor review is an opt-in exception only when:

- the exported contract is frozen;
- focused evidence is GREEN;
- write sets and exclusive resources are disjoint;
- the upstream change is not a volatile security, persistence, migration, or recovery primitive; and
- downstream work is automatically invalidated/rebased if review changes the contract.

Worktrees prevent some file collisions; they do not prevent schema ordering, generated-client drift, shared-fixture contention, browser/cluster locks, or semantic contract conflicts. [S1]

Observed git conflicts occurred in only two of seven canonical Claude executions, so merge conflict is a real but secondary risk. The more common risk was semantic contract drift and serialized review. Shared routes, navigation, translations, generated files, migrations, browser sessions, and mutable acceptance environments should have an integration owner or exclusive resource lane. [S2]

### Are brainstorming and stress-test questions good enough?

No. Current brainstorming has strong repository grounding but relies on model improvisation for product coverage and mandates one question per message plus section-by-section approvals. Current stress testing has broad technical lenses but thin product/domain/operational/migration/evidence coverage and mandates one branch per round trip. [S3]

The historical Claude workflows asked about 65 unique brainstorming questions across eight planning workflows. The problem was not question quantity: most questions were about storage, registries, dependencies, workstreams, build order, and technical section approval before actors, jobs, complete journeys, authority states, and observable success were stable. One product-heavy Spec 7 flow skipped user questions entirely, then used stress testing after design and planning to discover product cuts and validation gaps. [S2]

Replace open-ended coverage with a visible matrix:

| Lens | Minimum questions |
|---|---|
| Business | actor/job, value, success measure, current workaround |
| Product | entry point, primary journey, discover/find-again/use, non-goals |
| Domain | vocabulary, ownership, lifecycle, rules/invariants, examples |
| Technical | contracts, failure modes, consistency, scale |
| Operations | observability, support, rollout, rollback, recovery |
| Migration | existing data/users, compatibility, cutover |
| Security | authority, denied states, revocation, abuse cases |
| Evidence | deterministic fixture, environment, artefact, cleanup |

Track each cell as `answered | inferred | unresolved | N/A`, with source status. Ask up to three independent questions together; keep a question singular only when its answer materially changes subsequent questions.

Stress testing should require at least one concrete counterexample/falsification attempt for each high-risk acceptance ID. Product and domain failures should be tested before implementation trivia.

### Does verification-before-completion always run and work?

**No.** The current skill's written contract is strong: required checks have `PASS | FAIL | BLOCKED | NOT_RUN`, only PASS satisfies completion, evidence substitution is forbidden, and acceptance IDs require fresh evidence. [S3]

Historical execution is inconsistent:

- In the sampled Claude workflows, 107 of 109 implementation/fix prompts explicitly required `verification-before-completion`, but only 25 nested agents invoked the skill: 23.4% of mandated cases. [S2]
- In large Codex executions, technical verification ran frequently, yet reviewers still found serious behavior not represented in the encoded tests. [S1]
- In an older Seraphim pre-PR flow, E2E was initially skipped because the live environment was unavailable; after the user rejected the substitution, the live sweep found a deployment bug. [S1][S4]
- In Claude Spec 7, green task-local tests and a hand-built conformance object did not exercise the production web adapter. Final live UI-to-kernel-to-database testing found incompatible stream IDs, leaked i18n keys, and non-atomic create behavior. [S2]
- A later acceptance audit found 61 required flows without deterministic fixtures/procedures. A combined dependency graph turned four harness gaps into 59 unrelated blockers until execution dependencies and acceptance dependencies were separated. [S1]

Therefore skill invocation is not a reliable quality proxy, and passing technical gates proves only encoded assertions. Enforcement should use an evidence manifest and behavior tests, not prose presence.

Recommended mechanics:

- bind every required acceptance ID to exact procedure, environment, artefact, and evidence state;
- prohibit closure with `FAIL`, `BLOCKED`, or `NOT_RUN` unless the user explicitly removes that named outcome from scope;
- cache evidence by commit, environment identity, and fixture version;
- use focused checks inside fix loops, affected suites before review, and full integration at merge/final boundaries or when evidence is stale;
- keep independent outcome review distinct from diff/code review; and
- run final code and outcome reviews concurrently when they do not mutate the same environment.

## Proposed Workflow

```text
research/ground truth
  -> conditional product-definition + domain baseline
  -> brainstorming/solution design
  -> stress-test product contract and high-risk assumptions
  -> plan as vertical Slice Contracts + execution/resource graph
  -> rolling implementation / early contract review / task review
  -> merge + unlock proof -> recompute readiness
  -> independent product-outcome review + code review
  -> evidence-aware finishing
```

The planner and implementer should negotiate a short "contract of done" before a large production diff. Anthropic found a similar sprint contract useful for translating high-level user stories into testable implementation in long-running application work. Their later simplification work also found bulky evaluator machinery can become pure overhead when a task is already within the model's reliable capability boundary. [S6]

## Prioritized Recommendations

### P0: Fix scheduling, model selection, and liveness

1. Replace ready-task batch barriers with a capacity-aware rolling scheduler.
2. Reserve at least one available slot for review/integration instead of filling every slot with implementers.
3. Require explicit model selection where the dispatch API supports it. Otherwise require an explicit `model: inherited` status and route through a model-capable mechanism or appropriately configured parent when a cheaper model is required. The current universal prose does not account for Codex's observed collaboration API. [S3][S12]
4. Require the minimum-sufficient Context Manifest, explicit isolated fork mode, task/base revision, and write/shared-resource declaration before dispatch.
5. Use a fresh implementer per task. Reuse it only for fixes to the same task; after two failed review cycles, split/re-plan and start a fresh context.
6. Make the controller solely responsible for rebase, merge, and push; implementers commit locally.
7. Add structured timestamps: dispatch, first material action, RED, GREEN, verification, review, fix rounds, merge, blocked/user wait/external wait.
8. Give each task a size/risk class and a no-progress budget. Interrupt and classify a breach rather than silently waiting.

Acceptance: a deterministic `A,B -> C,D` fixture starts A/B together, starts A's reviewer while B remains active, prevents C/D until both prerequisites are integration-proven, and blocks concurrent tasks declaring the same shared resource. A separate fixture fails any dispatch with inherited implementation history, an unacknowledged inherited model, a stale task/base revision, or reuse of one agent across two task IDs.

### P0: Add conditional product-definition/domain modelling

Create the skill described above and remove duplicate product questioning from brainstorming. Add a bypass path for clear internal-only work.

Acceptance: an ambiguous multi-role fixture cannot enter architecture design without resolved or explicitly user-owned product/domain cells; an internal mechanical fixture can bypass with a recorded reason.

### P1: Enforce vertical Slice Contracts and executable acceptance

1. Replace component-oriented task examples with outcome-oriented slices.
2. Separate implementation dependencies, acceptance dependencies, and exclusive-resource conflicts.
3. Require stable acceptance IDs from product baseline through task, tests, and evidence.
4. Require deterministic fixtures/procedures and explicit cleanup.
5. Reject orphaned acceptance IDs, horizontal-only plans, and foundation tasks without an immediate consuming slice.

### P1: Improve questions while reducing human latency

Use the coverage matrices above, batch up to three independent questions, and require counterexamples for high-risk decisions. Keep single-question turns for decision-dependent branches only.

This should reduce serial round trips without trading away product discovery.

### P1: Reduce review and verification amplification

1. Add a pre-implementation contract review after RED tests/interface sketch for high-risk tasks.
2. Have the first reviewer consolidate all observable findings rather than drip-feed them across rounds.
3. Use focused re-review of changed invariants plus affected regressions.
4. Cache/reuse unchanged evidence by commit/environment identity.
5. Keep security, persistence, recovery, migrations, and shared contracts on the stricter path; use risk-tiered review for bounded deterministic edits.

### P1: Reduce task-packet and planning payload

Plans should retain exact outcomes, interfaces, constraints, commands, and expected results. Full code should be required only for novel public contracts or non-obvious algorithms; routine implementation can use precise pseudocode. Load systematic debugging only after an unexpected failure, and require LSP blast-radius work for shared/public symbols rather than every local helper. [S3]

Replace “share full context, not summaries” with the governing-facts/reference rule from the Context Manifest. Separately investigate whether Claude/Codex skill discovery can avoid injecting dozens of irrelevant skill descriptions into every child without impairing skill triggering; this is a harness optimization, not a reason to omit task-critical facts. [S11][S12]

### P2: Add behavioral workflow tests

Current tests mostly inspect strings or ask an agent to describe a skill. Add executable fixtures that fail when:

- a successor starts before prerequisite integration proof;
- a dispatch omits a model where the API supports selection, or fails to declare inherited model status where it does not;
- a write/resource conflict is scheduled concurrently;
- an acceptance ID is orphaned or closed as BLOCKED/NOT_RUN;
- an extra feature is accepted;
- evidence is substituted; or
- a stale integration fixture uses the old handoff model. [S3]

## Measurement and Experiments

Do not optimize against task age or summed agent-hours alone. Track:

- critical-path elapsed time excluding user and external-blocker time;
- median and p90 implement, verify, review, fix, merge, and queued durations;
- task-prompt size, total first-turn input context, and relevant-to-ambient context ratio;
- fork/inheritance mode, model/effort, task/base revision, and compactions per agent;
- context clarifications classified as delivery omission, upstream definition gap, stale context, authority conflict, or task oversizing;
- review findings classified as missing/wrong contract versus implementation defect;
- compactions and follow-ups per task;
- review rounds and severity by task size/risk;
- repeated full-suite executions and reused evidence;
- rebase/merge repairs;
- acceptance PASS/FAIL/BLOCKED/NOT_RUN by evidence class; and
- escaped product defects after completion.

Run staged replay/A-B experiments on representative historical workflows:

| Experiment | Change | Success condition |
|---|---|---|
| A | Explicit model or inherited status, fresh task agents, stable skill alias | Lower p90/compactions without lower acceptance pass rate |
| B | Rolling scheduler + reserved review capacity + resource graph | Lower critical path without more rebases or contract invalidations |
| C | Product-definition + Slice Contracts | Fewer late product/domain review findings and recovery beads |
| D | Tiered verification + evidence reuse | Fewer broad reruns without escaped regressions |
| E | Question coverage matrix + limited batching | Fewer user round trips with no increase in unresolved product cells |
| F | Context Manifest + isolated fork + task revision guard | Fewer NEEDS_CONTEXT events, cross-task compactions, and context-caused review findings with a smaller task packet |
| G | Relevant-only child skill catalogue | Lower first-turn context/latency without reduced required-skill adherence |

## Additional Testable Hypotheses

1. **Review bandwidth, not implementer capacity, is the current throughput constraint.** Prediction: adding implementers without reserved review capacity increases queue time and work in progress but not merged slices per hour.
2. **Context reuse after task boundaries creates more tail latency than prompt incompleteness.** Prediction: fresh task agents with compact immutable packets reduce compactions and correction rounds even when prompt characters decrease.
3. **Product recovery work is a hidden lead-time tax.** Prediction: a conditional product/domain baseline reduces post-implementation recovery ledgers, acceptance rewrites, and late product findings enough to repay its discovery time.
4. **A real first vertical seam has more defect-detection value than another component test layer.** Prediction: requiring an early production-adapter journey finds cross-boundary identity, persistence, vocabulary, and permission defects before the epic midpoint.
5. **Writing plans currently duplicates implementation effort.** Prediction: replacing routine step-by-step code with precise outcome/interface contracts shortens planning and reduces stale instructions without reducing reviewer approval or acceptance pass rates.
6. **Speculative dependent execution is usually a loss on high-risk tasks.** Prediction: for security, persistence, migrations, and recovery work, rebase/invalidation cost exceeds overlap saved; low-risk frozen contracts may show the opposite result.
7. **Semantic context density matters more than prompt volume.** Prediction: Context Manifest packets with fewer total characters but explicit outcome/domain/boundary fields outperform longer technical prompts without those fields.
8. **Cross-task reuse causes context debt nonlinearly.** Prediction: compactions and contradictory/stale assumptions rise sharply after the second task in one agent, while same-task fix follow-ups remain beneficial for one or two rounds.
9. **Ambient skill catalogues consume avoidable attention budget.** Prediction: relevant-only catalogues reduce first-turn input and time-to-first-material-action without lowering correct skill invocation, provided required skills are named directly in the task packet.

## Refuted or Downgraded Claims

- **"The 23+ hour epic means subagents implemented for 23+ hours."** Refuted. About 8h11m was a host-resource/user pause; planning and orchestration were also included. Active work was still excessive. [S1]
- **"Subagents are generally slow."** Downgraded. Median Claude subagent spans were minutes; the p90 tail and a few reused contexts dominate. [S2]
- **"More context will fix the problem."** Refuted as a general remedy. Claude packets averaged about 4.7k prompt characters beside roughly 28.7k characters of skill catalogue, while technical handoff fields were already common. The missing information was disproportionately product/domain/acceptance context, and Codex cross-task reuse accumulated stale context. [S10][S11][S12]
- **"Codex's named epic was slow because every implementation child inherited the full parent conversation."** Refuted. All 22 named-epic SDD implementation/review/fix spawns used `fork_turns: none`; the failure was later task reuse plus large ambient baseline and oversized contracts. Other sampled Codex workflows did use `all`, so inheritance remains an enforcement gap. [S12]
- **"A fresh isolated context is sufficient to prevent rework."** Refuted. Fresh Task 11/12 agents still required multiple review rounds because the tasks and security/concurrency contracts were broad. [S12]
- **"More parallel implementers will reduce elapsed time."** Refuted under the current bottleneck. Review, integration, shared resources, and rework limit throughput. [S1][S5]
- **"Verification does not run."** Too broad. It runs heavily in large Codex executions, but Claude skill invocation was inconsistent and both systems can verify the wrong semantic layer. [S1][S2]
- **"Removing review is the obvious speed win."** Rejected. Reviews found serious defects; smaller slices and earlier/rolling review are safer speed levers. [S1]
- **"The current skills have no product safeguards."** Outdated. Commit `d6eb16b` added important safeguards on 2026-07-14; their runtime effectiveness is not yet established. [S3]

## Open Questions

1. Which task-size signal best predicts rework in this repository: changed files, diff bytes, interfaces crossed, risk class, or estimated review package size?
2. What is the optimal child-slot reservation under Codex's four-slot limit and Claude's available concurrency?
3. Can the harness expose reliable active/queued/tool-wait timestamps, or must Superbeads emit its own lifecycle events?
4. Which evidence environments need exclusive locks, and which can be cloned cheaply?
5. How much of the 23.4% Claude invocation gap is a reporting artifact versus failure to follow the mandated skill?
6. Should speculative downstream work be implemented initially, or deferred until rolling scheduling and resource graphs have measured results?
7. How much of Claude/Codex's globally injected skill catalogue can be filtered per worker without breaking tool/skill discoverability?
8. What exact task/base revision mechanism is stable across Beads updates, worktrees, and rebases?
9. Which context fields predict review success after controlling for task size and risk?

## Recommended Beads

These are proposed commands, not executed as part of this read-only workflow review:

- `bd create "Add rolling capacity-aware SDD scheduler" -t feature -p 0 --notes "Severity: Important\nConfidence: Confirmed\nEvidence: docs/research/2026-07-15-superbeads-skill-usage-workflow-review.md; skills/subagent-driven-development/SKILL.md"`
- `bd create "Add platform-aware worker model routing and execution liveness telemetry" -t feature -p 0 --notes "Severity: Important\nConfidence: Confirmed\nEvidence: skills/subagent-driven-development/SKILL.md; skills/subagent-driven-development/implementer-prompt.md; observed Codex collaboration dispatch schema"`
- `bd create "Add minimum-sufficient SDD Context Manifest and isolation guards" -t feature -p 0 --notes "Severity: Important\nConfidence: Confirmed\nEvidence: docs/research/2026-07-15-superbeads-skill-usage-workflow-review.md; skills/subagent-driven-development/implementer-prompt.md; sampled Claude/Codex SDD traces"`
- `bd create "Add conditional product-definition and domain-model skill" -t feature -p 0 --notes "Severity: Important\nConfidence: Confirmed\nEvidence: docs/research/2026-07-15-superbeads-skill-usage-workflow-review.md"`
- `bd create "Enforce vertical Slice Contracts and resource declarations" -t feature -p 1 --notes "Severity: Important\nConfidence: Confirmed\nEvidence: skills/writing-plans/SKILL.md; docs/research/2026-07-15-superbeads-skill-usage-workflow-review.md"`
- `bd create "Add product and domain coverage matrices to discovery and stress test" -t feature -p 1 --notes "Severity: Important\nConfidence: Confirmed\nEvidence: skills/brainstorming/SKILL.md; skills/stress-test/SKILL.md"`
- `bd create "Add behavioral tests for scheduling and acceptance enforcement" -t task -p 1 --notes "Severity: Important\nConfidence: Confirmed\nEvidence: tests/claude-code; tests/skills; docs/research/2026-07-15-superbeads-skill-usage-workflow-review.md"`

## Sources

- **[S1] Codex local task records** — Primary local evidence — 2026-07-02 through 2026-07-15 — `/Users/samstevens/.codex/sessions/`; deep traces `019f5e29...`, `019f5f29...`, `019f49b2...`, `019f5a06...`, `019f5aaa...`, `019f5bc7...`, `019f60a3...`, and `019f60fd...`.
- **[S2] Claude local conversation records** — Primary local evidence — 2026-07-02 through 2026-07-15 — `/Users/samstevens/.claude/projects/`; 18 explicit top-level skill records, 13 logical workflows, and 271 nested subagent records.
- **[S3] Superbeads repository skills, prompts, tests, and git history** — Primary local evidence — 2026-07-15 — `skills/brainstorming/SKILL.md`, `skills/stress-test/SKILL.md`, `skills/writing-plans/SKILL.md`, `skills/subagent-driven-development/`, `skills/verification-before-completion/SKILL.md`, `skills/finishing-a-development-branch/SKILL.md`, `tests/skills/`, `tests/claude-code/`, commit `d6eb16b`.
- **[S4] [Seraphim workflow review](/Users/samstevens/Documents/Codex/2026-07-14/can/outputs/seraphim-workflow-review.md)** — Primary local synthesis — 2026-07-14 — product-outcome, lifecycle, evidence substitution, and recovery-ledger findings.
- **[S5] [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)** — Primary/official — 2025-06-13 — delegation contracts, parallelism limits, token cost, and tool ergonomics.
- **[S6] [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps)** — Primary/official — 2025 — tractable chunks, structured handoff, sprint contracts, evaluator cost, and harness simplification.
- **[S7] [Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)** — Primary/official — 2025 — outcome, transcript, harness, and evaluation-suite distinctions.
- **[S8] [Working in small batches](https://dora.dev/capabilities/working-in-small-batches/)** — Primary/official — accessed 2026-07-15 — independent, valuable, small, testable changes and AI reviewability.
- **[S9] [Get One Piece Done](https://basecamp.com/shapeup/3.2-chapter-11)** — Primary/official — accessed 2026-07-15 — vertical integration and tangible slices.
- **[S10] [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)** — Primary/official — 2025 — finite context, context rot, and context curation.
- **[S11] Claude SDD context-packet corpus** — Primary local evidence — 2026-07-02 through 2026-07-15 — 111 implementer/fix and 109 task-review/re-review dispatches across seven canonical execution workflows; representative plaintext packets in `/Users/samstevens/.claude/projects/-Users-samstevens-vmgr-seraphim/1eacf07f-6805-4969-add8-57a992fabdab/subagents/agent-a78284d4a83b4c3e1.jsonl` and `agent-a80158c1c074101ef.jsonl`.
- **[S12] Codex SDD context-lifecycle corpus** — Primary local evidence — 2026-07-02 through 2026-07-15 — 150 implementation/integration/review/fix spawns across five deep workflows; named parent `/Users/samstevens/.codex/sessions/2026/07/14/rollout-2026-07-14T11-06-28-019f5e29-3da5-7bf2-9096-e26c8b52e1c5.jsonl` and representative reused child `/Users/samstevens/.codex/sessions/2026/07/14/rollout-2026-07-14T14-53-31-019f5ef9-1917-72a2-8fa3-3aecccbb1389.jsonl`.
