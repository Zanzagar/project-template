# ECC Integration Guide

Features integrated from [Everything Claude Code](https://github.com/anthropics/ecc) patterns, adapted for this template.

## What Was Integrated

| Feature | Source | Files |
|---------|--------|-------|
| Token optimization presets | ECC settings patterns | `.claude/settings-presets.json` |
| Context management docs | ECC token guidance | `.claude/rules/context-management.md` |
| MCP discipline (10/80 rule) | ECC budget patterns | `scripts/manage-mcps.sh`, `docs/MCP_SETUP.md` |
| Session persistence | ECC session hooks | `.claude/hooks/session-end.sh`, `pre-compact.sh` |
| Session init reload | ECC continuity patterns | `.claude/hooks/session-init.sh` |
| Pre-compaction state | ECC state preservation | `.claude/hooks/pre-compact.sh` |
| Context injection modes | ECC mode patterns | `.claude/contexts/dev.md`, `review.md`, `research.md` |
| Python standards reorganization | ECC modular rules | `.claude/rules/python/coding-standards.md` |
| Agent definitions | ECC agent patterns | `.claude/agents/` |
| Code review enhancement | ECC review patterns | `.claude/skills/code-review/SKILL.md` |
| Health check MCP audit | ECC budget monitoring | `.claude/commands/health.md` |

## Quick Start

### Token Optimization

```bash
/settings optimized
```

Sets three environment variables:
| Variable | Value | Effect |
|----------|-------|--------|
| `MAX_THINKING_TOKENS` | 10000 | Caps thinking budget (default: 31999) |
| `CLAUDE_CODE_AUTOCOMPACT_PCT_OVERRIDE` | 50 | Compacts earlier (default: ~95%) |
| `CLAUDE_CODE_SUBAGENT_MODEL` | haiku | Lighter sub-agents |

**Trade-off:** Shallower reasoning + earlier context loss, but 60-80% cost reduction.

### Session Persistence

Enable with any preset that includes hooks:
```bash
/settings safe       # Includes session-init + session-end
/settings thorough   # Includes session-init + session-end
/settings optimized  # Includes session-init + pre-compact + session-end
```

**How it works:**
1. `session-end.sh` runs on Stop → writes summary to `.claude/sessions/`
2. `session-init.sh` runs on SessionStart → detects and displays recent summaries
3. `pre-compact.sh` runs on UserPromptSubmit → saves state before `/compact`

### Context Modes

Launch Claude Code with mode-specific behavior:
```bash
alias claude-dev='claude --append-system-prompt "$(cat .claude/contexts/dev.md)"'
alias claude-review='claude --append-system-prompt "$(cat .claude/contexts/review.md)"'
alias claude-research='claude --append-system-prompt "$(cat .claude/contexts/research.md)"'
```

| Mode | Focus | Token overhead |
|------|-------|----------------|
| `dev` | Code-first, frequent commits | ~100 tokens |
| `review` | Severity-ordered, >80% confidence | ~100 tokens |
| `research` | Read-first, cite sources | ~100 tokens |

### MCP Discipline (10/80 Rule)

```bash
# Check your budget
./scripts/manage-mcps.sh audit

# Optimize if over budget
./scripts/manage-mcps.sh select
```

**Target:** Max 10 MCPs, 80 tools. Keeps startup overhead at ~15-20% of context.

### Agents

Invoke via Task tool with agent-specific prompts. Definitions in `.claude/agents/`:

| Agent | Model | Tools | Use Case |
|-------|-------|-------|----------|
| planner | opus | Read-only | Architecture planning, implementation design |
| code-reviewer | sonnet | Read-only | Code review with severity tiers |
| security-reviewer | sonnet | + Bash | OWASP Top 10, dependency scanning |
| build-resolver | sonnet | All | Build failures, CI fixes |

## Migration Notes

If upgrading from a pre-ECC template version:

1. **New files** — Copy these directories:
   - `.claude/agents/`
   - `.claude/contexts/`
   - `.claude/sessions/` (with `.gitkeep`)

2. **Updated files** — Review changes in:
   - `.claude/settings-presets.json` (new `optimized` preset, hooks in `safe`/`thorough`)
   - `.claude/hooks/settings-example.json` (new hooks)
   - `.claude/rules/context-management.md` (token optimization section)
   - `.claude/commands/health.md` (MCP budget section)
   - `docs/HOOKS.md` (new hook documentation)
   - `docs/MCP_SETUP.md` (10/80 rule section)

3. **Moved files** — If you customized:
   - `.claude/rules/python-standards.md` → `.claude/rules/python/coding-standards.md`

4. **New scripts** — Add to `scripts/`:
   - `manage-mcps.sh` now has `audit` command

5. **gitignore** — Add: `.claude/sessions/*.md`
