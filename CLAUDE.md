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

## Key Decisions & Constraints

<!-- Document important architectural decisions -->
- Example: "Package-first: Core code in `src/`, notebooks for demos"
- Example: "All database queries go through the repository layer"

## Gotchas & Watch-outs

<!-- Document project-specific pitfalls to avoid -->
- Example: "Widget X requires version 8.1+ to work"
- Example: "Never call function Y without checking Z first"

## Taskmaster Workflows

```bash
# List tasks for current tag
task-master list --with-subtasks

# Show specific task details
task-master show <id>

# Update task status
task-master set-status --id <id> --status=<status>

# Get next recommended task
task-master next

# Expand task into subtasks
task-master expand --id=<id>

# Parse PRD to generate tasks
task-master parse-prd <prdfile> [--num-tasks N]
```

## Development Workflow

### Daily Loop
1. Pull latest changes; check task-master for next task
2. Implement changes; run linter and tests
3. Small, focused commits; PR when ready

### Release Loop
1. All tests passing; CHANGELOG entry added
2. PR with references to tasks/PRDs
3. Review, merge, tag release if applicable

## Current Focus

<!-- Update frequently - helps Claude understand context -->
- [ ] Current task being developed
- [ ] Known issues being addressed

## Reference Docs

When needed, consult:
- `docs/rules/git-workflow.md` - Git commands and recovery
- `docs/rules/python-standards.md` - Code style reference
- `docs/MCP_SETUP.md` - MCP server configuration (Task Master, Context7, GitHub)
