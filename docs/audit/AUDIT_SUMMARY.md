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
| 1: Hooks | **Complete** | 2 Adopt, 6 Adapt, 4 Keep, 5 New, 3 Skip | 2026-03-19 |
| 2: Skills + Commands | Not started | — | — |
| 3: Agents + Rules | Not started | — | — |
| 4: Scripts + Infra | Not started | — | — |
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
