# Superpowers v5.0.2 Integration Audit

## Purpose

This is an **integration audit**, not a competitive comparison. Superpowers is a required template dependency — the question is not "adopt or skip" but "are our integration rules correct, complete, and still necessary?"

## Component Inventory

**Superpowers v5.0.2** installed at `~/.claude/plugins/cache/superpowers-marketplace/superpowers/5.0.2/`

| Component Type | Count | Items |
|---------------|-------|-------|
| Skills | 14 | brainstorming, dispatching-parallel-agents, executing-plans, finishing-a-development-branch, receiving-code-review, requesting-code-review, subagent-driven-development, systematic-debugging, test-driven-development, using-git-worktrees, using-superpowers, verification-before-completion, writing-plans, writing-skills |
| Hooks | 1 event | SessionStart only (hooks.json + run-hook.cmd + session-start script) |
| Agents | 1 | code-reviewer.md |
| Commands | 3 | brainstorm, execute-plan, write-plan (all deprecated stubs) |
| Supporting files | 13 | Across brainstorming (2), requesting-code-review (1), subagent-driven-development (3), systematic-debugging (7) |
| Docs | 14 | testing.md, platform guides, design specs, implementation plans |
| Tests | 44 | Integration tests, skill triggering tests, explicit request tests, SDD end-to-end tests |
| Platform configs | 7 | Claude Code, Cursor, Codex, OpenCode, Gemini CLI |

**Audit date**: 2026-03-19

## Our Integration Rules (comparison targets)

| Rule | Purpose | Location |
|------|---------|----------|
| superpowers-integration.md | Brainstorming exit override, correct pipeline, skill routing | `.claude/rules/` |
| workflow-enforcement.md | Task type workflows, TDD applicability, branch completion | `.claude/rules/` |
| authority-hierarchy.md | Rules > Superpowers > Instincts > Defaults | `.claude/rules/` |

---

## Part 1: Skill-by-Skill Integration Analysis

### Primary Routing Chain

Superpowers defines a primary routing chain:

```
using-superpowers → brainstorming → writing-plans → subagent-driven-development → finishing-a-development-branch
                                                   ↘ executing-plans ────────────↗
```

Our template **overrides** one transition in this chain (brainstorming → writing-plans) with our extended pipeline:

```
brainstorming → /research (validate tech) → PRD → parse-prd → analyze-complexity → expand → TDD per task
```

Each skill below is analyzed for integration correctness.

---

### 1. using-superpowers — ALIGNED

**Skill behavior**: Meta-skill loaded at session start via SessionStart hook. Establishes skill invocation requirement: "IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE." 11 red-flag rationalizations. SUBAGENT-STOP gate prevents subagents from triggering. Priority order: user instructions > Superpowers skills > default system prompt.

**Integration with our rules**:
- **Priority order matches**: Superpowers says "user instructions take precedence." Our `authority-hierarchy.md` says "Rules > Superpowers > Instincts > Defaults." Since rules ARE user instructions (checked into repo), these are equivalent.
- **SUBAGENT-STOP gate**: Prevents our subagents (code-reviewer, planner, etc.) from triggering the full skill workflow. This is correct — our subagents should execute their specific task, not re-enter the skill routing system.
- **Skill type classification**: "Rigid (TDD, debugging): Follow exactly. Flexible (patterns): Adapt principles." Matches our `workflow-enforcement.md` which mandates TDD for code but allows validation testing for infrastructure.

**Integration status**: **Fully aligned.** No conflicts, no overrides needed.

---

### 2. brainstorming — OVERRIDE ACTIVE (superpowers-integration.md)

**Skill behavior**: 9-step checklist with HARD-GATE preventing any implementation before design approval. Explores project context, asks clarifying questions, proposes 2-3 approaches, writes design doc to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`, runs spec review loop (up to 5 iterations via subagent), gets user approval. **Terminal state: invoke writing-plans.**

**Our override** (`superpowers-integration.md`): After brainstorming completes, do NOT invoke writing-plans. Instead: `/research` (validate tech assumptions) → PRD → parse-prd → analyze-complexity → expand → TDD per task.

**Is the override still necessary?** YES. The brainstorming skill (v5.0.2) still explicitly states: "The terminal state is: invoke writing-plans to write the plan." This directly conflicts with our Task Master pipeline. Without the override, brainstorming would route to writing-plans (a micro-planning tool for single tasks), bypassing PRD creation, task decomposition, and complexity analysis entirely.

**Spec review loop interaction**: The skill's step 7 (spec review loop) fires BEFORE our override takes effect. This is correct — let the subagent validate the design doc quality, THEN our override routes to technical validation and PRD. The spec review and our `/research` step are complementary: spec review checks document quality, `/research` checks technical feasibility.

**Scope detection**: The skill's step 1 includes scope detection: "if request describes multiple independent subsystems, flag immediately for decomposition." This complements our Task Master complexity analysis, which catches oversized tasks later. Both are useful at different stages.

**Visual companion**: Optional browser-based visual brainstorming companion (278-line guide, Express/WS server). Zero overhead when unused — only activates if user requests it or topic involves visual questions. No integration concern.

**Integration status**: **Override active and still necessary.** The brainstorming skill's terminal routing to writing-plans conflicts with our Task Master pipeline. Override documented in `superpowers-integration.md`, confirmed correct for v5.0.2.

---

### 3. writing-plans — SCOPED BY OUR RULES

**Skill behavior**: Creates detailed micro-plans with 2-5 minute granular tasks, exact file paths, complete code in plan, exact commands with expected output. Saves to `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`. Plan review loop (subagent, up to 5 iterations). Execution handoff: if subagents available, REQUIRED to use subagent-driven-development; otherwise executing-plans.

**Our scoping** (`superpowers-integration.md`): writing-plans is ONLY for micro-planning within a single task. Project-level planning goes through PRD → Task Master.

**Is the scoping still necessary?** YES. The writing-plans skill has no awareness of Task Master. It would create a monolithic plan file for the entire project, bypassing task decomposition, complexity analysis, and per-task tracking. Our scoping restricts it to its appropriate use case: breaking one Task Master task into 2-5 minute executable steps.

**Plan review loop**: The skill dispatches a plan-document-reviewer subagent to check plan quality. This is fine for micro-plans — it validates task granularity and completeness.

**REQUIRED subagent execution**: The skill says "if harness has subagents, subagent-driven-development is REQUIRED." This is aggressive but aligned with our SDD-preferring approach.

**Integration status**: **Scoping active and still necessary.** writing-plans is appropriate for single-task micro-planning, not project-level planning.

---

### 4. executing-plans — ALIGNED (with scope restriction)

**Skill behavior**: Loads a plan file, creates TodoWrite checklist, executes tasks sequentially, runs verifications, uses finishing-a-development-branch at the end. STOP immediately on blockers. REQUIRED: use git-worktrees before starting. Notes that subagent-driven-development is recommended if available.

**Integration with our rules**: executing-plans is the fallback execution path when subagents aren't available. Our `superpowers-integration.md` says it's "valid for micro-planning within a single task" — same scoping as writing-plans. The skill's requirement to use git-worktrees aligns with our isolation preferences.

**Integration status**: **Aligned.** Same scope restriction as writing-plans applies.

---

### 5. subagent-driven-development — ALIGNED

**Skill behavior**: The most complex skill (278 lines + 3 supporting prompts). Two-stage review (spec compliance FIRST, then code quality). Sequential task execution. Model selection guidance (cheap for mechanical, capable for review). Review loops until approved. Uses finishing-a-development-branch at the end.

**Integration with our rules**:
- **Sequential execution**: Matches our `workflow-enforcement.md` "one task in-progress at a time" rule.
- **Two-stage review**: Spec compliance before code quality. This is Superpowers' contribution — our template didn't define review ordering.
- **Model selection**: "cheap models for mechanical tasks, capable for review" aligns with our `CLAUDE_CODE_SUBAGENT_MODEL` pattern (MEMORY.md).
- **No parallel implementation agents**: The skill explicitly says "Never dispatch multiple implementation subagents in parallel." This prevents file conflicts.

**Supporting prompts quality**:
- `implementer-prompt.md` (113 lines): Good TDD enforcement, self-review checklist, 4 status types (DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED).
- `spec-reviewer-prompt.md` (62 lines): Excellent skepticism framing: "The implementer finished suspiciously quickly. Their report may be incomplete, inaccurate, or optimistic." Forces independent verification.
- `code-quality-reviewer-prompt.md` (27 lines): Thin wrapper referencing the code-reviewer template.

**Integration status**: **Fully aligned.** SDD is our preferred implementation execution path. No conflicts with template rules.

---

### 6. test-driven-development — ALIGNED (with infrastructure exception)

**Skill behavior**: RED-GREEN-REFACTOR cycle. The Iron Law: "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST." Write code before test? "Delete it. Start over." 11 common rationalizations with counters. 13 red flags. Extended "Why Order Matters" section.

**Integration with our rules**:
- `workflow-enforcement.md` mandates TDD for code tasks but explicitly exempts infrastructure/config tasks: "TDD requires testable behavior. Infrastructure tasks produce *configurations*, not *behavior*. Validate that configs are syntactically correct and load successfully — don't force-fit unit tests around YAML files or Dockerfiles."
- `authority-hierarchy.md` says "Superpowers enforcement: Hard workflow enforcement. Deletes code without tests." But adds "Requires explicit acknowledgment" for user override.

**Potential conflict**: Superpowers TDD skill says "No exceptions without your human partner's permission." Our rule says infrastructure tasks use validation testing instead. Since our rules are user instructions (highest priority per both systems), the infrastructure exemption holds without needing explicit per-case permission.

**Integration status**: **Aligned with documented exception.** The infrastructure task exemption in `workflow-enforcement.md` takes precedence for Docker/CI/config tasks. Code tasks follow TDD strictly.

---

### 7. systematic-debugging — ALIGNED

**Skill behavior**: 4 mandatory phases (Root Cause Investigation → Pattern Analysis → Hypothesis and Testing → Implementation). The Iron Law: "NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST." If 3+ fixes fail, STOP and question architecture. 12 red flags, 8 common rationalizations.

**Integration with our rules**: `workflow-enforcement.md` says "Complex [bug]: > 50 lines or unclear root cause → superpowers:systematic-debugging first." This is the correct trigger.

**Supporting files** (7 total): root-cause-tracing.md, defense-in-depth.md, condition-based-waiting.md (with TypeScript example), find-polluter.sh (test polluter bisection), CREATION-LOG.md (meta-documentation of skill creation process), test-academic.md (skill comprehension test). These are high-quality reference materials that load only when the debugging skill is active — zero overhead otherwise.

**Integration status**: **Fully aligned.** Our rules correctly route complex bugs to this skill.

---

### 8. verification-before-completion — ALIGNED

**Skill behavior**: 5-step gate function (IDENTIFY → RUN → READ → VERIFY → ONLY THEN claim). The Iron Law: "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE." 7 common failure patterns, 8 red flags, 8 rationalization preventions. Cites 24 failure memories as motivation.

**Integration with our rules**: Our `workflow-enforcement.md` branch completion sequence requires review, push, CI verification before merge. This skill enforces the same discipline at a more granular level — before ANY success claim, not just branch completion.

**Integration status**: **Fully aligned.** Complementary to our branch completion rules.

---

### 9. finishing-a-development-branch — ALIGNED

**Skill behavior**: 5-step process. Tests MUST pass (hard gate). Present exactly 4 options: merge locally, push and create PR, keep as-is, discard. Option 4 requires typed "discard" confirmation.

**Integration with our rules**: `workflow-enforcement.md` defines the branch completion sequence (review → push → PR → CI verify → merge → sync → cleanup). The skill's 4 options present all valid paths. Our rules specify squash merge as default — the skill doesn't override this, leaving merge strategy to the user's git configuration.

**Minor gap**: The skill doesn't mention our squash merge preference or the CI verification step (`gh run watch`). These are enforced by our rules, not the skill.

**Integration status**: **Aligned.** Our rules add CI verification and merge strategy details that the skill doesn't cover. No conflict.

---

### 10. requesting-code-review — ALIGNED

**Skill behavior**: Dispatch code-reviewer subagent with BASE_SHA/HEAD_SHA diff. Fix Critical immediately, fix Important before proceeding, note Minor for later. Mandatory after each task in SDD, after major features, before merge.

**Integration with our rules**: Our `proactive-steering.md` auto-invoke table routes "code complete, need review" to `/code-review`. The Superpowers skill provides the subagent template. These are complementary — our rule triggers the review, the skill defines how to conduct it.

**Integration status**: **Fully aligned.**

---

### 11. receiving-code-review — ALIGNED

**Skill behavior**: 6-step response pattern (READ → UNDERSTAND → VERIFY → EVALUATE → RESPOND → IMPLEMENT). Forbidden responses: "You're absolutely right!", "Great point!", "Excellent feedback!" YAGNI check before implementing suggestions. External feedback gets 5-point verification checklist.

**Integration with our rules**: No template rule covers how to receive code review. This skill fills a gap — it prevents performative agreement and blind implementation of suggestions.

**Integration status**: **Fully aligned.** No conflict, fills a gap our rules don't address.

---

### 12. dispatching-parallel-agents — ALIGNED

**Skill behavior**: Pattern for identifying and dispatching independent tasks in parallel. Decision flowchart for when to use. Common mistakes with explicit bad/good examples.

**Integration with our rules**: Our `proactive-steering.md` doesn't specifically address parallel agent dispatch. The skill provides useful guidance without conflicting with any template rule.

**Integration status**: **Fully aligned.** Flexible pattern skill — no rigid enforcement to conflict with.

---

### 13. using-git-worktrees — ALIGNED

**Skill behavior**: Directory selection priority, safety verification (must be gitignored), project setup auto-detection, baseline test verification. REQUIRED by executing-plans and subagent-driven-development.

**Integration with our rules**: No template rule specifically addresses worktree creation. The skill's safety verification (ensuring worktree directory is gitignored) is a good practice our template doesn't enforce.

**Integration status**: **Fully aligned.** Good practice, no conflicts.

---

### 14. writing-skills — NO TEMPLATE INTERACTION

**Skill behavior**: TDD-adapted process for creating skills. RED phase (create pressure scenarios), GREEN phase (write minimal skill), REFACTOR phase (add rationalization counters). Claude Search Optimization (CSO) guidance for skill descriptions.

**Integration with our rules**: This skill is used when creating new skills for Superpowers itself. Our template doesn't create Superpowers skills — our `/skill-create` command creates template skills. No interaction.

**CSO insight worth noting**: Superpowers discovered that Claude follows skill description summaries instead of reading the full skill content. This means skill descriptions should ONLY contain triggering conditions ("Use when..."), never workflow summaries. This insight applies to our template skills too.

**Integration status**: **No interaction.** Valuable CSO insight documented for our own skill design.

---

## Part 2: Hook Comparison

### Superpowers session-start vs our session-init.sh

**Superpowers hook**: SessionStart event. Reads `using-superpowers/SKILL.md`, JSON-escapes it using fast bash parameter substitution, outputs as `additionalContext` via JSON. Also detects legacy `~/.config/superpowers/skills` directory and warns about migration. Cross-platform via `run-hook.cmd` polyglot wrapper (works in both CMD and bash).

**Our session-init.sh**: SessionStart event. Detects project phase, checks for missing template components (Taskmaster, Superpowers, CLAUDE.md customization), loads recent session summaries, queries Taskmaster for task counts, prints rich formatted status panel, auto-starts observer daemon.

**Relationship**: These run in parallel as separate SessionStart hooks. No conflict — they serve completely different purposes. Superpowers injects skill discovery context; ours injects project state context.

**Performance note**: Superpowers' hook uses `${content//...}` parameter substitution for JSON escaping, which they note is 7x faster than the old char-by-char loop. Our hook has 8-12 subprocess forks that add visible latency. The hooks audit (hooks-decisions.md) already identified this as an Adapt candidate.

**Integration status**: **No conflict.** Parallel execution, different purposes.

---

## Part 3: Agent Comparison

### Superpowers code-reviewer vs our code-reviewer agent

**Superpowers code-reviewer** (`agents/code-reviewer.md`):
- Model: `inherit` (uses session's model)
- Triggers: After major project steps
- Review checklist: 6 points (plan alignment, code quality, architecture/design, documentation/standards, issue identification with Critical/Important/Suggestions tiers, communication protocol)
- Output format: Strengths, Issues (tiered), Recommendations, Assessment (Ready to merge: Yes/No/With fixes)

**Our code-reviewer** (`.claude/agents/code-reviewer.md`):
- Model: `sonnet` (explicit, lighter model)
- Triggers: Code review skill, /code-review command, /orchestrate review
- Review scope: Guided by skill template with BASE_SHA/HEAD_SHA diff range
- Output format: Defined by requesting-code-review skill's code-reviewer.md template

**Key differences**:
1. **Model selection**: Superpowers uses `inherit` (session model, likely Opus), ours uses `sonnet` (cheaper, still capable for review). Our choice is deliberate — review agents don't need Opus-level reasoning.
2. **Trigger mechanism**: Superpowers' agent is dispatched by SDD and requesting-code-review skills. Our agent is dispatched by our /code-review command and /orchestrate review pipeline.
3. **The agents coexist**: When Superpowers' SDD dispatches `superpowers:code-reviewer`, it uses their agent definition. When our template dispatches code review via /code-review, it uses our agent definition. Different triggers, different agents, same purpose.

**Integration status**: **Coexisting.** Both agents are valid — they're dispatched by different skill/command pathways. The Superpowers agent is used during SDD implementation; our agent is used for ad-hoc and orchestrated reviews.

---

## Part 4: Commands and Other Components

### Deprecated commands (3)

All three Superpowers commands (`/brainstorm`, `/execute-plan`, `/write-plan`) are deprecated stubs pointing users to the skill equivalents. Our template has its own `/brainstorm`, `/plan`, and related commands that are NOT deprecated — they invoke the Superpowers skills correctly via the Skill tool.

**Integration status**: **No conflict.** Superpowers deprecated its own commands; our commands remain functional.

### Platform configs

Superpowers supports 5 platforms (Claude Code, Cursor, Codex, OpenCode, Gemini CLI). Our template targets Claude Code only. The platform configs have no impact on our integration.

### Tests (44 files)

Superpowers has extensive tests: skill triggering tests (6 prompts testing naive trigger detection), explicit skill request tests (12 files), SDD end-to-end tests (2 complete projects — Go fractals and Svelte todo), brainstorm server tests, and OpenCode plugin tests. These are Superpowers' internal quality assurance — no integration concern for our template.

**Notable finding**: The `spec-reviewer-prompt.md` used by SDD contains excellent skepticism framing: "The implementer finished suspiciously quickly. Their report may be incomplete, inaccurate, or optimistic. You MUST verify everything independently." This aligns with our `verification-before-completion` philosophy.

---

## Part 5: Integration Summary

### Override Status

| Override | Rule Location | Still Necessary? | Reason |
|----------|--------------|-------------------|--------|
| Brainstorming exit → PRD pipeline (not writing-plans) | superpowers-integration.md | **YES** | Skill still routes to writing-plans as terminal state |
| writing-plans scoped to single-task micro-planning | superpowers-integration.md | **YES** | Skill has no Task Master awareness |
| Infrastructure tasks exempt from TDD | workflow-enforcement.md | **YES** | Skill makes no infrastructure exception |
| Rules > Superpowers precedence | authority-hierarchy.md | **YES** | Matches Superpowers' own priority model |

### Alignment Status

| Skill | Integration Status | Notes |
|-------|-------------------|-------|
| using-superpowers | Fully aligned | Priority model matches our authority-hierarchy |
| brainstorming | Override active | Brainstorming exit redirected to PRD pipeline |
| writing-plans | Scoped | Only for single-task micro-planning |
| executing-plans | Aligned (scoped) | Same scope restriction as writing-plans |
| subagent-driven-development | Fully aligned | Sequential execution, two-stage review |
| test-driven-development | Aligned with exception | Infrastructure tasks use validation testing |
| systematic-debugging | Fully aligned | Rules correctly route complex bugs here |
| verification-before-completion | Fully aligned | Complementary to branch completion rules |
| finishing-a-development-branch | Aligned | Our rules add CI verification details |
| requesting-code-review | Fully aligned | Complementary trigger mechanisms |
| receiving-code-review | Fully aligned | Fills gap our rules don't address |
| dispatching-parallel-agents | Fully aligned | Flexible pattern, no conflicts |
| using-git-worktrees | Fully aligned | Good practice, no conflicts |
| writing-skills | No interaction | CSO insight valuable for our skills |

### Key Findings

1. **All 4 overrides remain necessary.** The brainstorming exit override is the most critical — without it, the entire Task Master pipeline would be bypassed for every non-trivial feature.

2. **No new conflicts discovered in v5.0.2.** The v5.0 changes (document review system, visual brainstorming, specs/plans directory restructure) are additive and don't conflict with our integration rules.

3. **Two agents coexist cleanly.** Superpowers' code-reviewer (model: inherit) is used during SDD; our code-reviewer (model: sonnet) is used for ad-hoc reviews. Different triggers, no collision.

4. **Session hooks run in parallel without conflict.** Superpowers injects skill context; our session-init injects project state.

5. **CSO insight is transferable.** Superpowers discovered that Claude follows description summaries instead of reading full skill content. Skill descriptions should contain ONLY triggering conditions ("Use when..."), never workflow summaries. This applies to our 40+ template skills.

6. **Superpowers' test suite is impressive.** 44 test files including end-to-end SDD tests with real project scaffolding. This level of skill testing is aspirational for our template.

7. **Spec reviewer skepticism is excellent practice.** The SDD spec-reviewer-prompt instructs the reviewer to assume "the implementer finished suspiciously quickly" and "MUST verify everything independently." This distrust-by-default approach catches optimistic or incomplete self-reports.

### Recommendations

1. **No rule changes needed.** All integration rules are correct for v5.0.2.
2. **Apply CSO insight to template skills.** Audit our skill descriptions to ensure they contain only triggering conditions, not workflow summaries.
3. **Document the coexisting agents** in CLAUDE.md to avoid confusion about which code-reviewer is used when.
4. **Consider adopting the spec reviewer skepticism pattern** for our own code-review subagent dispatch templates.
5. **When Superpowers v5.1+ releases**, re-run this audit to verify overrides are still necessary. If brainstorming ever adds Task Master awareness or configurable exit routing, the override may become unnecessary.
