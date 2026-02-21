# Test 2: Continuous Learning — Session Prompt

> **Copy everything below the line into a fresh Claude Code session at:**
> `cd ~/projects/ISKCON-GN/postiz_social_automation && claude`

---

## Context

You are testing the **continuous learning** system of a project bootstrapped from the `project-template`. This project is a Postiz social media automation stack with a Python health monitoring module. The template infrastructure (.claude/, .taskmaster/, rules, agents, skills, hooks, commands) was copied in via `init-project.sh` (copy mode).

**What already exists:**
- `scripts/health_storage.py` — SQLite health storage layer (137 lines)
- `tests/test_storage.py` — 12 passing tests for HealthStorage
- `tests/conftest.py` — pytest fixture for temp SQLite database
- `pyproject.toml` — Python project config (postiz-health-monitor v0.1.0)
- `.taskmaster/docs/prd_health_monitoring.txt` — PRD for health monitoring features
- `.taskmaster/tasks.json` — EMPTY (tasks from previous test were lost)
- `.claude/hooks/pattern-extraction.sh` — Auto-extracts candidate instincts on session end
- `.claude/hooks/session-end.sh` — Creates session summaries on session end
- `.claude/hooks/settings-example.json` — Full hook wiring config (NOT currently active)
- `.claude/settings.local.json` — Only has permissions, NO hooks configured
- No `.claude/instincts/` directory exists yet

**What this test validates:**
1. Hook wiring works (pattern-extraction, session-end)
2. Instinct candidates are generated after enough commits
3. `/learn` command manually extracts patterns
4. `/instinct-status` shows instinct state
5. `/instinct-export` exports instincts
6. `/evolve` detects clusters (if enough instincts exist)

## Instructions (follow in order)

### Step 1: Wire the Hooks

The hooks exist as scripts but aren't connected to Claude Code events. Merge the hook events from `.claude/hooks/settings-example.json` INTO `.claude/settings.local.json`, preserving the existing `permissions` block.

The result should look like:
```json
{
  "permissions": {
    "allow": [ ...existing permissions... ]
  },
  "hooks": {
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-end.sh" },
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pattern-extraction.sh" }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-init.sh" }
        ]
      }
    ]
  }
}
```

Only wire `Stop` (session-end + pattern-extraction) and `SessionStart` (session-init). Skip PreToolUse/PostToolUse hooks — they add friction and aren't the focus of this test.

Create the instincts directory structure:
```bash
mkdir -p .claude/instincts/candidates
```

Commit this configuration change.

### Step 2: Re-parse the Existing PRD

The health monitoring PRD exists but tasks.json is empty. Re-create the tasks:

```bash
task-master tags add health-monitoring
task-master tags use health-monitoring
task-master parse-prd .taskmaster/docs/prd_health_monitoring.txt --num-tasks 0
```

**CRITICAL**: Use CLI for parse-prd, NOT MCP. The `claude-code` provider tries to spawn nested Claude subprocess which fails.

Then analyze complexity and expand:
```bash
task-master analyze-complexity
task-master expand --id=<id>   # For each task flagged as complex in the report
```

### Step 3: Implement 2-3 Health Monitor Tasks via TDD

Pick tasks that involve writing Python code (not Docker/config tasks). Good candidates:
- Health checker module (HTTP/TCP checks against services)
- Webhook notification sender
- Analytics/uptime calculation module

For EACH task:
1. `task-master set-status --id <id> --status=in-progress`
2. **RED**: Write a failing test first
3. **GREEN**: Implement minimum code to pass
4. **REFACTOR**: Clean up if needed
5. Run `pytest` to verify
6. Commit with conventional commit message
7. `task-master set-status --id <id> --status=done`

**Goal: Accumulate 3+ commits** so `pattern-extraction.sh` has enough data to work with when the session ends.

### Step 4: Manually Extract Patterns with /learn

After implementing 2-3 tasks, invoke:
```
/learn
```

This should:
1. Review your session's work (commits, patterns, decisions)
2. Identify extractable patterns (e.g., "always uses pytest fixtures", "SQLite for local storage")
3. Ask you to confirm before saving
4. Create instinct JSON files in `.claude/instincts/`

**Expected output**: At least 1-2 instinct files created with confidence 0.4-0.5 (candidate level).

### Step 5: Check Instinct Status

Run:
```
/instinct-status
```

**Expected output**: Table showing instincts grouped by category with confidence scores and active/candidate status.

### Step 6: Export Instincts

Run:
```
/instinct-export
```

**Expected output**: Creates `.claude/instincts/export-YYYY-MM-DD.json` with exported instincts.

### Step 7: Test Evolution (if enough instincts)

If you have 3+ instincts in the same category, run:
```
/evolve
```

**Expected output**: Either detects clusters and proposes skill creation, OR reports "not enough clustered instincts yet" (both are valid outcomes for this test).

If you don't have 3+ instincts in a category, just note that in the results and skip this step.

### Step 8: Verify Hook Will Fire on Exit

Before ending the session, verify the hooks are correctly wired:
```bash
cat .claude/settings.local.json | python3 -c "import json,sys; d=json.load(sys.stdin); print('Stop hooks:', len(d.get('hooks',{}).get('Stop',[{},])[0].get('hooks',[])))"
```

This should print `Stop hooks: 2` (session-end + pattern-extraction).

**Then end the session normally** (type `/quit` or Ctrl+C). The Stop hooks should fire and:
1. Create `.claude/sessions/session_*.md` (session summary)
2. Create `.claude/instincts/candidates/session_*.json` (auto-extracted patterns)

## Report Format

### 1. Append friction to the SHARED friction log

`docs/WORKFLOW_FRICTION.md` already has items F1-F10 from Test 1. **Append** new friction items starting at **F11+** using the same format:

```markdown
| F11 | T2-Step1 | SEVERITY | Issue description | Resolution or "OPEN" |
```

Use `T2-StepN` as the Phase column to identify these came from Test 2.

### 2. Create per-test results

Create `docs/TEST2_CONTINUOUS_LEARNING_RESULTS.md` with:

```markdown
# Test 2: Continuous Learning Results

**Date**: YYYY-MM-DD
**Tester**: Claude Opus 4.6
**Project**: postiz_social_automation

## Summary
| Step | Description | Result | Notes |
|------|-------------|--------|-------|
| 1 | Hook wiring | PASS/FAIL | |
| 2 | PRD re-parse | PASS/FAIL | |
| 3 | TDD implementation (X tasks) | PASS/FAIL | |
| 4 | /learn manual extraction | PASS/FAIL | |
| 5 | /instinct-status display | PASS/FAIL | |
| 6 | /instinct-export | PASS/FAIL | |
| 7 | /evolve clustering | PASS/FAIL/SKIP | |
| 8 | Stop hooks fire on exit | PASS/FAIL | Check after restart |

## Instincts Generated
[List each instinct: pattern, confidence, category, source]

## Friction Items Added
[List F-IDs added to docs/WORKFLOW_FRICTION.md this session]

## Key Findings
- What worked well
- What didn't work
- Surprises

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
