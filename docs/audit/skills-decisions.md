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

## Adopt — Update Existing (17 skills)

Replace our SKILL.md with ECC's version. For skills marked "merge", preserve our unique additions.

| Skill | Size Ratio | Key ECC Additions | Merge Notes |
|-------|-----------|-------------------|-------------|
| api-design | 2.5x | Rate limit tiers, filtering operators, multi-lang samples, pre-ship checklist | Clean adopt |
| continuous-learning-v2 | 2x | v2.1 project-scoped instincts, promotion pathway, project hash isolation | Merge: keep our confidence dynamics and authority hierarchy notes |
| cost-aware-llm-pipeline | 1.05x | Updated model IDs (claude-sonnet-4-6) | Model ID update only |
| cpp-coding-standards | 2.1x | Performance section, 12k more content, anti-pattern blocks | ECC is strict superset |
| cpp-testing | 1.5x | UBSan/TSan sanitizers, both coverage workflows, fuzzing appendix | Merge: keep our Catch2 BDD and benchmark examples |
| database-migrations | 1.4x | golang-migrate, FOR UPDATE SKIP LOCKED, SeparateDatabaseAndState, rollout timeline | Merge: keep our Online Schema Change tools table |
| deployment-patterns | 1.5x | Go/Node Dockerfiles, startup probe, prod readiness checklist | Merge: keep our monitoring/observability section |
| django-patterns | 1.0x | Near-identical | Clean adopt (stay aligned) |
| django-security | 3.6x | Production settings, RBAC, file uploads, rate limiting, CSP, password hashing, security logging | Clean adopt |
| django-tdd | 3.1x | Full pytest.ini, conftest fixtures, serializer testing, ViewSet testing, integration tests | Merge: keep our TestCase hierarchy table |
| docker-patterns | 2.1x | Mailpit dev stack, cap_drop security, debug commands | Clean adopt |
| e2e-testing | 2.2x | Full playwright.config.ts, flaky quarantine, Web3/financial patterns | Clean adopt |
| golang-patterns | 3.5x | Project layout, package conventions, composition, memory optimization, anti-patterns | Merge: keep our fan-out/fan-in pattern |
| golang-testing | 3.8x | TDD workflow, golden files, interface mocking, HTTP testing, coverage targets | Merge: keep our testify and build tag patterns |
| python-testing | 4.3x | Comprehensive assertions, autouse fixtures, autospec, PropertyMock, async mocking | Merge: keep our factory fixture and DI-preference philosophy |
| regex-vs-llm | 1.1x | identify_low_confidence as named helper, "When to Use" section | Clean adopt |
| springboot-verification | 1.1x | Fuller test code examples | Clean adopt |

## Keep — Our Version is Better (16 skills)

| Skill | Size Ratio | Why Ours is Better |
|-------|-----------|-------------------|
| backend-patterns | 0.6x | Python/messaging/resilience patterns (circuit breaker, DLQ, Celery) ECC lacks |
| django-verification | 0.6x | Custom check framework, migration safety table, template/URL/settings test suites |
| eval-harness | 0.9x | Stronger math (pass@k formulas), YAML eval format, decision framework table |
| frontend-patterns | 0.25x | Multi-framework (Vue + Svelte + React); ECC is React-only |
| iterative-retrieval | 0.98x | Token-budget management framing; more actionable for context-conscious template |
| java-springboot | 0.5x | Spring profiles, Actuator, detailed JPA/N+1; ECC is API-layer focused |
| jpa-patterns | 1.4x | N+1 solutions comparison, second-level cache config, JPQL optimization, anti-patterns table |
| postgresql-patterns | 1.6x | EXPLAIN ANALYZE, PostGIS spatial queries, CTE optimization, partitioning, VACUUM tuning |
| python-patterns | 0.5x | Modern 3.9+ syntax, TypeAlias, slots dataclass, Pathlib, Enum patterns |
| security-scan | 1.2x | Educational "what to look for and why" content; component scan checklist; agent tool access table |
| spring-boot-security | 0.7x | Full JWT/OAuth2 config, method security, security testing patterns, misconfiguration table |
| spring-boot-tdd | 1.9x | Test slice annotations table, 8 Mockito patterns, event-driven testing |
| strategic-compact | 0.8x | Template integration (settings presets, hooks, Task Master in persists table) |
| tdd-workflow | 0.6x | Polyglot (Python/Go/JS), decision trees, "when NOT to TDD" section |
| typescript-patterns | N/A | No ECC equivalent; covers generics, utility types, discriminated unions uniquely |
| verification-loop | 2x | Polyglot commands, SKIP/WARN taxonomy, continuous verification, TDD integration |

## New — Unique to Us (7 skills)

| Skill | Lines | Purpose | ECC Gap |
|-------|-------|---------|---------|
| code-review | 101 | General code review workflow with severity tiers, >80% confidence | ECC splits into security-review + plankton-code-quality |
| database-patterns | 169 | SQL optimization, indexing, N+1, connection pooling | Broader than ECC's postgres-patterns |
| debugging | 99 | 4-step debugging workflow (Reproduce, Isolate, Understand, Fix) | ECC has no debugging skill |
| frontend-design | 42 | Distinctive UI design with high design quality | Not in ECC |
| git-recovery | 96 | Git emergency recovery and troubleshooting | Not in ECC |
| python-data-science | 351 | NumPy, pandas, scikit-learn, spatial, geostatistics | Not in ECC |
| python-django | 164 | Python-Django integration patterns | Not in ECC (they have django-patterns separately) |

## Add from ECC — New Skills for Template (5 skills)

| ECC Skill | Purpose | Why Add |
|-----------|---------|---------|
| ai-regression-testing | 4 AI blind-spot test patterns (sandbox/prod mismatch, SELECT omission, error leakage, optimistic rollback) | Addresses AI writes-and-reviews-own-code gap identified in dogfood testing |
| blueprint | Multi-session construction plans with cold-start context briefs and adversarial review gate | Bridges brainstorming → Task Master for complex multi-PR features |
| claude-api | Anthropic SDK patterns (Messages API, streaming, tool use, batches, prompt caching) | No SDK reference skill in template; covers non-obvious patterns |
| search-first | Enforces "search before coding" with npm/PyPI/MCP/GitHub search shortcuts | Makes our "adopt-first" principle a first-class workflow skill |
| skill-stocktake | Automated skill audit with quality checklist, Quick Scan mode, JSON results cache | Makes future audits automatable (like this one) |

## Skip — ECC-Only Not Adopted (~70 skills)

### Evaluated and Rejected (3)

| ECC Skill | Why Skip |
|-----------|----------|
| agentic-engineering | Covered by existing rules (context-management, proactive-steering, Task Master) |
| deep-research | Requires firecrawl/exa MCPs not in our default config |
| mcp-server-patterns | Niche use case; skill defers to Context7 anyway |

### Domain-Specific (not evaluated, ~65)

Skills like `carrier-relationship-management`, `customs-trade-compliance`, `investor-materials`, `logistics-exception-management`, `energy-procurement`, `video-editing`, `visa-doc-translate`, `x-api`, etc. are industry/product-specific and not relevant for a general-purpose template.

### Language-Specific We Don't Cover (~10)

`kotlin-*` (4 skills), `laravel-*` (4 skills), `swift-*` (4 skills), `rust-*` (2 skills), `perl-*` (3 skills), `android-*` (1 skill) — these could be added as optional plugins if demand exists.

## Near-Match Name Mapping

| Our Name | ECC Name | Verdict |
|----------|----------|---------|
| java-springboot | springboot-patterns | Keep ours |
| spring-boot-security | springboot-security | Keep ours |
| spring-boot-tdd | springboot-tdd | Keep ours |
| springboot-verification | springboot-verification | Adopt ECC's |
| postgresql-patterns | postgres-patterns | Keep ours |

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
