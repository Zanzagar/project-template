# Dogfood Test History & Comparative Analysis

This document tracks every dogfood test of the project template, comparing what was tested, what broke, and how the template improved. Use it alongside `DOGFOOD_CHECKLIST.md` to assess whether template changes actually improve the workflow.

---

## Test Registry

| # | Project | Date | Template Version | Duration | Phases Tested | Tasks Done | Key Discovery |
|---|---------|------|-----------------|----------|---------------|------------|---------------|
| 1 | rideshare-rescue | 2025-12-01–03 | pre-v1 (no version) | 3 sessions | Build only | 10/30 | Template can support full-stack apps |
| 2 | analog_image_generator (test-projects/) | ~2025-12 | early | setup only | Ideation, Planning | 0/30 | Complexity analysis + --research flag |
| 3a | postiz (test-projects/) | 2026-02-19–20 | ~v2.2 | 3 sessions | Ideation → partial Build | 1/22 | 18 friction items, MCP/CLI split |
| 3b | ISKCON-GN/postiz_social_automation | 2026-02-18–20 | ~v2.3 | 2-day sprint | Build + Review | ~5 features | TDD works, orchestration works, instincts work |
| 3c | ISKCON-GN/gita_valley_digital_ops | ~2025-11–12 | early | multi-month | Planning + Build | 8+ tasks | Full PRD→TM pipeline, deployment stalled |
| 4 | **postiz-social-automation (NEW)** | 2026-02-23+ | **v2.3.1** | TBD | **Full workflow** | TBD | TBD |

---

## Test 1: Rideshare Rescue (Dec 2025)

**Context**: Earliest real-world usage. Full-stack FastAPI + Next.js rideshare platform. Template was pre-release — no version tags, no hooks, no Superpowers.

### What Was Tested

| Phase | Tested? | Evidence |
|-------|---------|----------|
| Bootstrap/Setup | Partial | CLAUDE.md created, Task Master init'd, 5 commands + 3 skills created manually |
| Session Start | No | No hooks existed yet |
| Ideation | Partial | PRD written manually (docs/PRD.md), no brainstorming skill |
| Planning | Partial | 30 tasks created (likely manually, not parsed from PRD) |
| Complexity Analysis | No | No analyze-complexity or expand evidence |
| Implementation | Yes | 13 models, 12 endpoints, 8 services, 20 React components |
| TDD | No | Tests exist but no RED-GREEN-REFACTOR evidence |
| Review | Partial | ESLint + ruff configured but no /code-review invocation |
| Branch Completion | No | All 12 commits directly to main, no PRs |

### What Was NOT Tested (0% coverage)

- Hooks (none existed)
- Rules auto-loading (rules/ not created)
- Superpowers (not invented yet)
- Per-phase tags (single `master` tag)
- Session persistence (no handoff docs)
- Continuous learning (no instincts)
- GitHub integration (no PRs)
- Branch workflow (direct to main)

### Quality Assessment

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Code output quality | High | Full-stack MVP with type safety, async, proper auth |
| Workflow compliance | Low | No TDD, no branches, no PRs, no tags |
| Template coverage | ~15% | Only CLAUDE.md, Task Master, commits tested |
| Reproducibility | Low | No session artifacts, manual work log only |

### Key Insights

- Template provided structure (CLAUDE.md, Task Master) but workflow was ad-hoc
- Conventional commits worked from day one — this feature is stable
- Feature velocity was high (6 MVP features in 3 sessions) but no quality gates
- **Lesson**: Code gets written regardless of template — the value is in the workflow discipline, which wasn't enforced

---

## Test 2: Analog Image Generator — test-projects/ (~Dec 2025)

**Context**: Physics-based geological image generator. Deep domain modeling with research papers. Template used for planning only — no code was committed.

### What Was Tested

| Phase | Tested? | Evidence |
|-------|---------|----------|
| Bootstrap/Setup | Yes | Full .claude/ structure (13 agents, 70+ commands, 48+ skills, 18 hooks, 13 rules) |
| Session Start | No | No git commits → hooks likely never fired |
| Ideation | Yes | 5 PRDs (fluvial, aeolian, estuarine variants) |
| Planning | Yes | parse-prd → analyze-complexity → expand full pipeline |
| Complexity Analysis | Yes | 6 complexity reports, scores 3-8 |
| Implementation | No | 6.5k LOC exists but 0 git commits — written outside template workflow |
| TDD | No | 1.8k test LOC but no test-first evidence |
| Review | No | No /code-review artifacts |
| Branch Completion | No | No git history at all |

### What Was NOT Tested (0% coverage)

- Git workflow entirely (zero commits)
- Superpowers TDD enforcement
- Any hook firing (no commits = no PreToolUse triggers in practice)
- Session persistence
- Code review / security audit
- Branch completion / PRs

### Quality Assessment

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Planning quality | Very High | 5 PRDs, 6 complexity reports, 30+ tasks with subtasks |
| Code output quality | High | 6.5k LOC with physics-based constraints, 1.8k test LOC |
| Workflow compliance | Very Low | Zero commits, no TDD cycle, no reviews |
| Template coverage | ~25% | Setup + planning pipeline only |
| Reproducibility | Low | No session artifacts, no git history |

### Key Insights

- Planning pipeline (PRD → parse → complexity → expand) works end-to-end
- Discovered `--research` flag improves subtask quality — first workflow optimization
- Complexity scoring threshold (>= 5 → expand) validated as useful
- **Lesson**: Planning without execution tells you nothing about build-phase workflow quality

---

## Test 3: Postiz Social Automation — test-projects/ (Feb 2026)

**Context**: Most thorough dogfood test before v2.3.1. Social media automation for a real client. 3 sessions over 2 days. Explicitly designed as a template audit.

### What Was Tested

| Phase | Tested? | Evidence |
|-------|---------|----------|
| Bootstrap/Setup | Yes | Symlinks to template, settings.local.json, Task Master configured |
| Session Start | No | Hooks not enabled in settings.local.json |
| Ideation | Yes | Brainstorming skill invoked → design doc saved |
| Planning | Yes | PRD → parse-prd → tag created → 22 tasks generated |
| Complexity Analysis | Partial | analyze-complexity skipped initially, expand --all used blindly |
| Implementation | Partial | 1 of 22 tasks done (config), 1 subtask of another (branding code) |
| TDD | Yes (1 task) | RED → GREEN → REFACTOR on branding checker: 14 tests, 100% pass |
| Review | No | Not reached |
| Branch Completion | No | Not reached |

### What Was NOT Tested (0% coverage)

- Hooks (none enabled)
- Session persistence (no session artifacts)
- Code review pipeline
- Branch completion sequence
- CI verification
- GitHub integration (PRs)
- Execution readiness check (didn't exist yet)

### Friction Items Discovered (18 total)

| Severity | Count | Examples |
|----------|-------|---------|
| HIGH | 5 | MCP/CLI incompatibility, TDD mismatch for infra tasks, no context monitoring, expand without complexity analysis, zero commits in session 1 |
| MEDIUM | 7 | Subtask status overhead, task IDs don't reset, brainstorming skips tag creation, Superpowers needs session restart |
| LOW | 6 | /health not registered, scripts/ not symlinked, pytest rootdir inherited |

### Quality Assessment

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Planning quality | High | Good PRD, proper tag, tasks generated |
| Code output quality | High (limited) | Branding checker is well-tested, 100% coverage |
| Workflow compliance | Medium | TDD worked for code tasks; many steps skipped due to infra-heavy project |
| Template coverage | ~35% | Best coverage so far but still gaps in review/shipping |
| Reproducibility | Medium | Friction log serves as session record, but no formal session artifacts |

### Key Insights

- **Brainstorming exit override broken** — routed to writing-plans instead of PRD (fixed by creating `superpowers-integration.md` rule)
- **Task Master CLI vs MCP split** is confusing — AI ops MUST use CLI, data ops can use MCP
- **TDD doesn't apply to infrastructure tasks** — 80% of postiz tasks are Docker/API config, not code
- **Context monitoring was disabled** — hit 94% context with zero warning
- **Friction logging is invaluable** — 18 items led directly to v2.3.0 and v2.3.1 improvements
- **Lesson**: First test that drove systematic template improvements

---

## Test 3b: ISKCON-GN/postiz_social_automation (Feb 2026)

**Context**: The "real" postiz deployment — a health monitoring system for the Postiz Docker stack, inside the ISKCON-GN monorepo. 2-day sprint (Feb 18-20). Most template-compliant test to date.

### What Was Tested

| Phase | Tested? | Evidence |
|-------|---------|----------|
| Bootstrap/Setup | Yes | Full template structure: 59 commands, 44 skills, 13 agents, 11 rules, 18 hooks |
| Session Start | Partial | Hooks configured, session-end fired (1 session artifact exists) |
| Ideation | Yes | Brainstorming artifacts present |
| Planning | No | tasks.json is empty — jumped straight to building |
| Complexity Analysis | No | No reports generated |
| Implementation | Yes | 19 commits, 5 feature modules, TDD-first evidence |
| TDD | Yes | 66+ tests in health_alerter alone, test commits precede feat commits |
| Review | Yes | `/orchestrate review` pipeline executed, REPORT.md generated |
| Branch Completion | No | All commits to main, no feature branches, no PRs |
| Session Lifecycle | Partial | 1 session artifact, 5 instincts extracted, eval harness configured |

### What Was NOT Tested (0% coverage)

- PRD → Task Master pipeline (tasks.json empty — skipped planning entirely)
- Feature branches (all 19 commits to main)
- Branch completion workflow (no PRs, no merge strategy)
- Complexity analysis / guided expansion
- Tag management (Task Master initialized but unused)

### Quality Assessment

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Code output quality | High | 5 feature modules with comprehensive tests (66+ tests) |
| Workflow compliance | Medium | TDD + conventional commits strong; planning + branches skipped |
| Template coverage | ~40% | Best build-phase coverage, but skipped planning and shipping |
| Reproducibility | Medium | Session artifact + instincts provide some continuity |

### Key Insights

- **TDD works when the project is code-centric** — health monitor is pure Python, every module testable
- **Orchestration pipeline validated** — `/orchestrate review` produced multi-agent review report
- **Continuous learning hooks work** — 5 instinct candidates extracted and persisted automatically
- **Planning was skipped entirely** — Task Master initialized but never populated (tasks.json empty)
- **Lesson**: When developers are eager to build, the planning phase gets skipped unless enforced. The template's planning rules are normative (no hook enforcement) — and normative rules get ignored under time pressure.

---

## Test 3c: ISKCON-GN/gita_valley_digital_ops (~Nov-Dec 2025)

**Context**: Donor acknowledgment automation for the ISKCON Gita Valley temple. Multi-month project. Full planning pipeline but building phase partially stalled.

### What Was Tested

| Phase | Tested? | Evidence |
|-------|---------|----------|
| Bootstrap/Setup | Minimal | Only settings.local.json — no commands/skills/hooks/agents |
| Planning | Yes | 4 PRDs, 4 complexity reports, 4 Task Master tags, 100+ tasks |
| Complexity Analysis | Yes | Full analyze-complexity → complexity-report pipeline |
| Implementation | Yes | 30+ tests, donor automation core complete |
| Branch Completion | No | 2 monolithic commits to main |

### Quality Assessment

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Planning quality | Very High | 4 PRDs with phased complexity, full TM pipeline |
| Code quality | High | 30+ tests, repository pattern, multi-channel support |
| Workflow compliance | Low | Non-conventional commits, no branches, monolithic commits |
| Template coverage | ~30% | Strong planning, weak execution discipline |

### Key Insights

- **Full PRD → Task Master → complexity → expand pipeline validated** at scale (100+ tasks across 4 tags)
- **Deployment phase stalled** by external dependency (temple hosting decision)
- **Lesson**: Planning pipeline scales well to multi-phase projects with phased PRDs

---

## Comparative Coverage Matrix

This matrix shows which template features were exercised in each test. The new test (Test 4) checklist items are mapped to show expected improvement.

### Phase Coverage

| Phase | Test 1 (RR) | Test 2 (AIG) | Test 3a (Postiz-TP) | Test 3b (Postiz-Real) | Test 3c (GV) | Test 4 (NEW) |
|-------|:-----------:|:------------:|:-------------------:|:--------------------:|:------------:|:------------:|
| 0: Bootstrap | Partial | Yes | Yes | Yes | Minimal | **Expected: Full** |
| 1: Session Start (hooks) | No | No | No | Partial | No | **Expected: Full** |
| 2: Ideation (brainstorm) | No | Yes | Yes | Yes | Yes | **Expected: Full** |
| 3: Planning (PRD → tasks) | Partial | Yes | Yes | **No** | Yes | **Expected: Full** |
| 4: Complexity Analysis | No | Yes | Partial | No | Yes | **Expected: Full** |
| 5: Task Expansion | No | Yes | Partial | No | Yes | **Expected: Full** |
| 6: Implementation (TDD) | Partial* | No | Partial | **Yes** | Partial | **Expected: Full** |
| 7: Review | No | No | No | **Yes** | No | **Expected: Full** |
| 8: Branch Completion | No | No | No | No | No | **Expected: Full** |
| 9: Session Lifecycle | No | No | No | Partial | No | **Expected: Full** |

*Test 1 had code implementation but no TDD discipline.

**Critical observation**: No single test has ever covered both planning (3-5) AND execution (6-9). Test 3a covered planning; Test 3b covered building. Test 4 must be the first to do both.

### Hook Coverage

| Hook | Test 1 | Test 2 | Test 3a | Test 3b | Test 3c | Test 4 (NEW) |
|------|:------:|:------:|:------:|:------:|:------:|:------------:|
| session-init.sh | — | — | — | ? | — | **Expected** |
| project-index.sh | — | — | — | ? | — | **Expected** |
| pre-compact.sh | — | — | — | ? | — | **Expected** |
| suggest-compact.sh | — | — | — | ? | — | **Expected** |
| pre-commit-check.sh | — | — | — | ? | — | **Expected** |
| protect-sensitive-files.sh | — | — | — | ? | — | **Expected** |
| doc-file-blocker.sh | — | — | — | ? | — | **Expected** |
| post-edit-format.sh | — | — | — | ? | — | **Expected** |
| console-log-audit.sh | — | — | — | ? | — | **Expected** |
| typescript-check.sh | — | — | — | ? | — | **Expected** |
| dev-server-blocker.sh | — | — | — | ? | — | **Expected** |
| long-running-tmux-hint.sh | — | — | — | ? | — | **Expected** |
| build-analysis.sh | — | — | — | ? | — | **Expected** |
| pr-url-extract.sh | — | — | — | ? | — | **Expected** |
| observe.sh | — | — | — | ✅ | — | **Expected** |
| session-end.sh | — | — | — | ✅ | — | **Expected** |
| session-summary.sh | — | — | — | ? | — | **Expected** |
| pattern-extraction.sh | — | — | — | ✅ | — | **Expected** |

Test 3b (ISKCON-GN/postiz) is the **only** test with any hook coverage — observe.sh, session-end.sh, and pattern-extraction.sh all produced artifacts. But 15 of 18 hooks remain unverified across all tests.

### Enforcement Coverage

| Rule Type | Test 1 | Test 2 | Test 3a | Test 3b | Test 3c | Test 4 (NEW) |
|-----------|:------:|:------:|:------:|:------:|:------:|:------------:|
| Conventional commits | Yes | — | Yes | Yes | No | **Expected** |
| Branch discipline | No | — | Partial | No | No | **Expected** |
| TDD enforcement | No | No | 1 task | **Yes** | Partial | **Expected** |
| PRD-first | No | Yes | Yes | No | Yes | **Expected** |
| Tag per phase | No | Yes | Yes | No | Yes | **Expected** |
| One task in-progress | ? | ? | ? | ? | ? | **Expected** |
| Commit frequency | Partial | No | Partial | Yes (19) | No (2) | **Expected** |
| Execution readiness | — | — | — | — | — | **Expected** |
| Brainstorm exit override | — | — | Broken | ? | — | **Expected** |
| Complexity-first expand | — | Yes | No | No | Yes | **Expected** |
| Orchestrate review | — | — | — | **Yes** | — | **Expected** |
| Continuous learning | — | — | — | **Yes** | — | **Expected** |

### Feature Discovery Timeline

| Discovery | Test | Template Fix | Version |
|-----------|------|-------------|---------|
| Conventional commits work | Test 1 | N/A (already stable) | — |
| `--research` flag improves subtasks | Test 2 | Documented in CLAUDE.md | — |
| Complexity threshold >= 5 useful | Test 2 | Added to MEMORY.md | — |
| MCP vs CLI split for AI ops | Test 3a | Documented in MEMORY.md | — |
| Brainstorm → writing-plans override | Test 3a | `superpowers-integration.md` rule | v2.3.0 |
| Context monitoring needs hooks | Test 3a | Hooks enabled by default | v2.3.0 |
| TDD mismatches infra tasks | Test 3a | Noted (not yet addressed) | — |
| `parse-prd` needs `--force` + timeout | Test 3a | Documented in MEMORY.md | — |
| `analyze-complexity` output bug | Test 3a | Workaround: use `complexity-report` | — |
| `expand --all` over-decomposes | Test 3a | Threshold rule documented | v2.3.0 |
| TDD works well for code-centric projects | Test 3b | Validates template design | — |
| Orchestrate review pipeline works e2e | Test 3b | Validates orchestration | — |
| Continuous learning hooks produce instincts | Test 3b | Validates CL system | — |
| Planning gets skipped under time pressure | Test 3b | Normative-only gap identified | — |
| Full PRD pipeline scales to 100+ tasks | Test 3c | Validates Task Master at scale | — |
| Local squash merge needs `-D` | Dogfood prep | Docs clarified | v2.3.1 |
| Execution readiness check needed | Dogfood prep | Rule added to context-management.md | v2.3.1 |

---

## How to Use This Document

### After Each Dogfood Test

1. **Fill in the Test Registry row** with project name, date, version, phases tested
2. **Create a new Test section** following the format of Tests 1-3
3. **Update the Comparative Coverage Matrix** — mark which hooks/features were tested
4. **Add discoveries to the Feature Discovery Timeline**
5. **Update Quality Assessment** with ratings

### When Evaluating a Template Change

Ask: "Does this change improve coverage in an area that was previously failing?"

1. Find the relevant row in the Comparative Coverage Matrix
2. Check if prior tests showed failures or gaps in that area
3. If yes → the change addresses a known problem (high confidence)
4. If no → the change is speculative (needs validation in next test)

### Regression Detection

After each dogfood test, verify that previously-passing areas still pass:

1. Conventional commits (passing since Test 1)
2. PRD → task pipeline (passing since Test 2)
3. Complexity analysis pipeline (passing since Test 2)
4. Brainstorm exit override (fixed in v2.3.0, verify not regressed)

If a previously-passing area fails, this is a **regression** — prioritize fixing it over new features.

---

## Metrics Over Time

| Metric | Test 1 | Test 2 | Test 3a | Test 3b | Test 3c | Test 4 |
|--------|--------|--------|---------|---------|---------|--------|
| Template version | pre-v1 | early | ~v2.2 | ~v2.3 | early | v2.3.1 |
| Phase coverage (of 10) | 2/10 | 3/10 | 4/10 | 5/10 | 4/10 | ?/10 |
| Hook coverage (of 18) | 0/18 | 0/18 | 0/18 | 3/18 | 0/18 | ?/18 |
| Enforcement rules tested | 2 | 3 | 5 | 5 | 3 | ? |
| Friction items found | 0* | 0* | 18 | 0* | 0* | ? |
| Tasks completed | 10/30 | 0/30 | 1/22 | ~5 features | 8+ | ? |
| Code LOC produced | ~8k | ~6.5k | 131 | ~500 | ~2k | ? |
| Test LOC produced | ~500 | ~1.8k | 95 | 66+ tests | 30+ tests | ? |
| Git commits | 12 | 0 | 7 | 19 | 2 | ? |
| Instincts extracted | 0 | 0 | 0 | 5 | 0 | ? |

*No formal friction logging in these tests.

### Trend Analysis

- **Phase coverage**: 2 → 3 → 4/5 → ? (improving, but planning + execution never in same test)
- **Hook coverage**: 0 → 0 → 0 → 3 → 0 → ? (Test 3b first to have ANY hook coverage)
- **Friction discovery**: Correlates with test thoroughness, not template maturity
- **Task completion**: Variable — depends on whether test focused on planning or building
- **Continuous learning**: Only activated in Test 3b (5 instincts extracted)

### The Planning-Execution Split

The most important pattern across all tests:

| Test | Planning phases (0-5) | Execution phases (6-9) | Both? |
|------|:--------------------:|:---------------------:|:-----:|
| Test 1 (RR) | Weak | Partial | No |
| Test 2 (AIG) | Strong | None | No |
| Test 3a (Postiz-TP) | Strong | Partial | **Almost** |
| Test 3b (Postiz-Real) | **None** | Strong | No |
| Test 3c (GV) | Strong | Partial | No |
| **Test 4** | **Expected** | **Expected** | **Goal** |

**No test has ever covered both planning AND full execution.** Test 4 must be the first to bridge this gap — it's the primary validation target.
