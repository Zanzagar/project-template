# Rules Audit Decisions

## Inventory

**Our rules**: 16 files (10 core + 6 language-specific) in `.claude/rules/`
**ECC rules**: 49+ files (9 common + ~40 language-specific across 8 languages) in `rules/`
**Structural difference**: ECC splits 5 files per language; we consolidate 1 file per language
**Audit date**: 2026-03-19

## Summary

| Verdict | Count | Description |
|---------|-------|-------------|
| Keep | 11 | Our version is a superset (core rules + language rules) |
| Adapt | 3 | Merge specific ECC content into existing rules |
| New | 8 | Our unique workflow rules — template's primary differentiator |
| Skip | 2 | ECC content conflicts with our approach or is already covered |

## Key Finding

**Rules are the inverse of every previous category.** We are consistently larger — our git-workflow is 8.4x ECC's, Python rules 4.2x, Go rules 2.1x. This is because rules ARE the template's primary differentiator. Eight of our rules (authority-hierarchy, superpowers-integration, taskmaster-usage, workflow-enforcement, proactive-steering, context-management, reasoning-patterns, workflow-guide) have no ECC equivalent at all.

## Structural Recommendation

**Keep the consolidated approach** (1 file per language). ECC's 5-file-per-language split is a thin-stub architecture (~400-900B each) where files exist primarily to reference skills. Our consolidated files (12,725B Python, 6,114B Go, 6,721B TypeScript) provide actionable guidance from the auto-loaded rule alone, without needing to discover and invoke skills. This matches our design contract: rules are authoritative, skills are supplementary.

---

## Detailed Analysis

### Part 1: Core Rule Overlap (1 direct match)

---

#### git-workflow.md — KEEP

**Our implementation** (5231B): Comprehensive guide covering daily workflow rules, branch naming conventions, conventional commit format with full type table and rationale (changelogs, semantic versioning, searchability), recovery commands (uncommitted/committed/pushed/emergency), team collaboration rules, quick reference table, and danger commands with warnings.

**ECC implementation** (622B): Minimal reference — conventional commit types list, a note about attribution being disabled globally, and a brief PR workflow checklist. Points to `development-workflow.md` for the rest.

**Assessment**: Ours is 8.4x larger and covers substantively more ground. ECC's version is a stub.

**Verdict**: **Keep**
**Reasoning**: Recovery commands, branch naming, danger command warnings, and commit rationale are all absent from ECC's thin stub.

---

### Part 2: ECC Common Rules Without Direct Equivalents (8)

For each ECC common rule, the question is: does our existing rule set already cover this content?

---

#### agents.md (ECC common) — ADAPT

**ECC content** (1544B): Agent table (10 agents), rule for immediate/automatic agent invocation, "Parallel Task Execution" section with explicit GOOD/BAD examples, "Multi-Perspective Analysis" pattern (factual reviewer, senior engineer, security expert, consistency reviewer, redundancy checker).

**Our coverage**: Partially covered in `proactive-steering.md` (auto-invoke table, orchestration patterns) and `workflow-guide.md` (tool selection tree). `CLAUDE.md` has full 14-agent table.

**Gap**: ECC's explicit "ALWAYS use parallel Task execution for independent operations" with concrete GOOD/BAD examples is tighter than our scattered coverage. Multi-perspective sub-agent roles are novel.

**Verdict**: **Adapt** — add parallel execution mandate with GOOD/BAD examples to `proactive-steering.md`
**Reasoning**: The behavioral rule (always parallelize independent operations) and the multi-perspective pattern are additive improvements. Our agent table is already more complete.

---

#### coding-style.md (ECC common) — ADAPT

**ECC content** (1402B): Immutability as CRITICAL universal principle (never mutate existing objects). File size limits (200-400 typical, 800 max). Error handling at every level. Input validation at system boundaries. Pre-completion checklist (readable names, small functions, no deep nesting, no hardcoding, no mutation).

**Our coverage**: File size limits appear in Python rule (100-300 lines, 800 max). Error handling and input validation are in language-specific rules. No universal immutability principle. No cross-language pre-completion checklist.

**Gap**: Immutability-first framing as a CRITICAL universal principle and the pre-completion quality checklist are not in any of our common rules.

**Verdict**: **Adapt** — add immutability principle and pre-completion checklist to `claude-behavior.md`
**Reasoning**: These are genuinely universal coding principles that apply across all languages and currently live only in language-specific rules or not at all.

---

#### development-workflow.md (ECC common) — KEEP (with note)

**ECC content** (2039B): 4-step workflow: (0) Research & Reuse (GitHub code search first, then libraries, then package registries — "prefer adopting over writing net-new"), (1) Plan First, (2) TDD, (3) Code Review. References agents.

**Our coverage**: Our `workflow-guide.md` + `workflow-enforcement.md` + `superpowers-integration.md` cover steps 1-3 with far more specificity (phase detection, enforcement thresholds, task-type workflows, Superpowers integration).

**Gap**: Step 0 "Research & Reuse" mandate (search before writing) is only in MEMORY.md as a pattern, not in any auto-loaded rule.

**Verdict**: **Keep** (with targeted addition)
**Reasoning**: Our workflow rules are 4x more specific. Add "Research & Reuse" as an explicit step in `workflow-guide.md` or `workflow-enforcement.md` to codify what's currently only in memory.

---

#### hooks.md (ECC common) — SKIP

**ECC content** (768B): Three hook types (PreToolUse, PostToolUse, Stop). Permission caution (never use `--dangerously-skip-permissions`). TodoWrite best practices.

**Our coverage**: Hook types documented in `docs/HOOKS.md`. TodoWrite in `claude-behavior.md`. Permission guidance conflicts with our documented observer daemon usage.

**Verdict**: **Skip**
**Reasoning**: Permission guidance conflicts with our documented `--dangerously-skip-permissions` use in the observer daemon (intentional, thoroughly documented in MEMORY.md). TodoWrite already in claude-behavior.md.

---

#### patterns.md (ECC common) — SKIP

**ECC content** (1022B): Skeleton Projects search pattern. Repository Pattern. API Response Format envelope.

**Our coverage**: "Skeleton Projects" = our "ADOPT FIRST, ADAPT SECOND" principle. Repository and API patterns are design patterns that belong in skills, not behavioral rules.

**Verdict**: **Skip**
**Reasoning**: Design patterns belong in skills/language rules, not common behavioral rules. Skeleton Projects covered by our adopt-first principle.

---

#### performance.md (ECC common) — KEEP

**ECC content** (1599B): Model Selection Strategy (Haiku/Sonnet/Opus). Context Window Management ("avoid last 20%"). Extended Thinking modes. Build troubleshooting.

**Our coverage**: `context-management.md` covers all of this at far greater depth — full thinking mode table (think/think hard/think harder/ultrathink with token counts), token budget awareness, compaction decision tables, degradation symptom checklist.

**Verdict**: **Keep**
**Reasoning**: Our `context-management.md` is a strict superset. ECC's "avoid last 20%" is a simplification of our more nuanced degradation-symptom approach.

---

#### security.md (ECC common) — ADAPT

**ECC content** (862B): Pre-commit security checklist (no hardcoded secrets, input validation, SQL injection, XSS, CSRF, auth/authz, rate limiting, error messages). Secret Management (env vars or secret manager, rotate exposed). Security Response Protocol (STOP → security-reviewer agent → fix CRITICAL → rotate secrets → review codebase).

**Our coverage**: Language-specific rules have "Security Essentials" sections. `CLAUDE.md` references `docs/SECURITY.md` and `/security-audit`. `workflow-enforcement.md` notes security review in branch completion. But none of this is auto-loaded as a common rule.

**Gap**: Pre-commit security checklist and Security Response Protocol are not in any auto-loaded rule. Currently only in non-auto-loaded docs.

**Verdict**: **Adapt** — create new `security.md` common rule or add to `claude-behavior.md`
**Reasoning**: The pre-commit checklist (covering CSRF, rate limiting, error leakage) and the Security Response Protocol (STOP → use agent → fix → rotate → review) are concise, memorable behavioral rules that should be auto-loaded.

---

#### testing.md (ECC common) — KEEP

**ECC content** (770B): 80%+ coverage mandate. All three test types (unit + integration + E2E). TDD workflow (RED/GREEN/IMPROVE). Troubleshooting guidance. Agent auto-invocation.

**Our coverage**: `workflow-enforcement.md` covers TDD requirements by task type with enforcement thresholds, mandatory RED-GREEN-REFACTOR, 80% floor, infra/config exceptions, hotfix exception. Substantially more specific.

**Gap**: "Fix implementation, not tests (unless tests are wrong)" — worth a one-line addition.

**Verdict**: **Keep**
**Reasoning**: Our `workflow-enforcement.md` covers the same ground at higher fidelity. One-line addition: "Fix implementation, not tests."

---

### Part 3: Language Rules Structure Comparison

---

#### Python rules — KEEP (consolidated)

**Our implementation** (12,725B, 1 file): Comprehensive coverage — naming, type hints, docstrings with examples, project structure, error handling (5 patterns), logging, testing (naming, fixtures, mocking, parametrize, async), file architecture, dependencies, configuration, security essentials, modern patterns (Protocol, frozen dataclasses). Links to `python-patterns` skill.

**ECC implementation** (3,063B, 5 files): Thin stubs — `coding-style.md` (711B, PEP 8 + formatting tools), `hooks.md` (424B, auto-format config), `patterns.md` (823B, Protocol + dataclasses), `security.md` (524B, dotenv + bandit), `testing.md` (581B, pytest + coverage). Each references skills for real content.

**Assessment**: Our consolidated file is a strict superset in every dimension. ECC's Python rules are thin stubs that reference skills.

**Verdict**: **Keep**
**Reasoning**: 4.2x larger, covers everything ECC has plus comprehensive inline examples. ECC's hooks.md (PostToolUse config) is a hooks/settings concern, not a coding standard.

---

#### Golang rules — KEEP (consolidated, minor fix)

**Our implementation** (6,114B, 1 file): Error handling (check always, wrap, custom types, sentinel), naming (MixedCaps, acronyms, receivers), package design, interface design (accept interfaces/return structs, small interfaces), goroutines/concurrency, testing (table-driven, helpers, race detection), struct patterns, security, tooling.

**ECC implementation** (2,890B, 5 files): Same thin-stub pattern. Each ~400-600B referencing skills.

**Assessment**: Our file is a 2.1x superset. One improvement from ECC: "1-3 methods" specificity for interface size vs our vaguer "keep interfaces small."

**Verdict**: **Keep**
**Reasoning**: 2.1x superset. Add "1-3 methods" specificity to interface section.

---

#### TypeScript rules — KEEP (consolidated, with adaptation)

**Our implementation** (6,721B, 1 file): Strict mode, type patterns (interfaces vs types, branded types, discriminated unions), null handling, import organization (4-tier), function patterns, React/TSX, error handling, security (Zod), immutability.

**ECC implementation** (6,805B, 5 files): Near-identical total. `coding-style.md` (4,291B) is substantial — covers `interface` vs `type`, no `any`, no `React.FC` with rationale, Zod validation. Plus hooks.md, patterns.md (ApiResponse<T>, useDebounce), security.md, testing.md.

**Assessment**: Near-parity in total size. Three gaps in our version:
1. Our `paths` frontmatter only covers `.ts`/`.tsx` — misses `.js`/`.jsx` mixed codebases
2. Missing JSDoc fallback guidance for `.js` files
3. Missing `ApiResponse<T>` interface pattern
4. "No React.FC" lacks the rationale (implicit children issue)

**Verdict**: **Keep** (with targeted adaptation)
**Reasoning**: Near-parity content, but fix three gaps: add `.js`/`.jsx` to paths, add JSDoc fallback section, add ApiResponse<T> pattern, strengthen React.FC rationale.

---

#### Java rules — NEW (no ECC equivalent)

**Our implementation** (java/coding-standards.md): Java/Spring Boot patterns. ECC has no `java/` rules directory.

**Verdict**: **New**

---

#### Frontend rules — NEW (no ECC equivalent)

**Our implementation** (frontend/component-standards.md, frontend/workflow.md): React/Vue/Svelte standards and frontend workflow. ECC has no `frontend/` rules directory.

**Verdict**: **New**

---

### Part 4: Our Unique Core Rules (8) — NEW

These rules are the template's primary differentiators. ECC has no equivalents.

| Rule | Size | Purpose | ECC Coverage |
|------|------|---------|-------------|
| **authority-hierarchy.md** | 3,265B | Precedence: Rules > Superpowers > Instincts > Defaults. Override behavior. | None |
| **superpowers-integration.md** | 4,921B | Overrides brainstorming exit. Defines when each Superpowers skill is appropriate. Three doc locations. | None |
| **taskmaster-usage.md** | 3,618B | MCP vs CLI decision matrix, token-conscious viewing cadence, expansion thresholds. | None |
| **workflow-enforcement.md** | 8,414B | Normative thresholds for every task type. Branch completion sequence. Merge strategy. Session management. | ECC's development-workflow covers ~15% |
| **proactive-steering.md** | 9,262B | Co-pilot patterns, auto-invoke table, scope management, session handoff, CI verification, phase transitions. | None |
| **context-management.md** | 9,752B | Thinking modes, context budget, compaction decisions, sub-agent patterns, token optimization. | ECC's performance covers ~20% |
| **reasoning-patterns.md** | 4,876B | Clarification triggers, brainstorming-before-building, pre-completion checklist, Five Whys, tiered doc lookup. | None |
| **workflow-guide.md** | 6,318B | Commitment checkpoints, phase detection, phase-specific auto-behaviors, tool selection tree, research workflow. | ECC's development-workflow covers ~25% |

All 8 are **New** — no ECC equivalent. They represent ~50KB of auto-loaded behavioral rules that define the template's unique value proposition.

---

## Action Items (Phase 5 Execution)

### Priority 1: Targeted Adaptations (add content to existing rules)

1. **proactive-steering.md**: Add explicit parallel execution mandate with GOOD/BAD examples from ECC's agents.md. Add multi-perspective sub-agent roles.

2. **claude-behavior.md**: Add immutability-first principle and pre-completion quality checklist from ECC's coding-style.md.

3. **New security.md common rule** (or add to claude-behavior.md): Add ECC's pre-commit security checklist and Security Response Protocol as auto-loaded guardrails.

4. **workflow-guide.md** or **workflow-enforcement.md**: Add explicit "Research & Reuse" step — mandate searching for existing implementations before writing net-new code. Codify what's currently only in MEMORY.md.

5. **workflow-enforcement.md**: Add "Fix implementation, not tests (unless tests are wrong)" one-liner.

### Priority 2: Language Rule Fixes

6. **typescript/coding-standards.md**: Add `.js`/`.jsx` to paths frontmatter. Add JSDoc fallback section. Add `ApiResponse<T>` pattern. Strengthen "no React.FC" rationale.

7. **golang/coding-standards.md**: Tighten interface size to "1-3 methods."
