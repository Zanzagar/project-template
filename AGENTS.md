# Agents & Responsibilities (Template)

| Agent | Scope | Definition of Done |
| --- | --- | --- |
| __Agent__ | Describe the workstream | Checklist for success |

## Collaboration Rituals
- Daily async update (channel of choice) with blocker/progress/plan.
- Weekly sync referencing GOALS + PRDs.
- **Claude Review Gate** before any Task Master parse: run lint/tests, summarize findings, confirm docs updated.

## Escalation Rules
1. Document how issues escalate (security, comms, infra, etc.).

## MCP & Model References
- `CLAUDE.md` – Project context file read by Claude Code at conversation start.
- `.taskmaster/config.json` – Claude Opus 4.5 / Sonnet 4.5 model configuration.
- Keep config in sync with template and restart `task-master-ai` after edits.
