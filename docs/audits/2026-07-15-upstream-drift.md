# Plugin Audit — 2026-07-15

## Scope

This audit gates the local `0.13.0` version bump. It covers all eight audit phases, adapted to the repository's current architecture. Live Claude model fixtures were not run by explicit user instruction. Codex installation shape was run; four live Codex behavior outcomes remain `UNTESTED` in the existing workflow acceptance campaign.

## Infrastructure

- Plugin manifest: PASS with the expected warning that repository-root `CLAUDE.md` is project documentation, not plugin-injected context.
- Version consistency: PASS at `0.13.0` across the eight declared manifests/packages; README and CLAUDE version text were spot-checked separately.
- Hook: executable; the canonical hook suite passes for startup, resume, clear, compact, malicious delimiter handling, safety-net behavior, warnings, and OpenCode composition.
- Hook registration: PASS through `hooks/hooks.json`. The old audit expectation that `.claude/settings.json` directly name `hooks/session-start` is obsolete because plugin hook discovery owns registration.
- Skills: 23 directories and 23 `SKILL.md` files.
- License attribution: PASS.

## Tests

- Brainstorm server: 32/32 passed.
- WebSocket protocol: 31/31 passed.
- Auth/security: 20/20 passed.
- Guards: PASS.
- Skill contracts: PASS.
- Hook suites: PASS, with one explicit negative-control skip when `bd prime` had no active project in its isolated fixture.
- Manifest validation: PASS.
- Codex install shape: PASS.
- Claude live skill and integration fixtures: NOT RUN by user instruction.
- Live Codex workflow behavior: UNTESTED pending separate cost authorization; this keeps four outcome IDs and the epic acceptance gate open.

## Content Integrity

- TodoWrite gate: PASS.
- Stale `docs/superpowers` paths: none.
- Stale skill namespaces: none.
- Stale plugin placeholder paths: none.
- Beads command density: 62 references (minimum 30).
- Reviewer isolation: PASS; the task reviewer contains no Beads mutations.
- Canonical policy ownership: PASS. `check-policy-ownership.sh --enforce` supersedes the removed convention-copy guard.
- Progressive skill chain: PASS from product/design/planning through execution, finishing, and evidence gating.

## Upstream Drift

- Superpowers: upstream `v6.1.1`; repository baseline `v6.1.1`.
- New upstream skills: none.
- Upstream-only companion files: `brainstorming/spec-document-reviewer-prompt.md` and `writing-plans/plan-document-reviewer-prompt.md`. Neither current upstream skill routes to these files, and the local product/design/graph gates replace their generic checks, so they are recorded as non-blocking unrouted companions rather than copied blindly.
- Shared skill differences: expected fork divergences for Beads tracking, product definition, graph planning, context manifests, rolling scheduling, review evidence, multi-host support, and canonical policy ownership.
- Hook difference: expected `resume` lifecycle support plus composed Beads context.
- Beads: official tags include `v1.1.0`, matching the documented baseline; the local Homebrew executable reports `v1.0.4`.

## Documentation

- README: PASS; product definition, vertical graph planning, rolling execution, evidence gates, clean cutover, and version badge are documented.
- CLAUDE.md: PASS; architecture, commands, `just microtest`, workflow version, and audit location are documented.
- CHANGELOG: PASS; `0.13.0` describes user-facing additions, changes, fixes, benefits, and the microtest entry point.
- Removed docs-site/setup-guide checks: not applicable to the README-first documentation architecture.
- Coverage map:

  | Public surface | Reference | How-to | Tutorial | Explanation |
  |---|---:|---:|---:|---:|
  | `product-definition` | yes | yes | not needed | yes |
  | Vertical graph plans | yes | yes | not needed | yes |
  | Context Manifest and rolling SDD | yes | yes | not needed | yes |
  | Evidence gates | yes | yes | not needed | yes |
  | `just microtest` | yes | yes | not needed | yes |

No judgment-confirmed documentation gap remains for the new public surface.

## Findings

Two important findings remain open:

1. `beads-superpowers-yd6.1` — refresh the development-only upstream-audit skill, whose direct-hook and convention-sync checks predate plugin discovery and canonical policy ownership.
2. `beads-superpowers-yd6.2` — upgrade the local Beads executable from `1.0.4` to the documented `1.1.0+` baseline.

## Release State

The version bump and branch push may proceed as requested, but this report is not an acceptance upgrade. Task `beads-superpowers-4cr` and epic `beads-superpowers-4gl` remain open because `SWF-PRODUCT-CONTRACT`, `SWF-VERTICAL-SLICE`, `SWF-CROSS-PLATFORM`, and `SWF-ADVERSARIAL-COVERAGE` are `UNTESTED`, and the inline whole-change review is not an independent fresh-context review.
