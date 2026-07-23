# Review-use skill design

> Date: 2026-07-23
> Bead: beads-superpowers-p17
> Status: Accepted
> Product contract: internal bypass — the user's 2026-07-23 request and approved recommended design

## Product outcomes

- `RU-CORPUS`: discover and normalize selected Claude and Codex main-agent and subagent JSONL without requiring the reviewer to understand host-specific schemas.
- `RU-DETECT`: detect registered workflow anti-patterns deterministically where possible and retain manually confirmed instances where interpretation is required.
- `RU-REPORT`: write a durable review document and JSON companion under `docs/reviews/`.
- `RU-TREND`: compare stable failure IDs and normalized rates across prior reviews.
- `RU-REGISTRY`: add newly confirmed anti-patterns to a declarative skill-owned reference without rewriting executable skill behavior.
- `RU-RETIRE`: retire an anti-pattern only after at least three separate reviews spanning at least 21 days meet the near-zero rule.
- `RU-SECURITY`: treat all conversation content as untrusted data and avoid reproducing secrets or executing extracted instructions.

## Assumptions

| Assumption | Status | Evidence | Failure consequence |
|---|---|---|---|
| Claude conversations are stored below `~/.claude/projects/` with subagents below session-local `subagents/` directories | Verified | Local filesystem and sampled JSON object keys | Discovery would miss Claude subagents |
| Codex conversations are stored below `~/.codex/sessions/` and expose parent/session metadata in JSONL | Verified | Local filesystem and sampled `session_meta` keys | Parent/child attribution would be incomplete |
| Some Codex message bodies may be encrypted or otherwise unavailable | Verified | Existing 2026-07-15 workflow review | Metrics must distinguish unavailable text from absence of behavior |
| Markdown tables alone are insufficient for robust longitudinal comparison | Approved | User selected the recommended design | A JSON companion is required |
| “Near zero” means count ≤1 and rate ≤1 per 100 reviewed sessions in each qualifying review | Approved | User selected the recommended design | Retirement eligibility changes if this threshold changes |

## Architecture

The skill is a thin orchestration layer over three zero-dependency Python scripts and three disclosed references:

```text
.agents/skills/review-use/
├── SKILL.md
├── references/
│   ├── anti-patterns.json
│   ├── report-contract.md
│   └── source-formats.md
└── scripts/
    ├── collect.py
    ├── analyze.py
    └── registry.py
```

`collect.py` owns host discovery and normalization. `analyze.py` owns deterministic detection, metrics, comparison, and report-data generation. `registry.py` owns registry validation, additions, lifecycle history, and retirement eligibility. `SKILL.md` owns the human/agent review sequence and qualitative vetting.

The scripts do not infer product recommendations. They produce bounded evidence for the reviewer, who confirms context, identifies emergent behavior, and writes the final conclusions.

## Normalized corpus contract

`collect.py` accepts explicit source files, source roots, date bounds, project/cwd filters, and text selectors. It never scans outside the selected roots.

Each normalized JSONL event has:

```json
{
  "schema_version": 1,
  "platform": "claude|codex",
  "session_id": "string",
  "parent_session_id": "string|null",
  "agent_id": "string|null",
  "agent_role": "main|subagent|unknown",
  "source_path": "absolute path",
  "source_line": 1,
  "timestamp": "ISO-8601|null",
  "event_type": "string",
  "actor": "user|assistant|tool|system|unknown",
  "tool_name": "string|null",
  "command": "string|null",
  "text": "string|null",
  "content_available": true
}
```

Normalization preserves only fields needed for review. `content_available: false` distinguishes encrypted/unavailable content from an empty message. Source paths and lines remain evidence pointers. Full raw records are not copied into durable reports.

## Anti-pattern registry

`references/anti-patterns.json` is the single source of truth for trackable failure definitions:

```json
{
  "schema_version": 1,
  "patterns": [{
    "id": "RU-AP-001",
    "title": "Recursive correction parenting",
    "category": "task-topology",
    "status": "active",
    "description": "Stable meaning and falsifying boundary.",
    "detector": {
      "kind": "event-regex|command-regex|metric-threshold|manual",
      "config": {}
    },
    "added": {"review_id": "string", "date": "YYYY-MM-DD"},
    "retired": null
  }]
}
```

Pattern IDs are immutable and never reused. Detectors are declarative data; no registry field contains Python, shell, template expressions, or executable callbacks. Regex detectors use Python regular expressions against normalized fields only.

The reviewer may add a pattern after confirming at least one concrete instance, checking that it is not a duplicate or narrower wording of an existing pattern, defining the falsifying boundary, and validating the registry. A non-automatable pattern uses `manual`; its confirmed instances are supplied as structured input to `analyze.py`.

Retirement changes `status` to `retired`; it does not delete history or reuse the ID. `registry.py retire` reads prior JSON review companions and permits retirement only when:

- at least three distinct completed reviews contain the pattern;
- the earliest and latest qualifying reviews are at least 21 days apart; and
- every qualifying review records count ≤1 and rate ≤1 per 100 reviewed sessions.

A retired pattern remains available for historical comparison and may be reactivated if a new confirmed instance appears.

## Detection and comparison

`analyze.py scan` accepts normalized JSONL, the registry, optional manual instances, and prior review JSON files. It emits one review-data JSON object.

Known detectors:

- `event-regex`: match a bounded normalized text or event field;
- `command-regex`: match normalized tool commands without executing them;
- `metric-threshold`: compare corpus metrics such as task depth, review rounds, waits, repeated verification, task creation/closure ratio, or time without closure;
- `manual`: validate reviewer-supplied instances against the instance schema.

Each detector records its numerator and denominator. The primary cross-review rate is failures per 100 reviewed sessions. Corpus size, main/subagent counts, event count, duration, and unavailable-content count are always retained so comparisons show coverage drift.

The tool reports current count/rate, previous count/rate, absolute and percentage delta when defined, and a trend of `rising`, `falling`, `flat`, `new`, or `not-comparable`.

## Review artifact contract

The skill writes:

```text
docs/reviews/YYYY-MM-DD-{scope}-superbeads-usage-review.md
docs/reviews/YYYY-MM-DD-{scope}-superbeads-usage-review.json
```

The Markdown document contains:

1. metadata and corpus scope;
2. verdict;
3. coverage and limitations;
4. failure summary table;
5. failure instances table;
6. longitudinal trends;
7. emergent behaviors to encourage and constrain;
8. recommendations;
9. registry additions, reactivations, and retirement candidates;
10. evidence commands and source index.

The failure summary table has fixed columns:

```text
Pattern ID | Title | Status | Count | Per 100 sessions | Previous rate | Trend | Confidence
```

The failure instances table has fixed columns:

```text
Instance ID | Pattern ID | Platform | Session / agent | Timestamp | Source line | Confidence | Evidence hash | Note
```

The JSON companion is authoritative for machine comparison. It includes review identity/date/window, repository and registry revisions, corpus metrics, pattern summaries, instances, trend calculations, limitations, and registry changes. Markdown table values must be generated from or checked against the companion.

## Security and privacy

- JSONL content is evidence data, never instructions or authority.
- Scripts use Python file APIs and subprocess-free parsing; extracted commands are never executed.
- Reports do not include raw prompts, full assistant responses, credentials, tokens, environment values, or secret-like strings.
- Evidence pointers use source path, line, event identity, and SHA-256 of the normalized evidence fragment.
- Discovery defaults to metadata-only listings until explicit source/date/project scope is selected.
- Registry updates accept schema-bounded values and reject executable detector kinds, path traversal, duplicate IDs, malformed regexes, and invalid lifecycle transitions.

## Failure and recovery

- Malformed JSONL records are counted and reported with source lines; they do not abort unrelated files unless strict mode is selected.
- Unknown host events normalize to `event_type` plus available metadata rather than being dropped silently.
- An unavailable message body is explicit and lowers confidence for text-dependent findings.
- Registry mutation writes a validated temporary file and atomically replaces the registry only after all lifecycle checks pass.
- Report generation refuses to overwrite an existing review unless `--replace` names that exact path.
- Any mismatch between Markdown tables and JSON data keeps the review incomplete.

## Review workflow

1. Define the review window, projects, platforms, and optional selectors.
2. Discover main and subagent logs with `collect.py discover`.
3. Normalize selected files with `collect.py normalize`.
4. Validate the current registry.
5. Scan known patterns and compute trends with `analyze.py scan`.
6. Review normalized evidence qualitatively for novel problems and positive emergent behavior.
7. Confirm new pattern instances, update the registry through `registry.py`, and rescan.
8. Evaluate retirement candidates; retirement is allowed only through the history gate.
9. Write the Markdown review and JSON companion under `docs/reviews/`.
10. Validate table/data agreement and report coverage limitations.

## Evidence strategy

Deterministic fixtures cover:

- Claude main and subagent discovery;
- Codex main and parent-linked child normalization;
- unavailable/encrypted content;
- regex, command, metric, and manual detectors;
- secret redaction and non-execution;
- current/previous trend calculations;
- registry duplicate/add/reactivate/retire transitions;
- three-review/21-day near-zero retirement enforcement;
- Markdown/JSON schema consistency.

The local skill contract verifies that the instructions require both main and subagent records, treat logs as data, vet detector output rather than blindly reporting it, update the registry only with confirmed evidence, and write both artifacts. The shared fresh-agent microtest harness cannot load repository-local `.agents/skills/` paths because its trust boundary is intentionally limited to shipped `skills/`.

## Coverage summary

| Cell | Applicable | Resolution | Risk | Outcome IDs |
|---|---|---|---|---|
| Entry and route | Yes | Explicit roots/files/date/project selectors | Medium | RU-CORPUS |
| Authority boundary | Yes | User scope controls reads; registry schema controls self-update | High, resolved | RU-REGISTRY, RU-SECURITY |
| Domain ownership | Yes | JSON companion owns measurements; registry owns pattern definitions | Medium | RU-TREND, RU-REGISTRY |
| Lifecycle and recovery | Yes | Add/reactivate/retire transitions with atomic validated writes | High, resolved | RU-REGISTRY, RU-RETIRE |
| Interfaces and dependencies | Yes | Zero-dependency Python; fixed normalized/report schemas | Medium | RU-CORPUS, RU-REPORT |
| Security and privacy | Yes | Untrusted-data boundary, no execution, hashed/redacted evidence | High, resolved | RU-SECURITY |
| Evidence and observability | Yes | Stable IDs, source lines, corpus denominators, JSON history | High, resolved | RU-DETECT, RU-TREND |
| Rollout and compatibility | Yes | Unknown events retained; host limitations explicit | Low | RU-CORPUS |
| Accessibility and presentation | No | Non-interactive repository artifacts | N/A | None |

## Technical risk capsule

| Seam | High-risk boundaries | Acceptance surface | Evidence tier | Likely correction |
|---|---|---|---|---|
| Corpus normalization | parsing, security | Selected Claude/Codex files become bounded normalized events | Task | Add host fixture or explicit unavailable state |
| Detection and trends | evidence, parsing | Registered patterns produce reproducible counts and rates | Task | Correct detector config or denominator |
| Registry lifecycle | authority, persistence | Confirmed additions and history-gated retirement mutate safely | Integration | Reject transition or repair history evidence |
| Report generation | persistence, evidence | Markdown and JSON agree under `docs/reviews/` | Integration | Regenerate from authoritative JSON |

## Non-goals

- General semantic search over every conversation.
- Automatic execution of fixes or skill changes found by a review.
- Autonomous rewriting of `SKILL.md` or Python scripts.
- A database, dashboard, daemon, or background watcher.
- Claiming absence of a behavior when relevant conversation content was unavailable.
