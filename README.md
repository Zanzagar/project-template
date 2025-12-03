# Project Template

A standardized project template optimized for **Claude Code** development.

## Design Philosophy

Based on [best practices for CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md):

- **Minimal CLAUDE.md** - Only project-specific info; Claude already knows general best practices
- **Linters over instructions** - Use `ruff`/`mypy` for style, not LLM instructions
- **Progressive disclosure** - Skills and docs load when needed, not upfront
- **WHAT/WHY/HOW** - Tech stack, purpose, and commands to run

## Quick Start

```bash
# Copy template
cp -r project-template my-new-project
cd my-new-project
rm -rf .git && git init

# Customize
# 1. Edit CLAUDE.md with your project info
# 2. Edit this README.md
# 3. Delete unused skills/commands
```

## Structure

```
project-template/
├── CLAUDE.md                    # Minimal context (tech stack, commands, patterns)
├── .claude/
│   ├── skills/                  # Model-invoked capabilities
│   │   ├── code-review/         # Systematic code review
│   │   ├── debugging/           # Debugging workflow
│   │   └── git-recovery/        # Git emergency recovery
│   └── commands/                # User-invoked slash commands
│       ├── lint.md
│       ├── test.md
│       └── ...
├── docs/rules/                  # Reference docs (loaded when needed)
│   ├── git-workflow.md
│   └── python-standards.md
├── scripts/
│   └── sync-template.sh         # Pull template updates
├── src/                         # Source code
└── tests/                       # Tests
```

## How Claude Code Uses This

| Component | When Loaded | Purpose |
|-----------|-------------|---------|
| `CLAUDE.md` | Every conversation | Project context, commands, patterns |
| `.claude/skills/` | When relevant | Claude decides when to use (code review, debugging, etc.) |
| `.claude/commands/` | When you type `/command` | User-invoked actions |
| `docs/rules/` | When referenced | Detailed documentation |

## Skills (Model-Invoked)

Skills are loaded automatically when Claude determines they're relevant:

| Skill | Triggers When |
|-------|---------------|
| `code-review` | You ask to review code, PRs, or quality |
| `debugging` | You report bugs, errors, or issues |
| `git-recovery` | You have git problems or need to undo |

## Commands (User-Invoked)

Type these in Claude Code:
- `/lint` - Run linter
- `/test` - Run tests
- `/tasks` - Show task list
- `/prd` - Generate PRD

## Keeping Projects Updated

```bash
# Check what's outdated
./scripts/sync-template.sh --check-versions

# Preview changes
./scripts/sync-template.sh --dry-run

# Sync from local template
./scripts/sync-template.sh

# Sync from git (no local clone needed)
./scripts/sync-template.sh --git https://github.com/USER/project-template.git
```

See [TEMPLATE_SYNC.md](TEMPLATE_SYNC.md) for details.

## Customization

### Add Project-Specific Skills

```bash
mkdir -p .claude/skills/my-skill
```

Create `.claude/skills/my-skill/SKILL.md`:
```yaml
---
name: my-skill
description: What it does. When Claude should use it.
---

# My Skill

Instructions for Claude...
```

### Add Slash Commands

Create `.claude/commands/deploy.md`:
```markdown
Run deployment: `./scripts/deploy.sh`
```

Use with `/deploy` in Claude Code.
