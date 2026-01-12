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

### MANDATORY: Commit Behavior

**You MUST commit frequently.** Do not batch multiple features or fixes into one commit.

**Commit triggers** - Create a commit after ANY of these:
- Completing a single feature or function
- Fixing a bug (even small ones)
- Adding or modifying tests
- Updating documentation
- Before switching to a different task
- Every 15-30 minutes of active coding (at natural breakpoints)

**Commit message format** - Use conventional commits:
```
<type>: <short description>

[optional body with details]
```

| Type | When to Use |
|------|-------------|
| `feat:` | New feature or functionality |
| `fix:` | Bug fix |
| `docs:` | Documentation changes |
| `refactor:` | Code restructuring (no behavior change) |
| `test:` | Adding or updating tests |
| `chore:` | Maintenance tasks, dependencies |

**Examples:**
```bash
git commit -m "feat: Add user authentication endpoint"
git commit -m "fix: Resolve null pointer in data parser"
git commit -m "test: Add unit tests for payment module"
```

**Branch workflow:**
- Create feature branch before starting work: `git checkout -b feature/description`
- Never commit directly to main
- Push regularly for backup: `git push -u origin <branch>`

### Proactive Git Behavior

After completing a logical unit of work, you should:
1. Run tests (`pytest`) and linter (`ruff check`)
2. Stage and commit with a conventional commit message
3. Inform the user: "I've committed this change: `feat: ...`"

If you've made multiple changes without committing, proactively suggest:
> "I notice we have uncommitted changes. Should I commit these now?"

See `docs/rules/git-workflow.md` for recovery commands and advanced workflows.

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

## AI Assistant Instructions

Always use context7 when I need code generation, setup or configuration steps, or
library/API documentation. This means you should automatically use the Context7 MCP
tools to resolve library id and get library docs without me having to explicitly ask.

## Plugins (Optional)

This template supports plugins from [wshobson/agents](https://github.com/wshobson/agents).
Plugins add specialized agents and skills for specific domains (Python, DevOps, Security, etc.).

```bash
# Interactive plugin selection (recommended for new projects)
/plugins
# Or: ./scripts/manage-plugins.sh select

# Quick presets
./scripts/manage-plugins.sh install-preset

# Individual plugins
./scripts/manage-plugins.sh install python-development
```

**Note**: Plugins consume context tokens. Start minimal and add as needed.
See `docs/PLUGINS.md` for full documentation.

## Slash Commands

Available commands for common tasks:

| Command | Description |
|---------|-------------|
| `/setup` | Guided project setup wizard |
| `/health` | Project health check |
| `/tasks` | List Taskmaster tasks |
| `/test` | Run pytest test suite |
| `/lint` | Run ruff linter |
| `/commit [message]` | Create conventional commit |
| `/pr [title]` | Create GitHub Pull Request |
| `/changelog [version]` | Generate changelog from git history |
| `/prd` | Show/parse PRD documents |
| `/generate-tests <file>` | Generate tests for a file |
| `/security-audit` | Security vulnerability scan |
| `/optimize <file>` | Performance analysis |
| `/settings [preset]` | Configure Claude Code settings |
| `/plugins` | Manage plugins |
| `/mcps` | Manage MCP servers |

## Hooks (Optional)

Automate validation and formatting with hooks. See `.claude/hooks/README.md` for details.

Quick setup:
```bash
# Use a preset (safe mode enables file protection + pre-commit checks)
/settings safe

# Or copy example settings manually
cp .claude/hooks/settings-example.json .claude/settings.local.json
```

Available hooks:
- **session-init.sh** - Detects project state (new/adopting/existing), loads context, shows next steps
- **pre-commit-check.sh** - Validates code before git commits
- **post-edit-format.sh** - Auto-formats files after edits
- **protect-sensitive-files.sh** - Blocks edits to .env, keys, etc.
- **session-summary.sh** - Logs session activity

See `docs/HOOKS.md` for full documentation.

## Reference Docs

When needed, consult:
- `docs/rules/git-workflow.md` - Git commands and recovery
- `docs/rules/python-standards.md` - Code style reference
- `docs/MCP_SETUP.md` - MCP server configuration (Task Master, Context7, GitHub)
- `docs/PLUGINS.md` - Plugin installation and management
- `docs/HOOKS.md` - Automation hooks setup and customization
