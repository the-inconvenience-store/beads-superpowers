#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECKER="$ROOT/scripts/check-policy-ownership.sh"
OWNER="$ROOT/skills/using-superpowers/references/session-policy.md"
EXPECTED="$ROOT/tests/fixtures/policy-ownership/expected-callers.txt"
CONVENTIONS="$ROOT/scripts/check-convention-sync.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for heading in "Capture Gate" "Durable Memory" "Beads Read/Write Economy" "Claim Boundary" "Session Completion"; do
  grep -Fq "## $heading" "$OWNER" || { echo "FAIL: owner missing $heading" >&2; exit 1; }
done
grep -Fq 'references/session-policy.md' "$ROOT/skills/using-superpowers/SKILL.md"
grep -Fq 'session-policy.md' "$ROOT/skills/using-superpowers/references/bootstrap-policy.md"

bash "$CHECKER" --report >"$TMP/report.txt"
cmp "$EXPECTED" "$TMP/report.txt" || { diff -u "$EXPECTED" "$TMP/report.txt"; exit 1; }
LC_ALL=C sort -c "$TMP/report.txt"
awk -F '\t' 'NF != 4 || $1 !~ /^(capture|memory|economy|completion)$/ || $3 !~ /^[0-9]+$/ || $4 != "legacy-copy" {exit 1}' "$TMP/report.txt"

python3 - "$CONVENTIONS" "$TMP/report.txt" <<'PY'
import re, sys
from pathlib import Path
source=Path(sys.argv[1]).read_text()
report={tuple(line.split("\t")[:2]) for line in Path(sys.argv[2]).read_text().splitlines()}
mapping={"CB3_SITES":"capture","CB4_SITES":"memory","CB5_SITES":"economy","LTP_SITES":"completion"}
declared=set()
for array, policy in mapping.items():
    match=re.search(rf"{array}=\(\n(.*?)\n\)", source, re.S)
    assert match, array
    for raw in match.group(1).splitlines():
        path=raw.strip()
        if path:
            declared.add((policy,path))
assert report == declared, (sorted(report-declared), sorted(declared-report))
PY

bash "$CHECKER" --self-test | grep -Fq "policy-ownership self-test: PASS"
bash "$CONVENTIONS"

echo "PASS: canonical workflow policy ownership"
