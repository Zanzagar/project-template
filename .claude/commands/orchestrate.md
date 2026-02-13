Execute a multi-agent pipeline for comprehensive task handling.

Usage:
- `/orchestrate feature` — Full feature pipeline
- `/orchestrate review` — Comprehensive review pipeline
- `/orchestrate refactor` — Safe refactoring pipeline
- `/orchestrate agent1 agent2 agent3` — Custom pipeline

Arguments: $ARGUMENTS

## Default Pipelines

### feature
```
planner → tdd-guide → [implement] → code-reviewer → security-reviewer
```
Full feature cycle: plan it, write tests, implement, review.

### bugfix
```
planner → tdd-guide → [implement fix] → code-reviewer
```
Bug investigation and fix: understand the problem, write regression test, fix, review.

### review
```
code-reviewer → security-reviewer → database-reviewer (if SQL detected)
```
Comprehensive review: code quality, security, then database if relevant.

### refactor
```
architect → refactor-cleaner → code-reviewer → [run tests]
```
Safe refactoring: design the target, refactor, verify with review and tests.

### security
```
security-reviewer → code-reviewer → architect
```
Security-focused: find vulnerabilities, assess code quality, evaluate architecture.

## Custom Pipelines

Specify agent names in order:
```
/orchestrate architect planner code-reviewer
```

Available agents: planner, architect, tdd-guide, code-reviewer, security-reviewer, database-reviewer, doc-updater, refactor-cleaner, e2e-runner, go-reviewer, go-build-resolver, python-reviewer

## Execution Flow

For each agent in the pipeline:

1. **Invoke** the agent as a sub-agent (Task tool)
2. **Collect** the agent's structured output
3. **Create handoff document** for the next agent
4. **Pass** context to the next agent in the chain

### Handoff Document Format

Each agent produces:
```markdown
## [Agent Name] Report

### Summary
[Brief summary of findings/work]

### Findings
[Ordered by severity: CRITICAL → HIGH → MEDIUM → LOW]

### Recommendations
[Actionable next steps]

### Context for Next Agent
[Specific information the next agent needs]
```

## Final Report

After all agents complete, produce an aggregated report:

```
╔══════════════════════════════════════════════════════════╗
║                  ORCHESTRATION REPORT                     ║
╠══════════════════════════════════════════════════════════╣

Pipeline: feature (4 agents)
Duration: ~X minutes

Agent Results:
  [1] planner ............... ✓ Complete (3 findings)
  [2] tdd-guide ............. ✓ Complete (5 test suggestions)
  [3] code-reviewer ......... ✓ Complete (2 HIGH, 4 MEDIUM)
  [4] security-reviewer ..... ✓ Complete (1 CRITICAL)

Aggregated Findings (by severity):
  CRITICAL: 1
  HIGH: 2
  MEDIUM: 4
  LOW: 3

Top Issues:
1. [CRITICAL] security-reviewer: SQL injection in user input handler
2. [HIGH] code-reviewer: Missing error handling in API client
3. [HIGH] code-reviewer: Race condition in cache invalidation

Conflicts Between Agents:
  (none — or list where agents disagreed)
╚══════════════════════════════════════════════════════════╝
```

## Parallel Execution

For independent checks, run agents in parallel rather than sequentially:

```
### Sequential (default)
planner → tdd-guide → code-reviewer → security-reviewer

### Parallel phase (when agents don't depend on each other)
planner → tdd-guide → [implement] → ┬─ code-reviewer    ──┐
                                     └─ security-reviewer ──┤→ Merge Results
                                                            │
                                        database-reviewer ──┘
```

Use parallel execution when agents are doing independent reviews of the same code. The final report merges all parallel outputs.

## Notes

- Each agent runs in a fresh sub-agent context (isolated)
- Pipeline stops on CRITICAL findings (unless `--continue` flag)
- Implement steps (marked with `[]`) are manual — you write the code
- Use `/orchestrate --dry-run` to preview pipeline without executing
