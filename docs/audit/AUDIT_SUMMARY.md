# Component Audit Summary

## Status: In Progress

**PRD**: `.taskmaster/docs/prd_component_audit.txt`
**Tag**: `component-audit` (pending parse)
**Branch**: `feature/superpowers-v5-alignment`

## Decision Framework

| Verdict | Meaning | Burden |
|---------|---------|--------|
| **Adopt** | Copy ECC's code + adapt (env vars, paths) | Default — upstream is presumed better |
| **Adapt** | Start from ECC's code, merge our improvements | Must document what we add and why |
| **Keep** | Our version is genuinely better | Must document specific technical reason |
| **New** | We have something they don't | Document as our contribution |
| **Skip** | They have something we don't need | Document why |

## Phase Progress

| Phase | Status | Decisions Made | Session |
|-------|--------|---------------|---------|
| 1: Hooks + Libraries | **Complete** | 2 Adopt, 6 Adapt, 4 Keep, 5 New, 3 Skip | 2026-03-19 |
| 2: Skills + Commands | **Complete** | 17 Adopt (skills), 10 Adopt + 1 Adapt (commands), 16 Keep (skills), 15 Keep (commands), 7 New (skills), 22 New (commands), ~93 Skip | 2026-03-19 |
| 3: Agents + Rules | **Complete** | 4 Adopt, 9 Adapt (agents), 3 Adapt (rules), 11 Keep (rules), 1 New (agents), 8 New (rules), 12 Skip | 2026-03-19 |
| 4: Scripts + Infra | **Complete** | 4 Adopt, 3 Adapt, 8 New, 22 Skip, 7 Defer | 2026-03-19 |
| 4b: Superpowers | **Complete** | Integration audit — all 4 overrides confirmed necessary, 14/14 skills aligned | 2026-03-19 |
| 5: Execution | Not started | — | — |
| 6: Reassessment | Not started | — | — |

### Phase 1 Key Findings
- **Transcript reading** (ECC's session-end.js) is architecturally superior to our git-only approach — adopt
- **Auto-tmux** (ECC's auto-tmux-dev.js) is strictly better than block-and-ask — adopt pattern
- **Two-hook strategies** (per-edit + session-sweep) catch more issues than single hooks — adopt for console-log, format
- **Our unique hooks** (protect-sensitive-files, project-index, pattern-extraction, observe, pre-commit-check) fill genuine ECC gaps
- **Our polyglot coverage** (Python, Go, Java, Ruby, Rust, Shell) exceeds ECC's JS/TS focus — preserve in all adaptations
- **ECC stubs**: build-analysis and git-push-reminder are empty/placeholder — skip
- **Bug found**: doc-file-blocker.sh missing MEMORY.md in allowed files

### Phase 4 Key Findings (Scripts + Infra)
- **CI validators are ECC's best infrastructure innovation**: 8 validators, 4 directly portable (agents, skills, rules, commands — 351 lines total). We have 0 CI validation for template artifacts.
- **Our scripts are a genuine differentiator**: 8/10 scripts have no ECC equivalent (project scaffolding, upstream tracking, template syncing, MCP management, plugin management)
- **harness-audit.js is the most generalizable ECC script**: Weighted scoring engine with 7 categories, normalized 0-10 scores, actionable fix suggestions. Defer to v2.5.0 Task 11.
- **13 unused hook events**: ECC's hooks.schema.json reveals 18 events; we use 5. PreCompact, TaskCompleted, SubagentStart/Stop, SessionEnd worth evaluating.
- **ECC's install system is their overhead**: 5 scripts + 5 schemas for multi-platform distribution. Irrelevant to our single-target template.

### Phase 4b Key Findings (Superpowers Integration)
- **All 4 overrides remain necessary**: Brainstorming exit → PRD pipeline, writing-plans scoped to single-task, infrastructure TDD exemption, authority hierarchy
- **No new conflicts in v5.0.2**: Document review system, visual brainstorming, and specs/plans restructure are additive
- **Two code-reviewer agents coexist**: Superpowers' (model: inherit) for SDD, ours (model: sonnet) for ad-hoc reviews — different triggers, no collision
- **CSO insight is transferable**: Skill descriptions should contain ONLY triggering conditions, never workflow summaries. Claude follows description summaries instead of reading full content.
- **Spec reviewer skepticism pattern is excellent**: "The implementer finished suspiciously quickly" framing catches optimistic self-reports

## Completed Adoptions

| Our File | ECC Source | Verdict | Commit |
|----------|-----------|---------|--------|
| .claude/hooks/lib/hook-flags.js | scripts/lib/hook-flags.js | Adopt | f9963ad |
| .claude/hooks/lib/run-with-flags.js | scripts/hooks/run-with-flags.js | Adopt | f9963ad |
| .claude/hooks/lib/run-with-flags-shell.sh | scripts/hooks/run-with-flags-shell.sh | Adapt | f9963ad |
| .claude/hooks/lib/check-hook-enabled.js | scripts/hooks/check-hook-enabled.js | Adopt | f9963ad |

### Adaptations in f9963ad
- `ECC_HOOK_PROFILE` → `TEMPLATE_HOOK_PROFILE`
- `ECC_DISABLED_HOOKS` → `TEMPLATE_DISABLED_HOOKS`
- `CLAUDE_PLUGIN_ROOT` → `CLAUDE_PROJECT_DIR`
- `set -euo pipefail` → `set +e` (bash resilience, learned from hook failures)
- Added extra arg passthrough in shell wrapper (for observe.sh pre/post)
- Path resolution: 3 levels up from `.claude/hooks/lib/` (vs 2 for ECC's `scripts/hooks/`)
