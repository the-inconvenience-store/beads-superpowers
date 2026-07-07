# Research: bd create --graph schema

> **Date:** 2026-07-07
> **Bead:** beads-superpowers-clq
> **Status:** Complete

## Summary

`bd create --graph` in `bd` 1.0.4 supports a small graph-specific JSON schema. It can create nodes with titles, descriptions, types, priorities, assignees, labels, flat string metadata, parent-child relationships, and typed dependency edges; it does not import the richer `bd create` CLI-only fields such as acceptance, context, spec IDs, design, notes, estimates, skills, external refs, due dates, or defer dates.

## Key Findings

### Supported node fields

> **Confidence:** high - verified by successful graph imports and JSON type rejection probes against the local `bd` 1.0.4 binary.

Supported node fields:

- `key`: string, required for graph-local references.
- `title`: string.
- `description`: string.
- `type`: string. Valid values follow the normal issue types, such as `epic`, `task`, `feature`, `bug`, `chore`, `decision`, `spike`, `story`, and `milestone`.
- `priority`: integer. Use `2`, not `"P2"`.
- `assignee`: string.
- `labels`: array of strings.
- `metadata`: object with string keys and string values.
- `parent_key`: string, referencing another node key.

`metadata` must be flat. Nested values fail JSON unmarshalling because the graph importer expects `map[string]string`.

### Unsupported or ignored node fields

> **Confidence:** high - each field was accepted with intentionally wrong JSON types and then absent from `bd show --json` and `bd export --all`, which indicates unknown fields are ignored by the graph JSON decoder.

The graph importer ignored these richer `bd create` fields:

- `acceptance`
- `context`
- `design`
- `notes`
- `estimate`
- `skills`
- `external_ref`
- `externalRef`
- `spec_id`
- `specId`
- `repo`
- `due`
- `defer`
- `no_history`
- `no_inherit_labels`
- `mol_type`
- `status`
- `owner`
- `children`
- `id`

To preserve acceptance criteria, context, spec links, and design notes when using `--graph`, put them in `description` sections or flat `metadata` fields.

### Supported edge fields

> **Confidence:** high - verified by graph imports and `bd show --json` on created probe beads.

Supported edge fields:

- `from_key`: string.
- `to_key`: string.
- `type`: string.

Valid dependency types observed through graph imports are:

- `blocks`
- `tracks`
- `related`
- `parent-child`
- `discovered-from`

Edge orientation matches the dependency row shown by `bd show`: `{ "from_key": "a", "to_key": "b", "type": "blocks" }` creates issue `a` depending on issue `b` with dependency type `blocks`. For `parent-child`, `from_key` is the child and `to_key` is the parent.

### Dry-run caveat

> **Confidence:** high - observed locally in this repo with `bd` 1.0.4.

`bd create --graph <file> --dry-run` still created issues during probing. Do not rely on `--dry-run` as a no-write validation step for graph imports in this version.

## Recommended Graph Shape

```json
{
  "nodes": [
    {
      "key": "epic",
      "title": "Epic: Implement planner",
      "type": "epic",
      "priority": 2,
      "description": "Goal and scope.\n\n## Success Criteria\n- Outcome is measurable.\n\n## Spec\n- docs/specs/planner.md",
      "labels": ["planning"],
      "metadata": {
        "spec_id": "docs/specs/planner.md"
      }
    },
    {
      "key": "task-1",
      "title": "Implement graph import path",
      "type": "task",
      "priority": 2,
      "parent_key": "epic",
      "description": "Implementation notes.\n\n## Acceptance Criteria\n- Tests cover successful import.\n- Tests cover invalid graph JSON.",
      "labels": ["backend"],
      "metadata": {
        "component": "planner"
      }
    }
  ],
  "edges": [
    {
      "from_key": "task-1",
      "to_key": "epic",
      "type": "parent-child"
    }
  ]
}
```

## Bulk Enrichment After Graph Import

> **Confidence:** high - verified with local `bd update --help`, `bd batch --help`, and `bd import --help`.

`bd update` supports the richer fields that `bd create --graph` ignores:

- `--acceptance`
- `--context`
- `--skills`
- `--spec-id`
- `--external-ref`

`bd update [id...]` can apply the same values to multiple issues, but it is not a heterogeneous bulk update format. `bd batch` is not enough for plan enrichment because its `update` grammar only supports `status`, `priority`, `title`, and `assignee`. `bd import` supports `acceptance_criteria`, but does not document support for `context`, `skills`, `spec_id`, or `external_ref`.

Recommendation: provide a small helper script for writing-plans that:

1. Reads an enriched graph JSON file containing the graph-supported fields plus an `enrichment` block per node.
2. Runs `bd create --graph <graph.json>` and captures the `node_key -> bead_id` mapping from stdout.
3. Runs one `bd update <bead-id>` per node needing enrichment, setting `--acceptance`, `--context`, `--skills`, `--spec-id`, and `--external-ref`.
4. Emits a summary mapping node keys to bead IDs and warns on enrichment keys that could not be applied.

This keeps the plan authoring artifact single-source while avoiding a long, error-prone list of manual `bd update` commands in the skill.

## Sources

- Local `bd version`: `bd version 1.0.4 (Homebrew)`.
- Local `bd create --help`: listed graph import support and richer CLI flags.
- Local `bd types`: listed available issue types.
- Local `bd link --help`: listed dependency types.
- Local `bd update --help`: listed supported update fields, including acceptance, context, skills, spec ID, and external ref.
- Local `bd batch --help`: showed batch update only supports status, priority, title, and assignee.
- Local `bd import --help`: documented JSONL import support for `acceptance_criteria`, but not context, skills, spec ID, or external ref.
- Probe commands against this repository's beads database, followed by `bd show --json` and `bd export --all`.
