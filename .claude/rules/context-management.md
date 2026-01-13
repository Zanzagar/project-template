<!-- template-version: 2.0.0 -->
<!-- template-file: .claude/rules/context-management.md -->
# Context & Session Management

Effective context management is critical for Claude Code performance. Apply these patterns automatically.

## Thinking Modes

Claude Code supports different thinking depths via keywords. Use the appropriate mode for the task:

| Mode | Tokens | When to Use |
|------|--------|-------------|
| `think` | ~4,000 | Simple tasks, quick fixes, routine operations |
| `think hard` | ~8,000 | Moderate complexity, single-file changes |
| `think harder` | ~16,000 | Multi-file changes, architectural decisions |
| `ultrathink` | ~32,000 | Complex problems, deep analysis, novel solutions |

### Mode Selection Guidelines

**Use `think` (default) for:**
- Bug fixes with obvious solutions
- Adding simple functions
- Documentation updates
- Routine git operations

**Use `think hard` for:**
- Implementing defined features
- Code review of single files
- Debugging with clear symptoms
- Refactoring within a module

**Use `think harder` for:**
- Features touching multiple files
- Debugging with unclear root cause
- API design decisions
- Integration work

**Use `ultrathink` for:**
- Architectural planning
- Complex algorithm design
- Unfamiliar codebases (initial exploration)
- Multi-system integration
- Research synthesis

### Prompting for Thinking Modes

Include the mode in your prompt:
- "Think about how to fix this null check"
- "Think hard about the best data structure here"
- "Think harder about how these services should communicate"
- "Ultrathink about the overall architecture for this feature"

## Context Rot: The 50% Threshold

**Critical insight:** Claude's ability to maintain coherent focus degrades significantly after ~50% of the context window is consumed.

### Symptoms of Context Rot
- Forgetting earlier instructions
- Repeating previously rejected approaches
- Missing obvious connections between files
- Declining code quality
- Ignoring established patterns

### Prevention Strategies

1. **Isolate problems**: One focused task per conversation when possible
2. **Break large tasks**: Use Task Master to decompose into smaller chunks
3. **Spawn sub-agents**: Use the Task tool for isolated subtasks with fresh context
4. **Monitor usage**: Check `/usage` periodically
5. **Start fresh**: When quality degrades, begin a new session

### When to Start a Fresh Session

- Context usage exceeds ~50%
- Claude forgets or contradicts earlier decisions
- Quality of responses noticeably declines
- Switching to unrelated task domain
- After completing a major milestone

## Session Management Best Practices

### Persist Context Externally

Don't rely on conversation history for important context. Write it to files:

```
Good: Update CLAUDE.md with architectural decisions
Good: Add notes to task descriptions in Task Master
Good: Create docs/decisions/YYYY-MM-DD-topic.md

Bad: Assume Claude remembers conversation from 30 messages ago
Bad: Keep unwieldy long conversations active
Bad: Reference "what we discussed earlier" without specifics
```

### Use the Project Index

The project index hook (`.claude/hooks/project-index.sh`) maintains a lightweight JSON index of your codebase at `.claude/project-index.json`. This allows:

- Sub-agents to understand codebase structure without loading files
- Quick navigation to relevant code
- Reduced context consumption for exploration

Reference it when spawning sub-agents or exploring unfamiliar code.

### Sub-Agent Best Practices

Sub-agents (via Task tool) get fresh context windows. Use them for:

| Task Type | Use Sub-Agent? | Why |
|-----------|----------------|-----|
| Isolated research | Yes | Fresh context, focused scope |
| Code review | Yes | Independent perspective |
| Validation/testing | Yes (blind) | Unbiased verification |
| Multi-step implementation | Sometimes | Break at natural boundaries |
| Quick fixes | No | Overhead not worth it |

**Blind Validator Pattern**: For testing, spawn a separate agent that only sees test results, not the implementation. This prevents bias in verification.

## Token Budget Awareness

### What Consumes Context

| Source | Approximate Tokens | Notes |
|--------|-------------------|-------|
| MCP tool definitions | ~25-30k total | Loaded at session start |
| Auto-loaded rules | ~3-5k | From `.claude/rules/` |
| Superpowers plugin | ~3-5k | Required for TDD |
| CLAUDE.md | ~1-2k | Project instructions |
| Conversation history | Varies | Grows with each exchange |
| File reads | Varies | ~1 token per 4 characters |
| Context7 queries | 5-20k each | Use sparingly |

### Token-Conscious Habits

1. **Read selectively**: Use line limits when reading large files
2. **Summarize findings**: Don't paste entire files into responses
3. **Use project index**: Reference structure, not full content
4. **Tier documentation lookups**: Existing knowledge → WebFetch → Context7
5. **Clear completed context**: Start fresh after major milestones

## Quick Reference

```
Context feeling sluggish?
├─► Check /usage
│   ├─ Under 50%? → Continue, maybe use lighter thinking mode
│   └─ Over 50%? → Consider fresh session
│
├─► Quality declining?
│   ├─ Same task? → Spawn sub-agent for fresh perspective
│   └─ New task? → Start fresh session
│
└─► Complex task ahead?
    ├─ Well-defined? → think hard, proceed
    └─ Exploratory? → ultrathink, then decompose
```
