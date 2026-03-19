# Skills Audit Decisions

## Inventory

**Our skills**: 40 in `.claude/skills/`
**ECC skills**: 108 in `skills/`
**Overlapping**: 31 (27 exact name + 4 near-match)
**Our unique**: 7 (no ECC equivalent)
**ECC-only evaluated**: 8 candidates
**Audit date**: 2026-03-19

## Summary

| Verdict | Count | Description |
|---------|-------|-------------|
| Adopt (update) | 17 | Replace our version with ECC's (larger, more comprehensive) |
| Keep | 16 | Our version is better (template-adapted, polyglot, or richer) |
| New | 7 | Unique to us, no ECC equivalent |
| Add from ECC | 5 | New skills to add from ECC |
| Skip ECC-only | ~70 | Domain-specific or covered by existing template features |

## Near-Match Name Mapping

| Our Name | ECC Name | Verdict |
|----------|----------|---------|
| java-springboot | springboot-patterns | Keep ours |
| spring-boot-security | springboot-security | Keep ours |
| spring-boot-tdd | springboot-tdd | Keep ours |
| springboot-verification | springboot-verification | Adopt ECC's |
| postgresql-patterns | postgres-patterns | Keep ours |

---

## Detailed Analysis

### Category 1: Core Development Skills

---

#### tdd-workflow — KEEP

**Our implementation** (6041B, 173 lines): Python-native examples throughout (pytest, Go table-driven tests). Differentiated coverage thresholds by code type (90% business logic, 60% config, skip generated). Mocking strategy decision tree (dependency injection preferred over mocking). Explicit "when NOT to TDD" section (prototyping, UI layout, one-off scripts). Go table-driven test pattern.

**ECC implementation** (9775B): Full user journey authoring as Step 1 (user stories before test cases). Explicit E2E test layer with Playwright examples. Test file organization diagram. Mocking templates for Supabase, Redis, OpenAI. Jest/React Testing Library patterns. CI/CD integration (GitHub Actions coverage upload). Success metrics with concrete targets (< 30s unit suite).

**Assessment**:
- Content depth: Both strong but different audiences — ours is polyglot, ECC's is TypeScript/Next.js
- Actionability: Ours has decision trees; ECC has concrete templates
- Template fit: Ours is better — polyglot decision trees match our multi-language audience; ECC's TypeScript-specific content (Supabase, Playwright, React Testing Library) would pollute a general-purpose template
- Unique value: Our "when NOT to TDD" section prevents over-application, which is critical for a workflow that enforces TDD via Superpowers

**Verdict**: **Keep**
**Reasoning**: Architecturally better for a polyglot Python/Go/JS template — richer decision trees, language-specific guidance, and the "when NOT to TDD" section that prevents over-application.

---

#### code-review — NEW (ours only)

**Our implementation** (3518B, 101 lines): Full general code review workflow covering correctness, security, performance, maintainability, error handling, testing. >80% confidence threshold with explicit "verify" prefix for uncertain findings. Four-tier severity classification (CRITICAL/HIGH/MEDIUM/LOW). Finding consolidation pattern. Python-specific anti-patterns. Structured output format with praise section.

**ECC implementation**: No equivalent. ECC splits this into `security-review` (security-only) and `plankton-code-quality` (automated write-time linting via hooks, not review feedback).

**Verdict**: **New**
**Reasoning**: Fills a genuine gap — provides structured human-readable code review feedback; ECC's alternatives are either narrowly security-focused or automated tooling hooks.

---

#### continuous-learning-v2 — ADOPT (partial merge)

**Our implementation** (6197B, 190 lines): Template-specific integration with `.claude/instincts/` project-local path. Three distinct learning paths table (observe.sh + observer + pattern-extraction.sh + /learn). Detailed observer daemon implementation notes. Explicit authority hierarchy integration (instincts never override rules). Week decay rate (-0.02/week). Initial confidence calibration table (1-2 obs=0.3, 3-5=0.5, etc.). Gitignore notes.

**ECC implementation** (12533B): v2.1 project-scoped instincts with per-git-remote hash isolation (prevents cross-project contamination). `projects.json` registry mapping project hashes to names. Project-level directory under `~/.claude/homunculus/projects/<hash>/`. Instinct promotion pathway (project → global when seen in 2+ projects with ≥0.8 confidence). `/promote` and `/projects` commands. Scope decision guide table (language conventions = project-scoped, security practices = global). v2.1 vs v2.0 comparison. Privacy section.

**Assessment**:
- Content depth: ECC 2x larger with v2.1 project-scoping architecture
- Key ECC addition: Project-scoped instincts solve a real contamination problem our version ignores entirely
- Key our addition: Better template integration notes, more precise confidence dynamics, authority hierarchy reference
- Template fit: Need to merge — ECC's project scoping + our template integration

**Verdict**: **Adopt (partial merge)**
**Reasoning**: ECC's v2.1 project-scoped instincts solve a real cross-project contamination problem; the promotion pathway adds meaningful value. Preserve our confidence dynamics and authority hierarchy notes during merge.

---

#### strategic-compact — KEEP

**Our implementation** (4378B, 109 lines): Template-specific hook setup (`.claude/hooks/suggest-compact.sh` + settings presets). "What Survives Compaction" table includes Task Master tasks, auto-loaded rules, and session summaries. Points to `context-management.md` rule and `pre-compact.sh` hook. Multi-threshold behavior (50/75/100 calls with advisory messages).

**ECC implementation** (5281B): Token optimization section with three sub-patterns: Trigger-Table Lazy Loading (skills load on keyword match, reducing baseline context 50%+), Context Composition Awareness, Duplicate Instruction Detection. Mentions `token-optimizer` MCP and `context-mode` tool.

**Assessment**:
- Template fit: Ours is better — references actual hooks and settings presets
- Key ECC addition: Trigger-Table Lazy Loading concept is interesting but belongs in context-management.md, not this skill
- Our advantage: Multi-threshold behavior, complete "What Survives" table, direct hook references

**Verdict**: **Keep**
**Reasoning**: Our template integration is more complete; ECC's token-optimization additions belong in context-management.md.

---

#### verification-loop — KEEP

**Our implementation** (4986B, 162 lines): Full polyglot command table for each phase (Python/TypeScript/Go/Java/Rust). Phase result taxonomy (PASS/FAIL/SKIP/WARN) with explicit "SKIP is not FAIL" rule. Continuous verification mode with three tiers (per-function, per-feature, per-commit). TDD integration diagram showing how verification loop nests within TDD cycles. Troubleshooting table (symptom → likely phase → fix). `npx ecc-agentshield scan` in security phase.

**ECC implementation** (2491B): Stripped-down subset — 6 phases, basic bash commands, single output format block. No polyglot coverage, no result taxonomy, no continuous verification mode.

**Assessment**:
- Content depth: Ours is 2x larger and a strict superset
- ECC additions: Nothing substantive
- Our advantage: Polyglot commands, SKIP/WARN taxonomy, continuous verification, TDD integration

**Verdict**: **Keep**
**Reasoning**: Ours is comprehensively better — twice the size with polyglot coverage, a proper SKIP/WARN taxonomy, and integrated TDD guidance that ECC entirely lacks.

---

#### eval-harness — KEEP

**Our implementation** (6046B, 206 lines): Mathematical formulas for pass@k and pass^k with derivation. Worked numerical example (7/10 correct → specific pass@k values). YAML-format eval definition with named cases, inline graders, threshold field. Four grader type comparison table (code syntax/contains/execution/model) with pros/cons. Decision framework table (pass@1 + pass^3 → interpretation + action). Integration with template components (skills improve pass@1, rules improve pass^k).

**ECC implementation** (6494B): Explicit pre-implementation workflow (Define → Implement → Evaluate → Report). Eval storage path convention. `/eval define`, `/eval check`, `/eval report` command syntax. Human grader as formal third category. Complete worked example (add-authentication). v1.8 Product Evals with four grader types, pass@k guidance table, eval anti-patterns (overfitting, happy-path only, flaky graders in release gates).

**Assessment**:
- Content depth: Near-identical size, different strengths
- ECC advantage: Anti-patterns section, release snapshot path
- Our advantage: Mathematical grounding, YAML eval format, decision framework table, template integration

**Verdict**: **Keep**
**Reasoning**: Stronger mathematical grounding, more actionable YAML format, the decision framework table, and explicit template integration; ECC's anti-patterns are useful but don't outweigh our analytical depth.

---

#### iterative-retrieval — KEEP

**Our implementation** (6571B, 191 lines): Three-phase framing (Survey/Reconnaissance/Deep Read) with token cost and time estimates per phase. Decision framework table (situation → start phase → depth needed). Explicit "when to stop retrieving" rules. Token cost table per action type (Glob/Grep/Read/sub-agent with token ranges). Budget allocation breakdown (1k/3k/8k/3k for 15k total). Sub-agent spawn guidance with net token savings. Anti-patterns table. Project-index.json integration.

**ECC implementation** (6687B): Explicit loop diagram (DISPATCH → EVALUATE → REFINE → LOOP, max 3 cycles). JavaScript pseudocode for retrieval loop. Formal relevance scoring (0.8-1.0 high, etc.). Two named examples showing 3-cycle progression. "Integration with Agents" section.

**Assessment**:
- Different framing: Ours is token-budget management; ECC's is algorithmic loop
- Our advantage: Token costs, budget allocation, "when to stop" rules — more actionable for context-conscious template
- ECC advantage: Loop diagram and relevance scoring — more useful for agent orchestration

**Verdict**: **Keep**
**Reasoning**: Our token-budget framing is more actionable for this template's context-conscious audience.

---

#### cost-aware-llm-pipeline — ADOPT (minimal)

**Our implementation** (5437B, 175 lines): Model tier routing, budget tracking, retry logic, prompt caching patterns. Pricing table uses older model names (Sonnet 4.5).

**ECC implementation** (5718B): Near-identical content. Updated model IDs (`claude-sonnet-4-6` instead of `claude-sonnet-4-5-20250929`). "When to Use" section. Slightly expanded retry guidance.

**Assessment**: Files are 95% identical. Only actionable difference is updated model version strings.

**Verdict**: **Adopt (minimal)**
**Reasoning**: Update model ID constants to match ECC's newer versions; everything else can stay.

---

#### debugging — NEW (ours only)

**Our implementation** (2253B, 99 lines): 4-step workflow (Reproduce → Isolate → Understand → Fix). Python-specific tools (pdb, breakpoint(), logging). Common error type checklist (ImportError, TypeError, AttributeError, IndexError). Diagnostic questions framework.

**ECC implementation**: No equivalent. ECC has no `debugging` skill; closest is `systematic-debugging` in Superpowers (different scope — that's workflow enforcement, not a reference guide).

**Verdict**: **New**
**Reasoning**: Stands alone in ECC's library. Thin (99 lines, Python-only) but no upstream to adopt from.

---

### Category 2: Framework-Specific Skills

---

#### django-patterns — ADOPT

**Our implementation** (21013B, 733 lines): Comprehensive Django patterns.

**ECC implementation** (21025B): Near-identical content — 12 bytes difference.

**Assessment**: Byte-for-byte nearly identical. Minor phrasing differences in "When to Activate" section.

**Verdict**: **Adopt**
**Reasoning**: Stay in sync with upstream; files are essentially identical.

---

#### django-security — ADOPT

**Our implementation** (4365B, 174 lines): CSRF config, XSS prevention, basic SQL injection guidance, `django-environ` snippet, `django-guardian` mention.

**ECC implementation** (15805B): Everything we have plus: production security settings configuration (full `settings/production.py`), Argon2/BCrypt password hashing, session management, full RBAC role model, file upload validation, complete API rate limiting with DRF throttle classes, Content Security Policy middleware, comprehensive security logging, 12-item Quick Security Checklist.

**Assessment**:
- Content depth: ECC is 3.6x larger
- ECC additions: 8+ major security topics ours omits entirely (RBAC, file uploads, rate limiting, CSP, password hashing, security logging, deployment checklist)
- Our additions: Nothing unique — ours is a subset

**Verdict**: **Adopt**
**Reasoning**: ECC covers 8+ major security topics we omit entirely.

---

#### django-tdd — ADOPT

**Our implementation** (6680B, 226 lines): TestCase hierarchy comparison table (SimpleTestCase/TestCase/TransactionTestCase/LiveServerTestCase). Middleware testing example. Stacked parametrize (cartesian product).

**ECC implementation** (20922B): Complete `pytest.ini` configuration, full test settings module (in-memory SQLite, DisableMigrations, faster password hashers, Celery eager mode), comprehensive `conftest.py` with 6 fixtures, complete factory_boy examples with FuzzyDecimal/FuzzyInteger, full serializer testing, complete DRF ViewSet test suite (filter, search, pagination), mocking external services (Stripe), mocking email, full integration test with checkout flow, DO/DON'T best practices, coverage targets table.

**Assessment**:
- Content depth: ECC is 3.1x larger
- ECC additions: Complete test infrastructure, serializer testing, ViewSet testing, integration patterns
- Our unique additions: TestCase hierarchy table, middleware test — worth preserving but minor

**Verdict**: **Adopt**
**Reasoning**: ECC provides complete test infrastructure our version lacks; append our TestCase hierarchy table post-adoption.

---

#### django-verification — KEEP

**Our implementation** (7030B, 215 lines): Custom system check framework examples (spatial index validation). Migration safety anti-patterns table (RunSQL without reverse, RenameField risks). Template validation tests. URL verification tests. Settings verification tests.

**ECC implementation** (11477B): 12-phase verification pipeline (vs our 6). Performance checks (N+1 query detection, missing index analysis). Static assets phase. Configuration review script. Logging verification. API documentation schema generation. Full GitHub Actions CI/CD YAML. Pre-deployment checklist with 16 items.

**Assessment**:
- Content depth: ECC is 1.6x larger with more pipeline phases
- ECC advantage: CI/CD YAML, N+1 detection, pre-deployment checklist
- Our advantage: Custom check framework, migration safety table, template/URL/settings test suites — these are code-level tests, more actionable than ECC's CLI pipeline steps

**Verdict**: **Keep**
**Reasoning**: Our code-heavy approach (custom check framework, migration safety, template/URL/settings tests) is more actionable for Django developers than ECC's generic CI shell commands.

---

#### golang-patterns — ADOPT

**Our implementation** (4030B, 188 lines): Fan-out/fan-in pipeline pattern. Table-driven test example (belongs in golang-testing).

**ECC implementation** (14029B): Core Principles section with 3 foundations (Simplicity, Zero Value, Accept Interfaces/Return Structs) with good/bad comparisons. `errgroup` for coordinated goroutines. Goroutine leak prevention (buffered channels + context cancellation). Complete standard project layout directory tree. Package naming conventions. Dependency injection over package-level state. Struct embedding for composition. Memory/performance section (`sync.Pool`, string Builder). Complete `golangci.yml` config. Anti-patterns section (naked returns, panic for control flow, context in struct, mixed receivers). Idioms quick reference.

**Assessment**:
- Content depth: ECC is 3.5x larger
- ECC additions: Project layout, package conventions, composition, memory optimization, anti-patterns — all critical Go knowledge
- Our unique addition: Fan-out/fan-in pattern (minor)

**Verdict**: **Adopt**
**Reasoning**: ECC covers project layout, conventions, composition, memory optimization, and anti-patterns that ours entirely omits.

---

#### golang-testing — ADOPT

**Our implementation** (4393B, 188 lines): Testify (`assert`/`require`) integration. `TestMain` for setup/teardown. Integration test build tags (`//go:build integration`).

**ECC implementation** (16638B): Full TDD RED-GREEN-REFACTOR section. Table-driven tests with error cases (wantErr pattern). Parallel subtests with `t.Parallel()`. Test helper functions with `t.Helper()`/`t.Cleanup()`. Golden files pattern with `-update` flag. Interface-based mocking. Benchmarks with multiple sizes. Memory allocation benchmarks. Fuzz tests with property-based assertions. HTTP handler testing with `httptest`. Coverage targets by code type. CI/CD GitHub Actions YAML. Comprehensive commands reference.

**Assessment**:
- Content depth: ECC is 3.8x larger
- ECC additions: TDD workflow, golden files, interface mocking, fuzz testing, comprehensive HTTP testing
- Our unique additions: Testify integration, build tags (worth preserving in merge)

**Verdict**: **Adopt**
**Reasoning**: ECC is 3.8x larger with TDD workflow, golden files, interface mocking, and HTTP testing patterns ours lacks.

---

#### python-patterns — KEEP

**Our implementation** (8150B, 323 lines): Modern Python 3.9+ built-in generics syntax (strongly discouraging `typing` module imports). `TypeAlias`. `collections.abc` imports. `@dataclass(slots=True)` for 3.10+. `@dataclass(frozen=True)`. Full Pathlib section. Async generators and context managers. Enum patterns (including `str, Enum` for serialization). Stacked parametrize. Domain-specific geo/spatial example.

**ECC implementation** (16748B): Core Principles (Readability, Explicit is Better, EAFP vs LBYL). Basic type annotations. Protocol-based duck typing. Custom exception hierarchy. Class-based decorator. Threading for I/O-bound, multiprocessing for CPU-bound. Package exports with `__all__`. Anti-patterns with code examples (mutable defaults, type(), None comparison). Complete `pyproject.toml`.

**Assessment**:
- Content depth: ECC is 2.1x larger but targets older Python
- ECC advantage: Exception hierarchy, threading/multiprocessing, anti-patterns with examples
- Our advantage: Modern 3.9+ syntax, TypeAlias, slots dataclass, Pathlib, Enum — reflects tighter Python 3.11+ targeting
- Template fit: Our version is more opinionated about modern idioms

**Verdict**: **Keep**
**Reasoning**: More opinionated about modern Python syntax (3.9+ generics, TypeAlias, slots), includes Pathlib and Enum sections ECC lacks, and uses current idioms reflecting our 3.11+ targeting.

---

#### python-testing — ADOPT

**Our implementation** (4406B, 170 lines): Dependency injection vs `@patch` preference hierarchy. Factory fixtures. Stacked parametrize for cartesian product. `AsyncMock`. `side_effect` list. Integration test organization. Branch coverage config.

**ECC implementation** (18862B): TDD cycle with RED-GREEN-REFACTOR code example. Comprehensive assertions reference (14 patterns). Fixture scopes section. Parameterized fixtures. Autouse fixtures. Markers configuration. `@patch` for function/return/exception/context. `autospec` usage. `PropertyMock`. Async fixture and mocking. Testing exception attributes. `tmp_path`/`tmpdir` fixtures. Test class organization with `autouse` setup. DO/DON'T section. API endpoint testing (FastAPI/Flask). Database session testing with rollback. Full `pytest.ini` and `pyproject.toml` config. 20+ command reference.

**Assessment**:
- Content depth: ECC is 4.3x larger
- ECC additions: Comprehensive assertions (14 patterns), autouse fixtures, autospec, PropertyMock, async mocking, API endpoint testing, database rollback testing, full config blocks, 20+ commands
- Our unique additions: Factory fixture pattern, DI-preference philosophy (minor)

**Verdict**: **Adopt**
**Reasoning**: ECC is 4.3x larger with comprehensive assertions, fixture patterns, and API/database testing ours lacks. Preserve our factory fixture and DI-preference in merge.

---

#### frontend-patterns — KEEP

**Our implementation** (3651B, 148 lines): Vue Composition API composables. Vue Provide/Inject pattern. Svelte stores (writable + derived). State management decision tree (local/shared/global). React basics.

**ECC implementation** (14759B): Compound components pattern. Render props. Full `useQuery` custom hook. Context + reducer pattern. Virtualization with `@tanstack/react-virtual`. Controlled form with validation. Framer Motion animations. Keyboard navigation with full handler. Focus management.

**Assessment**:
- Content depth: ECC is 4x larger but React-only
- ECC advantage: Deep React patterns (compound components, virtualization, animations, keyboard nav)
- Our advantage: Multi-framework (Vue + Svelte + React)
- Template fit: Our breadth matches template's multi-framework support

**Verdict**: **Keep**
**Reasoning**: Uniquely covers Vue and Svelte alongside React; ECC's React depth is superior but our breadth matches the template's multi-framework support.

---

#### java-springboot vs springboot-patterns — KEEP

**Our implementation** (4882B, 189 lines): Spring Boot auto-configuration and `@ConditionalOnProperty`. Profiles (`application-dev.yml`/`application-prod.yml`). Detailed JPA/Hibernate patterns (lazy loading, `@EntityGraph`, N+1, native PostGIS query). `@OneToMany`/`@ManyToOne` with `orphanRemoval`. Security Filter Chain with OAuth2 JWT. Spring Actuator with custom health indicator.

**ECC implementation** (9919B): REST API structure with `@Validated` and `Page<>` response. DTOs using Java records. `GlobalExceptionHandler` `@ControllerAdvice`. Caching with `@Cacheable`/`@CacheEvict`. Async with `@Async` + `CompletableFuture`. Structured JSON logger. Request logging middleware. Rate limiting with Bucket4j (with security notes about `X-Forwarded-For` spoofing). Spring Events/Kafka. Observability (Micrometer, Prometheus, OTel).

**Assessment**:
- Content depth: ECC is 2x larger, focused on API layer
- ECC advantage: Exception handler, caching, async, observability, rate limiting with security notes
- Our advantage: Profiles, Actuator, JPA/N+1 patterns, Security Filter Chain — different layer
- These are complementary, not redundant — strongest "merge" candidate

**Verdict**: **Keep** (merge candidate)
**Reasoning**: Covers different layers (ECC: API + caching + async + observability; ours: profiles + JPA + security + actuator). Both have unique value. Consider restructuring as entry-point that delegates to specific springboot-* skills.

---

#### spring-boot-security vs springboot-security — KEEP

**Our implementation** (5874B, 191 lines): Full JWT configuration (NimbusJwtDecoder, audience validator, custom `JwtAuthenticationConverter` with roles claim mapping). Complete CORS config with `ExposedHeaders`. Fine-grained method security (`@PostAuthorize`, `@PreFilter`, `@P` binding). HSTS security header configuration. Security misconfiguration table (7 items with risk and fix). Complete `@SpringBootTest` security test examples with `@WithMockUser`.

**ECC implementation** (8019B): Input validation (bad vs good `@Valid` pattern with records). SQL injection prevention (native query examples). Password encoding guidance. Secrets management (env var vs Vault). OWASP Dependency Check / Snyk. Logging/PII guidance. File upload validation. 10-item pre-release checklist.

**Assessment**:
- ECC advantage: Input validation, SQL injection, PII logging, pre-release checklist
- Our advantage: Deeper JWT/OAuth2 config, method security, security testing, misconfiguration table
- Different focus: ECC covers breadth of security topics; ours covers depth of Spring Security

**Verdict**: **Keep**
**Reasoning**: Deeper JWT/OAuth2 configuration, more complete method security, security testing patterns, and misconfiguration reference table.

---

#### spring-boot-tdd vs springboot-tdd — KEEP

**Our implementation** (7054B, 233 lines): Full test slice annotations table (6 types with speed ratings and use cases). `@JsonTest` and `@RestClientTest` slices. `TestEntityManager` usage in `@DataJpaTest`. Spatial query testing (`findWithinRadius`). Service test with event publishing verification. Complete Mockito patterns section (8 patterns: `anyLong()`, `eq()`, `argThat()`, `verify`, `ArgumentCaptor`, `doThrow()`, sequential returns). Test organization directory structure.

**ECC implementation** (3774B): `@ParameterizedTest` mention. Test data builder pattern (inner `MarketBuilder` class). CI commands for Maven and Gradle.

**Assessment**:
- Content depth: Ours is 1.9x larger
- ECC addition: Test data builder (only notable addition)
- Our advantage: Comprehensive test slice table, 8 Mockito patterns, event-driven testing

**Verdict**: **Keep**
**Reasoning**: 1.9x larger with comprehensive test slice reference, Mockito patterns catalog, and event-driven testing.

---

#### springboot-verification — ADOPT

**Our implementation** (5418B, 215 lines): Same 6 phases, same commands, same output template, same continuous mode. Shorter/simpler test examples.

**ECC implementation** (5821B): Structurally near-identical. Fuller test code examples — complete unit test with duplicate email check, integration test with `@Testcontainers`/`@DynamicPropertySource`, `@WebMvcTest` API test with valid and invalid email.

**Assessment**: 93% identical; ECC has more complete test code examples.

**Verdict**: **Adopt**
**Reasoning**: Near-identical structure; ECC has fuller test snippets. Stay aligned.

---

#### jpa-patterns — KEEP

**Our implementation** (6213B, 218 lines): Fetch type rules table (all 4 annotations with defaults and recommendations). `@BatchSize` as N+1 solution. JPQL optimization (projections with constructor expressions, bulk `@Modifying` update, native PostGIS spatial query). Second-level cache with Ehcache YAML config and `@QueryHints`. `Propagation.REQUIRES_NEW` for audit logging. Complete anti-patterns table (6 items including Open Session in View, missing `@Version`). Detached entity handling.

**ECC implementation** (4548B): Entity `@Table` with `@Index` annotation. `@EntityListeners(AuditingEntityListener.class)` with `@CreatedDate`/`@LastModifiedDate`. `@EnableJpaAuditing`. Interface-based projections. HikariCP connection pool properties. Flyway/Liquibase migration guidance. Testcontainers for `@DataJpaTest`.

**Assessment**:
- Content depth: Ours is 1.4x larger
- ECC advantage: JPA auditing, interface projections, HikariCP, Testcontainers
- Our advantage: N+1 solutions comparison (including `@BatchSize`), second-level cache, JPQL optimization, propagation examples, anti-patterns table

**Verdict**: **Keep**
**Reasoning**: Richer N+1 solutions, second-level cache config, JPQL patterns, and comprehensive anti-patterns table.

---

#### postgresql-patterns vs postgres-patterns — KEEP

**Our implementation** (6252B, 208 lines): Full `EXPLAIN ANALYZE` usage with key metric interpretation (Seq Scan, Rows Removed by Filter, buffer hit ratio, planning time). Complete PostGIS spatial query section (ST_Within, KNN `<->` operator, ST_DWithin, ST_Transform). JSONB patterns with GIN index. Python connection pooling with `psycopg_pool`. CTE optimization (MATERIALIZED vs NOT MATERIALIZED). Partitioning (range with pg_partman). VACUUM/maintenance (autovacuum tuning for high-write tables).

**ECC implementation** (3808B): Data type quick reference table. RLS policy optimization. UPSERT with `ON CONFLICT`. Cursor pagination SQL. Queue processing with `FOR UPDATE SKIP LOCKED`. Unindexed FK detection query. Slow query detection (`pg_stat_statements`). Configuration template. `database-reviewer` agent cross-reference.

**Assessment**:
- Content depth: Ours is 1.6x larger
- ECC advantage: RLS, UPSERT, queue patterns, FK detection — Supabase-focused
- Our advantage: EXPLAIN ANALYZE interpretation, PostGIS spatial queries, CTEs, partitioning, VACUUM tuning
- Different specialization: ECC is Supabase-oriented; ours is general PostgreSQL

**Verdict**: **Keep**
**Reasoning**: Covers EXPLAIN ANALYZE, PostGIS, CTEs, partitioning, and VACUUM tuning that ECC entirely omits; ECC is Supabase-focused.

---

### Category 3: Infrastructure & Architecture Skills

---

#### api-design — ADOPT

**Our implementation** (5211B, 244 lines): Basic REST patterns, error response format, pagination, versioning.

**ECC implementation** (13110B): Everything we have plus: naming rules with GOOD/BAD examples. HTTP method table with Idempotent/Safe columns. Response envelope with TypeScript types. Full filtering/sorting with bracket-notation operators, dot-notation for nested fields, `fields=` sparse fieldsets. Rate limit tier table (Anonymous/Authenticated/Premium/Internal). Versioning with "maintain at most 2 versions" rule. Implementation samples in TypeScript, Python (DRF), and Go. API design pre-ship checklist.

**Assessment**:
- Content depth: ECC is 2.5x larger
- ECC additions: Rate limit tiers, filtering operators, multi-language samples, pre-ship checklist
- Our additions: Nothing unique — ours is a subset

**Verdict**: **Adopt**
**Reasoning**: ECC is more than twice as complete with critical content (rate limit tiers, filtering operators, multi-language samples, checklist) that ours omits.

---

#### backend-patterns — KEEP

**Our implementation** (8144B, 283 lines): Layered architecture diagram. Cache-aside, write-through, and stampede prevention patterns. Message queue patterns (Work Queue, Pub/Sub, Dead Letter Queue, idempotency). Circuit breaker pattern. Celery background job patterns. Bulkhead isolation. Graceful degradation. Anti-patterns table.

**ECC implementation** (13825B): TypeScript/Node.js/Next.js throughout. Repository pattern. Service layer with DI. Middleware pattern with HOF. N+1 prevention with batch fetch. Supabase transactions. RBAC with `rolePermissions` map. Structured JSON logger. In-memory JobQueue class.

**Assessment**:
- Content depth: ECC is 1.7x larger but different focus
- ECC advantage: TypeScript/Node patterns, RBAC, Supabase transactions
- Our advantage: Python/messaging/resilience (circuit breaker, DLQ, Celery, bulkhead, graceful degradation)
- Complementary, not duplicative

**Verdict**: **Keep**
**Reasoning**: Covers Python/messaging/resilience patterns (circuit breaker, DLQ, Celery) that ECC entirely lacks.

---

#### database-migrations — ADOPT

**Our implementation** (6769B, 242 lines): Alembic code examples. Batched backfill for Django. Online Schema Change tools table (pt-osc, pg_repack, gh-ost, CREATE INDEX CONCURRENTLY). Rollback decision matrix. Pre-migration checklist.

**ECC implementation** (9481B): Everything we have plus: 5 core principles up front. `FOR UPDATE SKIP LOCKED` in batch pattern. `SeparateDatabaseAndState` Django pattern. golang-migrate section (entirely absent from ours). Day 1/2/3/7 timeline example for zero-downtime rollout.

**Assessment**:
- Content depth: ECC is 1.4x larger
- ECC additions: golang-migrate (entirely absent), `SeparateDatabaseAndState`, rollout timeline
- Our additions: Online Schema Change tools table, Alembic examples (worth preserving)

**Verdict**: **Adopt**
**Reasoning**: ECC adds golang-migrate, `SeparateDatabaseAndState`, and rollout timeline. Preserve our Online Schema Change tools table in merge.

---

#### deployment-patterns — ADOPT

**Our implementation** (7196B, 262 lines): Python Dockerfile. Deploy-time Grafana annotations. Graceful shutdown signal handler. Monitoring/observability "three pillars" table. Deploy-on-Friday anti-pattern.

**ECC implementation** (11000B): Multi-stage Dockerfiles for Node.js, Go, AND Python/Django. Docker best practices. Kubernetes probes (liveness/readiness/startup with `failureThreshold`). Env config validation with Zod schema. CI/CD pipeline stages narrative. Rollback checklist with platform-specific commands (Railway, Vercel, kubectl, prisma). Production readiness checklist (4 sections: Application, Infrastructure, Monitoring, Security/Operations).

**Assessment**:
- Content depth: ECC is 1.5x larger
- ECC additions: Go/Node Dockerfiles, Kubernetes probes, prod readiness checklist, rollback commands
- Our additions: Monitoring/observability section (worth merging)

**Verdict**: **Adopt**
**Reasoning**: Production readiness checklist, multi-language Docker examples, and startup probe config make it substantially more useful.

---

#### docker-patterns — ADOPT

**Our implementation** (3971B, 184 lines): Basic Docker Compose. `docker scout cves`/Trivy. Compose secrets. Anonymous volume "exclude" trick.

**ECC implementation** (8251B): Full web app Compose stack with postgres, redis, mailpit. Dev-stage vs production-stage Dockerfile. `docker-compose.override.yml` vs `docker-compose.prod.yml`. Custom networks with frontend/backend isolation. Security: `security_opt: no-new-privileges`, `read_only: true`, `tmpfs`, `cap_drop: ALL`. Full debugging section with commands. Updated `.dockerignore`.

**Assessment**:
- Content depth: ECC is 2.1x larger
- ECC additions: Complete dev stack, network isolation, cap_drop security, debug commands
- Our additions: Nothing unique

**Verdict**: **Adopt**
**Reasoning**: ECC has complete dev stack, security hardening, and debug reference ours entirely lacks.

---

#### e2e-testing — ADOPT

**Our implementation** (3749B, 152 lines): Cypress `cy.intercept` and fixture example. Visual regression with `toHaveScreenshot`. Test data factory pattern.

**ECC implementation** (8065B): Full `playwright.config.ts` with `forbidOnly`, `retries`, `workers`, multi-browser `projects`, `webServer`. Flaky test quarantine (`test.fixme`, `test.skip`, `--repeat-each`). Artifact management (screenshots, traces, videos). Test report Markdown template. Web3/financial flow testing patterns.

**Assessment**:
- Content depth: ECC is 2.2x larger
- ECC additions: Complete playwright.config.ts (absent from ours), flaky test quarantine, artifact management
- Our additions: Cypress example, visual regression threshold values

**Verdict**: **Adopt**
**Reasoning**: Full playwright.config.ts, flaky test quarantine workflow, and domain-specific patterns make it a more complete reference.

---

#### cpp-coding-standards — ADOPT

**Our implementation** (10419B, 331 lines): Subset of C++ Core Guidelines covering I/F/C/R/CP/ES/NL rules.

**ECC implementation** (22279B): Strict superset — all our content plus: 12 additional rules per category. Explicit DO/DON'T blocks at each section. Entire Performance section (Per.1-Per.19) with `constexpr` lookup table and cache-friendliness example. SL section (SL.con, SL.str, SL.io). Additional Naming/SF rules. Enum anti-patterns. Anti-patterns blocks at every major section. Expanded checklist.

**Assessment**: ECC is a strict superset with 12,000 bytes of additional content.

**Verdict**: **Adopt**
**Reasoning**: ECC is a strict superset — Performance section, more rules per category, anti-pattern blocks at each section.

---

#### cpp-testing — ADOPT

**Our implementation** (6185B, 261 lines): Catch2 BDD-style examples (SCENARIO/GIVEN/WHEN/THEN). Benchmark testing with `DoNotOptimize`. Valgrind example. Test organization directory tree.

**ECC implementation** (9163B): TDD workflow with RED/GREEN/REFACTOR. UBSan (`-fsanitize=undefined`) and TSan (`-fsanitize=thread`) in addition to ASan. GCC + gcov + lcov AND Clang + llvm-cov coverage workflows. `ENABLE_COVERAGE` CMake option. Flaky test guardrails. Fuzzing/libFuzzer appendix.

**Assessment**:
- ECC additions: UBSan/TSan sanitizers, both coverage workflows, TDD loop, fuzzing
- Our additions: Catch2 BDD, benchmarks, Valgrind (worth preserving in merge)

**Verdict**: **Adopt**
**Reasoning**: UBSan/TSan sanitizers, dual coverage workflows, and fuzzing appendix. Merge: preserve our Catch2 BDD and benchmark content.

---

#### security-scan — KEEP

**Our implementation** (5171B, 177 lines): Detailed vulnerability descriptions with code examples (command injection, curl|bash, git force-push in hooks). Per-component scan checklist with checkboxes. What each file scans for per component (CLAUDE.md, hooks, MCP, agents, environment). Agent tool access table (planner/reviewer/security/doc-updater/build-resolver). Common findings severity table.

**ECC implementation** (4469B): AgentShield severity grading table (A-F with scores). All CLI flags with format options. `--fix` auto-fix flag. `--opus` three-agent pipeline. `npx ecc-agentshield init` scaffold. GitHub Action YAML block.

**Assessment**:
- Our advantage: Educational "what to look for and why" with code examples; component-specific checklists; agent tool access table
- ECC advantage: CLI flags reference, GitHub Action block

**Verdict**: **Keep**
**Reasoning**: Our educational content (vulnerability code examples, component checklists, agent access table) is more valuable than ECC's quickstart approach. Add ECC's CLI flags and GitHub Action block.

---

#### regex-vs-llm-structured-text — ADOPT

**Our implementation** (5750B, 193 lines): Decision framework for regex vs LLM.

**ECC implementation** (6481B): Same content plus `identify_low_confidence` as named helper function, "When to Use" section.

**Assessment**: 88% identical; ECC adds a named helper and usage section.

**Verdict**: **Adopt**
**Reasoning**: Minor improvement — primarily adding the helper function and "When to Use" section. Stay aligned.

---

#### typescript-patterns — KEEP (no ECC equivalent)

**Our implementation** (3485B, 140 lines): TypeScript strict mode (`noUncheckedIndexedAccess`). Generics with constraints. Utility types (`Partial<>`, `Pick<>`, `Omit<>`). Discriminated unions. Module patterns. Exact optional properties.

**ECC equivalent**: None. ECC has `coding-standards` (TS/JS general style) and `frontend-patterns` (React/Next.js). Neither covers TypeScript language features specifically.

**Verdict**: **Keep**
**Reasoning**: Fills a gap ECC doesn't address — TypeScript language features (generics, conditional types, discriminated unions) rather than coding style.

---

### Category 4: ECC-Only Skills — Evaluated for Adoption

---

#### ai-regression-testing (ECC-only) — ADD

**Purpose**: Patterns for catching 4 AI-specific blind spots: sandbox/production path mismatch, SELECT clause omission, error state leakage, optimistic update rollback. Includes vitest setup for sandbox mode and `/bug-check` command.

**Verdict**: **Add**
**Reasoning**: Addresses the "AI writes and reviews its own code" quality gap identified in dogfood testing. Four concrete regression patterns with test code. Complements TDD (which prevents bugs before writing) by catching the category of bugs that same-model-writes-and-reviews lets through.

---

#### blueprint (ECC-only) — ADD

**Purpose**: Multi-session construction plans with cold-start context briefs per step. Adversarial Opus review gate. Dependency graph. Parallel step detection. 15 steps max, each independently verifiable.

**Verdict**: **Add**
**Reasoning**: Bridges the gap between brainstorming output and Task Master task decomposition for complex multi-PR features. The cold-start context brief pattern addresses our session continuity challenge.

---

#### claude-api (ECC-only) — ADD

**Purpose**: Anthropic SDK patterns for Python and TypeScript — Messages API, streaming, tool use, vision, extended thinking, Batches API (50% cost), prompt caching, model selection.

**Verdict**: **Add**
**Reasoning**: No SDK reference skill in template. Covers non-obvious patterns (prompt caching, batches, agentic tool-use loop) relevant to template users building AI applications.

---

#### search-first (ECC-only) — ADD

**Purpose**: Enforces "search before coding" with 5-step workflow and category-specific search shortcuts for npm/PyPI/MCP/GitHub.

**Verdict**: **Add**
**Reasoning**: Makes our "adopt-first" principle (from MEMORY.md) a first-class workflow skill with actionable shortcuts, rather than just an advisory memory note.

---

#### skill-stocktake (ECC-only) — ADD

**Purpose**: Automated skill audit with quality checklist, Quick Scan mode (re-evaluate only changed files), JSON results cache.

**Verdict**: **Add**
**Reasoning**: Makes future skill audits (like this one) automatable by any agent session. Low-cost ongoing maintenance.

---

#### agentic-engineering (ECC-only) — SKIP

**Purpose**: AI-assisted engineering operating model — eval-first, 15-minute task units, model routing, cost discipline.

**Verdict**: **Skip**
**Reasoning**: Already covered by context-management.md, proactive-steering.md, and Task Master workflow.

---

#### deep-research (ECC-only) — SKIP

**Purpose**: Multi-source web research using firecrawl and exa MCPs.

**Verdict**: **Skip**
**Reasoning**: Requires firecrawl/exa MCPs not in our default config. Our `/research` command and reasoning-patterns.md tiered lookup already cover this.

---

#### mcp-server-patterns (ECC-only) — SKIP

**Purpose**: Build MCP servers with Node/TypeScript SDK.

**Verdict**: **Skip**
**Reasoning**: Niche use case; the skill itself defers to Context7/official docs for current API signatures.

---

## Action Items (Phase 5 Execution)

### Priority 1: Clean Adopts (8 skills — copy ECC's SKILL.md directly)
api-design, django-patterns, django-security, docker-patterns, e2e-testing, cpp-coding-standards, regex-vs-llm, springboot-verification

### Priority 2: Merge Adopts (9 skills — start from ECC, preserve our unique content)
continuous-learning-v2, cost-aware-llm-pipeline, cpp-testing, database-migrations, deployment-patterns, django-tdd, golang-patterns, golang-testing, python-testing

### Priority 3: Add New Skills (5 skills — copy from ECC, adapt paths)
ai-regression-testing, blueprint, claude-api, search-first, skill-stocktake

### Priority 4: Keep Fixes (minor improvements to existing keeps)
- security-scan: Add ECC's CLI flags and GitHub Action block
- java-springboot: Consider restructuring as entry-point to springboot-* skills
