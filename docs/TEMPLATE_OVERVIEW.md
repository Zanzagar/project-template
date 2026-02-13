# Project Template: An AI-Augmented Software Engineering Framework

**Author:** Corey Hoydic
**Date:** February 13, 2026
**Version:** 2.1.0
**Repository:** github.com/Zanzagar/project-template

---

## Executive Summary

This project template is a **comprehensive configuration framework for AI-assisted software development** built on top of Claude Code (Anthropic's CLI agent). It transforms a general-purpose LLM from a reactive code-completion tool into a **structured engineering co-pilot** with enforced workflows, specialized sub-agents, persistent learning, and resource-conscious context management.

The template was developed through systematic analysis and integration of best practices from the open-source community — most notably [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) (45K+ stars, Anthropic hackathon winner) — combined with original workflow enforcement patterns designed for disciplined, production-quality software development.

**By the numbers:**
- 13 specialized AI agents
- 32 skills (domain-specific knowledge modules)
- 46 slash commands
- 17 behavior rules (7 core + 5 language-specific + 5 workflow)
- 9 automation hooks
- Multi-model collaboration (Claude + Gemini + Codex)
- Continuous learning system with cross-session memory

---

## The Problem: Why "Out of the Box" Isn't Enough

### What happens without a template

When a developer opens Claude Code (or any LLM coding assistant) without configuration, they get:

1. **A blank slate every session.** The AI has no memory of your project's conventions, architecture decisions, or past mistakes. Every session starts from zero.

2. **No workflow enforcement.** The AI will happily write production code without tests, skip security reviews, push to main without review, or commit broken code. It does what you ask — including bad practices.

3. **No resource management.** Claude Code has a ~200K token context window, but startup overhead (tool definitions, system prompts) consumes 15-25K tokens before you type a word. Without management, you hit quality degradation mid-session with no recovery strategy.

4. **Generic responses.** The AI doesn't know your team's conventions, your framework's idioms, or your project's architectural decisions. It generates "textbook" code that may not fit your codebase.

5. **No specialization.** A single general-purpose model handles everything — code review, security analysis, architecture planning, test generation — with equal (mediocre) depth in each.

### What a well-configured template provides

| Capability | Without Template | With Template |
|-----------|-----------------|---------------|
| **Session continuity** | Forgets everything | Persistent memory, session summaries, work logs |
| **Code quality** | Whatever you ask for | TDD enforcement, automated linting, security gates |
| **Architecture** | Generic patterns | Project-specific rules, conventions, prior decisions |
| **Specialization** | One model does all | 13 purpose-built agents (security, architecture, review...) |
| **Resource efficiency** | Burns through context | Token-conscious presets, strategic compaction, tiered lookups |
| **Workflow** | Reactive (does what you say) | Proactive (detects phase, suggests next steps, catches mistakes) |
| **Learning** | Starts fresh daily | Instinct system captures patterns, evolves into skills |
| **Collaboration** | Single model | Multi-model parallel execution (Claude + Gemini + Codex) |

The difference is analogous to the difference between giving someone a text editor and giving them an IDE. The underlying capability is the same, but the **scaffolding around it** determines whether that capability translates into reliable, high-quality output.

---

## Architecture Overview

```
project-template/
├── .claude/
│   ├── agents/          # 13 specialized sub-agents
│   ├── commands/        # 46 slash commands (user-invocable)
│   ├── skills/          # 32 domain knowledge modules (on-demand)
│   ├── rules/           # 17 behavior rules (auto-loaded)
│   ├── hooks/           # 9 automation scripts
│   ├── instincts/       # Continuous learning patterns (JSON)
│   ├── contexts/        # Session mode injection (dev/review/research)
│   ├── sessions/        # Session persistence and summaries
│   └── work-log.md      # Cross-session decision ledger
├── .taskmaster/         # Task Master integration (AI task management)
├── docs/
│   ├── ECC_INTEGRATION.md
│   ├── SECURITY.md
│   ├── MCP_SETUP.md
│   ├── PLUGINS.md
│   ├── HOOKS.md
│   └── CODEMAPS/        # Auto-generated architecture documentation
├── CLAUDE.md            # Master configuration (loaded every session)
└── CHANGELOG.md         # Release history
```

### Token Budget Awareness

A critical but often overlooked aspect of LLM-assisted development is **context window management**. The template is designed with precise token accounting:

| Component | Tokens | Loading |
|-----------|--------|---------|
| MCP tool definitions | ~25-30K | Always (startup) |
| Core behavior rules | ~5K | Always (startup) |
| CLAUDE.md | ~2K | Always (startup) |
| **Startup overhead** | **~35K** | **Before any work** |
| Skills (32 total) | 0 | On-demand only |
| Slash commands | 0 | On-demand only |
| Language rules | 0 | Only when matching files edited |
| **Working context** | **~165K** | **Available for actual work** |

This design ensures maximum working context. Previous iterations loaded everything upfront and wasted 50K+ tokens on tools that might never be used.

---

## Component Deep Dive

### 1. Specialized Agents (13)

Rather than using one general-purpose model for everything, the template deploys **purpose-built sub-agents** that operate in isolated context windows with appropriate tool access:

| Agent | Model | Purpose | Why Specialized? |
|-------|-------|---------|-------------------|
| **Planner** | Opus | Architecture planning | Needs deep reasoning, read-only to prevent premature coding |
| **Architect** | Opus | System design, ADR output | High-stakes decisions warrant strongest model |
| **Code Reviewer** | Sonnet | Quality review, severity tiers | >80% confidence filtering, cost-effective for frequent use |
| **Security Reviewer** | Sonnet | OWASP Top 10, dependency scanning | Needs Bash access for scanning tools |
| **TDD Guide** | Sonnet | Test-driven development coaching | Advisory role (Superpowers plugin enforces) |
| **Build Resolver** | Sonnet | Fix compilation errors | Needs all tools for surgical fixes |
| **E2E Runner** | Sonnet | End-to-end test generation | Playwright/Cypress/Selenium expertise |
| **Database Reviewer** | Sonnet | SQL optimization, N+1 detection | Domain-specific patterns |
| **Doc Updater** | Haiku | Documentation maintenance | Low-stakes, high-frequency — cheapest model |
| **Refactor Cleaner** | Sonnet | Dead code removal | Write access, but preserves all tests |
| **Go Reviewer** | Sonnet | Go-specific patterns | Goroutine leaks, error wrapping, interface design |
| **Go Build Resolver** | Sonnet | Go module/CGO errors | Go-specific build toolchain |
| **Python Reviewer** | Sonnet | Python async, metaclasses, GIL | Framework-specific (Django, FastAPI, Flask) |

**Why this matters:** A security review by a dedicated security agent with OWASP training produces categorically better results than asking a general-purpose model "does this code have security issues?" The specialization is in the system prompt, tool access, and model selection — not just the question asked.

### 2. Slash Commands (46)

Commands are user-invocable workflows triggered by typing `/command-name`. They range from simple shortcuts to complex multi-step pipelines:

**Development Commands:**
`/plan`, `/tdd`, `/build-fix`, `/test`, `/lint`, `/verify`, `/test-coverage`

**Review Commands:**
`/code-review`, `/python-review`, `/go-review`, `/security-audit`, `/e2e`

**Language-Specific:**
`/go-build`, `/go-test`, `/go-review`, `/python-review`

**Project Management:**
`/tasks`, `/task-status`, `/prd`, `/github-sync`, `/orchestrate`

**Quality & Documentation:**
`/eval`, `/update-codemaps`, `/update-docs`, `/changelog`, `/health`

**AI Collaboration:**
`/multi-plan`, `/multi-execute`, `/brainstorm`, `/research`

**Learning & Evolution:**
`/learn`, `/skill-create`, `/evolve`, `/instinct-status`, `/instinct-import`, `/instinct-export`

**Infrastructure:**
`/setup`, `/settings`, `/plugins`, `/mcps`, `/commit`, `/pr`, `/checkpoint`, `/sessions`

### 3. Skills (32 domain knowledge modules)

Skills are **on-demand reference material** that Claude loads only when relevant. They cost zero tokens at startup but provide deep domain knowledge when activated:

**Backend:** api-design, backend-patterns, database-patterns, database-migrations, postgresql-patterns, deployment-patterns, docker-patterns

**Frontend:** frontend-patterns, typescript-patterns, e2e-testing

**Python Ecosystem:** python-testing, python-django, django-security

**Go Ecosystem:** golang-patterns, golang-testing

**Java Ecosystem:** java-springboot

**Workflow:** code-review, debugging, git-recovery, iterative-retrieval, continuous-learning-v2

**Infrastructure:** api-design, deployment-patterns, docker-patterns

### 4. Behavior Rules (17)

Rules are **auto-loaded constraints** that define how Claude behaves. They're the "constitution" of the template:

**Core Rules (always loaded, ~5K tokens):**
- **claude-behavior.md** — Commit frequency, conventional commits, proactive git behavior
- **git-workflow.md** — Branch naming, recovery commands, team collaboration rules
- **reasoning-patterns.md** — Clarification before assumption, brainstorming before building, five whys debugging
- **workflow-guide.md** — Phase detection (ideation → planning → building → review → shipping), tool selection
- **context-management.md** — Thinking modes, compaction strategy, session persistence
- **proactive-steering.md** — Project co-pilot behaviors, scope management, milestone tracking
- **authority-hierarchy.md** — Rules > Instincts > Defaults precedence

**Language Rules (loaded only when editing matching files):**
- Python, TypeScript, Go, Java, Frontend (React/Vue/Svelte)

### 5. Continuous Learning System

The template includes a **cross-session learning mechanism** inspired by ECC's instinct system:

```
Session Work → Pattern Extraction → Instinct (confidence 0.3-0.7)
                                        ↓ (reinforced)
                                   Active Instinct (>0.7)
                                        ↓ (clustered via /evolve)
                                   Promoted to Skill
```

- **Instincts** are lightweight JSON patterns with confidence scores that decay when unused
- When multiple instincts cluster around a theme, `/evolve` promotes them into full skills
- Authority hierarchy ensures instincts never override explicit rules
- Instincts can be exported/imported for team sharing

### 6. Multi-Model Collaboration

The template supports **parallel execution across multiple AI models** for diverse perspectives:

```
/multi-plan "Design authentication system"
    ├── Claude (Opus): Architecture, security considerations
    ├── Gemini: Alternative approaches, frontend patterns
    └── Codex: Implementation patterns, code generation

    → Synthesized plan combining strengths of each
```

This is particularly valuable for architectural decisions where groupthink from a single model can lead to blind spots.

---

## Workflow Enforcement

### The TDD Cycle

The template doesn't just suggest test-driven development — it **enforces** it:

1. **Superpowers plugin** (required) will delete production code written without failing tests
2. **RED phase:** Write a failing test that defines the desired behavior
3. **GREEN phase:** Write the minimum code to make the test pass
4. **REFACTOR phase:** Improve the code while keeping tests green

This enforcement catches the most common failure mode in AI-assisted development: the AI generates plausible-looking code that was never tested.

### The Verification Pipeline

`/verify` runs a structured quality gate:

```
Stage 1: Tests (pytest/jest/go test)     → PASS/FAIL/SKIP
Stage 2: Linting (ruff/eslint/golint)    → PASS/FAIL/SKIP
Stage 3: Type Checking (mypy/tsc)        → PASS/FAIL/SKIP
Stage 4: Security (bandit/npm audit)     → PASS/FAIL/SKIP

Result: READY / NOT READY for PR
```

SKIP (tool not installed) is distinct from FAIL — the template adapts to whatever tooling the project actually has, rather than demanding a specific stack.

### Proactive Phase Detection

The template automatically detects what phase of development you're in and adjusts behavior:

| Phase | Signals | Behavior |
|-------|---------|----------|
| **Ideation** | "I want to build..." | Brainstorming, research, NO code |
| **Planning** | PRD exists, creating tasks | Task breakdown, dependency mapping |
| **Building** | Task in progress | TDD enforcement, frequent commits |
| **Review** | Code complete | Security audit, quality review |
| **Shipping** | Ready to merge | PR creation, changelog, issue sync |

---

## Comparison: Template vs. Raw Claude Code

### Scenario: "Build a REST API for user management"

**Without template (raw Claude Code):**
1. Developer types the request
2. Claude generates the entire API in one shot — models, routes, middleware, database
3. No tests. No security review. No type checking.
4. Developer copy-pastes into their project
5. Bugs, security holes, and architectural decisions are discovered in production

**With template:**
1. `/plan Build a REST API for user management` → Planner agent creates phased plan, waits for approval
2. Developer approves Phase 1 (database models)
3. `/tdd` → TDD guide writes failing tests for User model, then implementation
4. `/verify` → Tests pass, linting clean, types checked
5. `/commit` → Conventional commit with semantic message
6. Repeat for Phase 2 (routes), Phase 3 (middleware)
7. `/code-review` → Code reviewer checks quality (>80% confidence filtering)
8. `/security-audit` → Security reviewer checks OWASP Top 10
9. `/pr` → Pull request with summary and test plan
10. `/learn` → Extract any reusable patterns from the session

The difference isn't just quality — it's **reproducibility**. The template produces consistently high-quality output because the process is enforced, not optional.

### Quantitative Comparison

| Metric | Raw Claude Code | With Template |
|--------|----------------|---------------|
| Test coverage | 0% (tests not written) | 80%+ (TDD enforced) |
| Security review | None | Automated OWASP scan |
| Commit quality | "fixed stuff" | `feat(auth): Add JWT token refresh` |
| Session continuity | None | Summaries, work log, instincts |
| Context efficiency | ~50K wasted on unused tools | <35K startup, 165K working |
| Specialization | 1 general model | 13 specialized agents |
| Documentation | Manual or forgotten | Auto-generated codemaps |
| Learning | Starts fresh every session | Persistent instinct system |

---

## Value Proposition for Academic Projects

### For Students

1. **Enforced best practices from day one.** Students don't need to know all the best practices — the template enforces them. TDD, conventional commits, security reviews, and code quality gates become habits, not afterthoughts.

2. **Domain expertise on demand.** Need to set up a Django project? The `python-django` skill provides production-grade patterns. Need PostgreSQL optimization? The `postgresql-patterns` skill knows about indexing strategies, N+1 detection, and migration safety.

3. **Consistent quality at scale.** A senior capstone project with 10,000+ lines of code maintains the same quality standards as the first 100 lines, because the template scales with the project.

4. **Learning acceleration.** The `/learn` and instinct system means discoveries in one session carry forward. Students build a growing knowledge base that compounds over time.

### For Research

1. **Reproducible engineering processes.** The template's workflow enforcement means two different students using it will follow the same development process, making collaboration and peer review meaningful.

2. **Multi-model perspectives.** `/multi-plan` and `/multi-execute` provide diverse AI perspectives on architectural decisions, reducing single-model bias in AI-assisted research tooling.

3. **Audit trail.** Conventional commits, work logs, session summaries, and task management create a complete record of how software was developed — valuable for methodology sections of papers.

### For the Department

1. **Standardized starting point.** Every project begins with production-grade tooling, not a blank directory. This raises the floor for all student work.

2. **Template as teaching tool.** The rules and skills encode best practices that students absorb through use. The authority hierarchy (Rules > Instincts > Defaults) teaches software engineering governance.

3. **Scalable mentorship.** The template acts as an "always-available senior engineer" that catches mistakes, suggests next steps, and enforces quality — supplementing (not replacing) faculty guidance.

---

## Development Timeline

### Completed (v2.0.0 — v2.1.0)

**Phase 1: ECC Integration (15 tasks)**
- Token optimization presets (60-80% cost reduction)
- Session persistence (summaries, pre-compaction state preservation)
- Dynamic context modes (dev, review, research)
- MCP discipline (10/80 rule enforcement)
- 4 core agent definitions + code review confidence filtering

**Phase 2: Full Feature Parity (35 tasks)**
- 9 additional agents (13 total)
- 10 multi-language skills
- Continuous learning v2 (instinct system)
- Multi-model collaboration (/multi-plan, /multi-execute)
- Orchestration pipelines (feature, review, refactor, bugfix, security)
- AgentShield security scanning
- Language-specific coding standards (Python, TypeScript, Go, Java, Frontend)

**Phase 2.1: Gap-Filling Release**
- 6 new skills (docker, API design, deployment, database migrations, backend patterns, iterative retrieval)
- 5 commands upgraded from ECC source comparison (eval, update-codemaps, orchestrate, checkpoint, update-docs)
- 12 agent-invoking slash commands (/plan, /tdd, /code-review, /e2e, /build-fix, /refactor-clean, /go-review, /python-review, /go-build, /go-test, /test-coverage, /learn)

### In Progress (v2.2.0 — to resume on Journel)

This release completes ECC feature parity by adding the remaining skills, automation hooks, and documentation rollup. All items below have been scoped and gap-analyzed against ECC's source code. Implementation resumes on the departmental Journel server.

#### 12 Domain Skills

Each skill is a self-contained knowledge module that loads on-demand (zero startup cost) when Claude detects it's relevant to the current task.

| Skill | What It Provides | Why It's Needed |
|-------|-----------------|-----------------|
| **tdd-workflow** | Complete RED-GREEN-REFACTOR cycle patterns, coverage thresholds by code type, mocking strategies per framework (Jest, pytest, Go test) | Our `tdd-guide` agent exists but lacks a portable skill reference. ECC's version includes framework-specific test patterns and Arrange-Act-Assert templates. |
| **verification-loop** | 6-phase verification system (build → types → lint → test → security → diff review) with continuous mode for long sessions | Complements our `/verify` command with reusable verification patterns that any agent can reference, not just the command itself. |
| **eval-harness** | Eval-driven development (EDD) framework with `pass@k` (capability) and `pass^k` (regression) metrics, code-based and model-based graders | Our `/eval` command was rewritten with ECC's model, but the underlying skill for building evaluation harnesses is missing. This teaches Claude how to construct evals, not just run them. |
| **security-scan** | AgentShield configuration auditing — scans CLAUDE.md for hardcoded secrets, hooks for command injection, MCP configs for supply-chain risks, agents for overly broad tool access | Our `security-reviewer` agent does code-level OWASP scanning. This skill covers *configuration-level* security — a different attack surface entirely. |
| **python-patterns** | Framework-agnostic Python idioms: type hints (3.9+ syntax), context managers, decorators, comprehensions, `__slots__`, async/await patterns, `pyproject.toml` configuration | We have `python-django` (Django-specific) but nothing for general Python. A student building a CLI tool or data pipeline gets no Python guidance without this. |
| **postgresql-patterns** | Query optimization (EXPLAIN ANALYZE), indexing strategies (B-tree vs GIN vs GiST), partitioning, connection pooling, JSONB patterns, CTE performance, vacuum tuning | Our `database-patterns` skill is generic SQL. PostgreSQL has specific optimization patterns (e.g., partial indexes, covering indexes) that generic advice misses. |
| **spring-boot-security** | Spring Security configuration, OAuth2/JWT integration, CORS policies, CSRF protection, method-level security annotations, security filter chain | Our `java-springboot` skill covers general Spring Boot but has zero security content. Security misconfigurations are the #1 vulnerability in Spring applications. |
| **spring-boot-tdd** | JUnit 5 + Mockito patterns, `@SpringBootTest` vs `@WebMvcTest` slice testing, `@DataJpaTest` for repository layers, TestContainers for integration tests | Our `java-springboot` skill has no testing patterns. Without this, Claude generates untested Spring code — exactly what TDD enforcement is meant to prevent. |
| **django-tdd** | pytest-django fixtures, `TestCase` vs `TransactionTestCase`, factory_boy patterns, API testing with DRF's `APIClient`, model testing, middleware testing | We have `django-security` but no TDD guidance for Django. Testing Django views, models, and middleware has framework-specific patterns that generic pytest advice doesn't cover. |
| **django-verification** | Django system checks framework, `manage.py check --deploy`, migration verification, template validation, URL resolution testing, settings validation | Quality assurance specific to Django — verifying migrations are complete, no missing template variables, deployment checklist passes. |
| **jpa-patterns** | Entity mapping (`@OneToMany`, `@ManyToOne`), lazy vs eager loading, N+1 query prevention with `@EntityGraph`, JPQL optimization, second-level caching, transaction boundaries | Our `java-springboot` skill covers Spring Boot generally but JPA/Hibernate is a deep domain with its own anti-patterns (the "open session in view" problem, detached entity exceptions). |
| **cpp-testing** | Google Test / Catch2 patterns, test fixtures, parameterized tests, mocking with GMock, memory leak detection with AddressSanitizer, benchmark testing | New language coverage. C++ testing has unique challenges (no reflection, manual memory management) that require specialized patterns. |

#### 6 Automation Hooks

Hooks are shell scripts that execute automatically in response to Claude Code events (before/after tool use, session start/end). They enforce discipline without requiring the developer to remember to run checks.

| Hook | Trigger | What It Does | Why It Matters |
|------|---------|-------------|----------------|
| **Doc File Blocker** | PreToolUse (Write) | Blocks creation of random `.md` / `.txt` files. Allows `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, and files in `docs/`. | LLMs have a tendency to create unnecessary documentation files ("let me create a NOTES.md..."). This prevents documentation sprawl by funneling all docs through proper channels. |
| **Console.log Audit** | PostToolUse (Edit) | Scans edited files for `console.log`, `print()`, `fmt.Println` debug statements and warns if found. | Debug statements that slip into production are a code review classic. Catching them at edit time is cheaper than catching them in review. |
| **Pattern Extraction** | SessionEnd | Analyzes the completed session for recurring patterns, error resolutions, and workarounds. Saves candidates as instincts (confidence 0.3-0.5) for the continuous learning system. | This is the engine that powers cross-session learning. Without it, the instinct system only grows via manual `/learn` invocations. With it, the template learns automatically from every session. |
| **Build Analysis** | PostToolUse (Bash) | After build commands (`npm run build`, `cargo build`, `go build`), runs a background analysis of build output without blocking the developer. | Provides proactive feedback about build health. Runs asynchronously so it doesn't slow down the workflow — results appear as advisory messages. |
| **TypeScript Check** | PostToolUse (Edit) | After editing `.ts` / `.tsx` files, runs `tsc --noEmit` on the changed file to catch type errors immediately. | Type errors caught at edit time take 5 seconds to fix. Type errors discovered 30 minutes later during a build take 5 minutes to fix. Immediate feedback dramatically reduces debugging time. |
| **Dev Server Blocker** | PreToolUse (Bash) | Blocks `npm run dev`, `pnpm dev`, and similar commands unless running inside tmux. Suggests the tmux command instead. | Dev servers run indefinitely and capture the terminal. Inside tmux, you can detach and reattach. Outside tmux, killing the terminal kills the server — and any unsaved session state with it. |

#### Documentation Rollup

- Update CLAUDE.md slash commands table from 34 to 46 entries
- Update component inventory counts across CLAUDE.md, ECC_INTEGRATION.md, and TEMPLATE_OVERVIEW.md
- Add CHANGELOG v2.2.0 entry documenting all new skills, hooks, and final ECC coverage metrics
- Update MCP_SETUP.md if any tool count changes

### Future Roadmap (v3.0+)

#### Phase 1: Journel Server Deployment

The template moves from a WSL development environment to Journel (departmental Linux server), which changes several operational assumptions:

| Task | What Changes | Implementation |
|------|-------------|----------------|
| **Environment validation** | WSL has path quirks (`/mnt/c/` vs `/home/`). Native Linux eliminates these but may introduce different issues (permissions, package availability). | Run `/health` on Journel, fix any environment-specific failures. Validate all hooks execute correctly on the server's shell (bash version, node availability). |
| **Claude Code installation** | WSL had Claude Code pre-installed. Journel needs fresh installation with OAuth authentication. | Install via `npm install -g @anthropic-ai/claude-code`. Configure OAuth (no API key needed with Claude Pro). Verify MCP servers (Task Master, Context7) connect. |
| **Multi-model API keys** | `/multi-plan` and `/multi-execute` require Gemini and OpenAI API keys for full functionality. | Configure `.env` with `GOOGLE_AI_KEY` and `OPENAI_API_KEY`. Without these, multi-model commands gracefully degrade to Claude-only mode. |
| **Shared instinct repository** | Currently, instincts live in each developer's `.claude/instincts/`. For team use, instincts should be shareable. | Create a shared instinct directory on Journel. Use `/instinct-export` and `/instinct-import` to sync patterns between team members. |
| **Git configuration** | Journel may have different git credentials, SSH keys, and remote access. | Configure git with SSH key for GitHub access. Verify `git push` works from Journel to the template repository. |

#### Phase 2: Project-Type Presets

Currently, the template requires manual selection of which skills and rules are relevant. Presets automate this:

```
/setup preset python-fastapi
  → Activates: python-patterns, api-design, database-patterns, postgresql-patterns
  → Configures: pytest, ruff, mypy in /verify pipeline
  → Creates: src/api/, src/models/, tests/ directory structure
  → Installs: fastapi, uvicorn, pydantic, sqlalchemy, alembic

/setup preset node-nextjs
  → Activates: typescript-patterns, frontend-patterns, e2e-testing
  → Configures: jest/vitest, eslint, tsc in /verify pipeline
  → Creates: app/, components/, lib/ directory structure (Next.js App Router)
  → Installs: next, react, typescript, playwright

/setup preset go-api
  → Activates: golang-patterns, golang-testing, api-design, postgresql-patterns
  → Configures: go test, golangci-lint, go vet in /verify pipeline
  → Creates: cmd/, internal/, pkg/ directory structure
  → Installs: go mod init, wire, sqlc

/setup preset java-spring
  → Activates: java-springboot, spring-boot-security, spring-boot-tdd, jpa-patterns
  → Configures: mvn test, spotbugs, checkstyle in /verify pipeline
  → Creates: standard Maven/Gradle project structure
```

Each preset is a JSON file mapping project type to skills, rules, directory structure, and verification pipeline configuration. Students run one command and get a fully configured project.

#### Phase 3: Team Collaboration Features

| Feature | Description | Value |
|---------|-------------|-------|
| **Shared instinct library** | Central repository of learned patterns that all team members' Claude instances can access. When one developer discovers a workaround, everyone benefits. | Eliminates redundant debugging across team members. A fix discovered on Monday is available to all teammates by Tuesday. |
| **Cross-project pattern extraction** | Analyze instincts across multiple projects to identify universal patterns vs project-specific ones. | Universal patterns become template-level skills. Project-specific patterns stay as project instincts. |
| **Team review aggregation** | Combine `/code-review` findings across team members to build a shared understanding of codebase quality. | Faculty can see aggregated quality metrics across all student projects without reviewing each one individually. |
| **Instinct conflict resolution** | When two developers' instincts contradict, surface the conflict and let the team decide which pattern wins. | Prevents "my Claude says X, your Claude says Y" disagreements by making learned patterns explicit and reviewable. |

#### Phase 4: CI/CD Integration

The template's `/verify` pipeline currently runs locally. CI/CD integration runs it automatically on every push:

```yaml
# .github/workflows/template-verify.yml
name: Template Verification
on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run test suite
        run: pytest --cov=src --cov-report=xml
      - name: Run linter
        run: ruff check .
      - name: Run type checker
        run: mypy src/
      - name: Run security scan
        run: bandit -r src/ -f json -o bandit-report.json
      - name: Upload coverage
        uses: codecov/codecov-action@v4
      - name: Comment PR with results
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            // Post verification results as PR comment
```

This means the same quality gates enforced locally by the template are also enforced in CI — no code merges to main without passing all stages.

#### Phase 5: Metrics Dashboard

Track development quality and velocity over time:

| Metric | Source | What It Shows |
|--------|--------|---------------|
| **Test coverage trend** | pytest/jest coverage reports | Is coverage improving, stable, or declining? |
| **Commit frequency** | Git log analysis | How often are students committing? (Template enforces frequent commits) |
| **Security issue density** | `/security-audit` historical results | Are security practices improving over time? |
| **TDD compliance** | Superpowers enforcement logs | What percentage of code was written test-first? |
| **Instinct growth** | `.claude/instincts/` file count and confidence scores | Is the team's collective knowledge growing? |
| **Code quality scores** | `/eval` pass@k metrics | Are feature implementations becoming more reliable? |

This data enables faculty to assess not just *what* students built, but *how* they built it — measuring process quality alongside output quality.

#### Phase 6: Academic Workflow Mode

Specialized rules and workflows for research-oriented development:

| Feature | What It Does |
|---------|-------------|
| **Experiment logging** | Automatically log hyperparameters, dataset versions, and results for ML experiments. Each run gets a timestamped entry in `experiments/`. |
| **Reproducibility checks** | `/verify` gains a reproducibility stage: checks for hardcoded paths, missing seed values, unversioned dependencies, and non-deterministic operations. |
| **Citation tracking** | When Claude references external libraries, papers, or techniques, it logs the citation. `/citations` generates a bibliography of all tools and references used. |
| **Notebook discipline** | Rules for Jupyter notebook hygiene: clear outputs before commit, no hardcoded credentials in cells, mandatory markdown headers explaining each section. |
| **Data pipeline validation** | Skills for validating data pipelines: schema checks, null handling, data drift detection, train/test leakage prevention. |
| **Thesis/paper integration** | `/update-docs` gains a mode for updating LaTeX or Markdown thesis chapters when the underlying code changes, keeping implementation descriptions in sync with actual code. |

#### Phase 7: Custom Agent Creation Framework

Allow students and faculty to define project-specific agents without modifying the template core:

```markdown
<!-- .claude/agents/custom/ml-reviewer.md -->
---
model: sonnet
tools: Read, Grep, Glob
description: Review ML code for common mistakes
---

# ML Code Reviewer

Check for:
- Train/test data leakage
- Missing random seeds
- Hardcoded hyperparameters that should be configurable
- Incorrect loss function for the task type
- Missing model checkpointing
- Evaluation on training data
```

This turns domain expertise into reusable AI configuration. A professor who knows ML anti-patterns writes them once as an agent definition, and every student's Claude instance enforces them automatically.

---

## Conclusion

The gap between "AI writes code" and "AI assists in engineering high-quality software" is not a matter of model capability — it's a matter of **scaffolding**. This template bridges that gap by providing:

1. **Structure** where raw LLMs offer none
2. **Enforcement** where raw LLMs only suggest
3. **Specialization** where raw LLMs generalize
4. **Memory** where raw LLMs forget
5. **Efficiency** where raw LLMs waste resources

The template is not a replacement for understanding software engineering. It is a **force multiplier** that ensures the AI's considerable capabilities are channeled through disciplined processes, producing output that meets professional standards rather than merely appearing to.

Any student using this template starts their project with the workflow enforcement, quality gates, and domain expertise that typically takes years of professional experience to internalize. The template makes the right way the easy way.

---

*Built with Claude Code (Anthropic) | Informed by Everything Claude Code (45K+ stars)*
*Template version 2.1.0 | 13 agents, 32 skills, 46 commands, 17 rules, 9 hooks*
