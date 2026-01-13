<!-- template-version: 2.0.0 -->
<!-- template-file: .claude/rules/reasoning-patterns.md -->
# Reasoning & Quality Patterns

These patterns improve output quality through structured thinking. Apply them automatically.

## Clarification Before Assumption

**When requirements are vague, ASK rather than assume.**

Before starting work on ambiguous requests:
1. Identify what's unclear (scope, approach, constraints)
2. List 2-3 specific clarifying questions
3. Wait for answers before proceeding

**Trigger phrases requiring clarification:**
- "Make it better" → Better how? Performance? Readability? UX?
- "Fix the bug" → Which bug? What's the expected behavior?
- "Add a feature" → What exactly should it do? Who uses it?
- "Improve this" → What metric defines improvement?

**Format:**
> Before I proceed, I need to clarify:
> 1. [Specific question about scope/approach]
> 2. [Specific question about constraints/preferences]

## Brainstorming Before Building

**For non-trivial features, brainstorm approaches first.**

When facing implementation decisions:
1. Generate 2-3 distinct approaches
2. List pros/cons for each
3. Recommend one with reasoning
4. Get user confirmation before coding

**Apply when:**
- Multiple valid architectures exist
- Trade-offs between simplicity/flexibility
- New feature with unclear best practice
- Performance vs maintainability decisions

## Reflection Before Completion

**Review work before declaring done.**

After completing significant work, pause and verify:

```
## Pre-Completion Checklist
- [ ] Does this actually solve the stated problem?
- [ ] Did I miss any edge cases mentioned in requirements?
- [ ] Are there obvious improvements I should mention?
- [ ] Would I be comfortable if someone else reviewed this?
```

**Self-review questions:**
1. "If I were the user, would this answer satisfy me?"
2. "What's the weakest part of this solution?"
3. "What would a senior engineer critique?"

## Five Whys for Debugging

**Trace problems to root cause, not symptoms.**

When debugging:
1. **Why** did this fail? → [immediate cause]
2. **Why** did that happen? → [deeper cause]
3. **Why** was that possible? → [systemic cause]
4. **Why** wasn't this caught? → [process gap]
5. **Why** does this gap exist? → [root cause]

Stop when you reach something actionable. Fix the root cause, not just the symptom.

## First Principles for Complex Problems

**Break down complex problems to fundamentals.**

When stuck or facing novel challenges:

1. **What do we know for certain?** (facts, constraints)
2. **What are we assuming?** (challenge each assumption)
3. **What's the simplest version?** (minimum viable solution)
4. **What would we do differently with no legacy?** (ideal state)
5. **What's the path from here to there?** (incremental steps)

## Research Before Recommending

**Don't guess at library APIs or best practices.**

When recommending technologies or approaches:
1. Use Context7 to get current documentation
2. Check for recent breaking changes
3. Verify compatibility with project stack
4. Cite sources for recommendations

**Never say:** "I think the API works like..."
**Instead:** "According to the documentation..." or "Let me check the current docs."
