Evaluate code quality metrics and track trends over time.

Usage: `/eval [--save] [--compare]`

Arguments: $ARGUMENTS

## Metrics Collected

### 1. Test Coverage
```bash
# Python
pytest --cov=src --cov-report=term-missing -q

# JavaScript/TypeScript
npx jest --coverage --coverageReporters=text-summary

# Go
go test -cover ./...
```
**Metric:** Line coverage percentage

### 2. Lint Score
```bash
# Count errors and warnings
ruff check . --output-format=json | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(f'Errors: {len([d for d in data if d.get(\"type\") == \"E\"])}')
print(f'Warnings: {len([d for d in data if d.get(\"type\") == \"W\"])}')
"
```
**Metric:** Issues per 1000 lines of code

### 3. Type Coverage
```bash
# Python (mypy)
mypy src/ --txt-report /dev/stdout | tail -1

# TypeScript
npx tsc --noEmit 2>&1 | tail -1
```
**Metric:** Percentage of typed functions/modules

### 4. Cyclomatic Complexity
```bash
# Python (radon)
radon cc src/ -a -nc

# JavaScript (eslint complexity rule)
npx eslint . --rule 'complexity: [warn, 10]' --format json
```
**Metric:** Average complexity per function (target: < 10)

## Output Format

```markdown
# Code Quality Eval — 2024-01-15 14:30

| Metric              | Current | Previous | Trend |
|---------------------|---------|----------|-------|
| Test Coverage       | 82%     | 78%      | +4% ↑ |
| Lint Score          | 0.3/kloc | 0.5/kloc | -0.2 ↑ |
| Type Coverage       | 91%     | 91%      | — |
| Avg Complexity      | 6.2     | 7.1      | -0.9 ↑ |

**Overall Health: GOOD** (all metrics trending positive)

## Recommendations
- [ ] Increase test coverage to 85% (target)
- [ ] Address 3 remaining lint warnings in src/utils/
```

## Flags

| Flag | Effect |
|------|--------|
| `--save` | Save results to `.claude/evals/eval_TIMESTAMP.json` |
| `--compare` | Compare against most recent saved eval |
| `--baseline` | Save as baseline for future comparisons |

## Saved Eval Format

```json
{
  "timestamp": "2024-01-15T14:30:00Z",
  "metrics": {
    "test_coverage": 82.0,
    "lint_score": 0.3,
    "type_coverage": 91.0,
    "avg_complexity": 6.2
  },
  "details": {
    "test_coverage": { "passed": 42, "failed": 0, "skipped": 2 },
    "lint_issues": [ { "file": "src/utils.py", "line": 42, "message": "..." } ]
  }
}
```

Saved to: `.claude/evals/eval_YYYYMMDD_HHMMSS.json`

## Integration with /health

The `/health` command checks for recent evals:
- If last eval > 7 days ago → recommend running `/eval`
- Shows latest metrics in health report summary
- Links to full eval history

## Graceful Degradation

Missing tools are handled gracefully:
- No pytest-cov → skip coverage, note in output
- No radon → skip complexity, note in output
- No previous eval → skip comparison, show current only

## When to Use

- Weekly quality check (establish cadence)
- Before major releases
- After significant refactoring
- When onboarding to assess codebase health
