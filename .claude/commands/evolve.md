Analyze instincts for clustering opportunities and suggest new skills.

Usage: `/evolve` or `/evolve --generate`

## Instructions

Run the instinct CLI evolve command:

```bash
python3 scripts/instinct-cli.py evolve
```

Display the output. If the user wants to generate the evolved structures, run:

```bash
python3 scripts/instinct-cli.py evolve --generate
```

### What Evolution Does

Analyzes instincts and clusters related ones into higher-level structures:
- **Commands**: When instincts describe user-invoked actions
- **Skills**: When instincts describe auto-triggered behaviors
- **Agents**: When instincts describe complex, multi-step processes

### Evolution Targets

| Source | Target | Criteria |
|--------|--------|----------|
| 2+ related instincts | Skill | Similar triggers, any confidence |
| Workflow instinct (>=70%) | Command | High-confidence workflow patterns |
| 3+ instincts (>=75% avg) | Agent | Complex multi-step patterns |

### Evolution Rules

**Command (User-Invoked):** When instincts describe actions a user would explicitly request:
- Multiple instincts about "when user asks to..."
- Instincts with triggers like "when creating a new X"
- Instincts that follow a repeatable sequence

**Skill (Auto-Triggered):** When instincts describe behaviors that should happen automatically:
- Pattern-matching triggers
- Error handling responses
- Code style enforcement

**Agent (Needs Depth/Isolation):** When instincts describe complex, multi-step processes:
- Debugging workflows
- Refactoring sequences
- Research tasks

### Generated Files

On `--generate`, evolved structures are written to `.claude/instincts/evolved/`

### Example Output Format

```
============================================================
  EVOLVE ANALYSIS - 12 instincts
============================================================

High confidence instincts (>=80%): 5

## SKILL CANDIDATES
1. Cluster: "adding tests"
   Instincts: 3
   Avg confidence: 82%
   Domains: testing

## COMMAND CANDIDATES (2)
  /adding-tests
    From: test-first-workflow
    Confidence: 84%

## AGENT CANDIDATES (1)
  adding-tests-agent
    Covers 3 instincts
    Avg confidence: 82%
```

### If Not Enough Instincts

```
Need at least 3 instincts to analyze patterns.
Currently have: N

To build up instincts:
  - Use /learn to extract patterns from sessions
  - The observer agent creates instincts automatically
  - Import shared instincts with /instinct-import
```
