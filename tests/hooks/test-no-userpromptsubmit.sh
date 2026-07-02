#!/usr/bin/env bash
# test-no-userpromptsubmit.sh — ADR-0039: per-prompt injection must never return.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
fail=0
for f in hooks/hooks.json hooks/codex-hooks.json; do
  if grep -q "UserPromptSubmit" "$ROOT/$f"; then
    echo "FAIL: UserPromptSubmit registered in $f"; fail=1
  fi
done
if [ -f "$ROOT/hooks/superpowers-reminder.sh" ]; then
  echo "FAIL: hooks/superpowers-reminder.sh still exists"; fail=1
fi
[ "$fail" = 0 ] && echo "PASS: no per-prompt hook surface in hooks/"
exit "$fail"
