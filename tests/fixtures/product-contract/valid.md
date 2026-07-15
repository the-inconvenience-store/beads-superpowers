# Product Contract: Workflow approvals

Revision: 1

## Goal

Enable a maintainer to approve workflow changes without losing product intent.

- Measurable success signal: every planned slice traces to an approved outcome ID.
- Current workaround: reconstruct product decisions during technical design.

## Source Ledger

| Source | Status | Precedence | Contribution |
|---|---|---:|---|
| Maintainer request | Original scope | 1 | Product intent and constraints |
| Workflow research | Verified research | 2 | Observed failure modes |

## Actors and Authority

| Actor | Role | Permissions | Authority grant | Decision owner |
|---|---|---|---|---|
| Maintainer | Approver | Approve or defer outcomes | Owns product scope | Sam |
| Designer | Contract author | Normalize supplied facts | Cannot invent product scope | Sam |

## Vocabulary and Domain Model

| Term or entity | Meaning | Owner | Rejected synonym |
|---|---|---|---|
| Product contract | Sole product-truth artifact | Maintainer | Technical spec |
| Outcome ID | Stable acceptance identity | Maintainer | Task number |

## Lifecycle and Invariants

- Transition: draft -> approved -> superseded.
- Invariant: downstream artifacts reference the approved revision and stable IDs.
- Transaction boundary: approval changes the contract revision atomically.
- Side effect: design and planning may begin after approval.

## Journeys and States

- Journey: maintainer starts with supplied requirements, reviews the normalized contract, approves it, and later finds it under `docs/product/`.
- States: draft, invalid, awaiting decision, approved, and superseded.
- Recovery: invalid contracts name the exact section; superseded contracts link to their replacement.

## Examples and Counterexamples

- Example: a new user workflow records actors, permissions, lifecycle, states, and evidence before design.
- Counterexample: a technically complete component list with no user journey is not a product contract.

## Outcome Trace

| Outcome ID | Actor and entry | Observable result | Evidence class |
|---|---|---|---|
| SWF-PRODUCT-CONTRACT | Maintainer starts substantial product work | Approved product truth is reusable by revision | Contract validation and behavioral scenario |

## Non-Goals and Decisions

- Non-goal: choose the technical architecture.
- Decision: the product contract owns product truth; the design owns solution truth.
- Deferred: none.

## Assumptions

- Verified: the repository stores design artifacts under `docs/`.
- Recalled: none.
- Assumed: none.

## Approval

- Status: Approved
- Approver: Sam
- Approved revision: 1
- Date: 2026-07-15
