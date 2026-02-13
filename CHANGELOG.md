# Changelog

All notable changes to this project template are documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.2.0] - 2026-02-13

ECC feature parity release: 12 domain skills and 6 automation hooks close remaining gaps identified in the ECC comparison audit. Template now has full coverage across Python, Java/Spring, Django, PostgreSQL, C++, and workflow automation.

### Added - Skills (12 new, 32 total)

**Core Workflow:**
- **tdd-workflow** - RED-GREEN-REFACTOR cycle patterns, coverage thresholds by code type, mocking strategies, AAA templates for pytest/Jest/Go
- **verification-loop** - 6-phase verification system (build → types → lint → test → security → diff), continuous verification mode
- **python-patterns** - Framework-agnostic Python idioms: type hints (3.9+), context managers, decorators, `__slots__`, async/await, pyproject.toml
- **security-scan** - AgentShield configuration auditing: CLAUDE.md secrets, hook injection, MCP misconfigs, agent tool access
- **eval-harness** - Eval-driven development (EDD) framework with pass@k/pass^k metrics, code-based and model-based graders

**Framework-Specific:**
- **postgresql-patterns** - EXPLAIN ANALYZE, indexing strategies (B-tree/GIN/GiST/BRIN), PostGIS spatial queries, JSONB, partitioning, vacuum tuning
- **django-tdd** - pytest-django, TestCase hierarchy, factory_boy, DRF APIClient, model/view/middleware testing
- **django-verification** - Django system checks, `--deploy` findings, migration safety, template/URL validation
- **spring-boot-security** - SecurityFilterChain (Spring 6+), JWT/OAuth2, CORS, CSRF, method-level security
- **spring-boot-tdd** - JUnit 5 + Mockito, @WebMvcTest/@DataJpaTest slice testing, TestContainers
- **jpa-patterns** - Entity mapping, lazy loading, N+1 prevention (@EntityGraph, JOIN FETCH), JPQL optimization, second-level cache
- **cpp-testing** - Google Test/Catch2, parameterized tests, GMock, AddressSanitizer, benchmark testing, CMake integration

### Added - Hooks (6 new, 15 total)
- **doc-file-blocker.sh** (PreToolUse: Write) - Blocks .md/.txt creation outside allowed locations
- **console-log-audit.sh** (PostToolUse: Edit) - Warns about debug statements across Python/JS/TS/Go/Java/Ruby
- **pattern-extraction.sh** (Stop) - Auto-extracts instinct candidates from session git history
- **build-analysis.sh** (PostToolUse: Bash) - Advisory analysis of build command output
- **typescript-check.sh** (PostToolUse: Edit) - Runs tsc --noEmit after editing .ts/.tsx files
- **dev-server-blocker.sh** (PreToolUse: Bash) - Blocks dev servers outside tmux

### Changed
- Updated settings-example.json with all new hook registrations
- Updated CLAUDE.md hooks list (now 15 hooks)
- Updated ECC_INTEGRATION.md with Phase 2.2 additions and corrected skill counts
- Updated TEMPLATE_OVERVIEW.md: version header, architecture tree, moved v2.2.0 from "In Progress" to "Completed"

## [2.1.0] - 2026-02-13

Gap-filling release: side-by-side comparison of every command against ECC's source code, with honest assessment of which implementation is better. Upgraded where ECC wins, kept ours where we're stronger.

### Added - Skills (6 new, 20 total)
- **docker-patterns** - Multi-stage builds, Compose, container security, networking
- **api-design** - REST patterns, versioning, pagination, error handling, OpenAPI
- **deployment-patterns** - CI/CD pipelines, blue-green, canary, rollback strategies
- **database-migrations** - Alembic, Django, Prisma, Drizzle, zero-downtime patterns
- **backend-patterns** - Caching, message queues, circuit breakers, resilience
- **iterative-retrieval** - Progressive context refinement (ECC novel pattern)

### Added - Infrastructure
- **suggest-compact.sh** hook - Advisory compaction suggestions at 50/75/100 tool calls
- **/sessions** command - Session history viewer with age tracking and cleanup

### Changed - Commands (upgraded from ECC comparison)
- **/eval** - Replaced metrics-only approach with ECC's feature-eval model (pass@k capability evals + pass^k regression evals); kept metrics as `/eval metrics` subcommand
- **/update-codemaps** - Replaced with ECC's token-lean format: freshness metadata, diff detection (30% threshold), staleness warnings, backend/frontend/data/dependencies structure
- **/orchestrate** - Added `bugfix` and `security` pipelines from ECC + parallel execution concept
- **/checkpoint** - Added `verify` subcommand from ECC for comparing against named checkpoints
- **/update-docs** - Added multi-source approach (package.json, .env, routes), staleness detection, and AUTO-GENERATED markers from ECC

### Kept (ours better than ECC)
- **/verify** - More polyglot (Python/JS/Go auto-detection), has security stage, SKIP-not-FAIL degradation
- **/code-review** - More actionable with >80% confidence filtering and severity tiers
- **/skill-create** - Clearer confidence thresholds and clustering pipeline
- **/checkpoint** content format - Richer context with task, reasoning, and session integration

## [2.0.0] - 2026-02-13

Major release integrating patterns from [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) (42K+ stars) while preserving the template's unique workflow enforcement approach.

### Phase 2: Multi-Agent & Continuous Learning (Tasks 16-50)

#### Added - Agents (9 new, 13 total)
- **architect** (opus, read-only) - High-level system design, component diagrams, technology selection
- **tdd-guide** (sonnet) - Advisory TDD coaching; Superpowers enforces the cycle
- **database-reviewer** (sonnet) - SQL optimization, N+1 detection, migration safety
- **doc-updater** (haiku) - Lightweight documentation maintenance
- **refactor-cleaner** (sonnet) - Controlled refactoring with minimal blast radius
- **e2e-runner** (sonnet) - Playwright/Cypress/Selenium test execution and debugging
- **go-reviewer** (sonnet) - Go-specific code review (goroutine leaks, interface design)
- **go-build-resolver** (sonnet) - Go module/CGO/cross-compilation error resolution
- **python-reviewer** (sonnet) - Deep Python review (async, metaclasses, GIL, packaging)

#### Added - Skills (10 new, 14 total)
- **python-testing** - pytest patterns, fixtures, parametrize, mocking, async testing
- **python-django** - Django ORM, middleware, signals, admin, DRF
- **typescript-patterns** - Strict mode, generics, utility types, discriminated unions
- **frontend-patterns** - React/Vue/Svelte, state management, accessibility
- **golang-patterns** - Go idioms, error handling, concurrency, interfaces
- **golang-testing** - Table-driven tests, benchmarks, fuzzing, testify
- **java-springboot** - Spring Boot, DI, JPA/Hibernate, security, actuator
- **e2e-testing** - Playwright/Cypress, page objects, network interception, CI
- **django-security** - CSRF, XSS, SQL injection, auth, secrets management
- **database-patterns** - SQL optimization, indexing, migration safety, N+1 prevention

#### Added - Slash Commands (12 new, 27+ total)
- `/orchestrate [pipeline]` - Multi-agent pipeline execution (feature, review, refactor)
- `/multi-plan <requirements>` - Parallel planning with Claude + Gemini + Codex
- `/multi-execute <task>` - Parallel implementation with multiple models
- `/verify [scope]` - Structured verification pipeline (test + lint + types + security)
- `/eval [--save]` - Code quality metrics with trend tracking
- `/checkpoint [label]` - Manual session state save
- `/instinct-status` - View learned instinct patterns
- `/instinct-import <file>` - Import instincts from shared JSON
- `/instinct-export` - Export instincts for sharing
- `/evolve` - Cluster instincts into new skills
- `/skill-create` - Auto-generate skills from git commit history
- `/update-codemaps` - Generate architecture docs in `docs/CODEMAPS/`
- `/update-docs [scope]` - Trigger doc-updater agent on changed files

#### Added - Continuous Learning v2
- Instinct-based pattern extraction with confidence scoring (0-1)
- Authority hierarchy: Rules > Instincts > Defaults (`.claude/rules/authority-hierarchy.md`)
- Instinct lifecycle: candidate (0.3-0.7) -> active (>0.7) with decay (-0.05/week)
- Skill evolution via `/evolve` command (cluster instincts into skills)

#### Added - Multi-Model Collaboration
- `/multi-plan` sends requirements to Claude + Gemini + Codex in parallel
- `/multi-execute` divides implementation across models, synthesizes results
- Graceful degradation when API keys are missing
- Configuration example at `.claude/examples/multi-model-config.json`

#### Added - Language-Specific Rules (5 languages)
- `python/coding-standards.md` (`.py` files)
- `typescript/coding-standards.md` (`.ts`, `.tsx` files)
- `golang/coding-standards.md` (`.go` files)
- `java/coding-standards.md` (`.java` files)
- `frontend/component-standards.md` (`.jsx`, `.tsx`, `.vue`, `.svelte` files)
- All use `paths:` frontmatter for zero startup overhead

#### Added - Security
- AgentShield documentation (`docs/SECURITY.md`)
- AgentShield status integrated into `/health` command
- Two-layer security model: config-level (AgentShield) + code-level (`/security-audit`)

### Phase 1: Core ECC Integration (Tasks 1-15)

#### Added - Token Optimization
- `optimized` settings preset (`/settings optimized`) for 60-80% cost reduction
- `MAX_THINKING_TOKENS`, `CLAUDE_CODE_AUTOCOMPACT_PCT_OVERRIDE` env var support
- `CLAUDE_CODE_SUBAGENT_MODEL` for cheaper sub-agent models
- Compaction decision table (when to compact vs fresh session)

#### Added - Session Persistence
- `session-end.sh` hook - saves session summaries on Stop events
- `session-init.sh` hook - detects and displays summaries from last 24 hours
- `pre-compact.sh` hook - preserves state before context compaction
- Automatic reload of recent session context

#### Added - Context Management
- Thinking modes documentation (think, think hard, think harder, ultrathink)
- Context budget breakdown (~40-50k startup, ~125-150k working)
- Quality degradation symptoms checklist
- Compaction survival matrix (what persists vs what's lost)

#### Added - Dynamic Context Modes
- `dev.md` - Code-first, minimal explanation, frequent commits
- `review.md` - Read-first, severity-ordered, >80% confidence
- `research.md` - Explore-first, no code until clear, cite sources
- CLI aliases using `--append-system-prompt`

#### Added - Agents (4 core)
- **planner** (opus, read-only) - Architecture planning
- **code-reviewer** (sonnet, read-only) - Severity-tiered review with >80% confidence
- **security-reviewer** (sonnet, + Bash) - OWASP Top 10, dependency scanning
- **build-resolver** (sonnet, all tools) - Build failures, CI fixes

#### Added - MCP Discipline
- 10/80 rule: max 10 MCP servers, 80 tools
- `manage-mcps.sh audit` command for budget checking
- `disabledMcpServers` documentation for temporary disabling
- Project-type presets in `docs/MCP_SETUP.md`

#### Added - Rules & Workflow
- `proactive-steering.md` - Project co-pilot behaviors, auto-tool invocation
- `context-management.md` - Thinking modes, compaction guidance
- `authority-hierarchy.md` - Rules > Instincts > Defaults precedence
- Commitment checkpoints in `workflow-guide.md`
- Session wrap-up pattern with work log

#### Changed
- Moved `python-standards.md` to `python/coding-standards.md` with `paths:` frontmatter
- Updated health check with MCP budget audit section
- Updated settings presets (safe, thorough, optimized) with session hooks
- Removed arbitrary context thresholds in favor of symptom-based detection

### Pre-ECC Foundation (v1.x)

#### Added
- Claude Code optimized project template with CLAUDE.md
- Sync script (`sync-template.sh`) with `--skills` flag
- MCP server setup documentation
- Superpowers plugin integration (required)
- Behavioral rules system (`.claude/rules/`)
- Phase detection workflow (IDEATION -> PLANNING -> BUILDING -> REVIEW -> SHIPPING)
- Task Master integration
- Git workflow rules with conventional commits
- Reasoning patterns (clarification, brainstorming, reflection, five whys)
- Project index hook for codebase navigation
- Settings presets (safe, thorough)
- Hooks system (protect-sensitive-files, post-edit-format, pre-commit-check)
- Core slash commands (/health, /setup, /commit, /pr, /test, /lint, /brainstorm, etc.)
- Python coding standards with testing and error handling patterns
- Plugin system with marketplace support

[2.0.0]: https://github.com/Zanzagar/project-template/releases/tag/v2.0.0
