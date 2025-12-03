# Project: [PROJECT_NAME]

[One-line description of what this project does]

## Tech Stack

- Python 3.11+
- [Add frameworks: FastAPI, PyTorch, etc.]
- [Add databases: PostgreSQL, Redis, etc.]

## Structure

```
src/              # Main source code
tests/            # Test files
docs/             # Documentation
```

## Development Commands

```bash
# Install dependencies
pip install -e ".[dev]"

# Run tests
pytest

# Run linter (handles style enforcement)
ruff check . --fix

# Type checking
mypy src/
```

## Git Conventions

- Branch naming: `feature/`, `bugfix/`, `hotfix/`
- Never commit directly to main
- See `docs/rules/git-workflow.md` for recovery commands

## Project-Specific Patterns

<!-- Add patterns unique to THIS project -->
- Example: "API endpoints go in `src/api/`"
- Example: "All models inherit from `BaseModel`"

## Current Focus

<!-- Update frequently - helps Claude understand context -->
- [ ] Current task being developed
- [ ] Known issues being addressed

## Reference Docs

When needed, consult:
- `docs/rules/git-workflow.md` - Git commands and recovery
- `docs/rules/python-standards.md` - Code style reference
