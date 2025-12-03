# Task Master Model Profile (Template)

Use these defaults whenever you initialize Task Master for a new project.

| Role | Provider | Model | Max Tokens | Temperature |
| --- | --- | --- | --- | --- |
| main | `claude-code` | `claude-opus-4-5-20250929` | 200,000 | 0.2 |
| research | `claude-code` | `claude-opus-4-5-20250929` | 200,000 | 0.1 |
| fallback | `claude-code` | `claude-sonnet-4-5-20250929` | 200,000 | 0.2 |

Copy `.taskmaster/config.json` from this template. Update only if needed (document changes in README).
