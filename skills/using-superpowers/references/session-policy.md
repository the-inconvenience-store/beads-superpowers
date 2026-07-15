# Session Policy

This is the semantic owner for workflow-wide session policy. Skills keep only the smallest rule needed at their decision point and route branch procedure here.

## Capture Gate

After design, research, debugging, or planning work settles, offer one explicit capture decision. Present only durable, evidence-backed candidates; the user chooses what to retain or skips. A dismissed, unavailable, or auto-resolved question is no consent.

## Durable Memory

Record an insight only when it remains useful beyond the current session and is grounded in a file, test, command, or durable decision. Update the existing keyed memory instead of creating a near-duplicate. Never retain guesses, one-off state, secrets, credentials, tokens, keys, or personal data.

## Beads Read/Write Economy

Use bounded reads, filtered output, and a single batch for related mutations. Preserve write confirmations as evidence. Never dump the full memory store or perform repetitive tracker round trips when one bounded query or batch answers the question.

## Claim Boundary

Auto-claim only inside an explicitly authorized autonomous take-next-task flow. When the user chose the work, orientation and planning remain read-only until the user authorizes execution. Efficiency cannot widen consent.

## Session Completion

The completion sequence is exactly: `bd close` → `bd dolt push` → `git pull --rebase && git push` → `git status`. Close only verified work, honor explicit user limits on remote actions, and never describe unsynced authorized work as landed.
