# Agents Audit Decisions

## Inventory

**Our agents**: 14 in `.claude/agents/`
**ECC agents**: 25 in `agents/`
**Superpowers agents**: 1 (code-reviewer.md — compared in Task 9)
**Overlapping**: 13 (12 exact name + 1 near-match)
**Our unique**: 1 (observer)
**ECC-only evaluated**: 12
**Audit date**: 2026-03-19

## Summary

| Verdict | Count | Description |
|---------|-------|-------------|
| Adopt | 4 | ECC version is dramatically more capable |
| Adapt | 9 | Merge ECC structural improvements while keeping our unique content |
| New | 1 | observer — unique architecture, no ECC equivalent |
| Skip ECC-only | 10 | Language-specific (plugin) or requires external infrastructure |
| Defer ECC-only | 2 | Depends on infrastructure we haven't built yet |

## Key Finding

ECC is larger for **every single overlapping agent** — ratios range from 1.1x to 13.7x. The pattern: our agents have correct frontmatter (model selection, tool access) but thin instructions. ECC agents have rich process workflows, worked examples, approval criteria, and self-orientation steps (`git diff` on invocation). The most critical gaps are missing tools (`Bash` absent from code-reviewer, go-reviewer, python-reviewer — preventing self-orientation via `git diff` and static analysis).

---

## Detailed Analysis — Overlapping Agents (13)

---

### architect — ADAPT

**Our implementation** (1804B): Opus model, read-only tools [Read, Grep, Glob]. Four capability areas (scalability, API boundaries, data flow, technology selection). Mandates ADR output format with Decision/Context/Options/Consequences/Diagram sections. Cleanly distinguishes architect from planner role.

**ECC implementation** (6291B): Same model and tools. Six-step review process, five architectural principles with sub-bullets, frontend/backend/data patterns catalog, filled-out ADR example using Redis vector search, system design checklist with 4 categories (functional, non-functional, technical, operations), red-flags anti-patterns list (Big Ball of Mud, Analysis Paralysis, God Object), and a scaling ladder example.

**Assessment**:
- Frontmatter: Identical model and tools. ECC uses "PROACTIVELY" activation language
- Instructions: ECC adds system design checklist catching non-functional requirements (performance targets, availability %, rollback plan) we omit entirely. Red-flags vocabulary is valuable. Worked ADR example shows expected detail level
- Template integration: Our planner/architect distinction is template-specific value worth keeping

**Verdict**: **Adapt**
**Reasoning**: ECC's checklist, anti-patterns catalog, and worked ADR example substantially increase usefulness; our planner/architect distinction must be preserved.
**Adaptation**: Keep our "Distinct from planner" preamble. Append ECC's system design checklist, red-flags list, and worked ADR example. Strip ECC's SaaS-specific architecture example.

---

### code-reviewer — ADOPT

**Our implementation** (647B): Sonnet, read-only [Read, Grep, Glob] — no Bash. Three review rules (>80% confidence, severity categories, consolidate findings), brief Python-specific section with four patterns, two-line output format. No process steps, no checklist, no approval criteria.

**ECC implementation** (8847B): Sonnet, adds Bash for `git diff`. Five-step review process (gather context via git diff, understand scope, read surrounding code, apply checklist, report). Confidence-based filtering. Comprehensive security section with SQL injection and XSS code examples. Code quality with before/after examples. React/Next.js patterns, Node.js/backend patterns. Structured summary table with verdict (Approve/Warning/Block). v1.8 AI-generated code review addendum. "Check CLAUDE.md for project conventions" integration point.

**Assessment**:
- Frontmatter: Missing `Bash` is a critical gap — our reviewer cannot see what changed without being explicitly told
- Instructions: The gap is fundamental — no process, no self-orientation via `git diff`, no approval criteria. Python-specific content belongs in `python-reviewer`, not here
- Template integration: ECC's "check CLAUDE.md" is a direct integration point with our template pattern

**Verdict**: **Adopt**
**Reasoning**: 13.7x size difference with fundamental gaps: no `git diff` self-orientation, no approval criteria, no framework-specific guidance, and a Python section that doesn't belong here.
**Adaptation**: Start from ECC. Remove or tag React/Next.js patterns as frontend-only. Keep >80% confidence rule. Add `Bash` to tools.

---

### database-reviewer — ADAPT

**Our implementation** (2022B): Sonnet, tools include Bash. Five review areas (query performance, index suggestions, N+1 detection, migration safety, schema design). Output format with Impact field. Concrete psql diagnostics. Python ORM-specific N+1 patterns (Django/SQLAlchemy).

**ECC implementation** (4348B): Same model, adds Write and Edit. Adds RLS (Row Level Security) as top-tier concern. Anti-patterns table (use bigint not int, text not varchar(255), timestamptz not timestamp, UUIDv7 not random UUID). Cursor pagination pattern. SKIP LOCKED for queues. Review checklist. References `postgres-patterns` and `database-migrations` skills.

**Assessment**:
- Frontmatter: ECC adds Write/Edit for generating migration files or fixes. Reasonable
- Instructions: ECC's anti-patterns table is significantly more actionable. RLS covers an important security dimension we miss. Our migration safety section (zero-downtime, rollback, lock-aware ALTER) is better
- Template integration: Neither references template components

**Verdict**: **Adapt**
**Reasoning**: ECC's anti-patterns table and RLS section are substantive improvements; our migration safety section is more thorough.
**Adaptation**: Keep our migration safety section. Add ECC's anti-patterns table, RLS section, cursor pagination. Add Write/Edit to tools.

---

### doc-updater — ADAPT (minor)

**Our implementation** (1712B): Haiku (cost-conscious), tools [Read, Write, Edit, Grep, Glob]. Four capability areas (README, docstrings, API docs, CHANGELOG). Five preservation rules (preserve structure, don't add content, match style, only update changed, no emojis). Explains haiku model choice.

**ECC implementation** (3383B): Same model, adds Bash for codemap generation scripts. Primary purpose pivots to codemap generation via TypeScript AST analysis. Codemap format specification. Quality checklist. "ALWAYS update" vs "OPTIONAL update" distinction.

**Assessment**:
- Agents have diverged in purpose: ours is general documentation maintainer, ECC's is codemap specialist
- Our preservation rules are better for general documentation
- ECC's when-to-update distinction and codemap format are additive

**Verdict**: **Adapt (minor)**
**Reasoning**: Our documentation maintenance instructions are better for general use. Adopt ECC's codemap format spec and when-to-update table.
**Adaptation**: Add codemap format spec and when-to-update table. Remove ECC's TypeScript toolchain commands (don't exist in our template). Keep our preservation rules and model rationale.

---

### e2e-runner — ADAPT

**Our implementation** (2208B): Sonnet, tools [Read, Bash, Grep, Glob] — no Write/Edit. Supported frameworks table (Playwright, Cypress, Selenium). Five-step debugging workflow. Four common issue categories with symptoms and fixes.

**ECC implementation** (4100B): Same model, adds Write and Edit. Introduces Agent Browser as preferred tool (ECC-specific). Page Object Model guidance. Flaky test quarantine with `test.fixme()`. Success metrics (100% critical journeys, >95% pass rate, <5% flaky, <10 min). Three-phase workflow (Plan → Create → Execute).

**Assessment**:
- Frontmatter: Missing Write/Edit is a real gap — agent can't create test files
- Instructions: Ours is debugging-focused; ECC is creation-focused. Agent Browser is ECC-specific. Flaky quarantine and success metrics are useful additions. Our debugging workflow is more detailed

**Verdict**: **Adapt**
**Reasoning**: Missing Write/Edit tools is a real gap. ECC's flaky test quarantine and success metrics add practical value.
**Adaptation**: Add Write and Edit to tools. Add flaky test handling and success metrics. Keep our debugging workflow. Remove Agent Browser content.

---

### go-build-resolver — ADAPT

**Our implementation** (2050B): Sonnet, all tools including Bash. Four problem categories (modules, CGO, cross-compilation, linker) with bash examples. Common-problems table. Reference-card style.

**ECC implementation** (3266B): Same model/tools. Resolution workflow as linear flowchart (build → read → fix → verify → vet → test). Common fix patterns table (10 error types). Stop conditions (same error after 3 attempts, more errors than fixed, architectural scope). Structured output format.

**Assessment**:
- ECC's workflow with verify gates is more procedurally disciplined than our reference-card approach
- Our CGO section is significantly more detailed (missing headers, compiler selection, shared libs)
- ECC's stop conditions prevent infinite retry loops

**Verdict**: **Adapt**
**Reasoning**: ECC's workflow structure and stop conditions are materially better; our CGO and cross-compilation sections are more thorough.
**Adaptation**: Replace unstructured instructions with ECC's workflow steps. Keep our CGO and cross-compilation sections. Add stop conditions and output format.

---

### go-reviewer — ADOPT

**Our implementation** (1678B): Sonnet, read-only [Read, Grep, Glob] — no Bash. Covers error handling, goroutine safety, interface design, package structure, tooling patterns.

**ECC implementation** (2788B): Same model, adds Bash for `git diff`, `go vet`, `staticcheck`, `golangci-lint`, `go build -race`, `govulncheck`. Invocation preamble (run `git diff -- '*.go'` first). Security CRITICAL section (SQL injection, command injection, path traversal, race conditions, insecure TLS). Error handling CRITICAL. Concurrency HIGH. Approval criteria (Approve/Warning/Block).

**Assessment**:
- Frontmatter: Missing Bash prevents running `go vet` or `git diff` — significant gap
- Instructions: Security CRITICAL section is entirely absent in ours — no mention of SQL injection or insecure TLS in a Go reviewer
- Our interface design section is slightly more detailed but the gap is small

**Verdict**: **Adopt**
**Reasoning**: Missing Bash and absent security CRITICAL section are substantive gaps.
**Adaptation**: Start from ECC. Keep our interface design section (1-3 methods rule, "define at point of use"). Add Bash.

---

### planner — ADOPT

**Our implementation** (710B): Opus, read-only [Read, Grep, Glob]. Minimal: role statement, five bullet responsibilities, five-item output format list. No process, no examples, no sizing guidance.

**ECC implementation** (7070B): Same model/tools. Four-phase planning process (requirements analysis, architecture review, step breakdown, implementation order). Per-step fields (file path, action, why, dependencies, risk level). Best practices (7 items). Worked example planning Stripe billing with explicit file paths and risk ratings. Sizing/phasing guide (Phase 1 MVP → Phase 4 optimization). Red-flags checklist.

**Assessment**:
- Instructions: 10x content difference. ECC's worked example shows expected granularity. Our output format is a bare list — developers don't know what detail level to expect
- Template integration: Neither references Task Master — an integration opportunity

**Verdict**: **Adopt**
**Reasoning**: 10x content gap represents 10x practical value — the worked example and per-step fields transform this from a vague role description into a usable specification tool.
**Adaptation**: Start from ECC. Add template note: "For multi-task features, output feeds into Task Master parse-prd workflow." Add our architect/planner distinction. Replace Stripe-specific example with generic alternative.

---

### python-reviewer — ADAPT

**Our implementation** (3057B): Sonnet, read-only [Read, Grep, Glob] — no Bash. Covers async/await (structured concurrency, asyncio.to_thread), metaclasses, descriptors, GIL implications, packaging (pyproject.toml), late-binding closures, mutable defaults, import cycles.

**ECC implementation** (3408B): Same model, adds Bash for `git diff`, mypy, ruff, bandit, pytest. Invocation preamble (run `git diff -- '*.py'` first). Security CRITICAL section (SQL injection, command injection, path traversal, eval/exec, unsafe deserialization). Approval criteria (Approve/Warning/Block). Framework checks (Django N+1, FastAPI async, Flask CSRF).

**Assessment**:
- Frontmatter: Missing Bash prevents static analysis invocation
- Instructions: Complementary not redundant — ECC is "practical review checklist," ours is "deep Python internals." ECC has security CRITICAL entirely absent in ours. Our async/await, metaclass, descriptor, and GIL sections are more detailed than anything in ECC
- Template integration: Our "Complements code-reviewer" framing should be preserved

**Verdict**: **Adapt**
**Reasoning**: The agents are genuinely complementary — merge ECC's security section, invocation preamble, and approval criteria into ours while keeping our deep internals value.
**Adaptation**: Add Bash. Add ECC's invocation preamble and security CRITICAL section. Add approval criteria. Keep our async/await, metaclass, descriptor, GIL, and packaging sections. Keep "Complements code-reviewer" framing.

---

### refactor-cleaner — ADAPT (minor)

**Our implementation** (1919B): Sonnet, all write tools. Four rules (preserve tests, no behavior change, extract-then-inline, atomic changes). Five capabilities. Five-step safety process (baseline tests → atomic change → verify → commit → revert on failure). Anti-patterns.

**ECC implementation** (2707B): Same model/tools. Detection-tools-first workflow (knip, depcheck, ts-prune — JS-specific). SAFE/CAREFUL/RISKY risk classification. When-NOT-to-use guidance (active development, pre-deploy, insufficient coverage). Success metrics.

**Assessment**:
- Different philosophies: ours is language-agnostic and safety-focused; ECC is TypeScript-ecosystem focused
- ECC's risk classification and when-NOT-to-use add practical guardrails
- Our five-step safety process is more rigorous

**Verdict**: **Adapt (minor)**
**Reasoning**: Our safety process is better; ECC's risk classification and guardrails are worth merging.
**Adaptation**: Keep our safety process. Add ECC's SAFE/CAREFUL/RISKY classification and when-NOT-to-use section. Replace TypeScript tools with language-appropriate alternatives.

---

### security-reviewer — ADOPT

**Our implementation** (698B): Sonnet, tools include Bash. Minimal: five focus areas, false-positive awareness (3 items), four-field output format. No process, no OWASP breakdown, no specific patterns.

**ECC implementation** (4480B): Same model, adds Write/Edit. Five-step workflow (initial scan → OWASP Top 10 → code pattern review → reporting). Analysis commands. Full OWASP Top 10 checklist with items and what to check. Patterns table (11 rows with severity and fix). Key defense principles. Emergency response protocol (5-step). When-to-run guidance.

**Assessment**:
- Frontmatter: ECC adds Write/Edit for creating security reports or fixes
- Instructions: 6.4x gap — our version is a stub. ECC has complete OWASP checklist, patterns table, emergency response protocol

**Verdict**: **Adopt**
**Reasoning**: Our version is a stub with three bullet points. 6.4x content gap is almost entirely additional operational value.
**Adaptation**: Start from ECC. Add Write/Edit. Replace `npm audit`/`eslint-plugin-security` with language-conditional equivalents (bandit for Python, govulncheck for Go). Keep all OWASP sections. Keep emergency response protocol.

---

### tdd-guide — ADAPT (minor)

**Our implementation** (2325B): Sonnet, tools [Read, Write, Edit, Grep, Glob] — no Bash. Critical frontmatter constraint: "NEVER write production code — only tests." Scoped to coaching RED phase only. Four capability sections. Example prompts. Arrange/Act/Assert test format. Explicit Superpowers integration note.

**ECC implementation** (2884B): Same model, adds Bash (for running tests). Six-step TDD workflow. Test types table. Eight mandatory edge cases. Test anti-patterns. Quality checklist (8 items). v1.8 eval-driven TDD addendum.

**Assessment**:
- Frontmatter: Missing Bash means agent can't run tests to verify RED/GREEN — important gap
- Instructions: Near-parity in quality. Our "NEVER write production code" constraint and Superpowers framing are critical template-specific content. ECC's edge cases list and anti-patterns are additive

**Verdict**: **Adapt (minor)**
**Reasoning**: Both are near-parity; ours has critical Superpowers integration. ECC's edge cases, anti-patterns, and quality checklist are additive.
**Adaptation**: Keep our "NEVER write production code" constraint and Superpowers framing verbatim. Add Bash to tools. Add ECC's eight mandatory edge cases, anti-patterns, and quality checklist. Drop ECC's six-step workflow (redundant with Superpowers skill).

---

### build-resolver vs build-error-resolver — ADAPT

**Our implementation** (499B): Sonnet, all write tools. Extremely minimal: three DO items, four DON'T items, five-step process. Smallest agent in template.

**ECC implementation** (3770B): Same model/tools. Five core responsibilities. Diagnostic commands. Two-phase workflow (collect ALL errors first → categorize → fix in priority order). Common fixes table (10 TypeScript error types). Priority levels (CRITICAL/HIGH/MEDIUM). Nuclear cache-clearing commands. Success metrics. When-NOT-to-use routing table.

**Assessment**:
- Our version is dangerously thin (499B) but language-agnostic
- ECC's "collect all errors first" strategy is better than our sequential approach
- ECC is too TypeScript/Next.js-specific for our Python-primary template
- ECC's when-NOT-to-use routing table prevents scope creep

**Verdict**: **Adapt**
**Reasoning**: Current version at 499B is too thin; adopt ECC's structural improvements while replacing TypeScript-specific content with multi-language patterns.
**Adaptation**: Keep language-agnostic spirit. Replace TypeScript diagnostics with multi-language alternatives. Keep ECC's "collect all errors first" workflow, priority levels, when-NOT-to-use routing, and success metrics.

---

### observer — NEW

**Our implementation** (unique): Haiku model (cost-appropriate). Runs as daemon, not interactive agent. Input: observations.jsonl. Four pattern detection types (user corrections, error resolutions, repeated workflows, tool preferences). Output: instinct markdown files. Confidence calculation with weekly decay.

**ECC equivalent**: None — ECC runs observer as a shell-invoked daemon, not a Claude Code agent.

**Verdict**: **New**
**Reasoning**: Template-original architecture with no ECC counterpart. Haiku model selection and confidence scoring are well-specified.

---

## ECC-Only Agents — Evaluated (12)

### Skip — Language-Specific (8)

| Agent | Verdict | Reason |
|-------|---------|--------|
| cpp-build-resolver | Skip | Plugin responsibility |
| cpp-reviewer | Skip | Plugin responsibility |
| java-build-resolver | Skip | Plugin responsibility |
| java-reviewer | Skip | Plugin responsibility |
| kotlin-build-resolver | Skip | Plugin responsibility |
| kotlin-reviewer | Skip | Plugin responsibility |
| rust-build-resolver | Skip | Plugin responsibility |
| rust-reviewer | Skip | Plugin responsibility |

### Skip — External Infrastructure (2)

---

#### chief-of-staff (ECC-only) — SKIP

**Purpose**: Personal communication triage agent across Gmail, Slack, LINE, Messenger. Opus model. Requires Gmail CLI (`gog`), `SOUL.md`, `private/relationships.md`, calendar scripts, optional Slack MCP.

**Verdict**: **Skip**
**Reasoning**: Personal productivity agent, not software development. Hard external dependencies that don't exist in the template. Unrelated to template's purpose.

---

#### docs-lookup (ECC-only) — SKIP

**Purpose**: Documentation specialist wrapping Context7 MCP into agent interface. Sonnet, read-only. Caps at 3 MCP calls. Prompt-injection resistance note.

**Verdict**: **Skip**
**Reasoning**: Our template already integrates Context7 in `reasoning-patterns.md` (Tier 3 lookup). Wrapping it in a sub-agent adds overhead for what amounts to two MCP tool calls. The prompt-injection note is a one-line addition to existing Context7 guidance, not a reason for a whole agent.

### Defer — Infrastructure Not Ready (2)

---

#### harness-optimizer (ECC-only) — DEFER

**Purpose**: Configuration audit agent. Runs `/harness-audit` to collect baseline score, identifies top-3 leverage areas, proposes minimal reversible config changes, applies and reports deltas. Sonnet + Edit access.

**Verdict**: **Defer** — after v2.5.0 Task 11 (harness-audit)
**Reasoning**: Depends on scoring system and `/harness-audit` command that don't exist yet. Adopt after Task 11 defines our scoring surface.

---

#### loop-operator (ECC-only) — DEFER

**Purpose**: Autonomous loop management agent. Monitors for stalls and retry storms, enforces stop conditions, manages scope reduction, escalates on cost drift. Sonnet + Edit. Requires: quality gates, eval baseline, rollback path, branch isolation.

**Verdict**: **Defer** — after regression testing infrastructure
**Reasoning**: Meaningful only with autonomous loop infrastructure, eval baselines, and cost budgets we don't have. Defer until AI regression testing and loop-start/loop-status commands are adopted.

---

## Action Items (Phase 5 Execution)

### Priority 1: Adopt (replace with ECC, minimal adaptation) — 4 agents
- **code-reviewer**: Add Bash, remove React/Next.js or tag as frontend-only
- **go-reviewer**: Add Bash, keep our interface design section
- **planner**: Add Task Master integration note, replace Stripe example
- **security-reviewer**: Add Write/Edit, replace JS tools with polyglot alternatives

### Priority 2: Adapt (merge specific sections) — 9 agents
- **architect**: Add checklist, anti-patterns, worked ADR; keep planner distinction
- **database-reviewer**: Add anti-patterns table, RLS; keep migration safety section
- **doc-updater**: Add codemap format spec, when-to-update table
- **e2e-runner**: Add Write/Edit tools, flaky quarantine, success metrics
- **go-build-resolver**: Adopt workflow structure and stop conditions; keep CGO section
- **python-reviewer**: Add Bash, security CRITICAL, approval criteria; keep internals sections
- **refactor-cleaner**: Add risk classification and when-NOT-to-use
- **tdd-guide**: Add Bash, edge cases list, anti-patterns; keep Superpowers constraint
- **build-resolver**: Adopt workflow structure, priority levels, routing table; make polyglot
