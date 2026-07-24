# Research: Superbeads v0.13 Skill Usage Audit

> Date: 2026-07-22
> Bead: `beads-superpowers-p4r`
> Status: Complete
> Mode: Repository-only, including local Claude/Codex transcripts and Beads stores
> Review window: 2026-07-16 through 2026-07-22 (Australia/Brisbane)
> Repository revision reviewed: `1ef51ae`

## Verdict

The v0.13 workflow has the right three-stage decomposition, but the boundaries are not yet crisp enough in either the templates or the enforcement:

1. The **product contract** should define product truth: actors, authority, vocabulary, lifecycle, observable invariants, representative journeys, and stable outcomes.
2. The **technical spec** should define how the product truth will be realized: architecture, ownership boundaries, state/data flow, interfaces, failure and recovery behavior, security boundaries, rollout, and an implementation topology.
3. The **plan** should compile the accepted contract and spec into independently reviewable execution slices: owned outcomes, exact write zones, produced and consumed interfaces, true semantic prerequisites, resource conflicts, and verification evidence.

Recent artifacts often repeat the same material at increasing length instead. The remedy is not to reduce product literacy. It is to make the spec deliberately more technical and to prohibit the plan from inventing either product or architectural decisions.

The dependency problem also has a concrete mechanical cause. The graph authoring skill says that resource conflicts are not dependency edges, but the validator rejects parallel-ready tasks whose paths or exclusive resources overlap. Adding an otherwise unnecessary `blocks` edge makes that validation disappear. This trains the planner to serialize work and hides resource conflicts inside a false semantic DAG.

SDD's median worker and reviewer turns are reasonable. Long completion times are dominated by oversized slices, repeated review/correction loops, controller setup work, and the tail of difficult security/recovery findings. The most important latency fix is enforcing the existing two-failed-review stop rule *before* another correction worker is dispatched.

`allowed_write_set` is effective and should remain. It has prevented scope creep and exposed incorrectly scoped corrections. Its cost comes from manual duplication and amendment, not from the authority boundary itself.

Memory quality is inconsistent. Juno has 74 memories and none use the current typed header format; Seraphim has 49, of which 24 remain headerless. Both contain useful semantic decisions, but also plan-acceptance episodes, stale branch state, procedural instructions, duplicates, and in one case raw test output. No memories were changed during this audit; a dry-run curation set appears below.

## Confidence

| Finding | Confidence | Basis |
|---|---:|---|
| Contract/spec/plan ownership is blurred | High | Skill text plus eight recent artifact sets |
| False DAG edges are partly validator-induced | High | Direct contradiction between skill and validator; observed redundant edges and a later dependency removal |
| SDD latency is driven by rework and slice size more than typical turn duration | High | Structured timing across five large Codex/Claude roots plus transcript review |
| `allowed_write_set` is useful but operationally expensive | High | 37 manifests and multiple worker/reviewer reports |
| Memory capture admits low-value episodic/procedural facts | High | Full Juno and Seraphim memory inventories |

## 1. Product Contract, Technical Spec, and Plan

### Recommended ownership

| Stage | Defines | Must not define |
|---|---|---|
| Product contract | User and operator truth; actors and authority; domain language; observable states and invariants; representative journeys; stable outcomes and acceptance boundaries | Concrete services, database transactions, files, types, function names, task order, or work ownership |
| Technical spec | Architecture; component and state ownership; domain/data flow; entry and integration interfaces; failure/recovery and security behavior; rollout; test and evidence strategy; implementation topology | New product outcomes or execution scheduling |
| Plan | Vertical slices; outcome ownership; write zones; produced/consumed interfaces; semantic prerequisites; resources; task-specific verification | New product behavior, unresolved architecture, chronological preferences disguised as dependencies |

This division is already latent in the skills. Product definition says the contract is the stable source of product truth and outcomes (`skills/product-definition/SKILL.md`). Brainstorming asks for architecture, boundaries, data flow, interfaces, failure behavior, security, evidence, and rollout (`skills/brainstorming/SKILL.md`; `skills/brainstorming/references/question-coverage.md`). Writing plans asks for independently rejectable slices, exact write sets, resources, prerequisites, and verification (`skills/writing-plans/SKILL.md`). The artifacts feel duplicative because those boundaries are described but not enforced by a shared ownership table or artifact lint.

### Evidence of artifact inflation

Representative recent artifact sizes show that the contract is often as long as, or longer than, the technical spec:

| Project / initiative | Contract words | Spec words | Plan words |
|---|---:|---:|---:|
| Juno backup/migration | 3,965 | 5,351 | 6,961 |
| Juno tool search | 4,482 | 6,539 | 7,105 |
| Juno shared cache | 3,611 | — | — |
| Juno apps | 22,573 | — | 8,615 |
| Juno remote | 9,476 | 7,720 | 9,029 |
| Juno users | 15,726 | 11,244 | 8,156 |
| Juno WebUI | 10,008 | 9,258 | 8,325 |
| Seraphim Skills | 3,981 | 2,892 | 4,487 |

Length is not itself a defect, but contracts exceeding 10,000–22,000 words are functioning as exhaustive specifications. The current product-contract template contributes to the ambiguity by placing “transaction boundaries” under product definition (`skills/product-definition/references/product-contract-template.md`). A product contract should state observable atomicity—for example, what the user may never observe—not the database or service transaction that implements it.

### Change package

1. Add the ownership table above to product-definition, brainstorming, and writing-plans.
2. Rename product-contract “transaction boundaries” to **observable atomicity and consistency invariants**. Route implementation transactions to the technical spec.
3. Require the spec to contain an **implementation topology / seam ledger** with:
   - state and data owner;
   - entry and integration interfaces;
   - interfaces produced and consumed;
   - security or authority boundary;
   - failure and recovery responsibility;
   - likely write zones;
   - true semantic prerequisites versus resource conflicts.
4. Require the plan to cite contract outcome IDs and spec seam/interface IDs instead of restating their prose.
5. Add a plan gate: if a task needs a new product or architecture decision, planning stops and returns to the owning artifact.
6. Prefer compact matrices and representative journeys over exhaustive narrative repetition.

This gives brainstorming/specification a stronger technical angle without undoing v0.13's product-literacy work. Product literacy remains upstream authority; the spec becomes its technical realization.

## 2. Dependency Graph Quality

### Observed graph shape

| Graph | Tasks | Edges | Maximum ready width | Transitively redundant edges |
|---|---:|---:|---:|---:|
| Juno backup/migration | 7 | 7 | 2 | 0 |
| Juno tool search | 4 | 3 | 1 | 0 |
| Juno shared cache | 4 | 3 | 2 | 0 |
| Juno apps | 13 | 18 | 3 | 3 |
| Juno remote | 10 | 12 | 3 | 0 |
| Juno users | 9 | 10 | 3 | 0 |
| Juno WebUI | 8 | 10 | 1 | 3 |
| Seraphim Skills | 5 | 6 | 2 | 2 |

The Juno WebUI plan is the clearest example. Settings, Apps, and client/capability console work were placed in a chain despite being distinct product domains. They also shared the `webui-openapi-and-generated-client` exclusive resource, which was enough for the scheduler to avoid unsafe overlap. Juno history later records removal of the spurious `yaoz -> azdy` dependency (`31ad452`), and a retained project memory explicitly classifies it as ordering rather than a technical prerequisite.

### Root cause in enforcement

Writing-plans correctly states that resource conflicts are scheduling constraints, not dependency edges (`skills/writing-plans/SKILL.md`). However, `scripts/validate-graph-plan.py` rejects overlapping write paths or exclusive resources when tasks are parallel-ready, and skips that collision when any dependency path exists. The easiest way to pass validation is therefore to add an edge.

Two additional enforcement gaps matter:

- Exclusive resources are normalized as whole strings rather than compared as individual resource tokens, so differently ordered or differently populated lists may conceal a shared resource.
- The validator does not reject transitively redundant edges, allowing graphs that exaggerate ordering even when reachability is unchanged.

### Change package

1. Treat declared write/resource conflicts as valid independent work. Let the scheduler serialize them dynamically.
2. Parse exclusive resources into sets and compare tokens, not serialized list strings.
3. Require every dependency edge to name a concrete reason:
   - a produced interface consumed by the downstream task;
   - an artifact or behavior that literally does not exist before the upstream task;
   - an irreversible migration/rollout ordering constraint.
4. Apply an **edge deletion test**: if deleting the edge leaves both tasks implementable against stable interfaces, the edge is invalid. “Do this first,” shared files, shared fixtures, reviewer convenience, or reduced merge risk are not semantic prerequisites.
5. Reject transitively redundant edges unless the format gains a separate non-DAG annotation for documentation.
6. Report both semantic maximum ready width and resource-constrained schedulable width. Warn when a graph has width one despite multiple independent outcomes.
7. Make `Produces:` and `Consumes:` stable interface IDs first-class task fields, derived from the spec seam ledger.

The technical spec should expose the seams; the plan should derive edges from actual consumption of those seams. That is more reliable than asking the planner to infer dependencies from filenames or narrative order.

## 3. Why SDD Still Takes a Long Time

### Timing summary

Structured transcript timing used an active-time approximation that caps long gaps between events at five minutes. It is intended for comparison, not billing or wall-clock accounting.

| Root session | Child agents | Approx. active child time | Implementer median | Reviewer median | Notable pattern |
|---|---:|---:|---:|---:|---|
| Codex, Juno backup/migration (`019f682b…`) | 43 | 15.8 h | 22.0 m | 7.5 m | Repeated high-risk review findings and diagnostic splits |
| Codex, Juno tool search (`019f6dd5…`) | 19 | 6.0 h | — | — | One oversized first slice reached nine failed review rounds |
| Codex, Juno multi-epic (`019f73dc…`) | 190 | 55.0 h | 23.1 m | 7.1 m | Large volume and long-tail workers |
| Claude, Juno (`60587…`) | 35 | 11.4 h | 36.6 m | 6.4 m | Significant manual manifest/setup work |
| Claude, Seraphim Skills (`a0b19…`) | 18 | 2.5 h | 15.3 m | 3.9 m | Smaller slices and shorter completion |

The medians are not especially slow. The tail and repeated loops are. In the backup/migration run, reviews found real security, recovery, and correctness defects, and some corrections needed further decomposition. In tool search, Slice 1 combined search/index behavior, bridge authority, prompts/configuration, embeddings, diagnostics, child isolation, and JSON-schema security. Passing the manifest's original verification commands did not mean the slice was review-ready.

The tool-search controller continued through review rounds 3–9. This contradicts the existing review policy: after two failed review rounds total, the controller should stop and diagnose/split (`skills/subagent-driven-development/references/review-evidence.md`). `scripts/sdd-evidence.py` enforces the threshold only when evidence is checked near closure, which is too late to prevent dispatching another correction worker.

Claude's Juno transcript also shows repeated controller work to inspect templates, hash artifacts, construct manifests, validate them, bind them, and then dispatch. That setup preserves authority, but much of it is deterministic and should not consume controller reasoning each time.

### Change package, in priority order

1. Add a **pre-correction dispatch gate**. A third failed review round must be mechanically rejected until the task is split or the governing design/contract changes.
2. Add a slice-complexity check based on technical domains and boundaries, not line count. A slice spanning several of authority, parsing, persistence, concurrency, recovery, external protocol, or security boundaries should be split even when it serves one product outcome.
3. Add `sdd prepare <task-id>` to derive a manifest from the graph, create/resolve the worktree, hash governing artifacts, populate resources and write paths, validate, and bind. Keep the generated manifest inspectable.
4. Define verification tiers:
   - focused checks owned by the task;
   - task/package checks;
   - integration checks after merge;
   - release gates once for the assembled graph.
5. Cache evidence by commit, environment, fixture revision, and command. Corrections rerun invalidated focused/task lanes; the controller owns integration and release evidence.
6. Preserve overlapping implementation and review where resource constraints permit it. The scheduler already supports this; better DAGs will expose more safe work.
7. Report time by phase—prepare, implement, review, correction, merge, release—so future audits can distinguish orchestration overhead from substantive work.

## 4. `allowed_write_set`

### Finding

Keep it.

Across 37 recent Juno manifests, the median allowed set was three paths (minimum one, maximum 26). Reports show the boundary doing useful work:

- `juno-aaxq.9-report.md` records refusal to change `internal/e2e/tool_search_test.go` because it was outside scope.
- `juno-71or-report.md` records an out-of-scope correction in `internal/compress/engine.go` remaining absent.
- `juno-aaxq.6-report.md` records a gate that could not be fixed within the exact set, exposing a planning/scope defect instead of silently broadening the worker.
- A later `juno-0qxt` amended manifest expanded to 24 paths, showing that large amendments are possible but operationally clumsy.

The negative evidence is about ergonomics: workers/controllers rebuild manifests when a legitimate correction crosses the original boundary, and duplicated path declarations can drift. Removing the boundary would trade visible planning defects for invisible scope creep.

### Change package

1. Make graph task `Files` the sole hand-authored source. Generate the normalized `allowed_write_set` in the manifest and add a `write_scope_hash` to detect drift.
2. Add `sdd-manifest.py check-diff BASE HEAD` to prove every changed path is allowed before review and merge.
3. Add a bounded amendment command that:
   - names the requested path and rationale;
   - recalculates task/resource overlap;
   - emits a new contract hash;
   - requires a fresh worker context when identity changes.
4. Distinguish planned product/source paths from generated report/evidence paths, while keeping both explicit.
5. Validate prefix overlap, not only exact-string intersection, between allowed and prohibited paths. A prohibited directory must deny its descendants.
6. Do not add an “adjacent files” wildcard. Needing an adjacent path is useful evidence that either the task boundary or the plan is wrong.

## 5. Memory Quality: Juno and Seraphim

### Inventory

| Project | Memories | Typed headers | Headerless |
|---|---:|---:|---:|
| Juno | 74 | 0 | 74 |
| Seraphim | 49 | 25 | 24 |

Both stores include valuable decisions and root causes. The issue is that capture has also admitted facts that are neither durable nor costly to rediscover.

Examples include:

- Juno `design-events-layer-plan-approved-for-subagent-driven`: an approval episode; the plan/graph is the canonical source.
- Seraphim `design-approved-cos-m3-spec-6-studio-authoring`: another approval episode without a durable decision delta.
- Two overlapping Juno continuation/resume entries for 2026-07-22.
- Three overlapping Juno memories about Beads checkout/rebase/hook procedure, which belongs in project instructions or a skill.
- Seraphim's `gotcha-bd-create-graph-dry-run-is-not` and related planning insight, now owned by the writing-plans workflow.
- Stale branch/SHA and superseded execution-state entries in Seraphim.
- Juno `lesson-run-juno-ci-style-go-gates-sequentially`, whose body contains a large raw failure dump rather than a concise reusable invariant.

### Tightened capture test

A candidate should be remembered only when all are true:

1. It will change a future decision or prevent a plausible repeated mistake.
2. Rediscovery is expensive or the evidence is otherwise easy to lose.
3. It is not already authoritative and searchable in a contract, spec, graph, AGENTS instruction, or skill.
4. It has evidence and an invalidation/expiry condition where relevant.
5. It can be stated as a concise semantic delta, not a transcript, command recipe, or completion announcement.

Reject or reroute candidates whose core claim is:

- “approved,” “accepted,” “implemented,” “complete,” or “ready for SDD”;
- only a plan/spec path or current branch/head/next task;
- a command or procedure that should change a skill or project instruction;
- a raw failure log;
- a restatement of a governing artifact without a surprising invariant.

Keep only one latest continuation per active stream, with a short expiry. Durable memories should name evidence and the event that invalidates them. The report or governing artifact remains the full explanation; memory is a retrieval index and decision delta.

### Workflow changes

1. Put the tightened capture test directly in the memory-capture path, not only in periodic curation.
2. Make “accepted/approved/completed” without a future decision delta a lint failure.
3. Route procedural discoveries to a proposed skill/AGENTS patch; do not duplicate them as memory.
4. Trigger a curator offer at a count/duplication threshold, but never mutate automatically.
5. Inject only high-salience durable memories and the single latest relevant continuation at session start.

## 6. Prioritized Implementation Sequence

The following sequence maximizes leverage and keeps changes independently reviewable:

1. **Fix DAG semantics and validation.** Remove the incentive for fake edges, parse resource sets, enforce edge reasons/deletion tests, and reject redundancy.
2. **Enforce the review-loop stop before dispatch.** This prevents the worst observed runaway behavior immediately.
3. **Clarify artifact ownership.** Add the contract/spec/plan table, move implementation transactions into the spec, and introduce the seam ledger.
4. **Generate SDD manifests and write-scope amendments.** Preserve authority while reducing controller setup cost.
5. **Introduce verification tiers and cached evidence.** Reduce correction and graph-wide retesting.
6. **Tighten memory capture, then run the approved Juno/Seraphim curation.** Prevent new noise before cleaning the existing stores.
7. **Add phase telemetry and repeat this audit after one week.** Compare graph width, redundant edges, failed review rounds, correction count, setup time, and memory rejection rate.

## 7. Suggested Success Metrics for the Next Audit

| Metric | Target |
|---|---|
| Dependency edges without a named produced/consumed interface or hard ordering reason | 0 |
| Transitively redundant edges | 0 |
| Third failed review round dispatched without diagnostic split | 0 |
| Independent-outcome graphs with semantic width 1 | Explicitly justified only |
| Manual manifest construction steps per task | 0 after `sdd prepare` |
| Out-of-scope changed paths reaching review | 0 |
| Memories whose only content is approval/completion/current branch state | 0 new |
| Procedural memories duplicating skills/project instructions | 0 new |

## Evidence Corpus and Limitations

Repository evidence included the v0.13 product-definition, brainstorming, writing-plans, SDD, context-lifecycle, review-evidence, scheduling, implementer/reviewer prompt, graph validation, manifest validation, and memory-curator materials; recent Juno and Seraphim contracts/specs/plans/graphs; 37 Juno manifests and their reports; Git history; and the complete local Beads memory inventories for both projects.

Local transcript evidence included Codex roots `019f682b…`, `019f6dd5…`, and `019f73dc…`, Claude Juno roots `60587…` and `51033…`, and Claude Seraphim roots `a0b19…` and `b56dd…`, including their child-agent trees. Message bodies were used only to classify workflow events and findings; this report records aggregate structure and concise paraphrases rather than reproducing conversations.

Limitations:

- Active-time estimates cap idle gaps and are comparative rather than exact wall time.
- Claude and Codex log formats differ, so counts are structurally normalized but not perfectly equivalent.
- Artifact word count is a signal of overlap, not an independent quality score.
- Memory deletion/consolidation is a dry run; evidence must be rechecked at mutation time.
- This audit did not browse external sources because the question concerns local workflow behavior and repository implementation.

## Refuted or Narrowed Claims

- **“The product contract is just a more detailed spec.”** Not by intended authority, but several recent contracts behave that way. The templates need sharper exclusions and compression.
- **“The spec needs to become technical, which may undo product literacy.”** A more technical spec is the correct complement to product literacy. It should realize the contract, not replace it.
- **“Agents are simply adding silly edges.”** Sometimes, but the validator currently rewards that behavior. Enforcement must change alongside prompting.
- **“SDD workers are generally slow.”** Median turns are acceptable; oversized slices, repeated review loops, controller setup, and long-tail defects dominate elapsed effort.
- **“`allowed_write_set` may not be effective.”** The evidence shows it preventing or exposing scope violations. Its generation and amendment workflow is the problem.
- **“Recorded memories are mostly useless.”** Both stores contain strong semantic decisions. The capture gate is too permissive, producing avoidable episodic and procedural noise around a useful core.
