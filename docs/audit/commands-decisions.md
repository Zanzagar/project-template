# Commands Audit Decisions

## Inventory

**Our commands**: 48 in `.claude/commands/`
**ECC commands**: 57 in `commands/`
**Superpowers commands**: 3 (all deprecated)
**Overlapping**: 26 (exact name match)
**Our unique**: 22 (no ECC equivalent)
**ECC-only evaluated**: 31
**Audit date**: 2026-03-19

## Summary

| Verdict | Count | Description |
|---------|-------|-------------|
| Adopt (update) | 10 | ECC version has worked examples or richer content |
| Adapt | 1 | Partial adopt of output format |
| Keep | 15 | Our version is better (template-integrated, richer, or superset) |
| New | 22 | Unique to us, no ECC equivalent |
| Add from ECC | 5 | New commands to add |
| Defer | 3 | Relevant but depends on v2.5.0 infrastructure |
| Skip ECC-only | 23 | Requires ECC infrastructure, language-specific (plugin), or already covered |
| Superpowers | 3 | All deprecated, no action needed |

---

## Detailed Analysis — Overlapping Commands (26)

### Category A: Development Workflow & Session Commands

---

#### build-fix — KEEP

**Our implementation** (2517B): Incrementally fixes build/type errors one at a time. Detects 8 build systems including Makefile. Groups errors by file/dependency order. Guardrails: stop on 3 retries, architectural changes, missing deps. Invokes `build-resolver` agent.

**ECC implementation** (2297B): Functionally identical 7-step structure, same "one error at a time" philosophy. Does NOT include Makefile detection. No agent cross-reference. Slightly more verbose summary output with file paths.

**Assessment**:
- Content depth: Effectively identical in procedure and guardrails
- Template integration: Ours references `build-resolver` agent; ECC has no agent cross-reference
- Unique value: Ours adds Makefile support (legitimate polyglot improvement) and agent reference

**Verdict**: **Keep**
**Reasoning**: Substantively identical; ours adds Makefile detection and agent invocation reference. Nothing in ECC's version justifies replacing ours.

---

#### checkpoint — KEEP

**Our implementation** (3518B): Saves structured markdown to `.claude/sessions/checkpoint-YYYYMMDD-HHMMSS.md` capturing Task Master task, recent commits, active reasoning, modified files, next steps, open questions. Includes verify subcommand (compares test counts/build status since checkpoint) and list subcommand. Integrated with `session-init.sh` hook and work log. Covers 5 use-case scenarios.

**ECC implementation** (1520B): Git stash/commit + simple `.claude/checkpoints.log` append. create/verify/list/clear subcommands. Verify compares files, test pass rate, coverage. No markdown file creation, no session hook integration, no Task Master awareness.

**Assessment**:
- Content depth: Ours is 2.3x larger with rich context capture including reasoning and Task Master state
- Template integration: Ours integrates with `session-init.sh`, `session-end.sh`, work log, Task Master. ECC is standalone git-based
- Unique value: Ours: rich session context capture, hook integration. ECC: `clear` subcommand (keeps last 5)

**Verdict**: **Keep**
**Reasoning**: Purpose-built for this template's session persistence model. ECC's git-centric alternative loses the context-continuity value. Backport ECC's `clear` subcommand.

---

#### verify — KEEP

**Our implementation** (3558B): Multi-stage pipeline with embedded bash detection code for pytest/npm/go test, ruff/eslint/golangci-lint, mypy/tsc, bandit/npm audit/gosec. Scope options: all/test/lint/types/security/pre-commit. PASS/WARN/FAIL/SKIP result levels with worst-case aggregation. Explains WARN-not-FAIL for coverage. References `/test`, `/lint`, `/security-audit`.

**ECC implementation** (1197B): Narrative procedure, no embedded bash. Five stages: build, type, lint, test, console.log audit, git status. Scope: quick/full/pre-commit/pre-pr. Pre-PR adds security. Compact one-line-per-stage output. Secrets check (not in ours).

**Assessment**:
- Content depth: Ours is 3x larger with actual runnable detection snippets and 4 result levels
- Template integration: Ours references `/test`, `/lint`, `/security-audit` by name. ECC is standalone
- Unique value: Ours: runnable bash snippets, SKIP level for missing tools, polyglot detection. ECC: secrets check, `pre-pr` scope, console.log audit stage

**Verdict**: **Keep**
**Reasoning**: Operationally superior — actual bash detection snippets that Claude can execute, graceful SKIP for missing tools. Add ECC's secrets check and `pre-pr` scope alias.

---

#### tdd — ADOPT (with adaptation)

**Our implementation** (2697B): RED-GREEN-REFACTOR cycle explanation, coverage requirements table (80% general, 100% auth/financial/security), framework detection table (6 frameworks), DO/DON'T list, Superpowers integration note ("will delete production code without failing tests").

**ECC implementation** (8283B): Same procedural content plus a full worked TypeScript example — interface definition through implementation, refactoring, and coverage verification with actual code blocks at every step. Test type taxonomy (unit/integration/E2E). Agent invocation documented.

**Assessment**:
- Content depth: ECC is 3.1x larger, entirely due to the worked example
- Template integration: Ours mentions Superpowers enforcement (critical for this template). ECC has no Superpowers reference
- Unique value: ECC's worked example shows what each TDD phase output should look like, reducing ambiguity. Ours has Superpowers context

**Verdict**: **Adopt (with adaptation)**
**Reasoning**: The worked example gives Claude concrete reference for TDD phase outputs. Must preserve our Superpowers enforcement section.
**Adaptation**: Start from ECC's content, add our "If Superpowers plugin is installed... will delete production code" section before agent reference.

---

#### plan — ADOPT (with adaptation)

**Our implementation** (2073B): Invokes `planner` agent (opus, read-only). 5-step planning process, output format template, mandatory user approval, integration with `/tdd`, `/build-fix`, `/code-review`, `/orchestrate review`.

**ECC implementation** (3641B): Same 5 steps plus a full worked example (real-time notifications system): phase breakdown with sub-steps, dependency list, risk tiers with rationale, time estimates, "WAITING FOR CONFIRMATION" gate. Plan modification dialogue pattern (`modify: [changes]`).

**Assessment**:
- Content depth: ECC's worked example demonstrates risk tiering, time estimates, and plan iteration
- Template integration: Ours references `/orchestrate review` (ECC does not)
- Unique value: ECC's worked example improves Claude's plan quality. Ours has pipeline integration

**Verdict**: **Adopt (with adaptation)**
**Reasoning**: Worked example with risk tiers and time estimates teaches plan quality. Add back `/orchestrate review` integration.
**Adaptation**: Take ECC's content, add `/orchestrate review` to "Integration" section.

---

#### sessions — KEEP

**Our implementation** (2245B): Simple session history viewer. Lists `.claude/sessions/` files, categorizes by type (summary/checkpoint/pre-compact), shows most recent, age-labels, suggests clean at 20+ files. No Node.js dependencies.

**ECC implementation** (10538B): Full session management system backed by `session-manager` and `session-aliases` Node.js modules. list/load/alias/unalias/info subcommands. Sessions carry metadata: branch, worktree, project name, statistics. Aliases persist in JSON. Designed for swarm monitoring. Requires `~/.claude/scripts/lib/session-manager`.

**Assessment**:
- Content depth: ECC is 4.7x larger with entirely different capability tier
- Template integration: Ours integrates with session-end.sh and session-init.sh hooks (project-local). ECC reads global `~/.claude/sessions/`
- Unique value: ECC: alias system, rich metadata, swarm support. Ours: project-local, hook integration, zero dependencies

**Verdict**: **Keep**
**Reasoning**: ECC requires `session-manager` and `session-aliases` Node.js modules that don't exist in our template. Would be non-functional without porting their library infrastructure. Ours correctly integrates with our bash hooks.

---

#### learn — KEEP

**Our implementation** (3142B): Manual pattern extraction with 4 categories (error resolution, debugging, workarounds, project-specific). Dual output: instinct (YAML to `.claude/instincts/personal/`) or skill (`SKILL.md` to `.claude/skills/learned/`). Documents instinct lifecycle (confidence 0.5 start, >0.7 active, -0.02/week decay, authority hierarchy). Pipeline context (observe.sh → observer daemon vs manual). Integration with `/instinct-status`, `/evolve`, `/instinct-export`, `/skill-create`.

**ECC implementation** (1605B): Same extraction categories. Outputs only skill files to global `~/.claude/skills/learned/`. No instinct output option, no authority hierarchy, no pipeline context.

**Assessment**:
- Content depth: Ours is 2x larger with dual output types, lifecycle docs, system integration
- Template integration: Ours is deeply integrated with instinct system, observer daemon, authority hierarchy. ECC is standalone

**Verdict**: **Keep**
**Reasoning**: Dual instinct/skill output path and integration with the template's learning pipeline are essential features ECC lacks.

---

#### skill-create — KEEP (selective backport)

**Our implementation** (3378B): Git-history analysis over configurable time window. Extracts commit types, co-change clusters, fix hotspots, test patterns. Confidence ratings (HIGH ≥6, MEDIUM 3-5, LOW 2). Requires user review before saving. Flags: `--days`, `--min-pattern`, `--include-fixes`, `--dry-run`.

**ECC implementation** (4529B): Same core concept. Adds `--commits N` flag (count vs date window), `--output <dir>`, `--instincts` flag for instinct candidates. No confidence table, no user review gate. Saves to global `~/.claude/skills/`.

**Assessment**:
- Template integration: Ours saves project-local. ECC saves global. Our user review gate is a deliberate quality control
- Unique value: ECC: `--commits N` and `--output` flags. Ours: confidence table, mandatory review gate

**Verdict**: **Keep (selective backport)**
**Reasoning**: User review gate and confidence table are deliberate quality controls. Backport `--commits N` and `--output <dir>` flags.

---

#### refactor-clean — KEEP

**Our implementation** (2821B): 6-step dead code removal with SAFE/CAUTION/DANGER tiers. Scope option. Invokes `refactor-cleaner` agent. Integration with `/code-review`, `/orchestrate refactor`.

**ECC implementation** (2803B): Structurally identical 6-step process, same tier table, same deletion loop. No agent reference, no scope option, no integration references.

**Assessment**: Near-identical. Ours has scope option, agent reference, and pipeline integration.

**Verdict**: **Keep**
**Reasoning**: Effectively the same document. Ours has marginally better template integration.

---

#### test-coverage — KEEP

**Our implementation** (2562B): 6-step coverage analysis. Detects 6 test frameworks. Analyzes below-80% files sorted worst-first. Scope option. Integration with `/tdd`, `/pr`, `/verify`.

**ECC implementation** (2629B): Functionally identical 5-step process. Slightly different summary format (table with Before/After columns). No scope option, no integration references.

**Assessment**: Near-identical. ECC's before/after table is marginally cleaner visually.

**Verdict**: **Keep**
**Reasoning**: Functionally equivalent. Ours has scope option and integration references.

---

#### evolve — ADOPT (with adaptation)

**Our implementation** (1170B): Minimal wrapper running `python3 scripts/instinct-cli.py evolve [--generate]`. Documents 3 evolution targets (Skill, Command, Agent) with threshold table. Shows empty-state message.

**ECC implementation** (4521B): Full evolution algorithm specification. Concrete examples for each evolution path (3 instincts → new-table command, 3 style instincts → functional-patterns skill, 4 debug instincts → debugger agent). Complete generated file formats with `evolved_from` frontmatter. `--generate` flag.

**Assessment**:
- Content depth: ECC is 3.9x larger with concrete examples that teach Claude what evolution output looks like
- Our wrapper gives Claude nothing to reason from when CLI is unavailable

**Verdict**: **Adopt (with adaptation)**
**Reasoning**: Concrete examples per evolution type are load-bearing for correct execution. Our minimal wrapper is insufficient.
**Adaptation**: Replace `CLAUDE_PLUGIN_ROOT` with `scripts/instinct-cli.py`. Keep our threshold table. Add ECC's examples and file format docs. Use `.claude/instincts/evolved/` not `~/.claude/homunculus/`.

---

#### instinct-export — ADOPT (with adaptation)

**Our implementation** (713B): Minimal wrapper running `scripts/instinct-cli.py export`. Lists 4 usage variants and 6 valid domains.

**ECC implementation** (1645B): Full specification with scope detection (project/global/all), filter logic, YAML output format example with complete frontmatter fields (id, trigger, confidence, domain, source, scope).

**Assessment**:
- ECC's YAML output format example is load-bearing when Claude must fall back to manual export
- Our version gives no reference for what output should look like

**Verdict**: **Adopt (with adaptation)**
**Reasoning**: YAML output format example enables manual fallback. Scope documentation makes `--scope` flag discoverable.
**Adaptation**: Keep our CLI path. Add ECC's output format and scope logic. Strip `project_id`/`project_name` if our format doesn't use them.

---

#### instinct-import — ADOPT (with adaptation)

**Our implementation** (1042B): Runs CLI with `--force`. Manual fallback (5-step process). Expected YAML format. 6 valid domains.

**ECC implementation** (2837B): Full import workflow with conflict detection, per-instinct resolution display (local vs import confidence comparison), merge behavior (higher confidence wins), source tracking fields. Flags: `--dry-run`, `--force`, `--min-confidence`, `--scope`. URL import support.

**Assessment**:
- ECC's conflict resolution display and merge behavior rules are load-bearing for the most common import scenario
- Our version is silent on conflict behavior

**Verdict**: **Adopt (with adaptation)**
**Reasoning**: Conflict detection and merge behavior rules fill a critical gap.
**Adaptation**: Keep our CLI path and manual fallback. Add ECC's conflict display, merge rules, source tracking, and flag documentation. Use `.claude/instincts/inherited/` not `~/.claude/homunculus/`.

---

### Category B: Review, Analysis & Language-Specific Commands

---

#### code-review — KEEP

**Our implementation** (2114B): Structured command with security (8 CRITICAL patterns), quality (7 HIGH patterns), best practices (5 MEDIUM patterns). Scope system (default/staged/path), approval criteria table, 80% confidence filtering. Integration with `/orchestrate review` and `/security-audit`. Invokes `code-reviewer` agent.

**ECC implementation** (985B): Bare-bones 3-step checklist. Same severity tiers but far less specific. No scope options, no confidence threshold, no integration, no agent invocation.

**Assessment**:
- Content depth: Ours is 2.1x larger with formal tables, confidence threshold, agent delegation
- Template integration: Ours connects to `/orchestrate review`, `/security-audit`, `code-reviewer` agent. ECC has none

**Verdict**: **Keep**
**Reasoning**: Materially better — scopes, confidence threshold, agent delegation, and pipeline integration are all absent from ECC's sketch.

---

#### eval — KEEP

**Our implementation** (4935B): 6 subcommands (define, check, report, list, metrics, clean). `/eval metrics` runs polyglot project-wide quality metrics (pytest-cov, ruff, mypy, radon for Python; jest, eslint, tsc for JS; go test -cover for Go) with trend comparison via `--save`. Integrates with `/health`.

**ECC implementation** (2214B): 4 subcommands (define, check, report, list, clean). Missing `/eval metrics` entirely. No `/health` integration. Simpler prose.

**Assessment**:
- Our `/eval metrics` is genuinely additive functionality not in ECC
- `/health` integration adds value
- ECC's core subcommands are structurally identical

**Verdict**: **Keep**
**Reasoning**: `/eval metrics` subcommand is a real functional addition. `/health` integration. Nothing in ECC we lack.

---

#### orchestrate — KEEP

**Our implementation** (6767B): Post-implementation analysis pipeline with 3 presets (review, refactor, security) plus custom. Iterative agent evaluation (3 cycles max), disk-persisted handoffs, parallel execution, structured REPORT.md. Strictly analysis-only.

**ECC implementation** (5313B): 4 presets including `feature` and `bugfix` (implementation workflows). tmux/worktree orchestration via `scripts/orchestrate-worktrees.js` with `seedPaths`. Control-plane snapshots. Simpler handoff format, no iterative evaluation.

**Assessment**:
- ECC's tmux/worktree orchestration depends on scripts we don't have
- ECC's `feature`/`bugfix` presets conflict with our superpowers-integration.md (orchestrate is analysis-only)
- Ours has iterative evaluation and REPORT.md structure

**Verdict**: **Keep**
**Reasoning**: ECC requires scripts we don't ship. `feature`/`bugfix` presets conflict with our analysis-only rule. Our iterative evaluation is a genuine improvement.

---

#### e2e — ADOPT

**Our implementation** (3289B): Invokes `e2e-runner` agent. Framework detection (Playwright/Cypress/Selenium), Page Object Model example, flaky test detection, artifact handling.

**ECC implementation** (10838B): Full worked example with 3 complete test cases (happy path, empty state, clear search). JUnit XML for CI, GitHub Actions workflow YAML, explicit browser matrix (Chrome/Firefox/Safari/Mobile), `playwright codegen` tip. Contains PMX-specific section (project contamination — must remove).

**Assessment**:
- ECC's 3 full test cases dramatically outperform our abstract description
- JUnit XML, CI YAML, browser matrix are concrete improvements
- PMX-specific section must be stripped

**Verdict**: **Adopt**
**Reasoning**: Worked example with 3 complete test cases provides substantially better behavioral signal.
**Adaptation**: Remove PMX-specific section. Add our framework detection table. Keep our integration section.

---

#### multi-execute — KEEP

**Our implementation** (3064B): 3-step workflow using `scripts/multi-model-query.py`. Check models, query Gemini + OpenAI in parallel, Claude merges. Graceful degradation without API keys.

**ECC implementation** (10573B): Entirely different architecture — `ccg:execute` using `codeagent-wrapper` with 7 phases, Code Sovereignty principle, dirty prototype refactoring, mandatory dual-model audit. Requires `~/.claude/bin/codeagent-wrapper`, `.ccg/prompts/`, and optionally `ace-tool` MCP.

**Assessment**:
- Not a richer version of the same command — fundamentally different architecture
- ECC requires infrastructure we don't ship (codeagent-wrapper, ace-tool MCP)
- Our version degrades gracefully and works immediately

**Verdict**: **Keep**
**Reasoning**: Incompatible architecture. Requires codeagent-wrapper binary and role prompt directories we don't have. Code Sovereignty and mandatory audit concepts are worth tracking as aspirations.

---

#### multi-plan — KEEP

**Our implementation** (3345B): 3-step planning with `scripts/multi-model-query.py`. Conflict table output. Graceful degradation.

**ECC implementation** (9367B): `ccg:plan` with 4-phase pipeline, `ace-tool` MCP integration, plan file save to `.claude/plan/<feature-name>.md`, session ID handoff to `ccg:execute`.

**Assessment**: Same incompatibility as multi-execute — requires codeagent-wrapper and ace-tool MCP.

**Verdict**: **Keep**
**Reasoning**: Same infrastructure incompatibility. Plan-file save convention worth considering as standalone improvement.

---

#### python-review — ADOPT

**Our implementation** (2267B): 4-tier severity (CRITICAL/HIGH/MEDIUM, 6+6+7 checks), automated tool commands, Django/FastAPI sections, approval criteria, integration notes. Invokes `python-reviewer` agent.

**ECC implementation** (6629B): Same tiers plus: worked example with actual before/after code diffs, Flask-specific review, "Common Fixes" section with 6 concrete code transformations, Python version compatibility table, `isort`/`safety check`/`pip-audit` in automated checks.

**Assessment**:
- ECC's worked example and Common Fixes provide rich behavioral signal
- Flask support and additional automated tools are concrete improvements
- Our structure (scope options, approval criteria, integration) should be preserved

**Verdict**: **Adopt**
**Reasoning**: Worked example with before/after transforms, Flask support, Common Fixes, and `isort`/`safety`/`pip-audit` are substantial improvements.
**Adaptation**: Keep our structure. Add ECC's worked example, Common Fixes, Flask section, Python version table, and automated tools.

---

#### go-build — ADOPT

**Our implementation** (1531B): Diagnostic commands, common error table (7 entries), 5-step fix strategy, stop conditions, integration links. Invokes `go-build-resolver` agent.

**ECC implementation** (3774B): Same content plus full worked example showing a 3-error resolution session with actual `go build` output, incremental fixes, final `go test` verification. Summary table format.

**Assessment**:
- ECC is 2.5x larger due to worked example showing incremental fix-and-verify loop concretely
- Same error table, same strategy — ECC extends rather than replaces

**Verdict**: **Adopt**
**Reasoning**: Worked example shows the incremental fix-and-verify loop concretely. Our content is a subset.
**Adaptation**: Add worked example. Keep our integration links. Add frontmatter.

---

#### go-review — ADOPT

**Our implementation** (1893B): CRITICAL/HIGH/MEDIUM tiers (6+6+5 checks), automated checks table, approval criteria, integration notes. Invokes `go-reviewer` agent.

**ECC implementation** (3428B): Same tiers plus worked example with actual Go code showing race condition fix (`sync.RWMutex`) and error wrapping (`fmt.Errorf("...: %w", err)`). Adds `govulncheck ./...` to automated checks.

**Assessment**:
- Worked example with the two most common Go issues (race conditions, error wrapping) is high-value
- `govulncheck` is a concrete automated check improvement

**Verdict**: **Adopt**
**Reasoning**: Worked example with race condition and error wrapping fixes provides quality signal. `govulncheck` addition.
**Adaptation**: Add worked example and `govulncheck`. Keep our integration section and scope options.

---

#### go-test — ADOPT

**Our implementation** (2343B): TDD cycle for Go with table-driven test pattern (code), parallel test, test helper, coverage commands/targets, DO/DON'T, integration links.

**ECC implementation** (5619B): Same patterns plus complete worked TDD session — email validator showing Steps 1-6: interface scaffold, test file, RED run, implementation, GREEN run, coverage check with actual `go test` output.

**Assessment**:
- ECC's worked example shows the complete RED-GREEN-REFACTOR cycle with real terminal output
- Everything else is structurally identical

**Verdict**: **Adopt**
**Reasoning**: Worked example for TDD is especially valuable — shows all 6 steps with real code and output.
**Adaptation**: Add ECC's "Example Session" section. Keep all our existing content.

---

#### update-codemaps — KEEP

**Our implementation** (5915B): 5-step workflow with scan, generate, diff detection, freshness metadata, staleness report. Scope options. Detailed codemap type examples (backend routes, architecture diagram, data schema). 30% diff threshold for approval. Comparison table vs `project-index.sh`. Design principles.

**ECC implementation** (2396B): Same 5 codemaps, same token-lean format, same freshness header. No scope options, no diff detection, no staleness report, no comparison table, simpler examples.

**Assessment**: Ours is 2.5x larger and a strict superset.

**Verdict**: **Keep**
**Reasoning**: Strict superset — scope, diff detection, staleness report, project-index comparison. Nothing to adopt.

---

#### update-docs — KEEP

**Our implementation** (3515B): 7-step workflow with doc-updater agent (haiku), staleness check, `<!-- AUTO-GENERATED -->` markers. 5 source types. Integration with `/pr` and `/verify`. Explains model choice.

**ECC implementation** (3006B): Similar 7 steps but generates CONTRIBUTING.md and RUNBOOK.md as explicit targets. No agent delegation, no model choice explanation, no `/pr`/`/verify` integration.

**Assessment**:
- Ours has better agent delegation and pipeline integration
- ECC's CONTRIBUTING.md/RUNBOOK.md targets are worth noting

**Verdict**: **Keep**
**Reasoning**: Better template integration. Add mention of CONTRIBUTING.md/RUNBOOK.md as concrete output targets.

---

#### instinct-status — ADAPT

**Our implementation** (1006B): Minimal — runs `scripts/instinct-cli.py status` with manual fallback. Status mapping thresholds (Active/Candidate/Fading).

**ECC implementation** (1562B): Output format example showing project-scoped vs global distinction, confidence bar visualization (block chars), observation stats, domain grouping. Plugin path references.

**Assessment**:
- ECC's output format example (confidence bars, project/global grouping) is concrete and useful
- Our status thresholds are not in ECC

**Verdict**: **Adapt**
**Reasoning**: Adopt ECC's output format specification while keeping our script path and status thresholds.
**Adaptation**: Keep `scripts/instinct-cli.py` path. Add ECC's output format example, confidence bars, project-scoped/global grouping.

---

## Our Unique Commands (22) — NEW

These have no ECC equivalent. All are documented as "New" — our template's contributions.

| Command | Lines | Purpose |
|---------|-------|---------|
| brainstorm | wraps superpowers:brainstorming skill | Structured ideation |
| changelog | generates CHANGELOG from git history | Release management |
| commit | conventional commit with validation | Git workflow |
| generate-tests | test generation for file/function/module | Test coverage |
| github-sync | sync Task Master tasks with GitHub Issues | Team visibility |
| health | project health check with AgentShield status | Project monitoring |
| lint | run ruff/eslint/golangci-lint | Code quality |
| mcps | MCP server selection wizard | MCP management |
| optimize | performance analysis for file | Performance |
| phase-check | validate phase transition prerequisites | Workflow enforcement |
| plugins | plugin selection wizard | Plugin management |
| pr | create GitHub PR with structured body | Shipping |
| prd | show/parse PRD documents | Planning |
| prd-generate | deep research PRD generation | Planning |
| research | structured research workflow | Research |
| rollback | guided rollback with session context | Recovery |
| security-audit | OWASP vulnerability scan | Security |
| settings | configure Claude Code settings for project | Configuration |
| setup | guided project setup wizard | Onboarding |
| task-status | update Task Master task status | Task management |
| tasks | list Task Master tasks | Task management |
| test | run pytest/jest/go test suite | Testing |

---

## ECC-Only Commands — Evaluated (31)

### Add to Template (5)

---

#### aside (ECC-only) — ADD

**Purpose**: Answers a quick side question mid-task without losing or modifying current task context. Wraps answer in `ASIDE: [question]` / `— Back to task:` format, then resumes the original task. Read-only during aside. Handles edge cases (task redirect detection, blocker discovery).

**Verdict**: **Add**
**Reasoning**: Pure behavioral instruction, no dependencies. Solves a real UX problem — mid-task curiosity currently requires derailing or suppressing. Zero startup tokens. High value-to-weight ratio.

---

#### quality-gate (ECC-only) — ADD

**Purpose**: On-demand quality pipeline for a specific file or directory. Detects language/tooling, runs formatter + lint/type checks, produces remediation list. Lighter than `/verify` (project-wide).

**Verdict**: **Add**
**Reasoning**: Fills gap between `/verify` (full project pipeline) and `/lint` (linter-only). Targeted, auto-detecting quality check for mid-session use. Pure behavior, no script dependencies.

---

#### learn-eval (ECC-only) — ADD

**Purpose**: Quality-gated `/learn` — checks for overlap with existing skills and MEMORY.md before writing. Issues holistic verdict (Save / Improve then Save / Absorb into X / Drop). Determines global vs project save location.

**Verdict**: **Add**
**Reasoning**: Strictly superior to our `/learn` for preventing skill proliferation. Mandatory overlap check, scope decision, and "Absorb" verdict are genuine improvements. Pure behavior, no dependencies.

---

#### resume-session (ECC-only) — ADD

**Purpose**: Loads most recent or specified session file, parses into structured briefing (project, current state, what NOT to retry, next step), waits for user direction before acting.

**Verdict**: **Add**
**Reasoning**: Fills session resume gap. The "What NOT to Retry" section prevents the most common session resume mistake. Needs adaptation to handle our `handoff-*.md` files per `proactive-steering.md`.

---

#### save-session (ECC-only) — ADD

**Purpose**: Deliberate mid-session or end-of-session capture of what worked, what failed with exact reasons, what's not yet tried, file states, decisions, next step. Confirmation before writing.

**Verdict**: **Add**
**Reasoning**: Fills the deliberate handoff gap between automatic `session-end.sh` and manual `/checkpoint`. The "What Did NOT Work" section is the highest-value part. Pairs with `/resume-session`.

---

### Defer to v2.5.0 (3)

---

#### harness-audit (ECC-only) — DEFER

**Purpose**: Runs `node scripts/harness-audit.js` to score repo across 7 categories (Tool Coverage, Context Efficiency, Quality Gates, Memory Persistence, Eval Coverage, Security, Cost Efficiency).

**Verdict**: **Defer** — v2.5.0 Task 11
**Reasoning**: Requires ECC's `scripts/harness-audit.js` which we don't ship. Task 11 should adopt this script wholesale per "adopt first" principle.

---

#### loop-start (ECC-only) — DEFER

**Purpose**: Initializes managed autonomous loop with patterns (sequential, continuous-pr, rfc-dag, infinite), writes runbook, enforces safety checks. References `ECC_HOOK_PROFILE`.

**Verdict**: **Defer** — after v2.5.0 Task 1 (hook profiles)
**Reasoning**: Depends on hook profile system (`ECC_HOOK_PROFILE`) being adapted as `TEMPLATE_HOOK_PROFILE`. Adopt post-Task 1.

---

#### loop-status (ECC-only) — DEFER

**Purpose**: Inspects active loop state — phase, checkpoint, failing checks, cost drift, intervention recommendation. `--watch` mode.

**Verdict**: **Defer** — paired with loop-start
**Reasoning**: Same infrastructure dependency. Adopt both together.

---

### Skip — Language-Specific (10)

| Command | Verdict | Reason |
|---------|---------|--------|
| cpp-build | Skip | Plugin responsibility — language-specific |
| cpp-review | Skip | Plugin responsibility |
| cpp-test | Skip | Plugin responsibility |
| kotlin-build | Skip | Plugin responsibility |
| kotlin-review | Skip | Plugin responsibility |
| kotlin-test | Skip | Plugin responsibility |
| rust-build | Skip | Plugin responsibility |
| rust-review | Skip | Plugin responsibility |
| rust-test | Skip | Plugin responsibility |
| gradle-build | Skip | Build-tool-specific, Java/Kotlin ecosystem |

---

### Skip — ECC Infrastructure Dependencies (8)

| Command | Verdict | Reason |
|---------|---------|--------|
| claw | Skip | Requires NanoClaw binary (previously rejected) |
| devfleet | Skip | Requires external MCP server (previously rejected) |
| prompt-optimize | Skip | Covered by proactive-steering.md ambient behavior |
| pm2 | Skip | Node.js ecosystem-specific project init |
| setup-pm | Skip | Requires ECC's setup-package-manager.js |
| multi-backend | Skip | Requires codeagent-wrapper binary |
| multi-frontend | Skip | Requires codeagent-wrapper binary |
| multi-workflow | Skip | Requires codeagent-wrapper + .ccg/ infrastructure |

---

### Skip — Already Covered or Unnecessary (5)

| Command | Verdict | Reason |
|---------|---------|--------|
| model-route | Skip | v2.5.0 Task 15 supersedes; advisory-only covered by existing rules |
| docs | Skip | Bypasses our tiered lookup hierarchy; `/research` covers it |
| projects | Skip | Requires ECC's Python instinct backend (homunculus) |
| promote | Skip | Same Python backend dependency |
| skill-health | Skip | Requires scripts/skills-health.js; our skills aren't tracked with metrics |

---

## Superpowers Commands (3, all deprecated)

| Command | Status | Impact |
|---------|--------|--------|
| brainstorm.md | Deprecated — redirects to `superpowers:brainstorming` skill | No action; our `/brainstorm` command is unaffected |
| execute-plan.md | Deprecated — redirects to `superpowers:executing-plans` skill | No action; we don't ship this command |
| write-plan.md | Deprecated — redirects to `superpowers:writing-plans` skill | No action; we don't ship this command |

---

## Key Pattern: Worked Examples

The dominant pattern across all Adopt verdicts is **worked examples** — ECC grew 2-4x primarily by adding concrete agent output with real code showing what each command's output should look like. These should be adopted across the board because they provide behavioral grounding at low structural cost.

Commands where we're larger (code-review, eval, orchestrate, update-codemaps, verify) have genuinely richer content — template-specific integration, additional subcommands, or polyglot coverage that ECC lacks.

---

## Action Items (Phase 5 Execution)

### Priority 1: Adopt with worked examples (7 commands)
tdd, plan, e2e, python-review, go-build, go-review, go-test

### Priority 2: Adopt instinct commands (3 commands)
evolve, instinct-export, instinct-import

### Priority 3: Add new from ECC (5 commands)
aside, quality-gate, learn-eval, resume-session, save-session

### Priority 4: Adapt (1 command)
instinct-status — adopt output format, keep script path

### Priority 5: Keep fixes (backports from ECC)
- checkpoint: add `clear` subcommand
- verify: add secrets check stage and `pre-pr` scope
- skill-create: add `--commits N` and `--output` flags
- update-docs: mention CONTRIBUTING.md/RUNBOOK.md as targets
