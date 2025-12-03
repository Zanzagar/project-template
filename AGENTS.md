# Agents & Responsibilities (Template)

| Agent | Scope | Definition of Done |
| --- | --- | --- |
| __Agent__ | Describe the workstream | Checklist for success |

## Collaboration Rituals
- Daily async update with blocker/progress/plan
- Weekly sync referencing GOALS + PRDs
- **Review Gate** before Task Master parse: run lint/tests, confirm docs updated

## Escalation Rules
1. Document how issues escalate (security, comms, infra, etc.)

## Claude Code References
- `CLAUDE.md` – Project context (read automatically at conversation start)
- `.claude/skills/` – Model-invoked capabilities (code-review, debugging, git-recovery)
- `.claude/commands/` – User-invoked slash commands
- `.taskmaster/config.json` – Task Master model configuration
