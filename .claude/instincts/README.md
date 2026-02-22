# Continuous Learning v2 — Instinct-Based Architecture

Adapted from [ECC](https://github.com/affaan-m/everything-claude-code) continuous-learning-v2.

Instincts are small, atomic learned behaviors that Claude extracts from your working sessions. They supplement (never override) the rules in `.claude/rules/`.

## How It Works

```
Session Activity
      |
      | observe.sh hooks capture every tool call
      v
+-------------------------------------------+
|         observations.jsonl                |
|   (tool names, inputs, outputs, timing)   |
+-------------------------------------------+
      |
      | Observer agent analyzes (background, Haiku)
      | OR /learn command (manual, in-session)
      v
+-------------------------------------------+
|          PATTERN DETECTION                |
|   - User corrections -> instinct          |
|   - Error resolutions -> instinct         |
|   - Repeated workflows -> instinct        |
|   - Tool preferences -> instinct          |
+-------------------------------------------+
      |
      | Creates/updates
      v
+-------------------------------------------+
|         instincts/personal/               |
|   - prefer-grep-before-edit.md (0.7)      |
|   - always-test-first.md (0.9)            |
+-------------------------------------------+
      |
      | /evolve clusters
      v
+-------------------------------------------+
|         instincts/evolved/                |
|   - skills/testing-workflow/SKILL.md      |
|   - commands/run-preflight.md             |
|   - agents/refactor-specialist.md         |
+-------------------------------------------+
```

## Authority Hierarchy

```
1. Rules (.claude/rules/*.md)     — Highest: project requirements
2. Instincts (.claude/instincts/) — Middle: learned suggestions
3. Defaults (Claude built-in)     — Lowest: baseline behavior
```

**If an instinct contradicts a rule, the rule always wins.**

## Instinct Format (YAML Frontmatter Markdown)

Each instinct is a `.md` file in `personal/` or `inherited/`:

```markdown
---
id: prefer-grep-before-edit
trigger: "when searching for code to modify"
confidence: 0.65
domain: "workflow"
source: "session-observation"
---

# Prefer Grep Before Edit

## Action
Always use Grep to find the exact location before using Edit.

## Evidence
- Observed 8 times across 3 sessions
- Pattern: Grep -> Read -> Edit sequence
- Last observed: 2026-02-22
```

## Domains

| Domain | Examples |
|--------|----------|
| `code-style` | Naming conventions, formatting preferences |
| `testing` | Test patterns, fixture preferences |
| `debugging` | Debugging workflow, log placement |
| `workflow` | Tool usage, command patterns |
| `architecture` | Module organization, dependency patterns |
| `git` | Commit patterns, branch strategies |

## Confidence Scoring

| Score | Meaning | Behavior |
|-------|---------|----------|
| 0.3 | Tentative | Suggested but not auto-applied |
| 0.5 | Moderate | Applied when relevant |
| 0.7 | Strong | Auto-approved for application |
| 0.9 | Near-certain | Core behavior |

**Confidence increases** when:
- Pattern is repeatedly observed
- User doesn't correct the behavior
- Similar instincts from other sources agree

**Confidence decreases** when:
- User explicitly corrects the behavior (-0.1)
- Pattern isn't observed for extended periods (-0.02/week)
- Contradicting evidence appears

## Directory Structure

```
.claude/instincts/
├── config.json              # Learning system configuration
├── README.md                # This file
├── observations.jsonl       # Raw tool use observations
├── personal/                # Auto-learned instincts
├── inherited/               # Imported from others
├── candidates/              # Git-based session summaries
├── evolved/                 # Graduated to skills/commands/agents
│   ├── skills/
│   ├── commands/
│   └── agents/
└── observations.archive/    # Processed observations
```

## Commands

| Command | Description |
|---------|-------------|
| `/instinct-status` | View all instincts with confidence scores |
| `/learn` | Manually extract patterns from current session |
| `/evolve` | Cluster related instincts into skills/commands |
| `/instinct-export` | Export instincts for sharing |
| `/instinct-import <file>` | Import instincts from others |

## Observation Hooks

Two hooks capture every tool call (configured in `.claude/settings.json`):

- **PreToolUse** `observe.sh pre` — Records tool start events
- **PostToolUse** `observe.sh post` — Records tool completion events

These feed into `observations.jsonl` for pattern analysis.

## Observer Agent

A background agent (`scripts/start-observer.sh`) can analyze observations automatically:

```bash
scripts/start-observer.sh        # Start background analysis
scripts/start-observer.sh status # Check if running
scripts/start-observer.sh stop   # Stop observer
```

The observer uses Haiku for cost efficiency and runs every 5 minutes.

## CLI Tool

`scripts/instinct-cli.py` provides programmatic access:

```bash
python3 scripts/instinct-cli.py status                    # Show all instincts
python3 scripts/instinct-cli.py export -o instincts.yaml  # Export
python3 scripts/instinct-cli.py import instincts.yaml     # Import
python3 scripts/instinct-cli.py evolve --generate         # Evolve to skills
```

## Git Policy

- `README.md`, `config.json` — Committed (documentation/config)
- `personal/`, `candidates/`, `observations.jsonl` — `.gitignore` (personal data)
- `inherited/` — Optionally committed (shared team patterns)
- `evolved/` — Committed when promoted (team skills)

## Privacy

- Observations stay **local** on your machine
- Only **instincts** (patterns) can be exported
- No actual code or conversation content is shared
- You control what gets exported
