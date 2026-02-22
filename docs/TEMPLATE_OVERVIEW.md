# Project Template: An AI-Augmented Software Engineering Framework

**Author:** Corey Hoydic
**Date:** February 13, 2026
**Version:** 2.2.0
**Repository:** github.com/Zanzagar/project-template

---

## Executive Summary

This project template is a **comprehensive configuration framework for AI-assisted software development** built on top of Claude Code (Anthropic's CLI agent). It transforms a general-purpose LLM from a reactive code-completion tool into a **structured engineering co-pilot** with enforced workflows, specialized sub-agents, persistent learning, and resource-conscious context management.

The template was developed through systematic analysis and integration of best practices from the open-source community — most notably [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) (45K+ stars, Anthropic hackathon winner) — combined with original workflow enforcement patterns designed for disciplined, production-quality software development.

**By the numbers:**
- 14 specialized AI agents
- 39 skills (domain-specific knowledge modules)
- 49 slash commands
- 13 behavior rules (8 core + 5 language-specific)
- 18 automation hooks
- 5 project-type presets for one-command scaffolding
- Multi-model collaboration (Claude + Gemini + Codex)
- Continuous learning system with cross-session memory
- Status line with context %, model, branch, and session duration

---

## The Problem: Why "Out of the Box" Isn't Enough

### What actually goes wrong without a template

Consider a concrete scenario: a graduate student building a geostatistical interpolation pipeline for their thesis. They open Claude Code and type "Build me a kriging pipeline that reads borehole data from CSV, fits a variogram, and generates a prediction grid as a GeoTIFF."

Within 90 seconds, Claude generates 300 lines of code — CSV parsing, variogram fitting with `pykrige`, grid generation, rasterio export. It looks complete. The student runs it, gets a GeoTIFF output, and commits with the message "added kriging" and moves on.

Here's what they don't realize happened:

1. **No tests exist.** The AI generated zero test files. The student now has a working pipeline with 0% test coverage. When they modify the variogram model from spherical to exponential two weeks later, the grid dimensions silently change because of a parameter they didn't understand. They discover this the night before their thesis committee meeting — their prediction surface no longer aligns with their validation data.

2. **The coordinate reference system is wrong.** Claude assumed WGS84 (EPSG:4326) but the borehole data is in a local projected CRS (e.g., NAD83 / UTM Zone 17N). The kriging results look reasonable because the data is clustered, but the spatial statistics are computed on unprojected coordinates — meaning distances are in degrees, not meters. Every variogram parameter and every prediction is subtly wrong. A code review would have caught this immediately, but none was enforced.

3. **The session is gone.** The next day, the student opens Claude Code and says "now add cross-validation." Claude has no memory of yesterday's decisions — which variogram model was chosen, what the grid resolution is, how the CRS was handled. The student spends 20 minutes re-explaining their own pipeline to the AI.

4. **Context degraded mid-session.** After loading 10 MCP tool definitions (134 tools, 50K+ tokens), Claude's effective working context is already halved before the student types anything. By the time they've loaded rasterio documentation, a few data files, and had some back-and-forth, quality silently degrades. Claude starts forgetting the CRS conventions from earlier, suggesting `matplotlib` plots when `rasterio` was already being used, and generating code that contradicts the existing pipeline.

5. **The commit history is useless.** After three weeks of development, the git log reads: "added kriging", "updates", "fixed stuff", "more changes", "final version", "actual final version". The thesis advisor reviewing the code can't tell what was built when, can't evaluate the development process, and has no way to verify which decisions the student made versus which the AI made.

**None of these failures are caused by the AI being incapable.** Claude Code can write tests, handle CRS transformations, remember context, and produce clean commits. It just doesn't do these things *automatically*. Without a template, the quality of AI-assisted output depends entirely on the developer knowing to ask for best practices — which is exactly what students are still learning.

### The five gaps a template fills

| Gap | What Happens Without It | What the Template Does |
|-----|------------------------|----------------------|
| **Memory** | Every session starts from zero. The AI forgets your architecture, conventions, and past decisions. | Persistent session summaries, work logs, instinct system, and CLAUDE.md carry context across sessions indefinitely. |
| **Discipline** | The AI writes whatever you ask for, including insecure code, untested features, and broken commits. | TDD enforcement (Superpowers deletes untested code), security gates, conventional commit rules, and verification pipelines make bad practices harder than good ones. |
| **Resources** | 50K+ tokens consumed by unused tools at startup. Quality degrades silently mid-session with no recovery. | Token-conscious design (35K startup, 165K working). Strategic compaction, tiered documentation lookups, and on-demand skill loading maximize working context. |
| **Context** | Generic "textbook" code that doesn't fit the project's patterns, framework idioms, or architectural decisions. | 13 behavior rules, 39 domain skills, and language-specific coding standards teach the AI your project's conventions. |
| **Specialization** | One general-purpose model handles security review, architecture planning, test generation, and documentation with equal (shallow) depth. | 13 purpose-built agents with appropriate model tiers, tool access, and domain training produce categorically deeper results in each specialty. |

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
│   ├── agents/          # 14 specialized sub-agents
│   ├── commands/        # 49 slash commands (user-invocable)
│   ├── skills/          # 39 domain knowledge modules (on-demand)
│   ├── rules/           # 13 behavior rules (auto-loaded)
│   ├── hooks/           # 18 automation hooks
│   ├── presets/         # Project-type preset definitions (JSON)
│   ├── instincts/       # Continuous learning patterns (JSON)
│   ├── contexts/        # Session mode injection (dev/review/research)
│   ├── sessions/        # Session persistence and summaries
│   └── work-log.md      # Cross-session decision ledger
├── .taskmaster/         # Task Master integration (AI task management)
├── scripts/
│   ├── init-project.sh    # Initialize local .claude/ structure (symlinks or copies)
│   ├── setup-preset.sh    # One-command project scaffolding
│   ├── smoke-test.sh      # Validate template overlay deployments
│   ├── sync-template.sh   # Sync/adopt template updates into existing projects
│   ├── manage-mcps.sh     # MCP server management
│   └── manage-plugins.sh  # Plugin management
├── docs/
│   ├── TEMPLATE_OVERVIEW.md
│   ├── TEMPLATE_OVERLAY_FRICTION.md  # Overlay testing results and fix status
│   ├── ECC_INTEGRATION.md
│   ├── ECC_COMPARISON.md
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
| Skills (39 total) | 0 | On-demand only |
| Presets (5 project types) | 0 | On-demand only |
| Slash commands | 0 | On-demand only |
| Language rules | 0 | Only when matching files edited |
| **Working context** | **~165K** | **Available for actual work** |

This design ensures maximum working context. Previous iterations loaded everything upfront and wasted 50K+ tokens on tools that might never be used.

---

## Project Lifecycle Pipeline

This section shows **what fires when** across all 188 components during a project lifecycle. Use this as a reference for understanding the system and identifying gaps.

### Always Active (every session, ~35k tokens)

| Component | Type | Purpose |
|-----------|------|---------|
| CLAUDE.md | Config | Project name, tech stack, patterns, constraints |
| 8 core rules | Auto-loaded | Commit style, git workflow, reasoning patterns, phase detection, context management, proactive steering, authority hierarchy, Superpowers integration |
| 5 language rules | Conditional | Load only when matching files are edited (.py, .ts, .go, .java, .jsx/.vue) |
| task-master-ai MCP | Tools | Task management (list, show, set-status, next, expand, parse-prd) |
| context7 MCP | Tools | Up-to-date library documentation lookup |
| Superpowers plugin | Skills | TDD enforcement, systematic debugging, brainstorming, verification |

### Session Lifecycle (automatic hooks)

**Session Start:**
- `session-init.sh` — Detects project phase (ideation/planning/building/review/shipping), shows status, loads last session summary (<24h), auto-starts observer daemon
- `project-index.sh` — Scans source files for signatures, writes `.claude/project-index.json`

**Every Tool Use:**
- `observe.sh` (pre+post) — Logs tool usage to `observations.jsonl` for continuous learning

**Every User Prompt:**
- `pre-compact.sh` — Saves working state if `/compact` detected
- `suggest-compact.sh` — Nudges at 50 tool calls, `/learn` nudge at 75

**On File Edit/Write:**
- `protect-sensitive-files.sh` — **BLOCKS** edits to .env, .pem, credentials
- `doc-file-blocker.sh` — **BLOCKS** random .md file creation outside docs/
- `post-edit-format.sh` — Auto-formats (ruff, prettier, gofmt, rustfmt, shfmt)
- `console-log-audit.sh` — Warns on debug statements (print, console.log, fmt.Println)
- `typescript-check.sh` — Runs `tsc --noEmit` after .ts/.tsx edits

**On Bash Commands:**
- `pre-commit-check.sh` — Lint + test + staged file scan before `git commit`
- `dev-server-blocker.sh` — **BLOCKS** dev servers outside tmux
- `long-running-tmux-hint.sh` — Advisory tmux reminder for slow commands
- `build-analysis.sh` — Advisory analysis after build commands
- `pr-url-extract.sh` — Shows PR creation URL after `git push`

**Session End (Stop event):**
- `session-end.sh` — Saves detailed session summary to `.claude/sessions/`
- `session-summary.sh` — Lightweight YAML session log
- `pattern-extraction.sh` — Extracts instinct candidates from git history (3+ commits)

### Phase 1: Ideation ("I want to build...")

| Action | Component | Type |
|--------|-----------|------|
| Explore ideas | `superpowers:brainstorming` | Skill (mandatory) |
| Research topic | `/research` | Command |
| Multi-model perspectives | `/multi-plan` → `multi-model-query.py` | Command + Script |
| Web research | WebSearch, WebFetch, Context7 | Tools |
| **Output** | `docs/plans/YYYY-MM-DD-<topic>-design.md` | Design doc |

### Phase 2: Planning ("Here's what we'll build")

| Action | Component | Type |
|--------|-----------|------|
| Create PRD | `/prd-generate` or manual | Command |
| Parse into tasks | `task-master parse-prd --num-tasks 0` | MCP |
| Analyze complexity | `task-master analyze-complexity` | MCP |
| Expand complex tasks | `task-master expand --id=<id>` | MCP |
| Architecture planning | planner agent (opus, read-only) | Agent |
| System design | architect agent (opus, read-only) | Agent |
| **Output** | Tasks with subtasks in Task Master | Task state |

### Phase 3: Building ("Implement task by task")

For each task, the TDD cycle runs:

| Step | Action | Component | Type |
|------|--------|-----------|------|
| Get task | `task-master next` / `set-status in-progress` | MCP | |
| **RED** | Write failing tests | `superpowers:test-driven-development`, `/tdd`, `/generate-tests` | Skill + Commands |
| **GREEN** | Make tests pass | Language rules + domain skills (39 available) load on demand | Rules + Skills |
| **REFACTOR** | Clean up | `/optimize` if needed | Command |
| Verify | Run pipeline | `/verify` (test + lint + types + security) | Command |
| Commit | Conventional commit | `/commit` → `pre-commit-check.sh` fires | Command + Hook |
| Complete | Mark done | `task-master set-status --id=X --status=done` | MCP |

**When things break:** `superpowers:systematic-debugging` (4 phases: Reproduce → Hypothesize → Test → Fix)

**Agents available:** build-resolver, go-build-resolver, tdd-guide, e2e-runner, database-reviewer

### Phase 4: Review ("Is it good enough?")

| Action | Component | Type |
|--------|-----------|------|
| Verify before claiming done | `superpowers:verification-before-completion` | Skill (mandatory) |
| Request code review | `superpowers:requesting-code-review` | Skill (mandatory) |
| Code quality | `/code-review` → code-reviewer agent (sonnet) | Command + Agent |
| Security scan | `/security-audit` → security-reviewer agent (sonnet) | Command + Agent |
| Multi-agent review | `/orchestrate review` → code + security + database reviewers | Command + Agents |
| Language-specific | `/python-review`, `/go-review` → specialized agents | Commands + Agents |
| Update docs | `/update-docs` → doc-updater agent (haiku) | Command + Agent |
| Architecture docs | `/update-codemaps` | Command |

### Phase 5: Shipping ("Get it out the door")

| Action | Component | Type |
|--------|-----------|------|
| Finish branch | `superpowers:finishing-a-development-branch` | Skill (mandatory) |
| Create PR | `/pr` → `pr-url-extract.sh` fires after push | Command + Hook |
| Update changelog | `/changelog` | Command |
| Sync issues | `/github-sync` | Command |
| Quality snapshot | `/eval [--save]` | Command |

### Background Systems (always running)

**Continuous Learning:**
```
observe.sh → observations.jsonl → observer daemon (every 5 min)
                                       ↓
                                 .claude/instincts/
                                 ├── candidates/ (confidence 0.3-0.5)
                                 ├── personal/   (confidence 0.5-0.7+)
                                 └── inherited/  (shared across team)

pattern-extraction.sh (session end) ──► candidates/
/learn (manual, nudged at 75 calls) ──► candidates/
/evolve (cluster instincts into skills)
/instinct-export / /instinct-import (team sharing)

Authority: Rules > Instincts > Defaults (always)
```

**Session Persistence:**
```
.claude/sessions/session_*.md ──── Detailed summaries (from Stop hooks)
.claude/sessions/pre-compact-state.md ── State before compaction
.claude/work-log.md ──── Manual decision ledger
.claude/instincts/ ───── Learned patterns (survive sessions)
.taskmaster/ ──────────── Task state (survive sessions)
```

### Component Summary

| Type | Count | Loading | Token Cost |
|------|-------|---------|-----------|
| Rules (core) | 8 | Always | ~5k |
| Rules (language) | 5 | On file edit | 0 at startup |
| Agents | 14 | On invocation | 0 at startup |
| Skills | 39 | On relevance | 0 at startup |
| Commands | 49 | On `/command` | 0 at startup |
| Hooks | 18 | On event trigger | 0 (shell scripts) |
| MCP tools | ~42 | Always | ~25k |
| Superpowers | 13 skills | Always | ~3-5k |
| **Total** | **188 components** | | **~35k startup** |

---

## Component Deep Dive

### 1. Specialized Agents (14)

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
| **Observer** | Haiku | Background pattern analysis | Analyzes session observations, creates instincts automatically |

**Why this matters:** A security review by a dedicated security agent with OWASP training produces categorically better results than asking a general-purpose model "does this code have security issues?" The specialization is in the system prompt, tool access, and model selection — not just the question asked.

### 2. Slash Commands (49)

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

### 3. Skills (39 domain knowledge modules)

Skills are **on-demand reference material** that Claude loads only when relevant. They cost zero tokens at startup but provide deep domain knowledge when activated:

**Backend:** api-design, backend-patterns, database-patterns, database-migrations, postgresql-patterns, deployment-patterns, docker-patterns

**Frontend:** frontend-patterns, typescript-patterns, e2e-testing

**Python Ecosystem:** python-testing, python-django, python-data-science, django-security

**Go Ecosystem:** golang-patterns, golang-testing

**Java Ecosystem:** java-springboot

**Workflow:** code-review, debugging, git-recovery, iterative-retrieval, continuous-learning-v2

**Infrastructure:** api-design, deployment-patterns, docker-patterns

### 4. Behavior Rules (13)

Rules are **auto-loaded constraints** that define how Claude behaves. They're the "constitution" of the template:

**Core Rules (always loaded, ~5K tokens):**
- **claude-behavior.md** — Commit frequency, conventional commits, proactive git behavior
- **git-workflow.md** — Branch naming, recovery commands, team collaboration rules
- **reasoning-patterns.md** — Clarification before assumption, brainstorming before building, five whys debugging
- **workflow-guide.md** — Phase detection (ideation → planning → building → review → shipping), tool selection
- **context-management.md** — Thinking modes, compaction strategy, session persistence
- **proactive-steering.md** — Project co-pilot behaviors, scope management, milestone tracking
- **authority-hierarchy.md** — Rules > Instincts > Defaults precedence
- **superpowers-integration.md** — Overrides Superpowers brainstorming→writing-plans routing to use PRD→Task Master pipeline instead

**Language Rules (loaded only when editing matching files):**
- Python, TypeScript, Go, Java, Frontend (React/Vue/Svelte)

### 5. Continuous Learning System

One of the fundamental limitations of LLMs is that they don't learn from experience. A model that makes a mistake on Monday will make the same mistake on Tuesday, because each session starts with the same weights. The template's continuous learning system works around this limitation by **persisting patterns as structured data** that gets loaded into future sessions.

#### How It Works

The system operates on three levels:

```
Level 1: INSTINCTS (lightweight, automatic)
  Session Work → Pattern Extraction → Instinct JSON (confidence 0.3)
                                           ↓ reinforced by repetition
                                      Active Instinct (confidence >0.7)
                                           ↓ unused for 2+ weeks
                                      Decayed Instinct (confidence <0.3) → removed

Level 2: SKILLS (permanent, curated)
  Multiple related instincts → /evolve command → Promoted to SKILL.md
  Skills don't decay. They become permanent reference material.

Level 3: RULES (immutable, project-defined)
  Rules are written by the developer and never modified by the learning system.
  Authority hierarchy: Rules > Instincts > Defaults (always)
```

#### Concrete Example

Suppose a student is building a geostatistical pipeline and discovers that all spatial operations must use a projected CRS (meters) rather than geographic coordinates (degrees) — otherwise distance-based computations like variogram fitting produce nonsensical results. The first time this happens:

1. The student (or Claude) debugs the variogram issue and adds a CRS reprojection step
2. `/learn` or the automatic pattern extraction hook captures this as an instinct:

```json
{
  "pattern": "spatial-crs-projection",
  "trigger": "When performing distance-based spatial operations (kriging, IDW, variograms, buffer, nearest-neighbor)",
  "action": "Verify data is in a projected CRS (units=meters). If geographic (EPSG:4326), reproject with geopandas.to_crs() before computing distances.",
  "confidence": 0.5,
  "source": "session-2026-02-13"
}
```

3. The next session, when Claude sees spatial code using `pykrige` or `scipy.spatial`, it proactively checks the CRS and suggests reprojection — even though the student didn't ask
4. If the student confirms this is useful (by accepting the suggestion), confidence increases toward 0.7
5. After several reinforcements, the pattern becomes an active instinct that Claude applies automatically
6. If the student accumulates several geospatial instincts (CRS handling, NoData masking, raster alignment), `/evolve` clusters them into a full `geospatial-data-hygiene` skill

#### Why This Matters

The learning system means that a student's Claude instance **gets better over the course of a semester**. The template they use in September is more knowledgeable than the one they started with in August — not because the model changed, but because the accumulated instincts represent the student's growing expertise, persisted in a format the AI can use.

For teams, instincts can be exported and imported (`/instinct-export`, `/instinct-import`). When one team member discovers a workaround, the entire team benefits in their next session.

#### Governance

The authority hierarchy prevents learned patterns from overriding explicit project rules:

| Source | Authority | Can Override? |
|--------|-----------|--------------|
| Rules (`.claude/rules/`) | Highest | Cannot be overridden by anything |
| Instincts (`.claude/instincts/`) | Medium | Override defaults, but yield to rules |
| Default Claude behavior | Lowest | Overridden by everything above |

This means a rule like "always use conventional commits" cannot be weakened by an instinct that says "batch commits are faster." The learning system supplements the rules — it never contradicts them.

### 6. Multi-Model Collaboration

A single AI model, no matter how capable, has blind spots. It was trained on a specific dataset, optimized for specific objectives, and develops characteristic patterns in its outputs. When an architect makes all decisions alone, the result reflects their biases. The same is true for AI models.

The template addresses this by enabling **parallel execution across multiple AI models**, synthesizing diverse perspectives into a single plan or implementation:

#### How It Works

```
/multi-plan "Design spatial interpolation pipeline for soil contamination mapping"

    ┌───────────────────────────────────────────────────────────┐
    │  Claude (Opus)            Gemini                Codex     │
    │  ─────────────            ──────                ─────     │
    │  Ordinary Kriging with    Random Forest with    Gaussian  │
    │  automatic variogram      spatial features      Process   │
    │  fitting. Cross-          (lat, lon, elevation, Regression│
    │  validation with          distance to source).  with RBF  │
    │  leave-one-out.           Argues: handles non-  kernel.   │
    │  Argues: geostatistical   stationarity better,  Argues:   │
    │  gold standard, provides  no variogram needed,  provides  │
    │  uncertainty estimates.   scales to many vars.  native UQ.│
    └───────────────────────────────────────────────────────────┘
                                ↓
    ┌───────────────────────────────────────────────────────────┐
    │  SYNTHESIZED PLAN                                         │
    │  ─────────────────                                        │
    │  Primary: Ordinary Kriging (Claude) — gold standard for   │
    │    the geostatistics audience, provides defensible UQ     │
    │  Adopted from Gemini: Add RF as comparison model to show  │
    │    kriging outperforms ML on this sparse-data problem     │
    │  Adopted from Codex: Use GPR's RBF kernel as a           │
    │    third comparison — mathematically equivalent to kriging │
    │    but connects to the ML literature                      │
    │  Rejected: Gemini's "no variogram needed" — the thesis    │
    │    committee expects variogram analysis as methodology     │
    └───────────────────────────────────────────────────────────┘
```

#### Why Multiple Models?

Each model brings different strengths:

| Model | Strength | Weakness |
|-------|----------|----------|
| **Claude (Opus)** | Deep reasoning, mathematical rigor, understanding of statistical methodology | Can over-engineer, favors complexity |
| **Gemini** | Broad knowledge across ML literature, strong on recent papers and alternative approaches | Less depth on classical geostatistics |
| **Codex/GPT** | Practical implementation patterns, strong on NumPy/scikit-learn/PyTorch code generation | Less methodological reasoning |

When all three agree, you can be highly confident in the approach. When they disagree, the disagreement itself is valuable — it surfaces trade-offs that a single model might gloss over.

#### Practical Impact

For a research project, multi-model collaboration means:
- **Methodology decisions** get three independent perspectives before code is written — reducing the risk of choosing an approach just because it was the first one the AI suggested
- **Implementation** can route numerical computation to the model strongest at NumPy/SciPy (Codex) and experimental design to the model strongest at methodology (Claude), with results synthesized
- **Literature awareness** from Gemini surfaces recent papers and alternative approaches that Claude or Codex might miss, broadening the student's awareness of the field

The template gracefully degrades when API keys aren't available — `/multi-plan` works with just Claude, but produces richer results with all three models.

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

### Scenario: "Build a kriging pipeline with cross-validation for soil heavy metal prediction"

**Without template (raw Claude Code):**
1. Student types the request
2. Claude generates the entire pipeline in one shot — data loading, variogram fitting, kriging, export
3. No tests. No CRS validation. No cross-validation correctness check. No type hints.
4. Student runs it, gets a pretty GeoTIFF, presents it
5. Thesis committee asks: "How did you handle spatial autocorrelation in your cross-validation?" The student has no answer — they didn't realize that random k-fold CV is invalid for spatially correlated data, and the AI didn't mention it because it wasn't asked

**With template:**
1. `/plan Build a kriging pipeline with cross-validation for soil heavy metal data` → Planner agent creates phased plan: (1) data loading & CRS validation, (2) exploratory spatial analysis, (3) variogram modeling, (4) kriging with spatial cross-validation, (5) export & visualization. Waits for approval.
2. Student approves Phase 1 (data loading)
3. `/tdd` → TDD guide writes failing tests: "test that input data is reprojected to UTM", "test that NaN values are handled", "test that output CRS matches input CRS"
4. `/verify` → Tests pass, ruff linting clean, mypy types checked
5. `/commit` → `feat(data): Add borehole CSV loader with CRS validation`
6. Repeat for Phase 2 (variogram), Phase 3 (kriging), Phase 4 (spatial CV — the planner flags that random k-fold is invalid for spatial data and recommends spatial leave-one-out or block CV)
7. `/code-review` → Python reviewer checks for NumPy anti-patterns, type safety, proper error handling
8. `/python-review` → Catches mutable default arguments, missing type hints, hardcoded file paths
9. `/pr` → Pull request documenting methodology decisions with test plan
10. `/learn` → Captures "spatial CV required for spatially correlated data" as an instinct for future sessions

The difference isn't just quality — it's **reproducibility**. The template produces consistently high-quality output because the process is enforced, not optional. And critically, the planner agent caught the spatial cross-validation issue *before* code was written — saving the student from a methodological error that would have undermined the entire thesis.

### Quantitative Comparison

| Metric | Raw Claude Code | With Template |
|--------|----------------|---------------|
| Test coverage | 0% (tests not written) | 80%+ (TDD enforced) |
| CRS validation | None (silent errors) | Enforced by tests and code review |
| Commit quality | "added kriging" | `feat(variogram): Add spherical model with auto-fit` |
| Methodology review | None | Planner catches spatial CV issues before coding |
| Session continuity | None | Summaries, work log, instincts |
| Context efficiency | ~50K wasted on unused tools | <35K startup, 165K working |
| Specialization | 1 general model | 14 specialized agents |
| Documentation | Manual or forgotten | Auto-generated codemaps, session summaries |
| Learning | Starts fresh every session | Persistent instinct system, cross-session memory |
| Reproducibility | Hardcoded paths, no seeds | Verified by `/verify` pipeline |

---

## Value Proposition for Academic Projects

### For Students

**Scenario: A graduate student building their first spatial prediction model.**

Without the template, they face a blank directory and an AI that will generate whatever they ask for — including methodological mistakes they won't catch until their committee defense. They hardcode file paths to `/home/student/data/` because they don't know about configuration management. They write no tests because "it's just research code." They commit once a week with messages like "update." They discover their cross-validation was statistically invalid when a committee member asks why they used random k-fold on spatially autocorrelated data.

With the template:
- Their first `/commit` is rejected because the message doesn't follow conventional commit format. They learn the convention immediately — and their thesis advisor can later read the git log to understand the development timeline.
- Their first attempt to write a variogram fitting function triggers the TDD guide: "Write a failing test first." They learn to define expected behavior *before* implementation — a discipline that prevents silent numerical errors from propagating through the pipeline.
- Their first spatial operation is accompanied by proactive CRS checking (from learned instincts). They learn about coordinate reference systems before computing invalid distances.
- When they use `pickle` to serialize a trained model (a security risk), the Python reviewer catches it and suggests `joblib` or safetensors instead.

**The result isn't just a better pipeline — it's a better researcher.** The template's enforced workflows become muscle memory. Students who use it for a semester internalize TDD, version control discipline, reproducibility practices, and code review habits that distinguish reliable research from one-off scripts.

Beyond enforcement, the template provides **domain expertise on demand.** Need to configure a PostgreSQL spatial database? The `postgresql-patterns` skill knows about GiST indexing for geometry columns, PostGIS query optimization, and migration safety. Need Python testing patterns? The `python-testing` skill provides pytest fixtures, parametrization, and mocking strategies. The 39 skills act as an always-available senior engineer across every domain the student might encounter — without requiring the student to know the right questions to ask.

Critically, **quality scales with the project.** A thesis codebase that grows to 10,000+ lines maintains the same quality standards as the first 100 lines, because the template's enforcement doesn't fatigue. The TDD guide is just as strict on line 10,000 as on line 1. The security reviewer doesn't get tired of scanning. This is where AI-assisted development fundamentally differs from manual discipline — the template never has a bad day.

**Specific capabilities students gain:**

| Situation | What the Template Does | What the Student Learns |
|-----------|----------------------|----------------------|
| Starting a new analysis | `/plan` creates phased approach, waits for approval | Methodology design before coding, scope management |
| Writing any code | TDD enforces tests first | Defining expected behavior before implementation |
| Committing code | Rules require conventional format | Professional version control, traceable development |
| Completing a pipeline stage | `/verify` runs test + lint + type + security pipeline | Multi-stage quality gates for research code |
| Getting unexpected results | Five Whys debugging pattern (from reasoning rules) | Root cause analysis vs tweaking parameters until it "looks right" |
| Feeling stuck | Proactive steering detects uncertainty, offers structured help | Breaking problems down, asking for help productively |
| End of session | `/learn` extracts patterns, instincts persist | Reflection and knowledge management |

### For Research

**Scenario: A graduate student building a geostatistical ML pipeline comparing kriging methods against deep learning for mineral concentration prediction.**

Research code in geostatistics and ML is notoriously difficult to reproduce. Hardcoded file paths to local shapefiles, missing random seeds in neural network training, unversioned GDAL/rasterio dependencies (where minor version differences change output), and undocumented preprocessing steps (how was the DEM resampled? which CRS was used for distance calculations?) mean that even the author can't reproduce their own results six months later — let alone a reviewer or future student extending the work.

The template addresses this at the process level:

1. **Every methodological decision is recorded.** Conventional commits, work logs, and session summaries create an audit trail that documents not just *what* was built, but *why* each decision was made. When a committee member asks "why did you use ordinary kriging instead of universal kriging with a trend surface?", the answer is in the work log — captured during the session where the decision was made, complete with the trade-offs considered, not reconstructed from memory months later.

2. **Dependencies are tracked from day one.** The template's verification pipeline catches unversioned dependencies before they become a problem. `pip freeze > requirements.txt` — including the exact versions of `rasterio`, `geopandas`, `pykrige`, `scikit-learn`, and `torch` — isn't something the student has to remember. It's part of the workflow. This prevents the "it worked on my machine" problem that plagues spatial computing where GDAL version differences can change raster output.

3. **Multi-model perspectives reduce methodological bias.** If a student asks one AI model "what interpolation method should I use for sparse borehole data?", they get one opinion shaped by that model's training data. `/multi-plan` gives them three independent opinions — perhaps kriging, random forest with spatial features, and Gaussian process regression — surfaces the trade-offs between them, and forces the student to reason about *why* one method is appropriate for their data rather than accepting the first suggestion.

4. **The methodology section writes itself.** When every commit follows a convention (`feat(variogram): Add spherical model auto-fitting with weighted least squares`), every development phase is tracked in Task Master, and every session generates a summary, the student has a complete record of their analytical pipeline development. The template doesn't just produce better code — it produces documentable, defensible methodology that can be directly referenced in a thesis or publication.

5. **Collaboration becomes meaningful.** When two researchers in the same group both use the template, they follow the same development process — the same commit conventions, the same testing discipline, the same code review standards. This makes peer review between group members productive rather than superficial, because both parties understand the workflow. Instincts can be exported and imported (`/instinct-export`, `/instinct-import`), so when one group member discovers that `pykrige` requires a specific variogram binning strategy for sparse data, the entire group benefits in their next session. The template transforms a collection of individual researchers into a group with shared engineering practices and shared institutional knowledge.

### For the Department

**Scenario: A professor overseeing 30 capstone projects with 4-person teams.**

Without standardization, each team invents their own workflow. Some use git effectively; others email zip files. Some write tests; others don't. Some teams communicate well; others have one person doing all the work while others struggle in silence. The professor has no visibility into process quality until the final presentation.

The template changes this:

1. **Every team starts with the same foundation.** The template is cloned once and provides identical tooling, rules, and workflows to every team. This eliminates the "our team didn't know about X" excuse and establishes a baseline of professional practice.

2. **Process quality becomes measurable.** The professor can look at any team's git log and see:
   - Are commits frequent and well-described? (Enforced by commit rules)
   - Are features tested before they're committed? (Enforced by TDD)
   - Are security issues caught early? (Tracked by `/security-audit`)
   - Is the team following a structured workflow? (Tracked by Task Master)

   This is not surveillance — it's the same visibility that a tech lead has on a professional team. The template creates a paper trail that makes good process visible and bad process obvious.

3. **The AI becomes a force multiplier for faculty guidance.** A professor can't sit with every team during every coding session. But the template can. It catches the same mistakes the professor would catch — hardcoded credentials, untested code, broken commits — and addresses them in real time. The professor's limited time can then focus on higher-level guidance: architecture decisions, research direction, and career mentorship.

4. **The template itself is a teaching tool.** The rules and skills encode best practices that students absorb through use — not through lectures. The authority hierarchy (Rules > Instincts > Defaults) teaches software engineering governance: some constraints are non-negotiable (rules), some are learned suggestions (instincts), and some are baseline defaults. This mirrors real-world engineering organizations where certain practices are mandated by policy, others are team conventions, and others are individual preferences. Students who internalize this hierarchy understand governance — a concept that's difficult to teach abstractly but natural to learn through a system that enforces it.

5. **Grading becomes more meaningful.** Instead of evaluating only the final output (does the app work?), the professor can evaluate the process (was the app built well?). The template's audit trail — commits, task completion, code review findings, test coverage — provides evidence of engineering discipline that a working demo alone cannot show.

---

## Development Timeline

### Completed (v2.0.0 — v2.2.0)

The template's development followed a deliberate research-first methodology: study the best existing implementations, understand their design decisions, then build something that combines their strengths with our unique requirements.

#### Phase 1: ECC Integration (15 tasks, 75 subtasks)

**The catalyst:** After building an initial template with workflow enforcement rules, proactive steering, and Task Master integration, we discovered [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) — a 45K+ star repository that won Anthropic's hackathon for Claude Code configuration. Rather than compete with ECC, we studied it systematically and integrated its best patterns.

**What we learned from ECC and adopted:**
- **Token optimization** was a blind spot. Our original template loaded 10 MCP servers (134 tools, 50K+ startup tokens) — violating ECC's own 10/80 rule. We reduced to 2 MCPs (42 tools, 25K startup). This single change recovered ~25K tokens of working context.
- **Session persistence** was critical. Without it, every session started from zero. ECC's pattern of saving session summaries on exit and reloading them on start meant context survived across sessions without manual effort.
- **Context modes** (dev/review/research) let the same template behave differently based on the task. A review session loads read-only rules and emphasizes thoroughness; a dev session loads write-first rules and emphasizes speed.
- **Agent architecture** with model tiering (Opus for high-stakes reasoning, Sonnet for frequent operations, Haiku for documentation) matched cost to value instead of using the most expensive model for everything.

**What we kept from our original design:**
- **Proactive steering** — Claude detects the development phase and adjusts behavior automatically. ECC doesn't have this.
- **Task Master integration** — AI-powered task management with dependencies, status tracking, and expansion. ECC uses a different approach.
- **Superpowers TDD enforcement** — The template requires the Superpowers plugin, which will delete production code written without failing tests. This is stricter than ECC's advisory TDD.

#### Phase 2: Full Feature Parity (35 tasks, 175 subtasks)

**The goal:** Bring the template to feature parity with ECC's component inventory — 13 agents, comprehensive skill coverage, multi-language support — while maintaining our architectural advantages.

**Key implementation decisions:**
- **Language-specific rules use `paths:` frontmatter** so they load only when matching files are edited. A Python developer never pays the token cost for Go rules. This was our innovation — ECC loads all language rules at startup.
- **Skills are on-demand** (loaded when Claude detects relevance), not startup-loaded. This means 39 skills contribute exactly 0 tokens to startup overhead. ECC handles this similarly.
- **The instinct system uses confidence scoring** (0.0-1.0) with automatic decay. Unused patterns lose 0.05 confidence per week and are removed when they reach 0. This prevents knowledge rot — outdated patterns fade naturally instead of persisting forever.

**Delivery:** 50 tasks, 250 subtasks total across both phases. All implemented through Claude Code itself — the template was built using the template's own workflow enforcement, which served as both a development tool and a stress test.

#### Phase 2.1: Gap-Filling Release (v2.1.0)

**The honest reckoning:** After declaring "feature parity," we performed a quantitative audit against ECC's actual component inventory. The results were humbling:
- Raw coverage: ~62% (we had claimed ~82% "effective" coverage by counting functional equivalents)
- The gap: we had been generous in counting our components as "equivalent" without actually comparing implementations

**What we did about it:**
1. **Fetched ECC's actual source code** for every overlapping command and compared line-by-line
2. **Replaced 2 commands entirely** (`/eval`, `/update-codemaps`) where ECC's design philosophy was fundamentally superior — ECC's feature-level eval model (`pass@k` capability, `pass^k` regression) was architecturally better than our metrics-only approach
3. **Merged improvements into 3 commands** (`/orchestrate`, `/checkpoint`, `/update-docs`) taking the best from both implementations
4. **Kept 3 commands unchanged** (`/verify`, `/code-review`, `/skill-create`) where our implementations were genuinely stronger — our `/verify` is more polyglot and our `/code-review` has confidence filtering that ECC lacks
5. **Added 6 new skills** covering gaps in Docker, API design, deployment, database migrations, backend patterns, and iterative retrieval
6. **Added 12 agent-invoking commands** (`/plan`, `/tdd`, `/code-review`, `/e2e`, `/build-fix`, `/refactor-clean`, `/go-review`, `/python-review`, `/go-build`, `/go-test`, `/test-coverage`, `/learn`) — the biggest UX gap, as we had all 13 agents but no user-facing commands to invoke most of them

#### Phase 2.2: ECC Feature Parity Completion (v2.2.0)

This release completed ECC feature parity by adding the remaining domain skills, automation hooks, and documentation updates. All items were gap-analyzed against ECC's source code and implemented.

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
| **PR URL Extract** | Stop | Extracts PR creation URL from `git push` output and suggests review commands. | After pushing, the next natural step is creating a PR — this hook surfaces the URL automatically so the developer doesn't need to navigate to GitHub manually. |
| **Tmux Hint** | PreToolUse (Bash) | Advisory reminder to use tmux for long-running commands (npm, pytest, cargo, docker). | Long-running commands can capture the terminal. Inside tmux, you detach and reattach; outside, an interrupted terminal kills the process. |
| **Observe** | PreToolUse/PostToolUse | Captures tool usage patterns to `observations.jsonl` for the continuous learning system. | The engine that feeds the observer agent — records what tools are used, on what files, enabling automatic pattern detection across sessions. |

#### v3.0 Phase 1: Project-Type Presets (Completed)

The first step beyond ECC feature parity: **one-command project scaffolding.** Previously, adopting the template required manually selecting which skills and rules were relevant, creating directory structures, and editing CLAUDE.md. Presets automate all of this.

**What was built:**

| Component | Description |
|-----------|-------------|
| `.claude/presets/project-presets.json` | Registry of 5 project-type presets with tech stacks, directory structures, dev commands, patterns, and package lists |
| `scripts/setup-preset.sh` | Bash script with `--dry-run`, `--force`, and `--name` options. Uses `awk` for surgical CLAUDE.md section replacement. |
| `.claude/skills/python-data-science/SKILL.md` | New skill: NumPy, pandas, scikit-learn, matplotlib, Jupyter, spatial/geostatistics patterns |
| `.claude/commands/setup.md` | Extended with `/setup preset <name>` subcommand |
| `.claude/hooks/session-init.sh` | Displays active preset name in session startup output |

**Available presets:**

| Preset | Stack | Skills Activated |
|--------|-------|-----------------|
| `python-fastapi` | FastAPI + SQLAlchemy + PostgreSQL | python-patterns, api-design, database-patterns, postgresql-patterns |
| `node-nextjs` | Next.js 14+ + React + TypeScript + Prisma | typescript-patterns, frontend-patterns, e2e-testing |
| `go-api` | Go stdlib + PostgreSQL + sqlc | golang-patterns, golang-testing, api-design, postgresql-patterns |
| `java-spring` | Spring Boot 3.2+ + JPA + PostgreSQL + Flyway | java-springboot, spring-boot-security, spring-boot-tdd, jpa-patterns |
| `python-data-science` | pandas + scikit-learn + Jupyter + matplotlib | python-patterns, python-testing, database-patterns |

**What each preset does:**
1. Creates the full directory structure with `.gitkeep` files
2. Rewrites CLAUDE.md sections (Tech Stack, Structure, Development Commands, Patterns) using `awk`-based section replacement
3. Writes `.claude/project-state.json` with preset metadata and tech stack
4. Appends preset-specific entries to `.gitignore`
5. Includes safety checks: blocks overwriting already-customized CLAUDE.md without `--force`

**Usage:**
```bash
# Interactive: preview first, then apply
./scripts/setup-preset.sh python-fastapi --dry-run
./scripts/setup-preset.sh python-fastapi --name "My API Project"

# Via slash command
/setup preset python-fastapi
```

**Why this matters for adoption:** A student can now clone the template, run one command, and have a fully configured project with the right directory structure, dev commands, linting configuration, and skill activation for their stack. The 30-minute manual setup becomes a 30-second command.

#### v3.0 Phase 2: Template Overlay Infrastructure (Completed)

Real-world overlay testing on three projects (analog_image_generator, rideshare-rescue, postiz-social-automation) revealed a **critical architectural finding**: Claude Code's parent-directory traversal registers rules and CLAUDE.md from parent directories, but does NOT register commands, skills, or hooks. This meant all 49 slash commands and 39 skills were silently broken for any project that didn't have its own local `.claude/` directory.

**What was built to fix this:**

| Component | Description |
|-----------|-------------|
| `scripts/init-project.sh` | Bootstraps local `.claude/` structure. Auto-detects nested projects (creates symlinks) vs standalone projects (copies files). Handles 6 subdirs: rules, commands, skills, agents, contexts, hooks. Idempotent, supports `--dry-run`, `--force`, `--mode`. |
| `scripts/smoke-test.sh` | Validates template overlay deployments. 8 checks (rules, commands, skills, agents, contexts, hooks, CLAUDE.md, .gitignore) with CRITICAL/WARN distinction. Uses `find -L` to follow symlinks. |
| `.claude/rules/superpowers-integration.md` | Rule override fixing a workflow conflict: Superpowers brainstorming skill hard-routed to `writing-plans`, bypassing the template's PRD → Task Master pipeline. Rules take precedence per authority hierarchy, so this override is enforced. |
| `session-init.sh` enhancements | Detects missing local commands/skills at session start, shows CRITICAL warning with fix instructions. |
| `/setup` Step 0 | Setup wizard now initializes local `.claude/` structure before all other setup steps. |
| `sync-template.sh` enhancements | `adopt` mode now copies all `.claude/` subdirectories, not just curated file lists. |
| `docs/TEMPLATE_OVERLAY_FRICTION.md` | Friction log documenting all 3 overlay tests, findings, and fix status. |

**Key architectural insight:** The correct workflow for the template is: brainstorm → PRD → parse-prd → analyze-complexity → expand → TDD per task. The Superpowers plugin's brainstorming skill previously bypassed this by routing directly to its own `writing-plans` skill. The `superpowers-integration.md` rule corrects this at the authority hierarchy level.

See `docs/TEMPLATE_OVERLAY_FRICTION.md` for the complete overlay testing results and friction pattern tracker.

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

#### Phase 2: Team Collaboration Features

| Feature | Description | Value |
|---------|-------------|-------|
| **Shared instinct library** | Central repository of learned patterns that all team members' Claude instances can access. When one developer discovers a workaround, everyone benefits. | Eliminates redundant debugging across team members. A fix discovered on Monday is available to all teammates by Tuesday. |
| **Cross-project pattern extraction** | Analyze instincts across multiple projects to identify universal patterns vs project-specific ones. | Universal patterns become template-level skills. Project-specific patterns stay as project instincts. |
| **Team review aggregation** | Combine `/code-review` findings across team members to build a shared understanding of codebase quality. | Faculty can see aggregated quality metrics across all student projects without reviewing each one individually. |
| **Instinct conflict resolution** | When two developers' instincts contradict, surface the conflict and let the team decide which pattern wins. | Prevents "my Claude says X, your Claude says Y" disagreements by making learned patterns explicit and reviewable. |

#### Phase 3: CI/CD Integration

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

#### Phase 4: Metrics Dashboard

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

#### Phase 5: Academic Workflow Mode

Specialized rules and workflows for research-oriented development:

| Feature | What It Does |
|---------|-------------|
| **Experiment logging** | Automatically log hyperparameters, dataset versions, and results for ML experiments. Each run gets a timestamped entry in `experiments/`. |
| **Reproducibility checks** | `/verify` gains a reproducibility stage: checks for hardcoded paths, missing seed values, unversioned dependencies, and non-deterministic operations. |
| **Citation tracking** | When Claude references external libraries, papers, or techniques, it logs the citation. `/citations` generates a bibliography of all tools and references used. |
| **Notebook discipline** | Rules for Jupyter notebook hygiene: clear outputs before commit, no hardcoded credentials in cells, mandatory markdown headers explaining each section. |
| **Data pipeline validation** | Skills for validating data pipelines: schema checks, null handling, data drift detection, train/test leakage prevention. |
| **Thesis/paper integration** | `/update-docs` gains a mode for updating LaTeX or Markdown thesis chapters when the underlying code changes, keeping implementation descriptions in sync with actual code. |

#### Phase 6: Custom Agent Creation Framework

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
*Template version 2.2.0 | 14 agents, 39 skills, 49 commands, 13 rules, 18 hooks | 5 project-type presets*
