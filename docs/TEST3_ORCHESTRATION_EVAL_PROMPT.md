# Test 3: Orchestration & Eval — Session Prompt

> **Copy everything below the line into a fresh Claude Code session at:**
> `cd ~/projects/ISKCON-GN/postiz_social_automation && claude`

---

## Context

You are testing the **orchestration and eval** systems of a project bootstrapped from the `project-template`. This project is a Postiz social media automation stack with a Python health monitoring module.

**What already exists (from Test 1 and Test 2):**
- `scripts/health_storage.py` — SQLite health storage layer
- `tests/test_storage.py` — 12+ passing tests
- Additional Python modules implemented in Test 2 (health checker, webhook sender, or similar)
- `.taskmaster/` — Task Master with health-monitoring tag and tasks
- `.claude/instincts/` — Instinct files from Test 2 (if Test 2 succeeded)
- `.claude/sessions/` — Session summaries from previous sessions (if hooks fired)
- Hooks wired in `.claude/settings.local.json` (Stop + SessionStart events)

**If Test 2 hasn't been run yet**, this test can still proceed — it just won't have instincts or session summaries to build on. Focus on the orchestration and eval steps.

**What this test validates:**
1. `/orchestrate review` runs a multi-agent analysis pipeline correctly
2. Agent outputs are persisted to `.claude/orchestrate/`
3. `/eval metrics` collects project-wide quality metrics
4. `/eval define` creates feature eval definitions
5. `/verify` runs the full test/lint/type/security pipeline
6. Session persistence works across session boundaries

## Instructions (follow in order)

### Step 1: Check Session Persistence

If hooks were wired in Test 2, check whether session-init.sh detected the prior session:
- Did you see a session summary from the last session on startup?
- Does `.claude/sessions/` contain any session summary files?

```bash
ls -la .claude/sessions/ 2>/dev/null || echo "No sessions directory"
ls -la .claude/instincts/candidates/ 2>/dev/null || echo "No candidates directory"
```

**Known from Test 2:** `session-end.sh` did NOT fire (no sessions/ dir created), but `pattern-extraction.sh` DID fire (4 candidate JSONs in instincts/candidates/). So session persistence via summaries likely won't work — mark as N/A if `.claude/sessions/` is empty. The candidates directory should have files though.

Note the results — this validates cross-session continuity (or documents its absence).

### Step 2: Run /verify (Baseline)

Before making changes, establish a baseline:

```
/verify
```

**Expected output**: A verification report with stages (Tests, Lint, Types, Security). Some may SKIP if tools aren't installed (ruff, mypy, bandit). pytest should PASS.

Note the results — we'll compare after implementation.

### Step 3: Run /orchestrate review

This is the main test. Run the review orchestration pipeline on the existing health monitoring code:

```
/orchestrate review
```

When prompted for what to review, describe:
> "Review the health monitoring module: scripts/health_storage.py and tests/test_storage.py. Assess code quality, security (SQLite injection, input validation), and any database patterns (query efficiency, connection handling)."

**What should happen:**
1. **code-reviewer agent** — Reviews the implementation for quality, patterns, issues
2. **security-reviewer agent** — Checks for security concerns (SQL injection, input validation)
3. **database-reviewer agent** — Evaluates SQLite usage, query efficiency, connection handling (if SQL detected)

**Watch for:**
- Each agent runs as a sub-agent (fresh context)
- Agent outputs are persisted to `.claude/orchestrate/review/`
- Handoffs between agents include context for the next agent
- Maximum 3 retry cycles per agent if output is insufficient
- A final aggregated REPORT.md is generated

**If /orchestrate is not recognized or fails**, fall back to running the pipeline manually:
1. Invoke the code-reviewer agent: use Task tool with subagent_type="code-reviewer"
2. Invoke the security-reviewer agent: use Task tool with subagent_type="security-reviewer"
3. Invoke the database-reviewer agent: use Task tool with subagent_type="database-reviewer"
4. Create the report manually at `.claude/orchestrate/review/REPORT.md`

### Step 4: Run /eval define

Define eval criteria for the existing health storage module:

```
/eval define health-storage
```

**Expected output**: Creates `.claude/evals/health-storage.md` with:
- Capability evals (what should work: CRUD operations, timestamp handling, data retrieval, cleanup)
- Regression evals (all 12+ existing tests still pass)
- Success criteria with pass@k and pass^k thresholds

### Step 5: Run /eval check

Run the eval against the existing implementation:

```
/eval check health-storage
```

**Expected output**: Results showing which capability and regression evals pass.

### Step 6: Run /eval metrics

Collect project-wide quality metrics:

```
/eval metrics
```

**Expected output**: Table with:
- Test coverage percentage
- Lint score (if ruff installed)
- Type coverage (if mypy installed)
- Complexity metrics (if radon installed)

Missing tools should show SKIP, not FAIL.

Try with `--save` to persist:
```
/eval metrics --save
```

**Expected output**: Saves to `.claude/evals/metrics_*.json`

### Step 7: Run /verify (Post-Analysis)

Run verification again to confirm nothing was inadvertently changed during analysis:

```
/verify
```

**Expected**: Tests still pass, overall result unchanged from baseline (this is an analysis-only test).

### Step 8: Run /code-review

Run a standalone code review on all changes:

```
/code-review
```

**Expected**: Severity-tiered findings (CRITICAL/HIGH/MEDIUM/LOW) with >80% confidence filtering.

### Step 9: Check Orchestration Artifacts

Verify that orchestration outputs were persisted:

```bash
ls -la .claude/orchestrate/review/ 2>/dev/null || echo "No orchestrate output dir"
```

**Expected**: Individual agent reports and a REPORT.md.

### Step 10: Commit and Prepare for Session End

Commit all analysis artifacts:
1. Eval definitions (`.claude/evals/`)
2. Orchestration reports (`.claude/orchestrate/review/`)
3. Test results document (`docs/TEST3_ORCHESTRATION_EVAL_RESULTS.md`)
4. Updated friction log (`docs/WORKFLOW_FRICTION.md`)

Use conventional commits. Then end the session to test hook firing.

## Report Format

### 1. Append friction to the SHARED friction log

`docs/WORKFLOW_FRICTION.md` has items from Tests 1 and 2. **Append** new friction items continuing the sequence (F11+ or wherever Test 2 left off) using the same format:

```markdown
| FNN | T3-StepN | SEVERITY | Issue description | Resolution or "OPEN" |
```

Use `T3-StepN` as the Phase column to identify these came from Test 3.

### 2. Create per-test results

Create `docs/TEST3_ORCHESTRATION_EVAL_RESULTS.md` with:

```markdown
# Test 3: Orchestration & Eval Results

**Date**: YYYY-MM-DD
**Tester**: Claude Opus 4.6
**Project**: postiz_social_automation

## Summary
| Step | Description | Result | Notes |
|------|-------------|--------|-------|
| 1 | Session persistence check | PASS/FAIL/N/A | |
| 2 | /verify baseline | PASS/FAIL | [stages that ran] |
| 3 | /orchestrate review | PASS/FAIL/PARTIAL | [agents that ran] |
| 4 | /eval define | PASS/FAIL | |
| 5 | /eval check | PASS/FAIL | |
| 6 | /eval metrics | PASS/FAIL | |
| 7 | /verify post-implementation | PASS/FAIL | |
| 8 | /code-review | PASS/FAIL | |
| 9 | Orchestration artifacts persisted | PASS/FAIL | |
| 10 | Commit + session end | PASS/FAIL | |

## Orchestration Pipeline Details
### Agents Executed
| Agent | Cycles | Key Findings |
|-------|--------|--------------|
| code-reviewer | 1/2/3 | [summary] |
| security-reviewer | 1/2/3 | [summary] |
| database-reviewer | 1/2/3 | [summary] |

### Final Report Location
`.claude/orchestrate/review/REPORT.md`

## Eval Results
### Feature Eval: health-storage
- Capability: X/Y passing (pass@1: Z%)
- Regression: X/Y passing (pass^1: Z%)

### Project Metrics
| Metric | Value | Trend |
|--------|-------|-------|
| Test Coverage | X% | |
| Lint Score | X | |
| Type Coverage | X% | |
| Complexity | X | |

## Verification Comparison
| Stage | Baseline | Post-Implementation |
|-------|----------|-------------------|
| Tests | PASS/FAIL | PASS/FAIL |
| Lint | PASS/SKIP | PASS/SKIP |
| Types | PASS/SKIP | PASS/SKIP |
| Security | PASS/SKIP | PASS/SKIP |

## Friction Items Added
[List F-IDs added to docs/WORKFLOW_FRICTION.md this session]

## Key Findings
- What worked well
- What didn't work
- Orchestration quality assessment
- Eval system usefulness

## Commits Made This Session
[List commit hashes and messages]
```

**Commit BOTH the results file AND the updated friction log before ending the session.**

## Important Rules (from CLAUDE.md)
- Use CLI (not MCP) for: parse-prd, expand, analyze-complexity, update, add-task
- MCP works for: get_tasks, list, show, set-status, next
- Always use conventional commits (feat:, fix:, test:, etc.)
- Follow TDD: test first, then implementation
- Each commit should be a single logical unit
- /orchestrate uses sub-agents (Task tool) — each gets fresh context
- Agent outputs should be persisted to .claude/orchestrate/<pipeline>/
- Eval definitions go in .claude/evals/
