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
.claude/rules/    # Auto-loaded behavior rules (synced from template)
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

## Superpowers (Optional)

For strict workflow enforcement, install the [superpowers](https://github.com/obra/superpowers) plugin:

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**Superpowers + Task Master work together:**
- **Task Master** (MCP) = WHAT to work on (task tracking, dependencies, status)
- **Superpowers** (Plugin) = HOW to work on it (TDD enforcement, debugging discipline)

**What Superpowers enforces:**
- Mandatory RED-GREEN-REFACTOR TDD cycles (deletes code written without failing tests)
- Systematic debugging with 4 mandatory phases
- Git worktree isolation for feature work
- Subagent-driven development with code review gates
- Plan writing before execution

**Warning**: Superpowers is opinionated and strict. It will delete production code written without tests first. Recommended for teams committed to TDD discipline.

Estimated token overhead: ~3-5k tokens.

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

## Auto-Loaded Rules

Claude Code automatically loads behavior rules from `.claude/rules/`:
- **claude-behavior.md** - Git commit enforcement, proactive behaviors, Context7 usage
- **git-workflow.md** - Detailed git commands and recovery procedures
- **python-standards.md** - Python coding conventions

These rules are synced from the template and can be updated independently of this file.

## Reference Docs

When needed, consult:
- `.claude/rules/` - Auto-loaded behavior rules
- `docs/MCP_SETUP.md` - MCP server configuration (Task Master, Context7, GitHub)
- `docs/PLUGINS.md` - Plugin installation and management (includes Superpowers)
- `docs/HOOKS.md` - Automation hooks setup and customization
