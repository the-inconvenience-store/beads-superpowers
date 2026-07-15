#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECKER="$ROOT/scripts/check-policy-ownership.sh"
OWNER="$ROOT/skills/using-superpowers/references/session-policy.md"
EXPECTED="$ROOT/tests/fixtures/policy-ownership/expected-callers.txt"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for heading in "Capture Gate" "Durable Memory" "Beads Read/Write Economy" "Claim Boundary" "Session Completion"; do
  grep -Fq "## $heading" "$OWNER" || { echo "FAIL: owner missing $heading" >&2; exit 1; }
done
grep -Fq 'references/session-policy.md' "$ROOT/skills/using-superpowers/SKILL.md"
grep -Fq 'session-policy.md' "$ROOT/skills/using-superpowers/references/bootstrap-policy.md"

bash "$CHECKER" --enforce
bash "$CHECKER" --report >"$TMP/report.txt"
cmp "$EXPECTED" "$TMP/report.txt" || { diff -u "$EXPECTED" "$TMP/report.txt"; exit 1; }
LC_ALL=C sort -c "$TMP/report.txt"
awk -F '\t' 'NF != 4 || $1 !~ /^(capture|memory|economy|completion)$/ || $3 !~ /^[0-9]+$/ || $4 != "pointer" {exit 1}' "$TMP/report.txt"

if rg -l 'After the work is settled, present the Capture gate|\*\*Capture what you learned\.\*\*|> \*\*bd frugality: bounded output, one round trip\.\*\*' \
  "$ROOT/skills" --glob '*.md' | grep -Fvx "$OWNER"; then
  echo "FAIL: copied workflow policy remains outside the owner" >&2
  exit 1
fi

if rg -l '`bd close` → `bd dolt push` → `git pull --rebase && git push` → `git status`' \
  "$ROOT/skills" "$ROOT/CLAUDE.md" --glob '*.md' | grep -Fvx "$OWNER"; then
  echo "FAIL: copied completion policy remains outside the owner" >&2
  exit 1
fi

bash "$CHECKER" --self-test | grep -Fq "policy-ownership self-test: PASS"
test ! -e "$ROOT/scripts/check-convention-sync.sh"
! grep -Fq 'check-convention-sync.sh' "$ROOT/scripts/run-guards.sh"
grep -Fq 'check-policy-ownership.sh --enforce' "$ROOT/scripts/run-guards.sh"

echo "PASS: canonical workflow policy ownership"
