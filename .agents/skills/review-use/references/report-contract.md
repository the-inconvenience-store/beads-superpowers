# Review artifact contract

Read this reference when generating, checking, or comparing a review artifact.

## Paths

Write a pair with the same stem:

```text
docs/reviews/YYYY-MM-DD-{scope}-superbeads-usage-review.md
docs/reviews/YYYY-MM-DD-{scope}-superbeads-usage-review.json
```

The JSON companion owns measurements. Markdown tables must agree with it.

## Required Markdown sections

1. Metadata and corpus scope
2. Verdict
3. Coverage and limitations
4. Failure summary
5. Failure instances
6. Longitudinal trends
7. Emergent behaviors to encourage and constrain
8. Recommendations
9. Registry changes
10. Evidence commands and source index

Failure summary columns:

```text
Pattern ID | Title | Status | Count | Per 100 sessions | Previous rate | Trend | Confidence
```

Failure instance columns:

```text
Instance ID | Pattern ID | Platform | Session / agent | Timestamp | Source line | Confidence | Evidence hash | Note
```

## Comparison rules

- Compare stable pattern IDs, not titles.
- Always show corpus session counts and unavailable-content counts.
- Normalize the primary rate as failures per 100 reviewed sessions.
- Use `new` when no prior row exists and `not-comparable` when the prior denominator is unusable.
- Preserve retired pattern history.
- State source-format limitations and any selected corpus that could not be read.

## Registry changes

Add a pattern only after confirming a concrete instance, checking for duplicates, and defining a falsifying boundary. Use a `manual` detector when context is required.

Retirement requires three separate completed reviews, at least 21 days between earliest and latest, and count ≤1 plus rate ≤1 per 100 sessions in every qualifying review. Retirement changes status; it never deletes or reuses the ID.
