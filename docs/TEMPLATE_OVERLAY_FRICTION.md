# Template Overlay Friction Log

Records friction, conflicts, and observations from overlaying the project template onto real codebases. Updated after each test to track patterns and guide improvements.

## Test 1: analog_image_generator

| Field | Value |
|-------|-------|
| **Date** | 2026-02-19 |
| **Project** | Analog Image Generator (Python 3.10+, numpy/scipy/matplotlib, Jupyter notebooks) |
| **Tester** | Claude Code (Opus 4.6) |
| **Result** | **PASS 7/7** — zero conflicts |

### What Was Tested

| # | Area | Status | Notes |
|---|------|--------|-------|
| 1 | Rules loaded | PASS | 7 core + 5 language-specific rules on disk; all 7 core confirmed in system context |
| 2 | Commands available | PASS | Template commands (`/health`, `/commit`, etc.) + project commands (`/demo`, `/smoke`, `/preview`, `/validate-anchors`) all registered |
| 3 | CLAUDE.md parsed | PASS | Project identity, tech stack, domain knowledge, Taskmaster tags, and Definition of Done all intact after merge |
| 4 | Agents visible | PASS | 13/13 agents defined; `python-reviewer` spawn test succeeded on `utils.py` (returned 5 findings) |
| 5 | Skills available | PASS | `/code-review`, `/debugging`, `/python-data-science` all accessible |
| 6 | Hooks inventory | PASS | 18 hook scripts + settings example; README comprehensive |
| 7 | Contexts | PASS | `dev.md`, `review.md`, `research.md` all present and valid |

### Friction Found

**None.** Template infrastructure (`.claude/rules/`, `.claude/agents/`, `.claude/hooks/`, `.claude/contexts/`) merged cleanly alongside project-specific content (custom CLAUDE.md sections, `scripts/`, Taskmaster tags, domain knowledge).

### Observations (Not Friction)

1. **Hooks opt-in gap**: No `.claude/settings.json` found — hooks are defined on disk but not wired. This is *by design* (hooks activate via `/settings safe` or manual copy of `settings-example.json`), but new users may not realize hooks exist without explicitly opting in. Consider whether the setup wizard (`/setup`) should prompt for hook activation.

### Lessons for Future Tests

- Project-specific commands (`/demo`, `/smoke`, etc.) coexist with template commands without namespace collision — the flat `.claude/commands/` directory works.
- A project with heavy domain knowledge in CLAUDE.md (geologic rules, variogram formulas) did not interfere with template instructions — section-based merging is robust.
- Language-specific rules (`python/coding-standards.md`) loaded correctly via `paths:` frontmatter targeting `.py` files.

---

## Friction Pattern Tracker

Tracks recurring themes across multiple tests. Update counts as new tests are added.

| Pattern | Occurrences | Severity | Status |
|---------|-------------|----------|--------|
| Hooks not auto-wired | 1/1 | Low (by design) | Monitor |
| Command namespace collision | 0/1 | — | No issue |
| CLAUDE.md section conflicts | 0/1 | — | No issue |
| Rule loading failures | 0/1 | — | No issue |
| Agent spawn failures | 0/1 | — | No issue |

---

*Add new test sections above the Friction Pattern Tracker. Update the tracker after each test.*
