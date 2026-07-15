#!/usr/bin/env bash
# Report declared legacy policy callers and prove one canonical semantic owner.
set -uo pipefail

ROOT="${POLICY_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
OWNER="skills/using-superpowers/references/session-policy.md"
CONVENTIONS="scripts/check-convention-sync.sh"
LTP='`bd close` → `bd dolt push` → `git pull --rebase && git push` → `git status`'

array_members() {
  local file="$1" array="$2"
  awk -v target="$array=(" '
    $0 == target { inside=1; next }
    inside && $0 == ")" { exit }
    inside { gsub(/^[[:space:]]+|[[:space:]]+$/, ""); if (length) print }
  ' "$file"
}

signature_for() {
  case "$1" in
    capture) printf '%s\n' 'After the work is settled, present the Capture gate' ;;
    memory) printf '%s\n' '**Capture what you learned.**' ;;
    economy) printf '%s\n' '> **bd frugality: bounded output, one round trip.**' ;;
    completion) printf '%s\n' "$LTP" ;;
  esac
}

array_for() {
  case "$1" in
    capture) printf '%s\n' CB3_SITES ;;
    memory) printf '%s\n' CB4_SITES ;;
    economy) printf '%s\n' CB5_SITES ;;
    completion) printf '%s\n' LTP_SITES ;;
  esac
}

audit() {
  local root="$1" report="$2" tmp fail=0 policy array signature path file count line rel
  tmp="$(mktemp -d)"
  : >"$tmp/report"
  : >"$tmp/declared"
  : >"$tmp/errors"

  if [ ! -f "$root/$OWNER" ]; then
    echo "owner: missing $OWNER" >>"$tmp/errors"; fail=1
  else
    for heading in "Capture Gate" "Durable Memory" "Beads Read/Write Economy" "Claim Boundary" "Session Completion"; do
      count=$(grep -Fc -- "## $heading" "$root/$OWNER" || true)
      if [ "$count" -ne 1 ]; then
        echo "owner: heading '$heading' must appear exactly once" >>"$tmp/errors"; fail=1
      fi
    done
    count=$(grep -Fc -- "$LTP" "$root/$OWNER" || true)
    if [ "$count" -ne 1 ]; then
      echo "owner: conflicting completion sequence (expected exactly one canonical sequence)" >>"$tmp/errors"; fail=1
    fi
  fi

  if [ ! -f "$root/$CONVENTIONS" ]; then
    echo "inventory: missing $CONVENTIONS" >>"$tmp/errors"; fail=1
  else
    for policy in capture memory economy completion; do
      array="$(array_for "$policy")"
      signature="$(signature_for "$policy")"
      array_members "$root/$CONVENTIONS" "$array" >"$tmp/members"
      if [ ! -s "$tmp/members" ]; then
        echo "inventory: $array has no callers" >>"$tmp/errors"; fail=1
      fi
      while IFS= read -r path; do
        printf '%s\t%s\n' "$policy" "$path" >>"$tmp/declared"
        file="$root/$path"
        if [ ! -f "$file" ]; then
          echo "$policy: unclassified caller missing file $path" >>"$tmp/errors"; fail=1
          continue
        fi
        count=$(grep -Fc -- "$signature" "$file" || true)
        if [ "$count" -ne 1 ]; then
          echo "$policy: unclassified caller $path has $count matching signatures" >>"$tmp/errors"; fail=1
          continue
        fi
        line=$(grep -nF -- "$signature" "$file" | head -1 | cut -d: -f1)
        printf '%s\t%s\t%s\tlegacy-copy\n' "$policy" "$path" "$line" >>"$tmp/report"
      done <"$tmp/members"

      {
        find "$root/skills" -type f -name '*.md' -print
        [ -f "$root/CLAUDE.md" ] && printf '%s\n' "$root/CLAUDE.md"
      } | LC_ALL=C sort >"$tmp/markdown-files"
      while IFS= read -r file; do
        rel="${file#"$root/"}"
        [ "$rel" = "$OWNER" ] && continue
        if grep -Fq -- "$signature" "$file" && ! grep -Fq -- "$policy	$rel" "$tmp/declared"; then
          echo "$policy: unknown copy signature in $rel" >>"$tmp/errors"; fail=1
        fi
      done <"$tmp/markdown-files"
    done
  fi

  LC_ALL=C sort "$tmp/report" >"$report"
  if [ "$fail" -ne 0 ]; then
    LC_ALL=C sort -u "$tmp/errors" >&2
  fi
  rm -rf "$tmp"
  return "$fail"
}

copy_fixture() {
  local destination="$1"
  mkdir -p "$destination/scripts"
  cp -Rf "$ROOT/skills" "$destination/skills"
  cp -f "$ROOT/CLAUDE.md" "$destination/CLAUDE.md"
  cp -f "$ROOT/$CONVENTIONS" "$destination/$CONVENTIONS"
}

self_test() {
  local tmp case_root failures=0
  tmp="$(mktemp -d)"

  case_root="$tmp/base"; copy_fixture "$case_root"
  audit "$case_root" "$tmp/base-report" >/dev/null 2>&1 || failures=$((failures + 1))

  case_root="$tmp/missing-heading"; copy_fixture "$case_root"
  awk '$0 != "## Durable Memory"' "$case_root/$OWNER" >"$tmp/owner" && mv -f "$tmp/owner" "$case_root/$OWNER"
  audit "$case_root" "$tmp/missing-report" >/dev/null 2>&1 && failures=$((failures + 1))

  case_root="$tmp/unknown-copy"; copy_fixture "$case_root"
  mkdir -p "$case_root/skills/unknown"
  printf '%s\n' '**Capture what you learned.**' >"$case_root/skills/unknown/SKILL.md"
  audit "$case_root" "$tmp/unknown-report" >/dev/null 2>&1 && failures=$((failures + 1))

  case_root="$tmp/unclassified"; copy_fixture "$case_root"
  awk 'index($0, "> **bd frugality: bounded output, one round trip.**") == 0' \
    "$case_root/skills/subagent-driven-development/SKILL.md" >"$tmp/caller" && \
    mv -f "$tmp/caller" "$case_root/skills/subagent-driven-development/SKILL.md"
  audit "$case_root" "$tmp/unclassified-report" >/dev/null 2>&1 && failures=$((failures + 1))

  case_root="$tmp/conflicting-completion"; copy_fixture "$case_root"
  grep -vF -- "$LTP" "$case_root/$OWNER" >"$tmp/completion" && mv -f "$tmp/completion" "$case_root/$OWNER"
  printf '%s\n' 'git push → bd dolt push → bd close → git status' >>"$case_root/$OWNER"
  audit "$case_root" "$tmp/completion-report" >/dev/null 2>&1 && failures=$((failures + 1))

  rm -rf "$tmp"
  if [ "$failures" -ne 0 ]; then
    echo "policy-ownership self-test: FAIL ($failures mutation checks)" >&2
    return 1
  fi
  echo "policy-ownership self-test: PASS"
}

case "${1:-}" in
  --report)
    output="$(mktemp)"
    if audit "$ROOT" "$output"; then cat "$output"; rc=0; else rc=1; fi
    rm -f "$output"
    exit "$rc"
    ;;
  --self-test) self_test ;;
  *) echo "usage: $0 --report | --self-test" >&2; exit 2 ;;
esac
