# Template Overlay Friction Log

Records friction, conflicts, and observations from overlaying the project template onto real codebases. Updated after each test to track patterns and guide improvements.

## Test 1: analog_image_generator

| Field | Value |
|-------|-------|
| **Date** | 2026-02-19 |
| **Project** | Analog Image Generator (Python 3.10+, numpy/scipy/matplotlib, Jupyter notebooks) |
| **Tester** | Claude Code (Opus 4.6) |
| **Result** | **PASS 7/7** — zero conflicts |

### What Was Tested

| # | Area | Status | Notes |
|---|------|--------|-------|
| 1 | Rules loaded | PASS | 7 core + 5 language-specific rules on disk; all 7 core confirmed in system context |
| 2 | Commands available | PASS | Template commands (`/health`, `/commit`, etc.) + project commands (`/demo`, `/smoke`, `/preview`, `/validate-anchors`) all registered |
| 3 | CLAUDE.md parsed | PASS | Project identity, tech stack, domain knowledge, Taskmaster tags, and Definition of Done all intact after merge |
| 4 | Agents visible | PASS | 13/13 agents defined; `python-reviewer` spawn test succeeded on `utils.py` (returned 5 findings) |
| 5 | Skills available | PASS | `/code-review`, `/debugging`, `/python-data-science` all accessible |
| 6 | Hooks inventory | PASS | 18 hook scripts + settings example; README comprehensive |
| 7 | Contexts | PASS | `dev.md`, `review.md`, `research.md` all present and valid |

### Friction Found

**None.** Template infrastructure (`.claude/rules/`, `.claude/agents/`, `.claude/hooks/`, `.claude/contexts/`) merged cleanly alongside project-specific content (custom CLAUDE.md sections, `scripts/`, Taskmaster tags, domain knowledge).

### Observations (Not Friction)

1. **Hooks opt-in gap**: No `.claude/settings.json` found — hooks are defined on disk but not wired. This is *by design* (hooks activate via `/settings safe` or manual copy of `settings-example.json`), but new users may not realize hooks exist without explicitly opting in. Consider whether the setup wizard (`/setup`) should prompt for hook activation.

### Lessons for Future Tests

- Project-specific commands (`/demo`, `/smoke`, etc.) coexist with template commands without namespace collision — the flat `.claude/commands/` directory works.
- A project with heavy domain knowledge in CLAUDE.md (geologic rules, variogram formulas) did not interfere with template instructions — section-based merging is robust.
- Language-specific rules (`python/coding-standards.md`) loaded correctly via `paths:` frontmatter targeting `.py` files.

---

## Test 2: rideshare-rescue

| Field | Value |
|-------|-------|
| **Date** | 2026-02-19 |
| **Project** | Rideshare Rescue (Python backend, TypeScript/React frontend) |
| **Location** | `test-projects/rideshare-rescue` (child of template directory) |
| **Inheritance** | Claude Code parent-directory traversal — no files copied into project |
| **Tester** | Claude Code (Opus 4.6) |
| **Result** | **PASS 7/8, PARTIAL 1/8** — functional but with friction |

### What Was Tested

| # | Area | Status | Notes |
|---|------|--------|-------|
| 1 | Rules loaded | PASS | All 7 core rules inherited from parent template. Language-specific rules for `.py`, `.tsx` present with `paths:` frontmatter. Project has NO local `.claude/rules/` — fully inherited. |
| 2 | Commands available | PASS (with dupes) | 49 template + 5 project commands. All 5 project commands (`lint`, `test`, `prd`, `task-status`, `tasks`) identical to template versions. Duplicates in listing — no functional conflict but visual noise. |
| 3 | CLAUDE.md parsed | PASS | Both files loaded: template's (workflow rules, slash commands, agents table) AND project's (Rideshare Rescue identity, tech stack, API docs, business rules). No content conflicts. |
| 4 | Agents visible | PASS | All 13 template agents inherited. `python-reviewer` spawned against `backend/app/main.py` — valid review in 7.7s (23k tokens). No path issues across boundary. |
| 5 | Skills available | PASS (with conflict) | All 39 template skills accessible. 3 project overlaps: `code-review` (DIFFERENT — project version simpler), `debugging` (identical), `git-recovery` (identical). |
| 6 | Hooks inventory | PARTIAL | 17 hook scripts + README + settings-example in template. Project has NO hooks dir and NO hook config in `settings.local.json`. Hooks exist on disk but are not wired. |
| 7 | Contexts | PASS | 3 context files (`dev.md`, `review.md`, `research.md`) accessible via parent inheritance. |
| 8 | MCPs loaded | PASS | task-master-ai (44 tools) + context7 (2 tools) = 46 total. Within 80-tool budget. |

### Friction Found

| Issue | Severity | Detail |
|-------|----------|--------|
| Skill version conflict: `code-review` | **MEDIUM** | Project has a simpler `code-review` SKILL.md (no confidence filtering, no severity tiers, no Python-specific patterns). Template version is richer. Project version likely takes precedence, downgrading the template's enhanced review. |
| Duplicate entries in skill/command listing | **LOW** | 5 commands and 3 skills appear twice — once from template, once from project. No functional breakage but creates confusion about which version runs. |
| Hooks not configured | **MEDIUM** | Template hooks exist at parent level but project has no hook config. Running `/settings safe` would wire them up, but this isn't automatic on overlay. |
| JWT tokens in `settings.local.json` | **HIGH** (security) | 5 hardcoded JWT tokens in permission entries (lines 56-68). Expired test tokens but bad pattern for commits. `protect-sensitive-files.sh` hook would catch this if enabled. |
| No local `.claude/rules/` | **INFO** | Project relies entirely on parent inheritance. Fine for `test-projects/` but would break if moved outside template tree. |

### Observations

1. **Inheritance model works well.** Claude Code's parent-directory traversal correctly loads all template infrastructure (rules, agents, contexts, commands, skills) without requiring local copies. This is the desired "overlay" behavior.
2. **Deduplication is imperfect.** When both parent and child have the same-named command/skill, both appear in the system listing. Claude Code should either deduplicate (child wins) or warn about conflicts. Currently it silently lists both.
3. **The `code-review` conflict is the biggest functional issue.** The project's simpler version likely shadows the template's enhanced version. Resolution: delete project's copy (to inherit template's) or sync it.
4. **Project `.claude/` is minimal and pre-dates template.** Only 5 commands, 3 skills, and 1 settings file — all created Dec 4-9, before template overlay. The overlay is purely additive via inheritance.
5. **46 MCP tools is well within budget** per the 10/80 rule.
6. **Missing ephemeral dirs are expected.** No `.claude/instincts/`, `.claude/sessions/`, `.claude/work-log.md` — these get created on first use by template hooks/workflows.
7. **Both CLAUDE.md files coexist cleanly.** Template provides workflow infrastructure; project provides domain context. Section-based merging is robust.
8. **Agent spawning works across the boundary.** `python-reviewer` defined in parent template successfully reads and reviews files in child project.

### Recommended Actions for Template

1. **Document dedup behavior** — Note that child `.claude/` files shadow parent files with the same name
2. **Add a `/setup` check** — Setup wizard should detect pre-existing `.claude/` content and warn about version conflicts
3. **Provide a sync script** — e.g. `scripts/sync-template-overlay.sh` to update project copies to match template versions
4. **Hook activation gap** — Template overlay should either auto-configure hooks or make `/settings safe` part of the setup flow
5. **Security: `settings.local.json`** — Add to `.gitignore` template (contains permission history with tokens)

---

## Test 3: postiz-social-automation

| Field | Value |
|-------|-------|
| **Date** | 2026-02-19 |
| **Project** | Postiz Social Automation (Docker/Postiz/n8n, greenfield — no app code yet) |
| **Location** | `test-projects/postiz-social-automation` (child of template directory) |
| **Inheritance** | Claude Code parent-directory traversal — no `.claude/` in project at all |
| **Tester** | Claude Code (Opus 4.6) |
| **Result** | **PASS 4/8, FAIL 3/8, PARTIAL 1/8** — major inheritance gap discovered |

### What Was Tested

**Phase A: Static file presence check (from parent session)**

| # | Area | Status | Notes |
|---|------|--------|-------|
| 1 | Rules loaded | PASS | All 7 core + 5 language-specific rules inherited from parent via directory traversal. Confirmed working at runtime. |
| 2 | Commands available | **FAIL** | Files exist in parent `.claude/commands/` (50 files) but Claude Code does **NOT** register them as invocable skills. `/health` returns "Unknown skill". **All slash commands broken.** |
| 3 | CLAUDE.md parsed | PASS | Both template and project CLAUDE.md loaded. No section conflicts. |
| 4 | Agents visible | PASS | All 13 template agents in parent `.claude/agents/`. Agent spawning works across directory boundary. |
| 5 | Skills available | **FAIL** | Files exist in parent `.claude/skills/` (40 dirs) but Claude Code does **NOT** register them as invocable skills. Same inheritance gap as commands. |
| 6 | Hooks inventory | PARTIAL | 17 hook scripts in parent template. Not wired (no config). Scripts exist on disk but are two directories up. |
| 7 | Contexts | **FAIL** | Files exist in parent `.claude/contexts/` (3 files) but untested whether `--append-system-prompt` resolves relative paths correctly from child project. |
| 8 | MCPs loaded | PASS | task-master-ai (44 tools) + context7 (2 tools) = 46 total. MCPs are user-scoped, not project-scoped — unaffected by directory. |

**Phase B: Live runtime verification (from new session in project dir)**

Running an actual Claude Code session in the project directory revealed that the static check was misleading. Parent-directory traversal works for:
- **Rules** (`.claude/rules/`) — auto-loaded into system context
- **CLAUDE.md** — merged from all parent directories
- **Agents** — can be spawned by name from parent definitions

Parent-directory traversal does **NOT** work for:
- **Commands** (`.claude/commands/`) — NOT registered as skills
- **Skills** (`.claude/skills/`) — NOT registered as skills
- **Hooks** (`.claude/hooks/`) — scripts not discoverable without local config

**Resolution:** Created symlinks in project `.claude/` pointing to template directories:
```
.claude/commands -> ../../../.claude/commands
.claude/skills   -> ../../../.claude/skills
.claude/agents   -> ../../../.claude/agents
.claude/contexts -> ../../../.claude/contexts
.claude/hooks    -> ../../../.claude/hooks
```

### Friction Found

| Issue | Severity | Detail |
|-------|----------|--------|
| Commands/skills don't inherit via parent traversal | **CRITICAL** | This is the single biggest finding across all 3 tests. Claude Code walks parent directories for rules and CLAUDE.md, but the skill/command registration system does NOT discover definitions from parent `.claude/` directories. Every slash command listed in the template CLAUDE.md is broken for child projects without local copies or symlinks. |
| Smoke test gave false positives | **HIGH** | The static file-presence check (Phase A) reported PASS for commands/skills because the files exist on disk. But existing on disk ≠ registered as skills. Live runtime testing was required to discover the gap. **All previous smoke tests should be re-evaluated for this.** |
| Hooks not configured | **MEDIUM** | Template hooks exist at parent level but project has no hook config. Even with symlinks, hooks need explicit activation via `/settings safe`. |
| No onboarding prompt | **MEDIUM** | A new user opening this project gets template rules and CLAUDE.md silently but has no indication that 50 commands, 40 skills, and 13 agents exist. `/setup` must be discovered. |
| `.gitignore` missing template entries | **LOW** | Fixed during this test — added `settings.local.json`, `.claude/sessions/`, `.claude/instincts/`, `.claude/work-log.md`, `.claude/project-index.json`. |

### Observations

1. **Inheritance is partial, not complete.** Claude Code's parent-directory traversal has two tiers: (a) rules + CLAUDE.md inherit automatically, (b) commands + skills + hooks do NOT. This is the most important architectural finding for the template.
2. **Smoke tests had a blind spot.** Checking "do files exist in the parent directory?" is not the same as "does Claude Code register them?" Future smoke tests must include a live runtime verification step (actually invoke a skill).
3. **Symlinks are a viable workaround.** Creating symlinks from project `.claude/` to template `.claude/` subdirectories makes commands and skills register correctly. This is lightweight and keeps the project in sync with the template automatically.
4. **The template needs a distribution mechanism.** For projects nested under the template tree, symlinks work. For standalone projects (like the original `ISKCON-GN/postiz_social_automation`), a copy/init script is needed. `/setup` should handle this.
5. **CLAUDE.md layering works perfectly.** Template provides workflow infrastructure; project provides domain context. This is the one inheritance mechanism that works flawlessly.
6. **Rules are the model.** Whatever mechanism Claude Code uses to load rules from parent directories should be extended to commands and skills. This may be worth reporting upstream.
7. **Docker-only project works fine.** The template doesn't assume any particular language or framework. Infrastructure and workflow are decoupled from code type.
8. **rideshare-rescue test was accidentally correct.** It had its own `.claude/commands/` and `.claude/skills/` from before the template existed, which masked the inheritance gap. The commands worked not because of inheritance, but because of local copies.

### Comparison Across All Three Tests

| Dimension | Test 1 (analog) | Test 2 (rideshare) | Test 3 (postiz) |
|-----------|-----------------|---------------------|-----------------|
| Pre-existing `.claude/` | Yes (template-applied) | Yes (pre-dates template) | None |
| Local commands/skills | 4 commands | 5 commands, 3 skills | None (symlinked after) |
| Commands work? | Yes (local copies) | Yes (local copies) | **NO** (until symlinked) |
| Conflicts | 0 | 5 (1 HIGH) | 1 CRITICAL |
| Hooks wired | No | No | No |
| App code exists | Yes (Python) | Yes (Python + TS) | No (Docker only) |
| Profile | Mature + clean | Mature + messy | Greenfield |

**Key insight:** Tests 1 and 2 passed for commands/skills because both projects had LOCAL copies in their `.claude/` directories. Test 3 was the first project with no local `.claude/` content, revealing that parent-directory inheritance does NOT extend to command/skill registration.

### Recommended Actions for Template

1. **CRITICAL: `/setup` must create local `.claude/` structure.** Either copy or symlink commands, skills, agents, contexts, and hooks from the template into the project. Without this, the entire slash command UX is broken for new projects.
2. **Add symlink-based init script** — `scripts/init-project.sh` that creates `.claude/` symlinks pointing to the template. Works for projects nested under the template tree.
3. **Add copy-based init script** — `scripts/init-project-standalone.sh` for projects outside the template tree. Copies `.claude/` subdirectories so the project is self-contained.
4. **`.gitignore` addendum** — Provide a standard block of template-aware ignores. Fixed for postiz during this test.
5. **Re-evaluate Tests 1 and 2** — Both masked the inheritance gap because they had local copies. Document that local `.claude/` is REQUIRED, not optional.
6. **Report upstream** — Consider filing a feature request for Claude Code to extend parent-directory traversal to commands and skills, matching the behavior already implemented for rules.

---

## Friction Pattern Tracker

Tracks recurring themes across multiple tests. Update counts as new tests are added.

| Pattern | Occurrences | Severity | Status |
|---------|-------------|----------|--------|
| **Commands/skills don't inherit from parent** | **1/3 (but masked in 2/3)** | **CRITICAL** | **Root cause of most friction — local `.claude/` is REQUIRED** |
| Hooks not auto-wired | 3/3 | Medium | **Confirmed pattern** — add to `/setup` flow |
| No onboarding/discovery prompt | 1/3 | Medium | Greenfield users don't know what's available |
| `.gitignore` missing template entries | 1/3 | Low | Template workflows create uncommittable files |
| Smoke test false positives (file presence ≠ runtime) | 1/3 | High | Future tests must include live skill invocation |
| Skill/command shadowing (child overrides parent) | 1/3 | Medium | Only with pre-existing `.claude/` content |
| Duplicate entries in listing | 1/3 | Low | Only with pre-existing `.claude/` content |
| Sensitive data in `settings.local.json` | 1/3 | High | Only with pre-existing `.claude/` content |
| Command namespace collision | 0/3 | — | No issue |
| CLAUDE.md section conflicts | 0/3 | — | No issue |
| Rule loading failures | 0/3 | — | No issue |
| Agent spawn failures | 0/3 | — | No issue |

---

*Add new test sections above the Friction Pattern Tracker. Update the tracker after each test.*
