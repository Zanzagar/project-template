# Design: Phase-Aware Context Loading

**Date**: 2026-03-18
**Status**: Proposal
**Problem**: Process overhead degrades brainstorming quality (dogfood finding #3)

## Problem Statement

The template loads 14 rules (~15k tokens) + 18 hooks into every session regardless of phase. During creative/divergent phases (IDEATION), this enforcement machinery competes with creative reasoning for context budget and cognitive attention.

**Evidence**: Dogfood Run 2 showed that alpha test 1 (0 rules, 0 hooks) produced the best brainstorming output (186-line design doc with rich domain engagement), while Run 2 (14 rules, 18 hooks, 735-line checklist) required 2 restarts and initially produced generic output.

**Paradox**: Run 2's downstream artifacts (PRD with dependency markers, 41 targeted subtasks) were measurably better than alpha 1's (flat 5-per-task). The enforcement helps everything *after* brainstorming.

## Proposed Approaches

### Approach A: Phase-Aware Rule Loading via paths: Frontmatter

**How**: Add phase conditions to rule frontmatter. Rules already support `paths:` for file-based conditional loading. Extend with `phases:` key.

```yaml
---
phases: ["building", "review", "shipping"]
---
# workflow-enforcement.md
# Only loads during implementation phases, not during ideation/planning
```

**Pros**:
- Cleanest implementation — leverages existing conditional loading
- Zero token cost for excluded phases
- Phase detection already exists in session-init.sh

**Cons**:
- Claude Code may not support `phases:` in frontmatter (needs verification)
- Phase detection happens in hooks, but rule loading happens at startup — timing mismatch
- How does Claude know the phase before rules load?

**Verdict**: Blocked by Claude Code platform — `phases:` is not a supported frontmatter key. Would require upstream feature request.

### Approach B: Settings Presets per Phase

**How**: Create phase-specific presets that load different rule/hook subsets.

```bash
/settings ideation    # Minimal: session hooks only, no enforcement rules
/settings building    # Full: all rules, all hooks
/settings review      # Read-heavy: review rules, no edit hooks
```

**Pros**:
- Works within existing Claude Code capabilities
- User explicitly controls the switch
- Clear mental model: phase = preset

**Cons**:
- Requires manual `/settings` switch at phase transitions
- Rules are files on disk, not preset-controlled — presets only control hooks and settings
- Would need a way to conditionally load rules (same platform limitation as A)

**Verdict**: Partially feasible for hooks (presets already exist). Rules remain always-loaded.

### Approach C: Lighter Brainstorming Flow (Recommended)

**How**: Accept that rules always load, but reduce their impact during brainstorming:
1. Keep rules lean (most are already <200 tokens each)
2. Modify brainstorming skill to explicitly deprioritize compliance checking
3. Add a "Creative Mode" instruction in the brainstorming skill: "During this brainstorming session, focus on creative exploration. Workflow enforcement rules apply after brainstorming completes, not during."
4. Remove TaskCreate checklist from brainstorming (use simple bullet points instead)

**Pros**:
- Works today, no platform changes needed
- Rules still load (available if needed) but don't dominate
- Brainstorming skill is already on-demand (0 startup tokens)

**Cons**:
- Relies on Claude's attention/discipline to deprioritize rules
- Rules are still in context, just less attended to
- Less clean than true conditional loading

**Verdict**: Most practical approach given current platform constraints.

## Recommendation

**Approach C** — modify the brainstorming skill to explicitly signal "creative mode" and reduce process overhead during ideation. This is implementable today without platform changes.

If Claude Code adds `phases:` frontmatter support in the future, revisit Approach A for a cleaner solution.

## Out of Scope

- Reducing rule count (rules are already lean and serve distinct purposes)
- Removing hooks during brainstorming (hooks are managed by settings.json, not rules)
- Changing Claude Code's rule loading behavior (platform constraint)
