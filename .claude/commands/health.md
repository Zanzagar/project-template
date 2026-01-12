# Project Health Check

Run a comprehensive health check on the project to ensure everything is properly configured.

## Instructions

Perform the following checks and report results:

### 1. Template Configuration

```bash
# Check template status
./scripts/sync-template.sh status
```

Report:
- Template source (local/git)
- Last sync date
- Files needing updates

### 2. CLAUDE.md Status

```bash
# Check if customized
grep -q "\[PROJECT_NAME\]" CLAUDE.md && echo "NOT CUSTOMIZED" || echo "Customized"
```

If not customized, prompt: "CLAUDE.md still has placeholder values. Run /setup to configure."

### 3. Taskmaster Status

```bash
# Check initialization
ls -la .taskmaster/ 2>/dev/null || echo "Not initialized"

# Check for tasks
task-master list 2>/dev/null | head -10
```

Report:
- Initialized: Yes/No
- Task count
- Current/next task

### 4. Git Status

```bash
# Branch
git branch --show-current

# Status
git status --short

# Remote
git remote -v
```

Report:
- Current branch (warn if on main/master)
- Uncommitted changes count
- Remote configured: Yes/No

### 5. Code Quality

```bash
# Run linter (if available)
ruff check src/ tests/ 2>/dev/null || echo "Linter not available or no src/"

# Run type checker (if available)
mypy src/ 2>/dev/null || echo "Type checker not available"

# Run tests (quick)
pytest -q --tb=no 2>/dev/null || echo "Tests not available"
```

Report:
- Linting: Pass/Fail/N/A
- Type checking: Pass/Fail/N/A
- Tests: Pass/Fail/N/A

### 6. Dependencies

```bash
# Python
pip list --outdated 2>/dev/null | head -10

# Node
npm outdated 2>/dev/null | head -10
```

Report:
- Outdated packages count
- Critical updates (security)

### 7. MCP Configuration

```bash
# Check project MCP config
cat .claude/mcp-project.json 2>/dev/null || echo "Not configured"

# Check active MCPs
claude mcp list 2>/dev/null | grep -c "✓ Connected"
```

Report:
- MCPs configured: Yes/No
- Active MCP count
- Estimated token overhead

### 8. Hooks Status

```bash
# Check if hooks enabled
cat .claude/settings.local.json 2>/dev/null | jq '.hooks' || echo "Not configured"
```

Report:
- Hooks enabled: Yes/No
- Which hooks are active

## Output Format

Present results as a health report:

```
╔════════════════════════════════════════════════════════════╗
║                    PROJECT HEALTH CHECK                     ║
╠════════════════════════════════════════════════════════════╣
║ Category              │ Status      │ Notes                 ║
╠───────────────────────┼─────────────┼───────────────────────╣
║ Template              │ ✓ Synced    │ v2.0.0               ║
║ CLAUDE.md             │ ✓ Customized│                       ║
║ Taskmaster            │ ✓ Active    │ 5 tasks pending       ║
║ Git                   │ ⚠ Warning   │ On main branch        ║
║ Linting               │ ✓ Pass      │                       ║
║ Tests                 │ ✗ Failing   │ 2 failures            ║
║ Dependencies          │ ⚠ Outdated  │ 3 packages            ║
║ MCPs                  │ ✓ Configured│ ~7,500 tokens         ║
║ Hooks                 │ ○ Optional  │ Not enabled           ║
╚════════════════════════════════════════════════════════════╝

Summary: 6 passed, 2 warnings, 1 failing

Recommendations:
1. Fix failing tests before continuing
2. Create a feature branch: git checkout -b feature/...
3. Update outdated dependencies: pip install --upgrade ...
```

## Actionable Recommendations

Based on findings, suggest specific fixes:

| Issue | Command |
|-------|---------|
| Not on feature branch | `git checkout -b feature/current-work` |
| Uncommitted changes | `/commit` |
| Failing tests | `pytest -v` to see details |
| Linting errors | `ruff check --fix src/` |
| MCPs not configured | `/mcps` |
| Hooks not enabled | `/settings safe` |
| CLAUDE.md not customized | `/setup` |
