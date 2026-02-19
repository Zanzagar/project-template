# ECC vs Project Template: Complete Component Comparison

**Purpose:** Persistent reference for development decisions. Documents every component in both repositories, what was adopted, what was omitted, and why.

**Principle:** Implement everything from ECC unless it (a) conflicts with our workflow ideology, (b) is ECC-internal/vendor-specific, or (c) our implementation is demonstrably better — with strong justification for choosing ours, since ECC is battle-tested (45K+ stars, Anthropic hackathon winner).

**Last updated:** 2026-02-18

---

## Summary

| Category | ECC | Ours | ECC-only Gaps | Our Additions |
|----------|-----|------|---------------|---------------|
| Agents | 13 | 13 | 0 (name diff only) | 0 |
| Skills | 43 | 39 | 8 (4 evaluate, 4 skip/defer) | 8 |
| Commands | 31 | 50 | 2 | 20 |
| Rules (files) | 23+ | 12 | 17+ (content merged) | 8 |
| Hooks | ~15 | 17 | 0 behaviors | 6 behaviors |
| Contexts | 3 | 3 | 0 | 0 |
| Presets | 0 | 5 | — | 5 |

---

## AGENTS (Parity Achieved)

Both repos have 13 agents. One name difference: ECC's `build-error-resolver` = our `build-resolver`.

| Agent | ECC | Ours | Notes |
|-------|-----|------|-------|
| architect | Y | Y | Both Opus, read-only |
| build-resolver | build-error-resolver | build-resolver | Same concept, our name is shorter |
| code-reviewer | Y | Y | Ours has >80% confidence filtering |
| database-reviewer | Y | Y | |
| doc-updater | Y | Y | Both Haiku |
| e2e-runner | Y | Y | |
| go-build-resolver | Y | Y | |
| go-reviewer | Y | Y | |
| planner | Y | Y | Both Opus |
| python-reviewer | Y | Y | |
| refactor-cleaner | Y | Y | |
| security-reviewer | Y | Y | |
| tdd-guide | Y | Y | Ours is advisory; Superpowers enforces |

**Status: COMPLETE. No action needed.**

---

## SKILLS

### Matched (28 skills present in both)

| Skill | Notes |
|-------|-------|
| api-design | |
| backend-patterns | |
| continuous-learning-v2 | |
| cost-aware-llm-pipeline | Added in ECC Gap Phase 2 |
| cpp-coding-standards | Added in ECC Gap Phase 2 |
| cpp-testing | |
| database-migrations | |
| deployment-patterns | |
| django-patterns | Added in ECC Gap Phase 1 |
| django-security | |
| django-tdd | |
| django-verification | |
| docker-patterns | |
| e2e-testing | |
| eval-harness | |
| frontend-patterns | |
| golang-patterns | |
| golang-testing | |
| iterative-retrieval | |
| jpa-patterns | |
| python-patterns | |
| python-testing | |
| regex-vs-llm-structured-text | Added in ECC Gap Phase 2 |
| security-scan | |
| springboot-verification | Added in ECC Gap Phase 2 |
| strategic-compact | Added in ECC Gap Phase 1 |
| tdd-workflow | |
| verification-loop | |

### Our Additions (8 skills ECC doesn't have)

| Skill | Value |
|-------|-------|
| code-review | Dedicated review methodology with confidence thresholds |
| database-patterns | Generic SQL patterns (ECC only has PostgreSQL-specific) |
| debugging | Systematic debugging with Five Whys |
| git-recovery | Emergency git recovery procedures |
| java-springboot | Combined Java/Spring patterns |
| postgresql-patterns | PostgreSQL-specific (EXPLAIN, GiST, PostGIS) |
| python-data-science | pandas, scikit-learn, Jupyter, geostatistics |
| python-django | Combined Django ORM/middleware/signals |

### ECC Has, We Don't (12 remaining gaps)

| ECC Skill | Priority | Action | Rationale |
|-----------|----------|--------|-----------|
| ~~**strategic-compact**~~ | ~~HIGH~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 1~~ |
| ~~**django-patterns**~~ | ~~HIGH~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 1~~ |
| ~~**cpp-coding-standards**~~ | ~~MEDIUM~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 2~~ |
| ~~**cost-aware-llm-pipeline**~~ | ~~MEDIUM~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 2~~ |
| ~~**regex-vs-llm-structured-text**~~ | ~~MEDIUM~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 2~~ |
| **java-coding-standards** | LOW | EVALUATE | We have `java/coding-standards.md` as a rule + `java-springboot` skill. May have overlap. Fetch ECC's content to see if it adds value beyond our rule. |
| **springboot-patterns** | LOW | EVALUATE | We have `java-springboot` skill. ECC uses different naming (`springboot-*`). Need to compare content — may be superset. |
| **springboot-security** | LOW | EVALUATE | We have `spring-boot-security`. Compare content — likely equivalent. |
| **springboot-tdd** | LOW | EVALUATE | We have `spring-boot-tdd`. Compare content — likely equivalent. |
| ~~**springboot-verification**~~ | ~~MEDIUM~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 2~~ |
| **coding-standards** (generic) | LOW | SKIP | ECC has a generic coding-standards skill. Our approach uses language-specific rules, which is more token-efficient. Generic standards are already embedded in our core rules. |
| **configure-ecc** | SKIP | SKIP | ECC self-configuration. Not applicable to our template. |
| **continuous-learning** (v1) | SKIP | SKIP | We have v2. v1 is obsolete. |
| **project-guidelines-example** | SKIP | SKIP | Template/example, not actionable skill content. |
| **content-hash-cache-pattern** | LOW | DEFER | Niche web caching pattern. Low priority unless a web-focused preset needs it. |
| **clickhouse-io** | SKIP | SKIP | Vendor-specific (ClickHouse). Too niche for a general template. |
| **nutrient-document-processing** | SKIP | SKIP | Vendor-specific (Nutrient SDK). Not applicable. |
| **swift-actor-persistence** | LOW | DEFER | Swift language support. Implement only if Swift preset is added. |
| **swift-protocol-di-testing** | LOW | DEFER | Swift language support. Implement only if Swift preset is added. |

### Skill Gap Action Summary

| Action | Count | Skills |
|--------|-------|--------|
| DONE | 6 | strategic-compact, django-patterns, cpp-coding-standards, cost-aware-llm-pipeline, regex-vs-llm-structured-text, springboot-verification |
| EVALUATE (may merge) | 3 | java-coding-standards, springboot-patterns, springboot-security/tdd |
| SKIP (justified) | 5 | configure-ecc, continuous-learning-v1, project-guidelines-example, clickhouse-io, nutrient-document-processing |
| DEFER | 3 | content-hash-cache-pattern, swift-actor-persistence, swift-protocol-di-testing |

---

## COMMANDS

### Matched (29 commands in both)

build-fix, checkpoint, code-review, e2e, eval, evolve, go-build, go-review, go-test, instinct-export, instinct-import, instinct-status, learn, multi-backend, multi-execute, multi-frontend, multi-plan, multi-workflow, orchestrate, plan, python-review, refactor-clean, sessions, skill-create, tdd, test-coverage, update-codemaps, update-docs, verify

### Our Additions (19 commands ECC doesn't have)

| Command | Category | Value |
|---------|----------|-------|
| /brainstorm | Ideation | Structured brainstorming for features/architecture |
| /changelog | Shipping | Generate changelog from git history |
| /commit | Git | Conventional commit helper |
| /generate-tests | Testing | Auto-generate tests for a file |
| /github-sync | Integration | Sync tasks with GitHub Issues |
| /health | Infrastructure | Project health check with MCP audit |
| /lint | Quality | Run linter |
| /mcps | Infrastructure | MCP server management wizard |
| /optimize | Performance | Performance analysis |
| /plugins | Infrastructure | Plugin management |
| /pr | Shipping | Create GitHub Pull Request |
| /prd | Planning | Show/parse PRD documents |
| /prd-generate | Planning | Deep research PRD generation (novel — ECC has no equivalent) |
| /research | Research | Structured research workflow |
| /security-audit | Security | Code-level vulnerability scanning |
| /settings | Infrastructure | Configure Claude Code settings |
| /setup | Onboarding | Guided project setup (now with presets) |
| /task-status | Tasks | Update Taskmaster status |
| /tasks | Tasks | List Taskmaster tasks |
| /test | Testing | Run pytest |

### ECC Has, We Don't (2 remaining gaps)

| ECC Command | Priority | Action | Rationale |
|-------------|----------|--------|-----------|
| ~~**/multi-backend**~~ | ~~HIGH~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 1~~ |
| ~~**/multi-frontend**~~ | ~~HIGH~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 1~~ |
| ~~**/multi-workflow**~~ | ~~HIGH~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 1~~ |
| **/pm2** | LOW | DEFER | PM2 process manager. Node.js-specific deployment tool. Relevant only for Node.js projects. Could add to node-nextjs preset later. |
| **/setup-pm** | LOW | EVALUATE | Package manager auto-detection (npm/yarn/pnpm/bun). Our `/setup` covers project setup but doesn't auto-detect package managers. Could merge into setup. |

### Command Gap Action Summary

| Action | Count | Commands |
|--------|-------|----------|
| DONE | 3 | /multi-backend, /multi-frontend, /multi-workflow |
| DEFER | 1 | /pm2 |
| EVALUATE (merge into /setup) | 1 | /setup-pm |

---

## RULES

### Structural Design Decision

**ECC approach:** Granular files — `common/` (7 files) + per-language subdirs with 5 files each (coding-style, hooks, patterns, security, testing) = 23+ files.

**Our approach:** Consolidated — 7 core files + 1 file per language (5 languages) = 12 files.

**Why ours is intentionally different (JUSTIFIED):**

1. **Token cost.** ECC loads ALL rule files for a language when that language is detected. Editing a `.py` file loads 5 Python rule files (~5K+ tokens). Our approach loads 1 Python rule file (~1K tokens). Our `paths:` frontmatter means each language costs 1 file load, not 5.

2. **Overlap avoidance.** ECC's `common/testing.md` + `python/testing.md` creates overlap — generic testing advice mixed with language-specific. Our approach puts all testing guidance in either (a) the language rule (for language-specific patterns) or (b) the tdd-workflow skill (for generic TDD). No duplication.

3. **Skill delegation.** What ECC puts in rules (auto-loaded, always consuming tokens), we put in skills (on-demand, 0 startup cost). ECC's `common/security.md` rule = our `security-scan` skill. ECC's `common/performance.md` rule = our `optimize` command. Same content, different loading strategy.

**However:** This doesn't mean ECC's rule CONTENT is irrelevant. The content from their granular files should be MERGED INTO our existing structures:

### Rule Content Gap Analysis

| ECC Rule | Where Our Content Lives | Gap? |
|----------|------------------------|------|
| common/coding-style.md | Language-specific rules + claude-behavior.md | Partial — check for missing generic style guidance |
| common/git-workflow.md | git-workflow.md | No gap — ours is comprehensive |
| common/testing.md | tdd-workflow skill + language rules | Partial — check for generic testing patterns missing |
| common/performance.md | context-management.md (model selection, context budgets, thinking modes) | **No gap** — ECC's "performance" is about Claude perf (model selection, context), not app perf. Our context-management.md covers model selection, thinking tokens, compaction strategy. Misclassified in earlier analysis. |
| common/patterns.md | reasoning-patterns.md + workflow-guide.md | Partial — check for missing design patterns |
| common/hooks.md | No equivalent | Gap — no rule teaching Claude about hook authoring (LOW priority — existing hooks serve as examples) |
| common/agents.md | proactive-steering.md (auto-invocation) + /orchestrate (sequential phases, iterative evaluation, parallel execution) | **No gap** — ECC's agents.md teaches when to auto-invoke and parallel execution patterns. Our proactive-steering.md has the auto-invoke table. /orchestrate now has iterative evaluation + objective context. Content distributed differently but present. |
| common/security.md | security-scan skill + system prompt (OWASP top 10) + pre-commit-check.sh hook | **Minimal gap** — Claude's system prompt already enforces "Be careful not to introduce security vulnerabilities (command injection, XSS, SQL injection, OWASP top 10)." Our pre-commit hook validates before commits. ECC's rule is a checklist; our system prompt + hook achieves the same always-on coverage. |
| {lang}/hooks.md | Not present | Gap — per-language hook patterns (e.g., React useEffect cleanup) |
| {lang}/patterns.md | In language coding-standards files | Partial — compare content |
| {lang}/security.md | Not present per-language | Gap — language-specific security patterns |
| {lang}/testing.md | Skills (python-testing, golang-testing, etc.) | By design — testing in skills, not rules |

### Rule Gap Action Plan

Rather than splitting our files to match ECC's structure (which would multiply token cost), we should:

1. **ENRICH existing language rules** with any missing content from ECC's `{lang}/patterns.md`, `{lang}/security.md`, and `{lang}/hooks.md`. One larger file per language is still cheaper than 5 smaller files.

2. **Create 1 new skill** (not rule) for:
   - `hook-authoring` — from ECC's `common/hooks.md` (teaching Claude how to write hooks)

3. ~~Create `performance-patterns` skill~~ — **NOT NEEDED.** ECC's `common/performance.md` is about Claude performance (model selection, context budgets), not application performance. Our `context-management.md` rule already covers this. Misclassified in earlier analysis.

4. ~~Create `common/agents.md` equivalent~~ — **NOT NEEDED.** ECC's agent orchestration patterns (auto-invocation, parallel execution, iterative retrieval) are already covered by our `proactive-steering.md` rule and updated `/orchestrate` command.

---

## HOOKS

### Structural Difference

| Aspect | ECC | Ours |
|--------|-----|------|
| Language | Node.js (.js) | Bash (.sh) |
| Config | hooks.json | settings.local.json |
| Cross-platform | Better (Node works on Windows) | Linux/Mac only |
| Dependency | Requires Node.js runtime | Requires bash + standard Unix tools |
| Complexity | Higher (import/export, async) | Lower (shell scripts, pipes) |

**Design decision (JUSTIFIED):** Our bash approach is intentional for our target audience (Linux server deployment on Journel). Node.js hooks add a runtime dependency and complexity. Bash scripts are simpler to audit, modify, and debug. If Windows support becomes needed, this decision should be revisited.

### Hook Behavior Gaps

| ECC Behavior | Priority | Action | Rationale |
|-------------|----------|--------|-----------|
| ~~**PR URL extraction/logging**~~ | ~~MEDIUM~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 2 (pr-url-extract.sh)~~ |
| ~~**Long-running command tmux reminder**~~ | ~~MEDIUM~~ | ~~DONE~~ | ~~Implemented in ECC Gap Phase 2 (long-running-tmux-hint.sh)~~ |
| **Package manager auto-detection** | LOW | MERGE INTO /setup | Auto-detect npm/yarn/pnpm/bun. Useful but can be folded into our existing `/setup` command rather than a standalone hook. |

### Our Hook Additions (ECC doesn't have)

| Hook | Value | Why ECC Doesn't Need It |
|------|-------|------------------------|
| protect-sensitive-files.sh | High — prevents accidental .env edits | ECC relies on .gitignore; we actively block |
| project-index.sh | High — lightweight codebase navigation | ECC uses different codebase awareness approach |
| session-summary.sh | Medium — mid-session snapshots | ECC's evaluate-session.js covers end-of-session |
| pre-commit-check.sh | High — full validation before commit | ECC relies on CI; we enforce locally |

---

## DECISIONS LOG

### Chose Ours Over ECC (with justification)

| Component | Our Version | ECC Version | Why Ours Is Better |
|-----------|-------------|-------------|-------------------|
| `/verify` | Polyglot auto-detect (Python/JS/Go), security stage, SKIP-not-FAIL degradation | Single-stack focused | Our version adapts to any project without configuration. SKIP (tool missing) is distinct from FAIL (tool present, code broken) — this is a real UX improvement. |
| `/code-review` | >80% confidence filtering, severity tiers (critical/high/medium/low) | All findings reported | Confidence filtering reduces noise. A review with 5 high-confidence findings is more actionable than 50 unfiltered findings. ECC's approach produces review fatigue. |
| `/skill-create` | Clear confidence thresholds, clustering pipeline, explicit promotion path | Less structured | Our version has a clearer lifecycle: extract → candidate → active → skill promotion. |
| Rule structure | 1 file per language (consolidated) | 5 files per language (granular) | 5x fewer file loads = 5x less token cost for language rules. Content equivalence achieved through enrichment. |
| Hook language | Bash (.sh) | Node.js (.js) | Simpler to audit, no runtime dependency, matches deployment target (Linux server). |
| Task management | Task Master MCP (deep integration) | Not integrated | Our core differentiator. AI-powered task tracking with dependencies, expansion, status tracking. ECC has no equivalent. |
| TDD enforcement | Superpowers plugin (deletes untested code) | Advisory tdd-guide agent only | Stricter discipline: Superpowers makes it physically impossible to skip tests. **Tradeoff:** Adds ~3-5K tokens startup + significant workflow complexity (worktrees, mandatory cycles, code deletion). ECC's advisory approach is simpler and aligns with their "configuration as fine-tuning, not architecture" philosophy. Superpowers is justified for teams wanting enforced discipline but is NOT universally better — it's a strictness-vs-simplicity choice. |
| Session learning | Instinct JSON with confidence scoring (0-1), decay, authority hierarchy | evaluate-session.js | Core advantage: authority hierarchy (rules > instincts > defaults) prevents instincts from overriding explicit rules. Confidence scoring + decay prevents stale/low-quality patterns. **Tradeoff:** More machinery than ECC's simple discovery-save approach. The periphery (import/export, evolution clustering) adds complexity with diminishing returns for solo developers. Core governance is justified; full lifecycle may be over-engineered for smaller projects. |

### Chose ECC Over Ours (previously implemented)

| Component | What We Replaced | Why ECC Was Better |
|-----------|-----------------|-------------------|
| `/eval` | Metrics-only approach | ECC's feature-eval model with `pass@k` (capability) and `pass^k` (regression) is architecturally superior. Evaluates features, not just metrics. |
| `/update-codemaps` | Verbose format | ECC's token-lean format with freshness metadata, diff detection (30% threshold), and staleness warnings uses less context for more information. |

### Adopted Best of Both (merged)

| Component | What We Took From ECC | What We Kept From Ours |
|-----------|----------------------|----------------------|
| `/orchestrate` | bugfix + security pipelines, parallel execution, file-persisted outputs, iterative agent evaluation (max 3 cycles), objective context passing | Our base pipeline structure, sub-agent isolation (stronger than manual `/clear`) |
| `/checkpoint` | verify + list subcommands | Our richer content format with task/reasoning/session |
| `/update-docs` | Multi-source (package.json, .env, routes), staleness detection | Our agent-based approach |

---

## IMPLEMENTATION PRIORITY QUEUE

### Phase 1: High-Value Gaps (COMPLETE — 2026-02-18)

| # | Type | Component | Est. Effort | Status |
|---|------|-----------|-------------|--------|
| 1 | Command | /multi-backend | Medium | DONE |
| 2 | Command | /multi-frontend | Medium | DONE |
| 3 | Command | /multi-workflow | Medium | DONE |
| 4 | Skill | strategic-compact | Small | DONE |
| 5 | Skill | django-patterns | Small | DONE |
| 6 | Rule enrichment | Enrich Python/TS/Go rules with ECC's security + patterns content | Medium | DONE |

### Phase 2: Medium-Value Gaps (COMPLETE — 2026-02-18)

| # | Type | Component | Est. Effort | Status |
|---|------|-----------|-------------|--------|
| 6 | Rule enrichment | Python/TS/Go security essentials + modern patterns | Medium | DONE |
| 7 | Skill | cpp-coding-standards | Small | DONE |
| 8 | Skill | cost-aware-llm-pipeline | Small | DONE |
| 9 | Skill | regex-vs-llm-structured-text | Small | DONE |
| 10 | Skill | springboot-verification | Small | DONE |
| 11 | Hook | PR URL extraction (pr-url-extract.sh) | Small | DONE |
| 12 | Hook | Long-running tmux reminder (long-running-tmux-hint.sh) | Small | DONE |
| -- | Command | /prd-generate (novel — deep research PRD generation) | Medium | DONE |
| ~~13~~ | ~~Skill~~ | ~~performance-patterns~~ | ~~Small~~ | ~~REMOVED — misclassified gap. ECC's performance.md is about model selection/context, which our context-management.md already covers.~~ |

### Phase 3: Low-Value / Evaluate

| # | Type | Component | Est. Effort | Notes |
|---|------|-----------|-------------|-------|
| 14 | Evaluate | java-coding-standards vs our rule | Small | May have overlap |
| 15 | Evaluate | springboot-* naming vs our spring-boot-* | Small | Content comparison needed |
| 16 | Evaluate | /setup-pm merge into /setup | Small | Package manager detection |
| 17 | Skill | content-hash-cache-pattern | Small | Only if web preset needs it |

### Intentionally Skipped (not implementing)

| Component | Reason |
|-----------|--------|
| configure-ecc | ECC-internal self-configuration tool |
| continuous-learning v1 | We have v2, v1 is obsolete |
| project-guidelines-example | Template/example, not actionable content |
| clickhouse-io | Vendor-specific (ClickHouse), too niche |
| nutrient-document-processing | Vendor-specific (Nutrient SDK), not applicable |
| swift-* skills | Defer until Swift preset requested |
| /pm2 | Node.js-specific deployment, defer until needed |
| Splitting rules into 5 files per language | Token cost multiplication. Enrich existing files instead. |
| Node.js hooks | Bash is simpler, matches target platform |

---

## HOW TO USE THIS DOCUMENT

When implementing a gap from the priority queue:

1. **Fetch ECC's source** for the component: `WebFetch` the raw file from `github.com/affaan-m/everything-claude-code`
2. **Compare** against any existing overlap in our template
3. **Adapt** to our conventions (naming, structure, token awareness)
4. **Document** the decision in this file's Decisions Log section
5. **Update** counts in TEMPLATE_OVERVIEW.md, CHANGELOG.md, and this file's summary table

When choosing our implementation over ECC's:
- Default to ECC unless you have a strong, specific reason
- "Our way is different" is NOT sufficient justification
- "Our way is better because [specific technical reason]" IS sufficient
- Document the reasoning in the Decisions Log above
