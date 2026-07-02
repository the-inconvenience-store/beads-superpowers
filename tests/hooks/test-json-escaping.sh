#!/usr/bin/env bash
# test-json-escaping.sh — verify session-start escape_for_json produces
# valid JSON when injected content contains double-quotes, backslashes, and real newlines.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fail=0

# Build a temp plugin tree with the hook and a crafted fixture file.
# Layout mirrors production: hooks/ and skills/using-superpowers/ siblings.
tmp=$(mktemp -d)
mkdir -p "$tmp/hooks" "$tmp/skills/using-superpowers"
cp -f "$ROOT/hooks/session-start" "$tmp/hooks/session-start"

# Fixture: contains a double-quote, a backslash, and multiple real newlines.
# All three require escape_for_json to produce valid JSON.
printf 'line one has a "double-quote"\nline two has a backslash \\\nline three is clean\n' \
  > "$tmp/skills/using-superpowers/SKILL.md"

# Run hook and pipe output directly to jq -e . (do NOT echo "$var" | jq — echo mangles \n).
# Generic dialect (no harness env vars) → top-level { "additionalContext": "..." }.
if bash "$tmp/hooks/session-start" 2>/dev/null | jq -e . >/dev/null 2>&1; then
  echo "PASS: escape_for_json — output is valid JSON with quotes, backslashes, and newlines in content"
else
  echo "FAIL: escape_for_json — output is NOT valid JSON"
  echo "--- raw hook output ---"
  bash "$tmp/hooks/session-start" 2>/dev/null || true
  echo "--- end ---"
  fail=1
fi

rm -rf "$tmp"
exit $fail
