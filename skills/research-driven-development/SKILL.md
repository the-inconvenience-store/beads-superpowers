---
name: research-driven-development
description: Use when the user asks a question about a topic, requests research, or when you need to understand something before planning. Dispatches parallel research agents, synthesizes findings into a persistent document, and writes it to the project's research directory. Triggers on "research this", "what is X", "how does Y work", "compare A vs B", "investigate", "deep dive", "look into".
---

# Research-Driven Development

Dispatch parallel research agents, synthesize their findings, and write a persistent research document. Research is not complete until there is a written artifact — verbal answers without documents are prohibited.

**Announce at start:** "I'm using the research-driven-development skill to investigate this topic."

## When to Use

- User asks a question about a technology, concept, or approach
- User says "research this", "deep dive", "investigate", "look into"
- User asks "what is X", "how does Y work", "compare A vs B"
- Before planning a non-trivial task that requires understanding first
- When you need to understand something before making a decision

## When NOT to Use

- User asks about a specific file in the current codebase (just read it)
- The answer is a single fact you already know with certainty
- User explicitly asks for a quick verbal answer

## Iron Law

> **NO RESEARCH WITHOUT A DOCUMENT.**
> Every research task produces a written artifact. Verbal answers without persistent documents are prohibited. If you researched it, write it down.

## Output Path

Research documents are written to: **!`bash ${CLAUDE_SKILL_DIR}/resolve-output-dir.sh`**

This path is resolved dynamically when the skill loads. Priority chain:

| Priority | Scope | How to set |
|----------|-------|------------|
| 1 | Per-project | `bd config set custom.research-output-dir "/absolute/path"` |
| 2 | Global | `export RESEARCH_OUTPUT_DIR="/absolute/path"` in shell profile |
| 3 | Default | `./.internal/research` |

**Important:** Always use absolute paths. Tilde (`~`) does not expand in `bd config` values.

## Pipeline

```
Step 0: Scope check (conditional)
Step 1: Create bead + calibrate effort
Step 2: Check existing knowledge
Step 3: Decompose + dispatch parallel research agents
Step 4: Synthesize + verify findings
Step 4.5: Gap-closing round (if needed)
Step 5: Write document
Step 6: Close bead
```

## Step 0: Scope Check (conditional)

If the question is already specific, **skip this step**. Fire it **only when you cannot name the sources you'd search or the decision the answer informs** — e.g. "research databases" (too vague). Do NOT fire when scope is already present — e.g. "compare Postgres vs SQLite for our embedded Dolt use case".

When it fires, ask 2–3 clarifying questions via `AskUserQuestion` (scope · use-case · the decision it informs), then weave the answers into the research question before Step 1. This is disambiguation, not a quality gate — mandatory scope-gating just duplicates what a capable model already does. The "When NOT to Use" list still applies.

## Step 1: Create a Bead + Calibrate Effort

```bash
bd create "Research: <topic>" -t task -p 2
bd update <id> --claim
```

**Calibrate effort — the query tier picks the agent count (this is the throttle, not a vibe):**

| Tier | When | Agents | Searches |
|------|------|--------|----------|
| Simple fact-finding | one factual answer | 0–1 (no decomposition) | ~3–10 |
| Comparison / decision | weigh 2+ options | 2–4 sub-questions, one agent each | ~10–15 each |
| Complex / open-ended | broad or architectural | up to 5 sub-questions | as needed |

**Hard ceiling: at most 5 parallel agents per round.** `@explore` (Step 3), when dispatched, counts as one of the 5. Scale effort to the question — do not over-dispatch.

## Step 2: Check Existing Knowledge

Before launching new research, search for existing coverage:

```bash
# Check beads memories for prior context
bd memories <keyword>

# Search project research directory
find "!`bash ${CLAUDE_SKILL_DIR}/resolve-output-dir.sh`" -name "*.md" -exec grep -l "<keyword>" {} \; 2>/dev/null
```

**If comprehensive coverage already exists:** Reference it, add any new findings as updates, and close the bead. Do not duplicate existing research.

## Step 3: Decompose + Dispatch Parallel Research Agents

**Decompose first** (skip for the Simple tier): break the topic into **3–6 complementary sub-questions** (for opinion/design topics, 2–3 perspectives) that collectively cover it. Assign **one researcher agent per sub-question** — never hand every agent the raw topic. Launch all agents in a **single message with multiple `Agent` tool calls** so they run concurrently. **Cap: 5 parallel agents (Step 1).**

### The delegation contract (every dispatch)

Each agent's brief MUST state all four parts (Anthropic's delegation contract — vague briefs cause duplicated and missed work):

1. **Objective** — the specific sub-question, not the whole topic.
2. **Output format** — structured findings, and a **verbatim supporting quote for every load-bearing claim** (this is what lets Step 4 verify soundness without re-fetching).
3. **Tools / sources** — which to prefer (official docs over blogs; LSP for code).
4. **Boundaries** — what this agent owns vs. its neighbours, so sub-questions don't overlap.

Add to every brief: **start wide, then narrow** — open with a SHORT broad query, see what's available, then narrow. Never lead with a long, hyper-specific query.

### Agent A: Researchers (web + documentation)

Dispatch via the `Agent` tool:

1. `Read` the prompt template at `./researcher-prompt.md`
2. Use its content as the `prompt` parameter, appending the sub-question + the four contract parts above + bead context (bead ID, what decision this informs, prior knowledge from `bd memories`)
3. Use `subagent_type: "general-purpose"` (do NOT use `"researcher"` — that built-in agent's system prompt overrides the template)

### Agent B: @explore (codebase) — one agent, conditional

Dispatch **exactly one** `@explore` agent (`subagent_type: "Explore"`) **only when the topic has codebase relevance** ("how does X work *here*", "should we adopt Y"). It counts as one of the 5 and is **not decomposed** (it's already a broad codebase sweep), but gets the same 4-part contract:

> Objective: find existing implementations, patterns, config, tests, and docs related to [topic] in this repo. Output: what exists, where (`file:line`), and how it relates. Boundaries: codebase only — no web. Report concisely.

### How many agents

- **Topic touches our codebase** (common case): N web sub-question agents + **1 `@explore`**, total ≤ 5.
- **Pure external topic**: skip `@explore`; all slots go to web sub-questions.
- **Pure codebase question**: dispatch only `@explore`.

## Step 4: Synthesize Findings

After both agents return, the **orchestrator** (you) synthesizes:

1. **Merge findings** — Combine web research with codebase findings
2. **Resolve contradictions** — If agents disagree or sources conflict, determine which is authoritative
3. **Identify gaps** — Note anything neither agent covered
4. **Extract actionable items** — If research reveals work to do, note recommended beads

## Step 5: Write the Document

Research output directory and categories:

**!`bash ${CLAUDE_SKILL_DIR}/resolve-output-dir.sh`**

If categories are listed above (after `---categories---`), pick the subdirectory that best matches the research topic. If no category fits, write to the base directory. If no categories exist, write to the base directory.

```bash
# Example: research about CI/CD → engineering-and-technology subdirectory
mkdir -p "<base-dir>/<category>"
```

Filename: `YYYY-MM-DD-<topic-slug>.md`

### Document Format

```markdown
# Research: [Topic]

> **Date:** YYYY-MM-DD
> **Bead:** <bead-id>
> **Status:** Complete

## Summary

[2-3 sentence overview of key findings. What did we learn? What's the recommendation?]

## Key Findings

### [Finding 1: Title]

[Details with specific facts, numbers, commands, code examples. Be concrete — no vague claims.]

### [Finding 2: Title]

[Details]

### [Finding 3: Title]

[Details]

## Comparisons

[Table comparing options/approaches if applicable]

| Criterion | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| ... | ... | ... | ... |

## Codebase Context

[What already exists in the codebase related to this topic. File paths, patterns, relevant tests.]

## Recommendations

[Clear, actionable recommendations based on findings. What should we do next?]

## Recommended Beads

[If research reveals follow-up work, list as bd create commands]

- `bd create "Title" -t <type> -p <priority>` — [Why]

## Open Questions

[Anything unresolved or needing further investigation]

## Sources

- [Source Title](URL) — [What was extracted and why it's authoritative]
- [Source Title](URL) — [What was extracted]
```

### Quality Checklist

Before writing, verify your document passes these checks:

- [ ] **Summary exists** and is 2-3 sentences (not a paragraph)
- [ ] **Every finding has evidence** — no unsourced claims
- [ ] **Sources section has 3+ entries** with URLs (not "various sources")
- [ ] **Dates and versions noted** for time-sensitive information
- [ ] **Contradictions resolved** — if sources disagreed, which is right and why
- [ ] **Codebase context included** — what exists now, not just what the web says
- [ ] **Recommendations are actionable** — "do X" not "consider doing X"

## Step 6: Close the Bead

If you discovered something reusable, capture it before closing:

```bash
# Only if worth preserving for future sessions:
bd remember "research: <key finding from research>"
```

```bash
bd close <id> --reason "Research complete: <1-line summary of finding>"
```

If research revealed follow-up work, create the recommended beads:

```bash
bd create "Follow-up: <title>" -t task -p <priority>
```

## Red Flags / Anti-Rationalization

| Thought | Reality |
|---------|---------|
| "I already know the answer" | You might be wrong. Check sources. The document is for future sessions too. |
| "This is a simple question, I'll just answer verbally" | Iron Law: NO RESEARCH WITHOUT A DOCUMENT. Write it down. |
| "I'll skip the codebase search — this is a general topic" | The codebase might already have an implementation. Always check. |
| "I'll write the document later" | You won't. Write it now while the research is fresh. |
| "One source is enough" | Cross-reference across 3+ independent sources. Single-source findings get flagged. |
| "I'll skip the knowledge base check" | You might duplicate existing research. Always search first. |

## Example

User asks: "How does Dolt handle merge conflicts?"

```
1. bd create "Research: Dolt merge conflict handling" -t task -p 2
2. bd memories "dolt merge" → check for prior research
3. Dispatch researcher (via ./researcher-prompt.md): "Research Dolt merge conflict resolution..."
   Dispatch @explore: "Search codebase for Dolt merge, conflict..."
4. Synthesize: researcher found cell-level merge docs, explore found bd dolt pull usage
5. Write to !`bash ${CLAUDE_SKILL_DIR}/resolve-output-dir.sh`/2026-05-01-dolt-merge-conflict-handling.md
6. bd close <id> --reason "Research complete: Dolt uses cell-level merge on SQL tables"
```

## Integration

**Invoked by:** User on-demand, or during the research phase before planning. No other skill invokes this directly.

**Invokes:** None. Dispatches @researcher and @explore agents in parallel internally, but does not invoke other skills.
