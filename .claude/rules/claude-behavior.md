<!-- template-version: 2.0.0 -->
<!-- template-file: .claude/rules/claude-behavior.md -->
# Claude Behavior Rules

These rules define how Claude should behave when working on this project.
They are automatically loaded by Claude Code from `.claude/rules/`.

## MANDATORY: Commit Behavior

**You MUST commit frequently.** Do not batch multiple features or fixes into one commit.

### Commit Triggers

Create a commit after ANY of these:
- Completing a single feature or function
- Fixing a bug (even small ones)
- Adding or modifying tests
- Updating documentation
- Before switching to a different task
- Every 15-30 minutes of active coding (at natural breakpoints)

### Commit Message Format

Use conventional commits:
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

### Examples
```bash
git commit -m "feat: Add user authentication endpoint"
git commit -m "fix: Resolve null pointer in data parser"
git commit -m "test: Add unit tests for payment module"
```

## Proactive Git Behavior

After completing a logical unit of work, you should:
1. Run tests (`pytest`) and linter (`ruff check`)
2. Stage and commit with a conventional commit message
3. Inform the user: "I've committed this change: `feat: ...`"

If you've made multiple changes without committing, proactively suggest:
> "I notice we have uncommitted changes. Should I commit these now?"

## Branch Workflow

- Create feature branch before starting work: `git checkout -b feature/description`
- Never commit directly to main
- Push regularly for backup: `git push -u origin <branch>`

See `.claude/rules/git-workflow.md` for recovery commands and advanced workflows.

## Context7 Usage

Always use Context7 when you need:
- Code generation for a library/framework
- Setup or configuration steps
- Library/API documentation

This means you should automatically use the Context7 MCP tools (`resolve-library-id` and `query-docs`) without the user having to explicitly ask.

## Task Management

Use the TodoWrite tool frequently to:
- Plan complex tasks before starting
- Track progress on multi-step work
- Give the user visibility into what you're doing
- Mark todos as completed immediately when done (don't batch)

## Code Quality Standards

Before committing:
- Run the test suite if tests exist
- Run the linter if configured
- Ensure no obvious errors or warnings

## Communication Style

- Be concise but informative
- Explain "why" not just "what" when making decisions
- Proactively surface potential issues or alternatives
- Ask clarifying questions when requirements are ambiguous
