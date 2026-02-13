Trigger the doc-updater agent to update documentation for recently changed files.

Usage: `/update-docs [scope]`

Arguments: $ARGUMENTS

## Scope Options

| Scope | Behavior |
|-------|----------|
| `recent` (default) | Files changed since last commit (`git diff --name-only`) |
| `all` | All source files in the project |
| `<path>` | Specific file or directory |

## Workflow

### 1. Identify Changed Files
```bash
# Recent (default)
git diff --name-only HEAD
git diff --name-only --cached

# Filter out non-code files
# Exclude: *.md, *.json, *.yaml, *.yml, *.toml, .gitignore, etc.
# Keep: *.py, *.ts, *.js, *.go, *.java, *.rs, etc.
```

### 2. Analyze What Changed
For each changed file, detect:
- New/modified public functions or classes → docstring updates needed
- New/modified API endpoints → README/API docs update needed
- New features or fixes → CHANGELOG entry needed
- New dependencies → installation docs update needed

### 3. Spawn doc-updater Agent
Delegate documentation work to the `doc-updater` agent (haiku model for lightweight operation):

**Agent updates:**
- **Docstrings** — For new/modified functions and classes
- **README.md** — If public API surface changed
- **API docs** — If endpoints were added/modified
- **CHANGELOG** — If new features or bug fixes detected

### 4. Report Changes

```markdown
# Documentation Update Report

## Files Analyzed
- `src/auth/tokens.py` (modified)
- `src/api/routes.py` (new endpoints)

## Updates Made
| File | Update | Reason |
|------|--------|--------|
| `src/auth/tokens.py` | Added docstring to `create_token()` | New function |
| `README.md` | Updated API section | New `/auth/refresh` endpoint |
| `CHANGELOG.md` | Added entry under "Added" | New auth refresh feature |

## Skipped
- `src/config.py` — No public API changes detected
```

## Integration with /pr

The proactive steering rule suggests running `/update-docs` before `/pr`:

```
Before creating a PR, ensure docs are current.
Run /update-docs to check for stale documentation.
```

This can also be added to the `/verify` pipeline as an optional stage.

## Model Usage

Uses the **doc-updater agent** which runs on **haiku** — the lightest model.
Documentation doesn't need deep reasoning, so haiku keeps token costs minimal.

## When to Use

- Before creating a PR (`/update-docs` → `/pr`)
- After implementing a feature
- After significant refactoring
- During code review to ensure docs match code
- Weekly maintenance check
