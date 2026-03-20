# Scripts and Infrastructure Audit Decisions

## Inventory

**Our scripts**: 10 files in `scripts/` (4,573 total lines)
**ECC scripts**: 17 top-level scripts + 8 CI validators + 9 JSON schemas + 51 shared lib files + 24 hook scripts + 51 test files
**Structural difference**: Our scripts are template-original (8/10 unique); ECC's are product infrastructure (install system, multi-platform, NanoClaw CLI)
**Audit date**: 2026-03-19

## Summary

| Verdict | Count | Description |
|---------|-------|-------------|
| Adopt   | 4     | CI validators (agents, skills, rules, commands) |
| Adapt   | 3     | hooks validator, personal-paths validator, hooks schema |
| Keep    | 0     | — |
| New     | 8     | Our unique scripts (no ECC equivalent) |
| Skip    | 22    | ECC install system (5), state store tools (3), Codex (2), platform (1), terminal UI (2), test runner (1), install-manifests validator (1), 7 schemas |
| Defer   | 7     | harness-audit.js, orchestrate-worktrees.js, release.sh, catalog.js concept, install-state provenance pattern, install-modules metadata, install-profiles pattern |

## Our Scripts (for reference)

| Script | Lines | Purpose | ECC Origin |
|--------|-------|---------|------------|
| check-upstream.sh | 258 | Check 5 upstream sources for changes | Unique |
| init-project.sh | 574 | Initialize project `.claude/` structure | Unique |
| instinct-cli.py | 737 | Continuous Learning v2 management | Adapted |
| manage-mcps.sh | 622 | MCP server management with 10/80 rule | Unique |
| manage-plugins.sh | 579 | Plugin installation from marketplace | Unique |
| multi-model-query.py | 166 | Query Gemini/OpenAI for multi-perspective | Unique |
| setup-preset.sh | 691 | Project-type preset scaffolding | Unique |
| smoke-test.sh | 241 | Template overlay verification | Unique |
| start-observer.sh | 182 | Background observer daemon for CLv2 | Adapted (11 fixes) |
| sync-template.sh | 523 | Sync template files into projects | Unique |

---

## Part 1: ECC CI Validators (8 scripts)

ECC runs 8 validation scripts as part of `npm test`. They enforce structural integrity of Claude Code artifacts (agents, commands, skills, rules, hooks) before merge. We have no equivalent — our `smoke-test.sh` checks file presence but not content validity.

### Comparison Matrix

| ECC Validator | Lines | Portable? | Verdict | Reasoning |
|--------------|-------|-----------|---------|-----------|
| validate-agents.js | 81 | Yes | Adopt | Change `AGENTS_DIR` path only |
| validate-skills.js | 54 | Yes | Adopt | Change `SKILLS_DIR` path only |
| validate-rules.js | 81 | Yes | Adopt | Change `RULES_DIR` path only |
| validate-commands.js | 135 | Yes | Adopt | Change 3 dir paths; cross-ref logic is universally useful |
| validate-hooks.js | 239 | Partial | Adapt | We use `settings.json` not `hooks.json`; event list and type checks are useful |
| validate-install-manifests.js | 211 | No | Skip | Validates ECC's install system we don't have |
| validate-no-personal-paths.js | 63 | Concept | Adapt | Username patterns need parameterization |
| catalog.js | 245 | No | Defer | Concept valuable (doc count drift detection) but regex patterns are ECC-specific |

---

### validate-agents.js (81 lines) — ADOPT

**ECC implementation**: Reads all `.md` files in `agents/` directory. Validates YAML frontmatter exists (delimited by `---`), checks two required fields (`model` and `tools` — both must be non-empty after trimming), validates model value is one of `haiku`, `sonnet`, `opus`. Handles BOM (`\uFEFF`) and CRLF line endings. Uses `indexOf(':')` instead of `split(':')` to handle colons in values.

**Our equivalent**: None. `smoke-test.sh` checks that agent files exist but does not validate frontmatter content. Invalid model names or missing `tools` field would not be caught until runtime.

**Assessment**:
- Architecture: ECC — validates content, not just presence
- Features: ECC — frontmatter field validation, model whitelist, encoding-robust parsing
- Error handling: ECC — clear error messages with filename context
- Performance: Minimal concern (reads file headers only)
- Cross-platform: ECC — Node.js

**Verdict**: **Adopt**
**Reasoning**: The validator is 81 lines of generic, well-tested code that directly applies to our `.claude/agents/` directory. The valid model list (`haiku`, `sonnet`, `opus`) matches our conventions exactly. Only the directory path constant needs changing.
**Action**: Copy `validate-agents.js` to `scripts/ci/`, change `AGENTS_DIR` from `../../agents` to `../../.claude/agents`. Add to CI pipeline.

---

### validate-skills.js (54 lines) — ADOPT

**ECC implementation**: Reads every subdirectory in `skills/`, checks that each contains a `SKILL.md` file, and verifies `SKILL.md` is not empty after trimming whitespace. Non-directory entries in `skills/` are silently ignored. Gracefully exits if the skills directory does not exist.

**Our equivalent**: `smoke-test.sh` checks for 3 hardcoded expected skills by name. Does not enumerate all skills or validate content.

**Assessment**:
- Architecture: ECC — dynamic enumeration vs our hardcoded spot-checks
- Features: ECC — catches empty SKILL.md files and missing SKILL.md in skill directories
- Error handling: ECC — specific error messages per skill directory
- Performance: Minimal concern (directory listing + file existence checks)
- Cross-platform: ECC — Node.js

**Verdict**: **Adopt**
**Reasoning**: At 54 lines, this is the simplest validator — pure structural check. Our template currently has 40+ skills from plugins that are only verified by name, not by content. Empty or missing SKILL.md files would cause silent skill invocation failures.
**Action**: Copy to `scripts/ci/`, change `SKILLS_DIR` path. Add to CI pipeline.

---

### validate-rules.js (81 lines) — ADOPT

**ECC implementation**: Recursively collects all `.md` files in `rules/` (including subdirectories), verifies each is non-empty after trimming whitespace. Non-markdown files are silently ignored. Handles broken symlinks (caught by try/catch on `readFileSync`). Uses `readdirSync` with `recursive: true` for flat collection.

**Our equivalent**: None. `smoke-test.sh` checks for the `rules/` directory existence and counts files, but does not validate individual rule content.

**Assessment**:
- Architecture: ECC — recursive enumeration handles our `rules/python/`, `rules/typescript/` subdirectory structure
- Features: ECC — catches empty rules that would waste context tokens on load
- Error handling: ECC — broken symlink detection (relevant since `init-project.sh` creates symlinks)
- Performance: Minimal
- Cross-platform: ECC — Node.js

**Verdict**: **Adopt**
**Reasoning**: Directly portable. The recursive collection handles our subdirectory structure (language-specific rules live in `rules/python/`, `rules/golang/`, etc.). Empty rules waste startup context tokens — catching them in CI is valuable.
**Action**: Copy to `scripts/ci/`, change `RULES_DIR` path. Consider adding frontmatter validation (our rules use `paths:` frontmatter for language targeting).

---

### validate-commands.js (135 lines) — ADOPT

**ECC implementation**: Validates every `.md` file in `commands/` is non-empty, then performs cross-reference integrity checking. After stripping fenced code blocks, scans for three types of references:
1. **Command references** (`` `/command-name` ``): verifies target `.md` file exists in `commands/`
2. **Agent path references** (`agents/name.md`): verifies target exists in `agents/`
3. **Skill directory references** (`skills/name/`): warns (does not fail) if missing
4. **Workflow diagrams** (`agent-a -> agent-b -> agent-c`): verifies every agent name exists

Skips references on lines containing `creates:` or `would create:` (generator commands). Uses `matchAll` for multi-ref-per-line handling.

**Our equivalent**: None. Our 48 commands are not validated for cross-reference integrity. Broken links between commands, agents, and skills are only discovered at runtime.

**Assessment**:
- Architecture: ECC — cross-reference validation is the standout feature; catches link rot between artifacts
- Features: ECC — four reference types, code block stripping, generator-line skipping, multi-ref handling
- Error handling: ECC — per-reference error messages with source filename and target name
- Performance: Light (reads all .md files once, string matching)
- Cross-platform: ECC — Node.js

**Verdict**: **Adopt**
**Reasoning**: Our template has 48 commands that reference agents and skills. The cross-reference validator catches broken links — a real class of bugs. With the `feedback_audit_rigor` rewrite, several commands were touched; this validator would catch any inadvertent link breakage. The code block stripping prevents false positives from example snippets.
**Action**: Copy to `scripts/ci/`, change 3 directory constants to `.claude/` prefix paths. This is the highest-value single adoption in the CI validator set.

---

### validate-hooks.js (239 lines) — ADAPT

**ECC implementation**: Validates a centralized `hooks/hooks.json` file that defines all hook configurations. Checks: valid JSON parsing, JSON schema validation against `hooks.schema.json`, all top-level keys are valid Claude Code event types (18 known events), matcher structure validation, per-hook-entry validation (type must be `command`/`http`/`prompt`/`agent`, type-specific field validation), inline JavaScript syntax checking via `vm.Script`. Supports both object and legacy array formats.

**Our equivalent**: None. Our hooks are configured in `.claude/settings.json` under the `hooks` key, not a standalone `hooks.json`. There is no validation of hook configuration beyond the runtime behavior.

**Assessment**:
- Architecture: Different — ECC uses centralized `hooks.json`, we embed in `settings.json`
- Features: ECC — event type whitelist (18 events), handler type validation, inline JS syntax check
- Error handling: ECC — precise location labels (`PreToolUse[0].hooks[1]`)
- Performance: Light
- Cross-platform: ECC — Node.js

**Verdict**: **Adapt**
**Reasoning**: The core validation logic (event type whitelist, handler type checking, command string validation) is universally applicable. However, the input format differs: ECC reads `hooks.json`, we read `.claude/settings.json` and extract the `hooks` key. The adaptation extracts the hooks section from our settings.json, then runs the same validation pipeline. The 18-event whitelist is also valuable as an authoritative reference.
**Action**: Fork `validate-hooks.js`, change input to read `.claude/settings.json` → parse `hooks` key. Keep all event type and handler validation logic. Add path existence checks for `command` hook scripts (we reference script paths in our commands).

---

### validate-install-manifests.js (211 lines) — SKIP

**ECC implementation**: Validates ECC's three-tier install system manifests (modules → components → profiles). Checks JSON schema conformance, referential integrity (module dependencies, profile-to-module links, component-to-module links), file path existence, duplicate detection, and required profile names.

**Our equivalent**: None — we don't have a modular install system.

**Assessment**: ECC-specific. Validates an architecture we don't replicate. The referential integrity pattern (cross-checking IDs across multiple JSON files) is good engineering but the specific entity types are irrelevant.

**Verdict**: **Skip**
**Reasoning**: We don't have install modules, components, or profiles. The three-tier manifest system is ECC's install infrastructure, not a Claude Code pattern.

---

### validate-no-personal-paths.js (63 lines) — ADAPT

**ECC implementation**: Recursively scans `skills/`, `commands/`, `agents/`, `docs/`, `README.md` for hardcoded personal paths (`/Users/<ecc-author>`, `C:\Users\<ecc-author>`). Skips `node_modules/` and `.git/`. Checks `.md`, `.json`, `.js`, `.ts`, `.sh`, `.toml`, `.yml`, `.yaml` file types.

**Our equivalent**: None. Personal paths in our template would be caught by code review but not by automated tooling.

**Assessment**:
- Architecture: ECC — automated hygiene check; concept is universally valuable
- Features: ECC — multi-directory scanning, multiple file types, Unix + Windows path patterns
- Error handling: ECC — per-file error with path context
- The blocked username is hardcoded to ECC's author

**Verdict**: **Adapt**
**Reasoning**: The concept is valuable — catching hardcoded personal paths before they ship to users. The adaptation needs: (1) parameterize blocked username (detect from `git config user.name` or environment), (2) update target directories to `.claude/` prefix, (3) add common template-specific patterns (e.g., `/home/<username>` shouldn't appear in shipped files).
**Action**: Fork, add username auto-detection, update directory targets. Low priority — run occasionally rather than on every CI.

---

### catalog.js (245 lines) — DEFER

**ECC implementation**: Counts actual agents, commands, and skills, then cross-checks against documented counts in README.md and AGENTS.md using regex pattern matching. Detects "documentation count drift" — when code changes add/remove artifacts but docs aren't updated. Supports `--json`, `--md`, `--text` output modes and "minimum" matching (e.g., "100+ skills").

**Our equivalent**: `smoke-test.sh` counts files but doesn't compare against documentation. CLAUDE.md says "14 agents" and "39 skills" — these could drift.

**Assessment**: The concept is valuable but the implementation is ECC-specific (regex patterns match ECC's README.md and AGENTS.md formatting). Writing our own version that checks CLAUDE.md count claims would be ~50 lines. Not worth adopting ECC's code — better to write fresh when we formalize this check.

**Verdict**: **Defer**
**Reasoning**: Good concept, wrong implementation. Defer to v2.5.0 when we have a CI pipeline to run it in. Add a simple count-checker that validates CLAUDE.md's agent/skill/command/hook counts.

---

## Part 2: ECC JSON Schemas (9 schemas)

ECC uses JSON Schema validation (via Ajv) to enforce structural contracts on configuration files. We have no formal schema validation — our configs are validated implicitly by the code that reads them.

### Comparison Matrix

| ECC Schema | Lines | Generalizable? | Verdict | Reasoning |
|-----------|-------|----------------|---------|-----------|
| hooks.schema.json | ~130 | High | Adapt | Authoritative 18-event list; validate our settings.json hooks |
| plugin.schema.json | ~55 | High | Defer | Useful for plugin manifest validation; low priority |
| install-modules.schema.json | ~75 | Medium | Defer | Best metadata pattern (cost/stability/kind); inspire our module system |
| install-profiles.schema.json | ~35 | Medium | Defer | Maps to our settings presets; formalize later |
| install-state.schema.json | ~120 | Medium | Defer | Provenance tracking pattern for upstream manifest |
| state-store.schema.json | ~220 | Low | Skip | ECC's internal SQLite-backed operational DB |
| ecc-install-config.schema.json | ~50 | Low | Skip | ECC's multi-target install config |
| install-components.schema.json | ~40 | Low | Skip | ECC's component grouping layer |
| package-manager.schema.json | ~15 | Low | Skip | JS package manager preference; trivial |

---

### hooks.schema.json (~130 lines) — ADAPT

**ECC implementation**: JSON Schema that validates Claude Code hook configuration. Defines the authoritative list of 18 hook events: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `Notification`, `SubagentStart`, `Stop`, `SubagentStop`, `PreCompact`, `InstructionsLoaded`, `TeammateIdle`, `TaskCompleted`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`, `SessionEnd`. Defines three handler types (`command`, `http`, `prompt`/`agent`). Command hooks support `async` boolean and `timeout`. HTTP hooks support custom `headers` and `allowedEnvVars`. Prompt/agent hooks support `model` selection.

**Our equivalent**: No schema. Our `settings.json` hook structure is validated implicitly by Claude Code's runtime. We currently use 5 of 18 events (SessionStart, PreToolUse, PostToolUse, UserPromptSubmit, Stop) and only the `command` handler type.

**Assessment**:
- The schema reveals 13 hook events we don't use, including potentially valuable ones: `PreCompact`, `SubagentStart/Stop`, `TaskCompleted`, `ConfigChange`, `SessionEnd`
- The `prompt` and `agent` handler types are first-class alternatives to our `command` type — prompt handlers use Haiku for LLM-evaluated decisions, agent handlers spawn full subagents
- The `async` and `timeout` fields on command hooks could improve our hook performance
- Two valid top-level shapes: object with `hooks` key or bare array of matcher entries

**Verdict**: **Adapt**
**Reasoning**: The schema itself can't validate our `settings.json` directly (different structure), but the event list and handler type definitions are the authoritative reference for Claude Code's hook system. Adapt into a validation function that extracts `hooks` from our settings.json and validates against the schema's constraints. Also use the 18-event list to inform which events we should consider adopting.
**Action**: Extract event list and handler type constraints into our `validate-hooks.js` adaptation. Document the 13 unused events with assessment of which to adopt in v2.5.0.

---

### plugin.schema.json (~55 lines) — DEFER

**ECC implementation**: Validates plugin manifest files (`plugin.json`). Required field: `name` only. Optional: `version` (strict semver), `description`, `author` (string or `{name, url}`), `homepage`, `repository`, `license`, `keywords`, `skills`, `agents`. A `features` object provides capability metadata: agent/command/skill counts, `configAssets` boolean, `hookEvents` and `customTools` arrays. Strict `additionalProperties: false`.

**Our equivalent**: `manage-plugins.sh` reads `registry.json` for plugin metadata but doesn't validate individual plugin manifests against a schema.

**Assessment**: Useful for validating plugins downloaded from the wshobson/agents marketplace. The `features` object with counts could feed into our token budget estimation. Low urgency — plugins are a secondary feature.

**Verdict**: **Defer**
**Reasoning**: Good pattern, low priority. Defer until our plugin system matures or we encounter malformed plugin manifests in the wild.

---

### install-modules.schema.json (~75 lines) — DEFER

**ECC implementation**: Defines atomic installable modules with 10 required fields: `id`, `kind` (7 types: rules/agents/commands/hooks/platform/orchestration/skills), `description`, `paths`, `targets`, `dependencies`, `defaultInstall`, `cost` (light/medium/heavy), `stability` (experimental/beta/stable). All fields required — fully specified manifests.

**Our equivalent**: No module manifest system. Our `manage-plugins.sh` uses a simpler `registry.json` with category-based organization.

**Assessment**: The `cost` (light/medium/heavy) and `stability` (experimental/beta/stable) fields are the most transferable concepts. They directly map to our token budget awareness and plugin maturity concerns. The `kind` taxonomy (7 types) aligns with our artifact types. The `dependencies` array enables dependency resolution.

**Verdict**: **Defer**
**Reasoning**: Best metadata pattern in ECC's schema set. When we formalize our plugin/module system, adapt this schema's `cost`, `stability`, and `dependencies` fields. The full 10-field manifest is over-engineered for our current needs.

---

### install-profiles.schema.json (~35 lines) — DEFER

**ECC implementation**: Named installation profiles — curated sets of modules. Each profile has a `description` and `modules` array. Profile names must be kebab-case. At least one profile required.

**Our equivalent**: `setup-preset.sh` has project-type presets hardcoded in the script. `/settings` has hook profile presets (fast, optimized, safe, thorough) also hardcoded.

**Assessment**: This schema externalizes what we hardcode. Data-driven presets would be more maintainable, but our current hardcoded approach works and is easier to understand.

**Verdict**: **Defer**
**Reasoning**: Valid pattern, but our presets work well as hardcoded scripts. Revisit if preset count exceeds ~10 or if users request custom presets.

---

### install-state.schema.json (~120 lines) — DEFER

**ECC implementation**: Records what was installed, when, and from where. Key sections: `target` (id, root, kind: "home"|"project"), `source` (repoVersion, repoCommit, manifestVersion — full provenance chain), `operations` (per-file records with `kind`, `moduleId`, `sourceRelativePath`, `destinationPath`, `strategy`, `ownership`, `scaffoldOnly`). The `ownership` field tracks whether ECC or the user "owns" each file. The `scaffoldOnly` boolean distinguishes one-time scaffolding from managed files.

**Our equivalent**: `.template/source` and `.template/version` store basic provenance. `upstream-manifest.json` is planned (see `project_upstream_provenance.md` memory) but not yet implemented.

**Assessment**: The `source` provenance tracking (repoVersion, repoCommit, manifestVersion) directly addresses our upstream manifest goal. The `ownership` and `scaffoldOnly` fields solve the real problem of knowing which files the template manages vs which are user-customized — critical for `sync-template.sh` to avoid overwriting user changes.

**Verdict**: **Defer**
**Reasoning**: Highest conceptual value in the schema set for our upstream tracking goals. The entity patterns (especially provenance chain and file ownership) should inform our upstream manifest design. Not adopting the full schema now because our manifest system is still being designed (Task 13).

---

### state-store.schema.json (~220 lines) — SKIP

**ECC implementation**: Defines 6 entity types for ECC's operational database (backed by SQLite via `sql.js`): sessions, skill runs, skill versions, decisions, install state, governance events. Notable features: `skillRun` tracks tokens used and duration per skill invocation; `skillVersion` tracks content hashes with promotion/rollback timestamps; `decision` records ADRs with supersession chains.

**Our equivalent**: None — we use flat files (`.claude/instincts/`, `.claude/sessions/`) not a database.

**Assessment**: ECC-specific. The entity concepts are interesting (especially skill analytics and ADR tracking) but the schema is tightly coupled to ECC's SQLite architecture. Individual patterns could inspire our instinct tracking, but the full schema is irrelevant.

**Verdict**: **Skip**
**Reasoning**: We use flat file storage by design (zero dependencies, `grep`-able, version-controllable). The SQLite approach has advantages for querying but conflicts with our portability goals.

---

### ecc-install-config.schema.json (~50 lines) — SKIP

**ECC implementation**: User-facing install configuration. Notable: `target` enum supports 5 AI coding tools (claude, cursor, antigravity, codex, opencode). Four component families: `baseline`, `lang`, `framework`, `capability`. Include/exclude mechanism for selective installation.

**Our equivalent**: `init-project.sh` with mode flags and `setup-preset.sh` with project-type presets.

**Assessment**: The multi-target concept (supporting multiple AI tools from one config) is interesting but beyond our current scope. The component family taxonomy is a good categorization pattern but we have simpler needs.

**Verdict**: **Skip**
**Reasoning**: ECC-specific multi-platform infrastructure. We target Claude Code exclusively.

---

### install-components.schema.json (~40 lines) — SKIP

**ECC implementation**: Middle tier of the three-tier install system (profiles → components → modules). Components group related modules by family.

**Assessment**: Over-engineered for our needs. Our simpler two-tier approach (presets → files) is sufficient.

**Verdict**: **Skip**

---

### package-manager.schema.json (~15 lines) — SKIP

**ECC implementation**: Trivial schema for npm/pnpm/yarn/bun selection.

**Assessment**: JS-specific. We're Python-focused.

**Verdict**: **Skip**

---

## Part 3: ECC Infrastructure Scripts (17 top-level + 2 Codex + 1 test runner)

ECC has 17 top-level scripts, 2 Codex integration scripts, and a test runner. Most are tightly coupled to ECC's install system (install-state lifecycle, SQLite state store, multi-target support). Three stand out as adoption candidates.

### Comparison Matrix

| ECC Script | Lines | Category | Verdict | Reasoning |
|-----------|-------|----------|---------|-----------|
| harness-audit.js | 291 | Quality scoring | **Defer** | Weighted scoring engine — best pattern, defer to v2.5.0 Task 11 |
| orchestrate-worktrees.js | 98 | Git worktrees | **Defer** | Parallel agent orchestration — compelling concept, needs investigation |
| release.sh | 76 | Release | **Defer** | Version bump + tag + push automation |
| doctor.js | 88 | Health/diagnostics | Skip | Requires install-state tracking we don't have |
| status.js | 148 | Dashboard | Skip | Requires SQLite state store |
| ecc.js | 128 | CLI entry point | Skip | CLI router, unnecessary with 10 scripts |
| sessions-cli.js | 170 | Session tools | Skip | Requires SQLite state store |
| session-inspect.js | 140 | Session tools | Skip | Skill self-improvement loop, heavy infrastructure |
| skills-health.js | 106 | Skills diagnostics | Skip | Requires skill-run tracking we don't have |
| repair.js | 87 | Recovery | Skip | Covered by init-project.sh --force + sync-template.sh --force |
| list-installed.js | 85 | Install system | Skip | Covered by sync-template.sh status |
| install-plan.js | 216 | Install system | Skip | Modular install system, overkill for us |
| install-apply.js | 149 | Install system | Skip | Multi-target install, not needed |
| uninstall.js | 88 | Install system | Skip | No clean uninstall path needed |
| setup-package-manager.js | 172 | JS setup | Skip | JS-specific, we're Python-focused |
| skill-create-output.js | 216 | Terminal UI | Skip | Rich ANSI output, low priority |
| orchestration-status.js | 49 | Orchestration | Skip | dmux-specific thin wrapper |
| check-codex-global-state.sh | 178 | Codex validation | Skip | Codex-specific, pattern reusable |
| install-global-git-hooks.sh | 57 | Git hooks | Skip | Global hooks conflict with project-scoped approach |
| tests/run-all.js | 106 | Test runner | Skip | We use pytest, not a custom runner |

---

### harness-audit.js (291 lines) — DEFER

**ECC implementation**: Deterministic scoring engine for evaluating ECC installation quality. Runs 26 checks across 7 categories (Tool Coverage, Context Efficiency, Quality Gates, Memory Persistence, Eval Coverage, Security Guardrails, Cost Efficiency). Each check is worth 2-4 points, producing a normalized 0-10 score per category. Supports scoping (repo, hooks, skills, commands, agents) and JSON output. Top-3 actionable fix suggestions sorted by impact. Zero LLM calls — pure filesystem checks.

**Our equivalent**: `smoke-test.sh` (241 lines) does pass/fail checks for 8 categories. Binary outcomes, no weighted scoring, no actionable suggestions sorted by impact, no JSON output.

**Assessment**:
- Architecture: ECC — weighted scoring is fundamentally superior to binary pass/fail for quality assessment
- Features: ECC — 7 categories vs our 8, but each ECC check has weight and impact scoring
- Error handling: Both adequate
- Performance: Both fast (filesystem checks only)
- Cross-platform: ECC — Node.js; ours — bash

**Verdict**: **Defer**
**Reasoning**: This is the most template-generalizable infrastructure script in ECC. A weighted scoring engine would transform our `/health` command from "check if files exist" to "measure template installation quality on a 0-10 scale with actionable improvement suggestions." The adaptation would replace ECC's 26 checks with template-specific ones (e.g., 14+ agent files, hooks wired in settings.json, CLAUDE.md customized, Task Master configured). Defer to v2.5.0 Task 11 which already covers this.
**Action**: Reference this analysis when implementing v2.5.0 Task 11. The scoring framework pattern (categories, weighted checks, normalized scores, sorted suggestions) is the valuable part, not the specific checks.

---

### orchestrate-worktrees.js (98 lines) — DEFER

**ECC implementation**: Orchestrates parallel Claude Code sessions across git worktrees using tmux. Takes a `plan.json` defining workers (each with branch, worktree path, task file, handoff file, launcher command). Creates worktrees, sets up coordination directories, launches tmux sessions with one pane per worker. Backed by `tmux-worktree-orchestrator.js` library (~200 lines).

**Our equivalent**: None. Superpowers' `using-git-worktrees` skill creates individual worktrees but doesn't orchestrate parallel agent sessions across them. Our `dispatching-parallel-agents` pattern uses Agent tool subagents (shared repo), not isolated worktrees.

**Assessment**:
- Architecture: ECC — true parallel isolation (each agent gets its own worktree + tmux pane)
- Features: ECC — plan-driven orchestration, coordination directories, structured handoff files
- Performance: ECC — real parallelism across worktrees vs our sequential-in-shared-repo
- Cross-platform: ECC — requires tmux (Linux/macOS only)

**Verdict**: **Defer**
**Reasoning**: Compelling concept — running multiple Claude agents in parallel on different worktrees would accelerate multi-task execution. However, the implementation depends on tmux and ECC's orchestration layer. The template already has Superpowers' `dispatching-parallel-agents` for simple cases and `subagent-driven-development` for reviewed implementation. Parallel worktree orchestration would be a v2.6.0+ feature.
**Action**: Document as a future enhancement. The `tmux-worktree-orchestrator.js` library is the valuable component, not this thin CLI wrapper.

---

### release.sh (76 lines) — DEFER

**ECC implementation**: Bumps version across multiple manifest files (package.json, plugin.json, marketplace.json), commits with version message, creates annotated git tag, pushes to remote. Validates semver format, enforces main branch, checks clean working tree. Uses `sed -i` for in-place version replacement.

**Our equivalent**: None. Version bumps and tagging are done manually or via the `/changelog` command. `.template/version` is updated by `sync-template.sh` but there's no release automation.

**Assessment**:
- Architecture: ECC — automated multi-file version bump + tag
- Features: ECC — semver validation, branch enforcement, clean tree check
- Our gap: No release script, manual process

**Verdict**: **Defer**
**Reasoning**: A release script that bumps `.template/version`, updates CLAUDE.md version references, commits, tags, and pushes would be useful for template releases. Low urgency — we release infrequently. Defer to v2.5.0 or later.

---

### doctor.js (88 lines), repair.js (87 lines) — SKIP

**ECC implementation**: `doctor.js` diagnoses drift by comparing install-state records against disk. `repair.js` restores drifted files. Together they form a detect-and-fix pair.

**Our equivalent**: `smoke-test.sh` (detect) + `init-project.sh --force` / `sync-template.sh --force` (fix). Less precise (re-apply everything vs just drifted files) but works without install-state tracking.

**Verdict**: **Skip** — requires install-state lifecycle we don't have. Our detect+fix pair is adequate.

---

### status.js (148 lines), sessions-cli.js (170 lines), session-inspect.js (140 lines) — SKIP

**ECC implementation**: Dashboard tools backed by SQLite state store (`sql.js`). Track sessions, skill runs (with token/duration metrics), install health, governance events, and skill self-improvement (amendify — proposing SKILL.md patches from failure evidence).

**Our equivalent**: Session hooks (flat markdown files), statusline.sh (runtime display), observer daemon (instinct creation).

**Verdict**: **Skip** — all three require ECC's SQLite state store. Our flat-file approach is simpler and sufficient. The skill self-improvement concept (amendify) is innovative but requires significant infrastructure to implement.

---

### skills-health.js (106 lines) — SKIP

**ECC implementation**: Skill success/failure tracking with confidence dashboards. Shows amendment history and patterns.

**Our equivalent**: `instinct-cli.py status` shows instinct confidence scores, but we don't track skill invocation success/failure rates.

**Verdict**: **Skip** — requires skill-run tracking infrastructure we don't have. The concept of tracking skill success rates is worth noting for future CLv3 enhancements.

---

### ecc.js (128 lines) — SKIP

**ECC implementation**: Unified CLI entry point routing subcommands (install, doctor, repair, status, sessions, etc.) to scripts via `spawnSync`.

**Verdict**: **Skip** — with 10 scripts invoked directly, a unified CLI router adds complexity without clear benefit.

---

### Install system scripts (install-plan.js, install-apply.js, uninstall.js, list-installed.js, setup-package-manager.js) — SKIP

**ECC implementation**: Five scripts forming ECC's selective-install system with profile/module/component manifests, multi-target support (5 AI tools), and install-state tracking.

**Our equivalent**: `init-project.sh` (symlink/copy), `sync-template.sh` (selective sync), `manage-plugins.sh` (plugin installation).

**Verdict**: **Skip** — ECC's install system is product infrastructure for a multi-platform distribution. Our template's simpler install model (symlink or copy) is appropriate for our single-target use case.

---

### skill-create-output.js (216 lines), orchestration-status.js (49 lines) — SKIP

**ECC implementation**: `skill-create-output.js` is a rich terminal formatter with ANSI animations and box-drawing (zero dependencies). `orchestration-status.js` is a thin wrapper around dmux session inspection.

**Verdict**: **Skip** — nice-to-have terminal aesthetics, not functional gaps.

---

### Codex scripts and test runner — SKIP

**check-codex-global-state.sh** (178 lines): Codex integration validation. The ok/warn/fail helper pattern is cleaner than our smoke-test.sh in places — worth noting for future smoke-test improvements.

**install-global-git-hooks.sh** (57 lines): Global git hooks via `core.hooksPath`. Conflicts with our project-scoped approach.

**tests/run-all.js** (106 lines): Custom test runner discovering `*.test.js` files. We use pytest — no need for a Node.js runner.

## Part 4: Our Unique Scripts (8 scripts — no ECC equivalent)

These scripts fill gaps that ECC doesn't address because ECC is used directly, not as a template that deploys into other projects.

---

### check-upstream.sh (258 lines) — NEW

**Purpose**: Checks 5 upstream sources (Superpowers, ECC, Anthropic plugins, Task Master npm, wshobson/agents) for changes since a configurable date. Compares installed versions against latest releases, counts recent commits. `--verbose` mode shows individual commit messages.

**ECC equivalent**: None. ECC does not track its own upstream sources because it IS the upstream.

**Why we need it**: Our template is a downstream consumer of ECC, Superpowers, and Task Master. Knowing when upstreams change is critical for keeping the template current. This script is the foundation for the sync workflow defined in Task 14 (check-upstream.sh enhancement).

**Verdict**: **New** — unique to template's downstream consumer role.

---

### init-project.sh (574 lines) — NEW

**Purpose**: Initializes a new project's `.claude/` directory structure. Auto-detects parent template (walks up to 5 levels), supports symlink and copy modes, creates skeleton `tasks.json`, copies tuned config with name substitution, verifies symlink security.

**ECC equivalent**: None. ECC has `install-plan.js` + `install-apply.js` but those install ECC itself — they don't scaffold new projects from a template.

**Why we need it**: This is the template's primary value delivery mechanism. Without it, users must manually create `.claude/` structure.

**Verdict**: **New** — core template scaffolding, no equivalent concept in ECC.

---

### instinct-cli.py (737 lines) — NEW (adapted)

**Purpose**: CLI for Continuous Learning v2 system with 4 subcommands: `status`, `import`, `export`, `evolve`. Manages project-scoped and global instincts with cross-project sharing.

**ECC equivalent**: Loosely adapted from ECC's continuous learning system, but the template version is project-scoped (vs ECC's global `~/.claude/homunculus/`), adds the `evolve` command for instinct-to-skill promotion, and adds import/export with a global store.

**Why we need it**: The continuous learning system is a template differentiator. Project-scoped instincts enable per-project pattern learning without cross-contamination.

**Verdict**: **New** (adapted) — substantially modified from ECC concept, now template-specific.

---

### manage-mcps.sh (622 lines) — NEW

**Purpose**: Manage MCP servers with registry-based operations, 10/80 rule enforcement, project-type presets, interactive wizard, and token budget auditing.

**ECC equivalent**: None. ECC documents MCP setup in guides but doesn't automate management.

**Verdict**: **New** — template original.

---

### manage-plugins.sh (579 lines) — NEW

**Purpose**: Install/remove plugins from wshobson/agents marketplace. GitHub Contents API enumeration, installation tracking, project-type presets.

**ECC equivalent**: None. ECC has its own install system but doesn't interface with third-party plugin marketplaces.

**Verdict**: **New** — template original.

---

### multi-model-query.py (166 lines) — NEW

**Purpose**: Query Gemini and OpenAI APIs for multi-perspective planning. Zero dependencies (stdlib only). Graceful degradation when API keys are missing.

**ECC equivalent**: ECC's `codeagent-wrapper` is their multi-model routing layer, but it's a much larger system integrated into their orchestration. Ours is a lightweight standalone utility.

**Verdict**: **New** — independent implementation, different architecture.

---

### setup-preset.sh (691 lines) — NEW

**Purpose**: Apply project-type presets that scaffold directories, rewrite CLAUDE.md sections, generate starter test files, update `.gitignore`, and write project state. 5 presets: python-fastapi, node-nextjs, go-api, java-spring, python-data-science.

**ECC equivalent**: None. ECC doesn't scaffold project types.

**Verdict**: **New** — template original.

---

### smoke-test.sh (241 lines) — NEW

**Purpose**: Verify template overlay integrity. 8 check categories (rules, commands, skills, agents, contexts, hooks, CLAUDE.md, .gitignore). Distinguishes between must-be-local (commands, skills) and inheritable (rules, agents) artifacts.

**ECC equivalent**: None. ECC doesn't have a template overlay verification tool. Their CI validators (Part 1) serve a related but different purpose — they validate content integrity, ours validates structural deployment.

**Verdict**: **New** — template original, complementary to CI validators.

---

### start-observer.sh (182 lines) — NEW (adapted)

**Purpose**: Start/stop/manage background observer daemon for CLv2. Uses `claude --model haiku --print --dangerously-skip-permissions`.

**ECC equivalent**: Adapted from ECC's observer daemon with 11 bug fixes (nested-session detection, archive-before-success, signal handling, `set -e` in subshells, foreground sleep blocking, etc.). Heavily modified.

**Verdict**: **New** (adapted) — so extensively modified (11 fixes) that it's effectively a rewrite.

---

### sync-template.sh (523 lines) — NEW

**Purpose**: Sync template files into projects from local path or git remote. Supports selective category syncing, interactive diff review, version tracking.

**ECC equivalent**: None. ECC's install system installs ECC directly — it doesn't sync a template into existing projects.

**Verdict**: **New** — template original, core to the template lifecycle.

---

## Part 5: Configuration & Test Infrastructure

### ECC's package.json and Test Infrastructure

**ECC approach**: `npm test` runs all 8 CI validators sequentially plus `tests/run-all.js`. Coverage via `c8` with 80% threshold. Linting: ESLint (3 rules) + markdownlint. Their state store is SQLite-backed (`sql.js`). Custom test framework using `node assert` with temp directory fixture injection (no external test runner).

**Our approach**: No CI pipeline for template artifacts. `smoke-test.sh` validates deployment. Tests are per-project (pytest, jest, go test), not for the template itself.

**Assessment**: ECC's CI pipeline catches artifact integrity issues before merge. Our template would benefit from similar validation, especially as we grow past 50 commands and 40 skills. The 4 adopted CI validators (Part 1) provide the foundation. A test runner and markdownlint would be nice-to-have additions.

**Recommendation**: Adopt the 4 CI validators (Part 1 verdicts) as our initial CI pipeline. Defer the full test framework and markdownlint until v2.5.0 CI infrastructure tasks.

### ECC's ESLint Configuration

**ECC approach**: Minimal ESLint flat config (v9+) with 3 rules: `no-unused-vars`, `no-undef`, `eqeqeq`. ESLint targets only their Node.js scripts — real quality enforcement is in CI validators.

**Our approach**: We use `ruff` for Python linting (configured in CLAUDE.md). No JS/Node.js linting since our hook scripts are bash-based.

**Assessment**: Not applicable unless we adopt Node.js hooks (which some Part 1 Adapt verdicts suggest).

**Recommendation**: Add ESLint if/when we have Node.js scripts to lint. Not needed for bash-only hooks.

---

## Part 6: Overall Findings

### Key Patterns Discovered

1. **CI validation is ECC's best infrastructure innovation**: 8 validators catching structural issues at merge time. We have 0. The 4 most portable validators (agents, skills, rules, commands) total only 351 lines and provide immediate value.

2. **Schema-driven validation vs implicit validation**: ECC uses JSON Schema (Ajv) for formal contracts. We rely on code that reads configs to implicitly validate them. Formal schemas catch a broader class of errors. The hooks schema with its 18-event whitelist is the most immediately useful.

3. **We have 13 unused hook events**: ECC's hooks.schema.json lists 18 events; we use 5. Events like `PreCompact`, `TaskCompleted`, `SubagentStart/Stop`, and `SessionEnd` could enhance our hook system substantially.

4. **Test infrastructure gap**: ECC has 51 test files (120+ tests for validators alone). We have 0 tests for template artifacts. This doesn't mean we need 51 test files, but the gap in CI coverage for our 48 commands and 40 skills is real.

5. **Our scripts are a genuine differentiator**: 8 of our 10 scripts have no ECC equivalent because they solve template-specific problems (project scaffolding, upstream tracking, template syncing, MCP management, plugin management). ECC doesn't need these because it IS the product, not a template for other products.

6. **ECC's install system is their infrastructure overhead**: 5 of their 17 scripts and 5 of their 9 schemas are install-system plumbing. This is necessary for their multi-platform (5 targets) install story but irrelevant to our single-target template.

### Adoption Priority (ordered)

| Priority | Item | Effort | Value |
|----------|------|--------|-------|
| 1 | validate-commands.js | Low (path changes) | High (cross-ref integrity) |
| 2 | validate-agents.js | Low (path change) | Medium (frontmatter validity) |
| 3 | validate-skills.js | Low (path change) | Medium (structural integrity) |
| 4 | validate-rules.js | Low (path change) | Medium (empty rule detection) |
| 5 | validate-hooks.js (adapted) | Medium (settings.json input) | Medium (event/type validation) |
| 6 | hooks.schema.json (adapted) | Medium (extract constraints) | Medium (authoritative event list) |
| 7 | validate-no-personal-paths.js | Medium (parameterize) | Low (hygiene check) |
