<p align="center">
  <img src="assets/banner.svg" alt="beads-superpowers — Process discipline and persistent memory for AI coding agents" width="100%" />
</p>

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  <a href=".claude-plugin/plugin.json"><img alt="Plugin version" src="https://img.shields.io/badge/plugin-v0.7.0-4f46e5.svg"></a>
  <a href="https://github.com/DollarDill/beads-superpowers/actions/workflows/release.yml"><img alt="Release" src="https://github.com/DollarDill/beads-superpowers/actions/workflows/release.yml/badge.svg"></a>
  <a href="https://github.com/DollarDill/beads-superpowers/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/DollarDill/beads-superpowers?style=social"></a>
</p>

---

A plugin for Claude Code, Codex, and OpenCode that makes your AI coding agent write tests before code, debug systematically instead of guessing, and remember what it worked on yesterday. 22 skills enforce the practices; a Dolt-backed issue tracker keeps context across sessions.

## How it works

When you start a task, the agent runs **brainstorming** to nail down requirements before touching code, then **writing-plans** to break the work into `bd`-tracked steps that survive session restarts. During implementation it follows **test-driven-development** (failing test first, always) and can fan out to parallel subagents via **subagent-driven-development** — each agent working in its own git worktree. `bd` stores every task, decision, and note in a local Dolt database, so the agent picks up exactly where it left off next session without relying on chat history.

## What's Inside

### Testing

| Skill | What it does |
|-------|-------------|
| `test-driven-development` | RED-GREEN-REFACTOR loop — Iron Law: no implementation without a failing test |
| `verification-before-completion` | Evidence before claims — requires proof before marking anything done |

### Debugging

| Skill | What it does |
|-------|-------------|
| `systematic-debugging` | 4-phase root-cause analysis before proposing any fix |

### Collaboration

| Skill | What it does |
|-------|-------------|
| `requesting-code-review` | Dispatches a code-reviewer subagent with structured criteria |
| `receiving-code-review` | Anti-sycophancy reception — evaluates each finding on its merits |
| `subagent-driven-development` | Fresh agent per task with spec + quality review; parallel batch mode for independent tasks |
| `dispatching-parallel-agents` | Fan-out to 2+ independent agents without shared state |

### Project management

| Skill | What it does |
|-------|-------------|
| `brainstorming` | Socratic design session before any code — produces a spec bead |
| `stress-test` | Adversarial interrogation of plans with recommended answers |
| `writing-plans` | Breaks work into bite-sized tasks, each tracked as a `bd` bead |
| `executing-plans` | Batch plan execution in a single session |
| `using-git-worktrees` | Isolated development branches per task |
| `finishing-a-development-branch` | Merge/PR flow + Land the Plane (close beads, push) |
| `document-release` | Post-ship doc audit — keeps README, CHANGELOG, and ARCHITECTURE in sync |
| `project-init` | Beads/Dolt DB setup, bootstrap, and recovery |
| `getting-up-to-speed` | Session orientation — loads `bd` context and produces a current-state summary |
| `research-driven-development` | Parallel research agents → synthesized knowledge-base document |
| `write-documentation` | Human-quality prose — 14-rule writing system with context-first drafting |

### Meta

| Skill | What it does |
|-------|-------------|
| `using-superpowers` | Bootstrap — injected at session start, routes to the right skill |
| `setup` | Post-install hook configuration (SessionStart + UserPromptSubmit) |
| `writing-skills` | Meta-skill for creating or modifying skills in this plugin |
| `auditing-upstream-drift` | Detects staleness vs upstream superpowers and beads releases |

## Install

### curl (recommended — works with all supported CLIs)

```bash
curl -fsSL https://raw.githubusercontent.com/DollarDill/beads-superpowers/main/install.sh | bash
```

The installer auto-detects which CLIs you have and installs accordingly:

| CLI | What gets installed |
|-----|-------------------|
| Claude Code | Skills to `~/.claude/skills/`, SessionStart + UserPromptSubmit hooks |
| Codex | Skills to `~/.codex/skills/`, enable with `codex_hooks = true` in `~/.codex/config.toml` |
| OpenCode | Skills to `~/.config/opencode/skills/`, native TypeScript plugin to `~/.config/opencode/plugins/` |

Supports `--yes` (skip prompts), `--version X.Y.Z` (pin version), `--dry-run` (preview), `--skip-checksum` (bypass SHA-256 verification), and `--uninstall`.

### Claude Code Marketplace

```bash
claude plugin marketplace add DollarDill/beads-superpowers
claude plugin install beads-superpowers@beads-superpowers-marketplace
```

### Codex CLI Marketplace

```bash
codex plugin marketplace add DollarDill/beads-superpowers
codex plugin install beads-superpowers@beads-superpowers-marketplace
```

After installing, enable hooks in `~/.codex/config.toml`:

```toml
[features]
codex_hooks = true
```

### npx (Vercel Skills CLI)

```bash
npx skills add DollarDill/beads-superpowers -a claude-code -g --copy -y
# npx installs skills only — no hooks. Run the setup skill in your
# chosen agentic terminal to configure the SessionStart and
# UserPromptSubmit hooks.
# Use -a codex to also install for Codex CLI.
```

## First project setup

Initialise beads in your project:

```bash
cd your-project
bd init
```

## Docs

**[dollardill.github.io/beads-superpowers](https://dollardill.github.io/beads-superpowers/)** — getting started, methodology, skills reference, example workflow, and tips.

## Built on

- **[Superpowers](https://github.com/obra/superpowers)** by Jesse Vincent — the skill system and development practices
- **[Beads](https://github.com/gastownhall/beads)** by Steve Yegge — persistent issue tracking with cross-session memory

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Ideas welcome in **[Discussions](https://github.com/DollarDill/beads-superpowers/discussions/27)**.

## License

[MIT](LICENSE)
