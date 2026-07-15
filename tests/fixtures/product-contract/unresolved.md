# Product Contract: Unresolved authority

Revision: 1

## Goal

Define approval behavior.

## Source Ledger

- Maintainer request, original scope, precedence 1.

## Actors and Authority

- Actor: maintainer; role: approver; permissions: approve; authority grant: owns scope; decision owner: Sam.

## Vocabulary and Domain Model

- Term: product contract; meaning: product truth; owner: maintainer.

## Lifecycle and Invariants

- Transition: draft -> approved. Invariant: stable IDs do not change.

## Journeys and States

- Journey: author then approve. States: draft, invalid, approved. Recovery: fix the named section.

## Examples and Counterexamples

- Example: approved product truth. Counterexample: implementation-only notes.

## Outcome Trace

| Outcome ID | Result | Evidence class |
|---|---|---|
| SWF-PRODUCT-CONTRACT | Approved contract | Validator |

## Non-Goals and Decisions

- Non-goal: architecture. Decision: product truth is separate. Deferred: none.

## Assumptions

- Assumed: TBD

## Approval

- Status: Approved
- Approver: Sam
- Approved revision: 1
