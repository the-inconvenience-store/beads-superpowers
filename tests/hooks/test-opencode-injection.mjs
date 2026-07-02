#!/usr/bin/env node
// test-opencode-injection.mjs — hermetic plugin test (ADR-0039 + bead 3ogl.13).
// HOME is a temp fixture; resolution never touches the real machine.
// Per-turn injection must be GONE.
//
// Run with:
//   npx tsx tests/hooks/test-opencode-injection.mjs
//   node --experimental-strip-types tests/hooks/test-opencode-injection.mjs  (Node >=22.6)
//
// Requires tsx or Node >=22.6 with --experimental-strip-types for .ts imports.
// Loud-skips (exit 0 + warning) if neither is available — never silently passes.

import assert from "node:assert"
import { fileURLToPath } from "node:url"
import { dirname, join } from "node:path"
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from "node:fs"
import { tmpdir } from "node:os"

const __dirname = dirname(fileURLToPath(import.meta.url))
const pluginPath = join(__dirname, "../../opencode/beads-superpowers-plugin.ts")

const fixtureHome = mkdtempSync(join(tmpdir(), "bsp-oc-test-"))
const skillDir = join(fixtureHome, ".claude/skills/using-superpowers")
mkdirSync(skillDir, { recursive: true })
writeFileSync(join(skillDir, "SKILL.md"), "# fixture skill\nEXTREMELY_IMPORTANT fixture body\n")
// Co-located reminder-content.txt so the pre-removal plugin has something to inject on
// message 2 — without this the old else-if branch is unreachable (empty reminder) and
// Test 2 would false-positive-pass before the fix, proving nothing (root-caused via
// systematic-debugging before writing this fixture line).
writeFileSync(join(skillDir, "reminder-content.txt"), "SUPERPOWERS REMINDER: fixture reminder body\n")
process.env.HOME = fixtureHome
process.env.PATH = "/nonexistent" // bd absent → bdPrime() returns ""

let BeadsSuperpowers
try {
  const mod = await import(pluginPath)
  BeadsSuperpowers = mod.BeadsSuperpowers
} catch (e) {
  const msg = String(e)
  if (
    e.code === "ERR_UNKNOWN_FILE_EXTENSION" ||
    msg.includes("Unknown file extension") ||
    msg.includes("unknown file extension")
  ) {
    console.warn("SKIP: TypeScript runner unavailable.")
    console.warn("  Install tsx:   npm install -g tsx")
    console.warn("  Or use Node >= 22.6 with:  node --experimental-strip-types <file>")
    process.exit(0)
  }
  throw e
}

if (typeof BeadsSuperpowers !== "function") {
  console.error("FAIL: BeadsSuperpowers is not exported as a function from the plugin")
  process.exit(1)
}

const hooks = await BeadsSuperpowers()

// Test 1: first message injects the bootstrap
const p1 = { message: {}, parts: [] }
await hooks["chat.message"]({ sessionID: "s1" }, p1)
assert.strictEqual(p1.parts.length, 1, "first message injects exactly one part")
assert.ok(p1.parts[0].text.includes("EXTREMELY_IMPORTANT"), "bootstrap contains skill body")

// Test 2: second message injects NOTHING (per-turn reminder removed, ADR-0039)
const p2 = { message: {}, parts: [] }
await hooks["chat.message"]({ sessionID: "s1" }, p2)
assert.strictEqual(p2.parts.length, 0, "subsequent messages inject nothing")

// Test 3: compaction pushes context
const c = { context: [] }
await hooks["experimental.session.compacting"]({ sessionID: "s1" }, c)
assert.strictEqual(c.context.length, 1, "compaction pushes one context entry")
assert.ok(c.context[0].includes("beads-superpowers is installed"), "compaction pointer present")

// Test 4: skill-not-found HOME → hint injected on first message.
// No re-import needed: BeadsSuperpowers reads process.env.HOME at CONSTRUCTION
// (each `await BeadsSuperpowers()` call), so re-invoke the same import.
const emptyHome = mkdtempSync(join(tmpdir(), "bsp-oc-empty-"))
process.env.HOME = emptyHome
const hooks2 = await BeadsSuperpowers()
const p3 = { message: {}, parts: [] }
await hooks2["chat.message"]({ sessionID: "s2" }, p3)
assert.ok(p3.parts[0].text.includes("not found"), "notFoundHint injected when skill missing")

rmSync(fixtureHome, { recursive: true, force: true })
rmSync(emptyHome, { recursive: true, force: true })
console.log("PASS: opencode plugin — bootstrap once, no per-turn, compaction OK, not-found hint OK")
