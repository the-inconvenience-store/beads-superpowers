#!/usr/bin/env bash
# tests/skills/test-diagnose-script.sh — run: bash tests/skills/test-diagnose-script.sh
set -euo pipefail
SCRIPT="$(cd "$(dirname "$0")/../.." && pwd)/skills/project-init/scripts/diagnose.sh"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" && cd "$TMP"
git init -q . 2>/dev/null || true

# read-only guard: script source must contain no mutating commands
[ -f "$SCRIPT" ] || { echo "FAIL: script missing"; exit 1; }
grep -nE -- '--fix|bd init|--force|dolt push|bd create|bd update|bd close' "$SCRIPT" \
  && { echo "FAIL: mutating command in diagnose.sh"; exit 1; }

# with fake bd: all sections present
cat > "$TMP/bin/bd" <<'FAKE'
#!/usr/bin/env bash
case "$1" in
  version) printf 'bd version 1.1.0\n' ;;
  list)    printf 'ok list row\n' ;;
  vc)      printf 'commit abc123\n' ;;
  dolt)    printf 'origin git+ssh://example\n' ;;
  *) exit 0 ;;
esac
FAKE
chmod +x "$TMP/bin/bd"
mkdir -p .beads && printf 'dolt_mode: embedded\n' > .beads/config.yaml && printf '{}\n' > .beads/metadata.json
out=$(PATH="$TMP/bin:$PATH" bash "$SCRIPT")
for s in versions beads-dir config db dolt-remote; do
  echo "$out" | grep -q "== $s ==" || { echo "FAIL: section $s missing"; exit 1; }
done

# bd absent: visible UNAVAILABLE, still exits 0
out2=$(PATH="/usr/bin:/bin" bash "$SCRIPT")
echo "$out2" | grep -q "UNAVAILABLE" || { echo "FAIL: no UNAVAILABLE hint without bd"; exit 1; }
echo "PASS: diagnose.sh"
