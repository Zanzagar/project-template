---
name: model-route
description: Get model tier recommendation for a task
arguments:
  - name: task
    description: Task description
    required: true
  - name: budget
    description: Budget constraint (low, med, high)
    required: false
---

# Model Route

Analyze the task "$task" and recommend the appropriate model tier.

Budget constraint: $budget (default: no constraint)

## Routing Heuristics

| Model | Use For | Cost | Speed |
|-------|---------|------|-------|
| **haiku** | Deterministic ops, formatting, simple transforms, status checks | Lowest | Fastest |
| **sonnet** | Implementation, refactoring, code generation, moderate review | Balanced | Fast |
| **opus** | Architecture, deep review, ambiguous problems, complex debugging | Highest | Slower |

## Decision Factors

Evaluate each factor and weight toward the appropriate tier:

1. **Complexity**: How many files/concepts are involved?
   - 1-2 files, single concept → haiku
   - 3-10 files, moderate logic → sonnet
   - 10+ files, architectural → opus

2. **Risk**: What happens if it goes wrong?
   - Easily reversible, no data impact → haiku
   - Moderate impact, tests catch issues → sonnet
   - Production risk, security-sensitive → opus

3. **Ambiguity**: How clear are the requirements?
   - Crystal clear, well-defined → haiku
   - Mostly clear, some design decisions → sonnet
   - Exploratory, open-ended, novel → opus

4. **Budget**: User-specified constraint
   - "low" → cap at sonnet, prefer haiku
   - "med" → default routing
   - "high" → allow opus freely

## Output Format

Provide your recommendation as:

```
Recommendation: [haiku | sonnet | opus]
Confidence: [high | medium | low]
Rationale: [1-2 sentence explanation]
Fallback: [next tier up if recommendation struggles]
```

## Sub-Agent Routing

When dispatching sub-agents via the Agent tool, use the `model` parameter:

| Sub-Agent Task | Model |
|----------------|-------|
| Research, file search, exploration | haiku |
| Code review, implementation | sonnet |
| Architecture planning, security review | opus |
| Doc updates, formatting | haiku |
