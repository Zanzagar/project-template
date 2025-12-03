# Task Master Model Profile (Template)

Use these defaults whenever you initialize Task Master for a new project.

| Role | Provider | Model | Max Tokens | Temperature |
| --- | --- | --- | --- | --- |
| main | `codex-cli` | `gpt-5.1-codex` | 260,000 | 0.2 |
| research | `codex-cli` | `gpt-5.1` | 200,000 | 0.1 |
| fallback | `codex-cli` | `gpt-5.1` | 200,000 | 0.2 |

Copy `.taskmaster/config.json` from this template and update only if you have a specific reason (document differences in README/GOALS).
