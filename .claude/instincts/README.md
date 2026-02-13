# Instincts — Continuous Learning v2

Instincts are learned patterns that Claude extracts from your working sessions. They supplement (never override) the rules in `.claude/rules/`.

## How It Works

1. After completing significant tasks, Claude identifies recurring patterns
2. Patterns become instincts with confidence scores (0.0–1.0)
3. High-confidence instincts are applied automatically as suggestions
4. Related instincts can cluster into new skills via `/evolve`

## Authority Hierarchy

```
1. Rules (.claude/rules/*.md)     — Highest: project requirements
2. Instincts (.claude/instincts/) — Middle: learned suggestions
3. Defaults (Claude built-in)     — Lowest: baseline behavior
```

**If an instinct contradicts a rule, the rule always wins.**

## Instinct Format

Each instinct is a JSON file in this directory:

```json
{
  "pattern": "Description of the learned behavior",
  "confidence": 0.85,
  "category": "coding-style",
  "source_sessions": ["2024-01-15", "2024-01-18"],
  "last_reinforced": "2024-01-18",
  "active": true
}
```

## Categories

| Category | Examples |
|----------|----------|
| `coding-style` | Naming conventions, formatting preferences |
| `testing-strategy` | Test patterns, fixture preferences, coverage approach |
| `debugging-approach` | Debugging workflow, log placement, tool selection |
| `architecture-preference` | Module organization, dependency patterns |
| `tool-usage` | MCP preferences, command patterns, workflow habits |

## Confidence Thresholds

| Range | Status | Behavior |
|-------|--------|----------|
| < 0.3 | Discarded | Too noisy, removed |
| 0.3–0.7 | Candidate | Needs reinforcement, not auto-applied |
| > 0.7 | Active | Applied automatically as suggestions |

## Confidence Dynamics

- **Reinforcement**: +0.1 per positive use (pattern confirmed)
- **Decay**: -0.05 per week unused (stale patterns fade)
- **Contradiction**: -0.2 when user explicitly rejects the pattern

## Commands

| Command | Description |
|---------|-------------|
| `/instinct-status` | View all instincts with confidence scores |
| `/instinct-import` | Import instincts from shared JSON file |
| `/instinct-export` | Export instincts for sharing |
| `/evolve` | Cluster related instincts into new skills |

## Git Policy

Instinct JSON files are **personal by default** (in `.gitignore`). To share instincts:
1. Export with `/instinct-export`
2. Share the exported file
3. Others import with `/instinct-import`

The README.md and example files ARE committed (documentation).
