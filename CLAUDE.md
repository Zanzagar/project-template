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

### Workflow Rules (MANDATORY)

1. **PRD first**: ALWAYS create a PRD before generating tasks. Never use `add-task` to build a task list from scratch — write a PRD in `.taskmaster/docs/`, then parse it.
2. **New tag per phase**: Each workflow phase gets its own tag (e.g., `feature-auth`, `bugfix-api`). Never pollute the `master` tag with phase-specific work.
3. **Switch tags**: Always `task-master tags use <name>` before running set-status, show, or list — operations target the active tag.
4. **Expand after parse**: Always run `task-master expand --id=<id>` on complex tasks after parse-prd to generate actionable subtasks.
5. **Float task count**: Use `--num-tasks 0` with parse-prd to let the AI determine the right number of tasks. Don't hardcode counts.

### Commands

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

# Parse PRD to generate tasks (use --num-tasks 0 to let AI decide count)
task-master parse-prd <prdfile> --num-tasks 0

# Switch tag context
task-master tags use <tag-name>
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

## Superpowers (Required)

This template requires the [Superpowers](https://github.com/obra/superpowers) plugin for workflow enforcement. Install it immediately after setting up the template:

```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**Task Master + Superpowers = Complete Workflow:**
- **Task Master** (MCP) = WHAT to work on (task tracking, dependencies, status)
- **Superpowers** (Plugin) = HOW to work on it (TDD enforcement, debugging discipline)

**What Superpowers enforces:**
- Mandatory RED-GREEN-REFACTOR TDD cycles (deletes code written without failing tests)
- Systematic debugging with 4 mandatory phases
- Git worktree isolation for feature work
- Subagent-driven development with code review gates
- Plan writing before execution

**Important**: Superpowers is strict by design. It will delete production code written without tests first. This is intentional - the template enforces TDD discipline to ensure code quality.

Token overhead: ~3-5k tokens (included in template budget).

## Slash Commands

Available commands for common tasks:

| Command | Description |
|---------|-------------|
| `/setup` | Guided project setup wizard |
| `/health` | Project health check (includes AgentShield status) |
| `/tasks` | List Taskmaster tasks |
| `/test` | Run pytest test suite |
| `/lint` | Run ruff linter |
| `/verify` | Full verification pipeline (test + lint + types + security) |
| `/eval [--save]` | Code quality metrics with trend tracking |
| `/commit [message]` | Create conventional commit |
| `/pr [title]` | Create GitHub Pull Request |
| `/changelog [version]` | Generate changelog from git history |
| `/prd` | Show/parse PRD documents |
| `/prd-generate <concept>` | Deep research PRD generation with architecture diagrams |
| `/generate-tests <file>` | Generate tests for a file |
| `/security-audit` | Security vulnerability scan (code-level OWASP) |
| `/optimize <file>` | Performance analysis |
| `/settings [preset]` | Configure Claude Code settings |
| `/plugins` | Manage plugins |
| `/mcps` | Manage MCP servers |
| `/brainstorm <topic>` | Structured brainstorming with approaches |
| `/github-sync [action]` | Sync tasks with GitHub Issues |
| `/research <topic>` | Structured research (papers, docs, exploration) |
| `/orchestrate <pipeline>` | Multi-agent analysis pipeline (review, security, refactor) |
| `/multi-plan <requirements>` | Multi-perspective planning (SIMULATED — Claude generates all views) |
| `/multi-execute <task>` | Multi-perspective implementation (SIMULATED — Claude generates all views) |
| `/multi-backend <task>` | Backend-focused development (NOT IMPLEMENTED — needs codeagent-wrapper) |
| `/multi-frontend <task>` | Frontend-focused development (NOT IMPLEMENTED — needs codeagent-wrapper) |
| `/multi-workflow <task>` | Full-stack collaborative workflow (NOT IMPLEMENTED — needs codeagent-wrapper) |
| `/checkpoint [label]` | Manual session state save |
| `/skill-create` | Auto-generate skills from git history |
| `/update-codemaps` | Generate architecture docs in `docs/CODEMAPS/` |
| `/update-docs [scope]` | Trigger doc-updater agent on changed files |
| `/instinct-status` | View learned instinct patterns |
| `/instinct-import <file>` | Import instincts from shared JSON |
| `/instinct-export` | Export instincts for sharing |
| `/evolve` | Cluster instincts into new skills |

## Context Modes (CLI Aliases)

Launch Claude Code with mode-specific behavior by appending context files:

```bash
alias claude-dev='claude --append-system-prompt "$(cat .claude/contexts/dev.md)"'
alias claude-review='claude --append-system-prompt "$(cat .claude/contexts/review.md)"'
alias claude-research='claude --append-system-prompt "$(cat .claude/contexts/research.md)"'
```

| Mode | Behavior | When to Use |
|------|----------|-------------|
| `dev` | Code-first, minimal explanation, frequent commits | Active implementation |
| `review` | Read-first, severity-ordered findings, >80% confidence | PR review, audits |
| `research` | Explore-first, no code until clear, cite sources | Investigation, planning |

Add aliases to `~/.bashrc` or `~/.zshrc`. Default `claude` (no alias) uses the project's normal settings.

## Token Optimization

For cost-conscious development or long sessions, use the optimized preset:

```bash
/settings optimized
```

This reduces costs 60-80% by capping thinking tokens, compacting context earlier, and using lighter sub-agent models. See `docs/ECC_INTEGRATION.md` for details.

## Status Line

A status line script ships at `.claude/statusline.sh` showing model, git branch, context usage, and session duration:

```
[Opus] feature/my-branch* │ ctx: ████░░░░░░ 42% │ 1h 15m
```

Context percentage is color-coded: green (<50%), yellow (50-75%), red (>75%). Zero token cost — runs locally.

**Setup:** Add to `~/.claude/settings.json`:
```json
{ "statusLine": { "type": "command", "command": ".claude/statusline.sh" } }
```

## Session Persistence

Sessions automatically save summaries on exit (when `session-end.sh` hook is enabled):
- Writes to `.claude/sessions/session-summary-*.md`
- `session-init.sh` detects and displays summaries from the last 24 hours
- `pre-compact.sh` preserves state before context compaction

Enable via `/settings safe`, `/settings thorough`, or `/settings optimized`.

## Agents

Specialized sub-agent definitions in `.claude/agents/`:

| Agent | Model | Access | Use Case |
|-------|-------|--------|----------|
| **planner** | opus | Read-only | Architecture planning, implementation design |
| **code-reviewer** | sonnet | Read-only | Code review with severity tiers, >80% confidence |
| **security-reviewer** | sonnet | + Bash | OWASP Top 10, dependency scanning |
| **build-resolver** | sonnet | All | Build failures, CI fixes |
| **architect** | opus | Read-only | System design, ADR output format |
| **tdd-guide** | sonnet | Read-only | TDD coaching (advisory only, Superpowers enforces) |
| **database-reviewer** | sonnet | Read-only | SQL optimization, N+1 detection, migration safety |
| **doc-updater** | haiku | Write | README, docstrings, API docs, CHANGELOG |
| **refactor-cleaner** | sonnet | Write | Controlled refactoring, preserves all tests |
| **e2e-runner** | sonnet | + Bash | Playwright/Cypress/Selenium, flaky test diagnosis |
| **go-reviewer** | sonnet | Read-only | Go-specific patterns, goroutine leaks |
| **go-build-resolver** | sonnet | All | Go module/CGO/cross-compilation errors |
| **python-reviewer** | sonnet | Read-only | Python async, metaclasses, GIL, packaging |

## MCP Discipline

Follow the 10/80 rule: max 10 MCP servers, 80 tools. Run `./scripts/manage-mcps.sh audit` to check.
See `docs/MCP_SETUP.md` for configuration by project type.

## Hooks (Enabled by Default)

All 17 hooks are enabled by default via the tracked `.claude/settings.json`. Use presets to slim down:

```bash
# Slim down with a preset (writes to settings.local.json, overrides tracked config)
/settings fast        # Disables all hooks
/settings optimized   # Lightweight subset + token savings
/settings safe        # Safety hooks only (no formatting/analysis)
```

See `.claude/hooks/README.md` for details.

Available hooks:
- **session-init.sh** - Detects project phase, loads context, reloads session summaries
- **session-end.sh** - Generates detailed session summary for cross-session continuity
- **pre-compact.sh** - Saves working state before context compaction
- **pre-commit-check.sh** - Validates code before git commits
- **post-edit-format.sh** - Auto-formats files after edits
- **protect-sensitive-files.sh** - Blocks edits to .env, keys, etc.
- **project-index.sh** - Maintains lightweight JSON index of codebase structure
- **suggest-compact.sh** - Advisory compaction suggestions at 50/75/100 tool calls
- **session-summary.sh** - Generates session summary snapshots
- **doc-file-blocker.sh** - Prevents LLM from creating random .md files outside docs/
- **console-log-audit.sh** - Warns about debug statements (print, console.log) after edits
- **pattern-extraction.sh** - Auto-extracts instinct candidates from session git history
- **build-analysis.sh** - Advisory analysis of build command output
- **typescript-check.sh** - Runs tsc --noEmit after editing .ts/.tsx files
- **dev-server-blocker.sh** - Blocks dev servers outside tmux to prevent terminal capture
- **pr-url-extract.sh** - Extracts PR creation URL from git push output, suggests review commands
- **long-running-tmux-hint.sh** - Advisory tmux reminder for long-running commands (npm, pytest, cargo, docker)

See `docs/HOOKS.md` for full documentation.

## Continuous Learning

The instinct system allows Claude to learn patterns across sessions:

- **Instincts** (`.claude/instincts/`) — Lightweight JSON patterns with confidence scoring (0-1)
- **Authority hierarchy**: Rules (`.claude/rules/`) > Instincts > Defaults
- **Management**: `/instinct-status`, `/instinct-import`, `/instinct-export`, `/evolve`
- **Evolution**: When instincts cluster, `/evolve` promotes them to full skills

See `.claude/instincts/README.md` for format and `.claude/rules/authority-hierarchy.md` for precedence.

## Multi-Model Collaboration

> **Status**: SIMULATED. Currently Claude generates all perspectives itself — no actual API calls to Gemini or Codex. Real multi-model integration is planned.

Use structured multi-perspective analysis during planning:

```bash
# Get diverse perspectives on a design (Claude simulates all views)
/multi-plan "Design authentication system"

# Get diverse implementation approaches (Claude simulates all views)
/multi-execute "Build JWT auth with refresh tokens"
```

Future: Real multi-model support will require API keys in `.env`:
- `GOOGLE_AI_KEY` — Gemini (alternative perspectives)
- `OPENAI_API_KEY` — Codex/GPT (implementation patterns)

See `.claude/examples/multi-model-config.json` for planned setup.

## Security

Two-layer security model:

| Layer | Tool | Scope |
|-------|------|-------|
| **Config-level** | AgentShield (`npx ecc-agentshield scan`) | CLAUDE.md secrets, MCP permissions, hook injection, agent misconfigs |
| **Code-level** | `/security-audit` | OWASP Top 10, SQL injection, XSS, dependency vulnerabilities |

See `docs/SECURITY.md` for full documentation.

## Auto-Loaded Rules

Claude Code automatically loads behavior rules from `.claude/rules/`:

**Core rules** (always loaded):
- **claude-behavior.md** - Git commit enforcement, proactive behaviors, token-conscious documentation
- **git-workflow.md** - Detailed git commands and recovery procedures
- **reasoning-patterns.md** - Clarification, brainstorming, reflection, and debugging patterns
- **workflow-guide.md** - Phase detection, tool selection, and human input triggers
- **context-management.md** - Thinking modes, context rot prevention, session management
- **proactive-steering.md** - Project co-pilot behaviors, auto-tool invocation, steering patterns
- **authority-hierarchy.md** - Rules > instincts > defaults precedence

**Language-specific rules** (loaded only when matching files are edited):
- **python/coding-standards.md** - Python conventions (`.py` files)
- **typescript/coding-standards.md** - TypeScript strict mode, patterns (`.ts`, `.tsx` files)
- **golang/coding-standards.md** - Go idioms, error handling (`.go` files)
- **java/coding-standards.md** - Java/Spring Boot patterns (`.java` files)
- **frontend/component-standards.md** - React/Vue/Svelte (`.jsx`, `.tsx`, `.vue`, `.svelte` files)

These rules are synced from the template and can be updated independently of this file.

## Reference Docs

When needed, consult:
- `.claude/rules/` - Auto-loaded behavior rules (core + language-specific)
- `docs/ECC_INTEGRATION.md` - ECC integration features, token optimization, session persistence
- `docs/SECURITY.md` - AgentShield config scanning + security audit workflows
- `docs/MCP_SETUP.md` - MCP server configuration (Task Master, Context7, GitHub)
- `docs/PLUGINS.md` - Plugin installation and management (includes Superpowers)
- `docs/HOOKS.md` - Automation hooks setup and customization
- `.claude/instincts/README.md` - Continuous learning instinct system
- `.claude/examples/multi-model-config.json` - Multi-model API key setup
