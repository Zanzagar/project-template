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
scripts/          # Harness audit, observer, multi-model, CLI tools
.claude/rules/    # Auto-loaded behavior rules (synced from template)
.claude/commands/  # 56 slash commands (run /help to list)
.claude/skills/   # 48 domain skills (loaded on relevance)
.claude/agents/   # 14 sub-agents (run /agents to list)
.claude/hooks/    # 22 event-driven hooks
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

## Task Master

AI task management via CLI. These rules are **mandatory**:

- ALWAYS create a PRD before generating tasks — never use `add-task` to build from scratch
- Each workflow phase gets its own tag — never pollute `master` with phase-specific work
- ALWAYS run `analyze-complexity` before expanding — expand only tasks scoring >= 5
- AI ops (parse-prd, expand, analyze) MUST use CLI, not MCP

Full details: `.claude/rules/taskmaster-usage.md` (CLI vs MCP), `.claude/rules/superpowers-integration.md` (pipeline), `.claude/rules/workflow-enforcement.md` (thresholds).

## Superpowers (Required)

TDD enforcement plugin — **will delete production code written without failing tests first**. This is intentional. Install after template setup:

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

Token overhead: ~3-5K. See `.claude/rules/superpowers-integration.md` for pipeline details and `docs/PLUGINS.md` for all plugins (optional: `/plugins` to browse).

## Hooks

22 hooks enabled via `.claude/settings.json`, controlled by profiles:

| Profile | Hooks | Activate |
|---------|-------|----------|
| `minimal` | 7 (lifecycle + safety) | `export TEMPLATE_HOOK_PROFILE=minimal` |
| `standard` | 18 (default) | No env var needed |
| `strict` | 22 (all) | `export TEMPLATE_HOOK_PROFILE=strict` |

Presets: `/settings fast` (no hooks), `/settings minimal`, `/settings safe` (safety only).
Disable specific hooks: `export TEMPLATE_DISABLED_HOOKS=build-analysis,console-log-audit`

See `docs/HOOKS.md` for full hook inventory and `.claude/hooks/README.md` for details.

## MCP Discipline

Follow the 10/80 rule: max 10 MCP servers, 80 tools. Never exceed this. Audit: `./scripts/manage-mcps.sh audit`. Configure: `docs/MCP_SETUP.md`.

## Security

Two layers: **config-level** (`npx ecc-agentshield scan`) and **code-level** (`/security-audit`).
Deny list recommendations and prompt injection guardrails: `.claude/rules/security-hardening.md`.
Full documentation: `docs/SECURITY.md`.

## Reference

When needed, consult:

| Topic | Location |
|-------|----------|
| Behavior rules (11 core + 6 language) | `.claude/rules/` (auto-loaded) |
| Workflow pipeline | `.claude/rules/superpowers-integration.md` |
| Task Master CLI vs MCP | `.claude/rules/taskmaster-usage.md` |
| Workflow thresholds | `.claude/rules/workflow-enforcement.md` |
| Hooks inventory & profiles | `docs/HOOKS.md` |
| Security & OWASP mapping | `docs/SECURITY.md` |
| Plugin management | `docs/PLUGINS.md` |
| MCP server setup | `docs/MCP_SETUP.md` |
| Continuous learning / instincts | `.claude/instincts/README.md` |
| Multi-model collaboration | `scripts/multi-model-query.py --check` |
| Context modes (dev/review/research) | `.claude/contexts/` |
| Session persistence & handoffs | `.claude/sessions/` (enabled via hooks) |
| ECC integration | `docs/ECC_INTEGRATION.md` |
| Template overview | `docs/TEMPLATE_OVERVIEW.md` |
