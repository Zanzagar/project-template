# Hook Scripts Audit Decisions

## Inventory

**Our hooks**: 18 bash scripts in `.claude/hooks/`
**ECC hooks**: 25 files in `scripts/hooks/` (3 already adopted as lib/)
**Remaining comparisons**: 22 ECC hooks to evaluate
**Audit date**: 2026-03-19

## Summary

| Verdict | Count | Hooks |
|---------|-------|-------|
| Adopt   | 2     | session-end.sh, typescript-check.sh |
| Adapt   | 6     | session-init.sh, post-edit-format.sh, dev-server-blocker.sh, console-log-audit.sh, suggest-compact.sh, pr-url-extract.sh |
| Keep    | 4     | pre-compact.sh, doc-file-blocker.sh, build-analysis.sh, long-running-tmux-hint.sh |
| New     | 5     | protect-sensitive-files.sh, project-index.sh, pattern-extraction.sh, observe.sh, pre-commit-check.sh |
| Skip    | 3     | session-summary.sh (vestigial), session-end-marker.js (ECC plumbing), pre-bash-git-push-reminder.js (ECC stub) |

## Already Adopted (f9963ad)

| Our File | ECC Source | Verdict |
|----------|-----------|---------|
| .claude/hooks/lib/hook-flags.js | scripts/lib/hook-flags.js | Adopt |
| .claude/hooks/lib/run-with-flags.js | scripts/hooks/run-with-flags.js | Adopt |
| .claude/hooks/lib/run-with-flags-shell.sh | scripts/hooks/run-with-flags-shell.sh | Adapt |
| .claude/hooks/lib/check-hook-enabled.js | scripts/hooks/check-hook-enabled.js | Adopt |

## Functional Mapping

### Category A: Session Lifecycle Hooks

| Our Hook | ECC Equivalent(s) | Overlap |
|----------|-------------------|---------|
| session-init.sh | session-start.js | Partial — ours has phase detection, theirs has transcript reading |
| session-end.sh | session-end.js | Partial — theirs reads transcripts for better summaries |
| pre-compact.sh | pre-compact.js (inside suggest-compact) | Partial — ours has state preservation |
| session-summary.sh | evaluate-session.js | Different approach — ours is snapshot, theirs is AI evaluation |

### Category B: File Operation Hooks

| Our Hook | ECC Equivalent(s) | Overlap |
|----------|-------------------|---------|
| post-edit-format.sh | post-edit-format.js, quality-gate.js | High — similar formatting trigger |
| protect-sensitive-files.sh | (none) | **New** — unique to us |
| doc-file-blocker.sh | doc-file-warning.js, pre-write-doc-warn.js | Partial — ours blocks, theirs warns |
| project-index.sh | (none) | **New** — unique to us |

### Category C: Development Workflow Hooks

| Our Hook | ECC Equivalent(s) | Overlap |
|----------|-------------------|---------|
| typescript-check.sh | post-edit-typecheck.js | High — same purpose |
| dev-server-blocker.sh | pre-bash-dev-server-block.js, auto-tmux-dev.js | Partial — theirs auto-launches tmux |
| build-analysis.sh | post-bash-build-complete.js | High — same purpose |
| console-log-audit.sh | post-edit-console-warn.js, check-console-log.js | High — same purpose |

### Category D: Auxiliary & Monitoring Hooks

| Our Hook | ECC Equivalent(s) | Overlap |
|----------|-------------------|---------|
| suggest-compact.sh | suggest-compact.js | High — same purpose |
| pattern-extraction.sh | (none — observer handles) | **New** — different architecture |
| observe.sh | (none — daemon, not hook) | **New** — fundamentally different approach |
| pr-url-extract.sh | post-bash-pr-created.js | High — same purpose |
| long-running-tmux-hint.sh | pre-bash-tmux-reminder.js | High — same purpose |
| pre-commit-check.sh | (none — they use git hooks) | **New** — different approach |

### ECC-Only Hooks (evaluated)

| ECC Hook | Function | Verdict | Reasoning |
|----------|----------|---------|-----------|
| cost-tracker.js | Token/cost telemetry | Defer | v2.5.0 PRD Task 6 covers this |
| quality-gate.js | Consolidated format+lint+typecheck | Defer | v2.5.0 PRD Task 5; folded into post-edit-format Adapt |
| insaits-security-wrapper.js | InsAIts security monitoring | Skip | Previously rejected — unproven SDK, per-call latency |
| insaits-security-monitor.py | InsAIts Python monitor | Skip | Previously rejected — unproven SDK |
| session-end-marker.js | Session boundary marker | Skip | NanoClaw plumbing artifact; no need in our bash pipeline |
| pre-bash-git-push-reminder.js | Push reminder | Skip | Explicit stub; our pre-commit-check.sh covers quality gates |

---

## Detailed Analysis

### Category A: Session Lifecycle

#### session-init.sh vs session-start.js — ADAPT

**Our implementation**: 525-line bash script. Detects project phase (ideation/planning/building/shipping), checks for missing template components (Taskmaster, Superpowers, CLAUDE.md customization), loads recent session summaries from `.claude/sessions/`, queries Taskmaster for task counts and current task, prints rich formatted project status panel with scenario-specific guidance, auto-starts observer daemon.

**ECC implementation**: 75-line Node.js script. Loads most recent `*-session.tmp` from `~/.claude/sessions/` and injects content directly into Claude's context via stdout. Detects project language/framework via 12-language rule set. Sessions stored globally.

**Assessment**:
- Architecture: Ours — project-centric storage, structured status panel
- Features: Split — ECC has stdout session injection + language detection; ours has phase/scenario/taskmaster/superpowers/observer
- Error handling: Ours — `set +e` guards throughout
- Performance: ECC — fewer subprocess forks (our 8-12 forks add visible latency)
- Cross-platform: ECC — Node.js vs bash

**Verdict**: **Adapt** — Keep all our project-specific logic. Adopt ECC's pattern of injecting previous session content via stdout (so Claude actually reads it). Optionally add language detection. Guard `task-master` calls with `command -v` check.

---

#### session-end.sh vs session-end.js — ADOPT

**Our implementation**: 81-line bash Stop hook. Reads git state (branch, commits, diff stat), queries Taskmaster for in-progress tasks via jq. Writes structured markdown to `.claude/sessions/session_TIMESTAMP.md`. Discards stdin JSON payload entirely.

**ECC implementation**: 280-line Node.js Stop hook. Reads `transcript_path` from stdin JSON, parses JSONL transcript to extract user messages (last 10), tool names used, and files modified. Idempotent update pattern using marker comments — repeated Stop events accumulate, not overwrite. Session ID in filename for cross-session reference.

**Assessment**:
- Architecture: ECC wins significantly — transcript reading captures ground truth vs our git-only view
- Features: ECC — idempotent updates, worktree tracking, session ID; ours has Taskmaster task capture (unique)
- Error handling: ECC — stdin size limit, JSONL error counter, missing transcript fallback
- Performance: ECC — single-process transcript parse vs our 5+ git subprocess forks
- Cross-platform: ECC — Node.js

**Verdict**: **Adopt** — Start from ECC's session-end.js. Add Taskmaster in-progress task query (our unique addition). Change sessions dir from `~/.claude/sessions/` to `${projectDir}/.claude/sessions/` to stay project-scoped.

---

#### pre-compact.sh vs pre-compact.js — KEEP

**Our implementation**: 110-line bash hook. Captures git state, Taskmaster active task/tag, TDD phase via pytest, writes to `.claude/sessions/pre-compact-state.md`. Uses UserPromptSubmit trigger with phrase matching.

**ECC implementation**: 55-line Node.js PreCompact hook. Appends timestamped entry to `compaction-log.txt`. No git/task/TDD capture — essentially a logging stub.

**Assessment**:
- Architecture: Ours wins substantially — rich state capture vs logging stub
- Features: Ours — branch, uncommitted files, active task, TDD phase
- Error handling: ECC slightly better on error patterns
- Performance: ECC faster (file write only vs our pytest execution)
- Cross-platform: ECC — Node.js

**Verdict**: **Keep** — Our state capture is far richer. Fix: add `timeout 10` guard on pytest call to prevent blocking. Consider migrating to PreCompact event if stable.

---

#### session-summary.sh vs evaluate-session.js — SKIP (ours)

**Our implementation**: 43-line bash Stop hook. Appends one-line YAML entry (timestamp + git diff stat) to `.claude/logs/sessions.log`.

**ECC implementation**: 120-line Node.js Stop hook for continuous learning pipeline. Counts transcript messages, gates learning attempts by session length.

**Assessment**: Our hook is vestigial — superseded by `session-end.sh` which writes richer markdown summaries. ECC's serves a different purpose (learning pipeline trigger) that our template handles via observer/pattern-extraction.

**Verdict**: **Skip** — Remove or disable `session-summary.sh`. Don't adopt ECC's evaluate-session.js without evaluating entire learning pipeline.

---

#### session-end-marker.js (ECC-only) — SKIP

22-line passthrough module for ECC's Windows hook-chaining infrastructure (NanoClaw). No need in our bash-based pipeline. NanoClaw previously rejected.

---

### Category B: File Operations

#### post-edit-format.sh vs post-edit-format.js + quality-gate.js — ADAPT

**Our implementation**: Bash case-statement formatter dispatch. Covers Python (ruff), JS/TS/JSON/MD (prettier), Go (gofmt), Rust (rustfmt), Shell (shfmt). Hardcoded formatter paths.

**ECC implementation**: Two-hook architecture. `post-edit-format.js` handles JS/TS with shared `resolve-formatter.js` (auto-detects Biome vs Prettier, caches results, prefers local node_modules). `quality-gate.js` handles broader coverage on Edit|Write|MultiEdit with env var controls (`ECC_QUALITY_GATE_FIX/STRICT`).

**Assessment**:
- Architecture: ECC — separation of concerns, shared formatter resolution with caching
- Features: ECC — Biome support, package manager awareness, env var controls; we have Rust + Shell (ECC lacks)
- Error handling: ECC — 15s timeouts, input size cap, Windows `.cmd` injection guard
- Performance: ECC — local-bin-first saves 200-500ms per invocation
- Cross-platform: ECC — explicit Windows shim handling

**Verdict**: **Adapt** — Adopt ECC's two-hook architecture + resolve-formatter.js. Merge our Rust (rustfmt) and Shell (shfmt) coverage. Rename env vars to `TEMPLATE_QUALITY_GATE_*`.

---

#### protect-sensitive-files.sh — NEW

PreToolUse hook blocking edits to `.env*`, credential files, key files, and protected directories. Hard block via exit 2.

**ECC has no equivalent** — their security is rule-based (post-hoc review), not preventive. This is a genuine gap in ECC.

**Verdict**: **New** — Keep as-is. Consider adding `.env.*` wildcard, `*.p12`, `*.pfx` patterns.

---

#### doc-file-blocker.sh vs doc-file-warning.js — KEEP

**Our implementation**: Hard-blocks (exit 2) `.md/.txt/.rst` file creation outside approved locations. Strict profile only.

**ECC implementation**: Warns (exit 0) on non-standard doc files. Broader allowed list includes AGENTS.md, MEMORY.md, WORKLOG.md.

**Assessment**: Our hard-block is intentionally stricter — the correct choice for preventing LLM doc sprawl.

**Verdict**: **Keep** — Our enforcement approach is a deliberate design choice. **Bug fix needed**: add `AGENTS.md`, `MEMORY.md`, `WORKLOG.md` to allowed files (MEMORY.md is actively used by this project).

---

#### project-index.sh — NEW

SessionStart + PostToolUse hook generating `.claude/project-index.json` with file signatures, imports, and directory structure. 5-minute staleness TTL.

**ECC has no equivalent** — they rely on direct file exploration via tools. Our pre-computed index saves context tokens for sub-agents.

**Verdict**: **New** — Unique concept worth keeping. Known issue: bash JSON generation can corrupt on special characters in signatures. Recommended future improvement: Node.js rewrite for `JSON.stringify()` safety.

---

### Category C: Development Workflow

#### typescript-check.sh vs post-edit-typecheck.js — ADOPT

**Our implementation**: Bash script, uses `grep "$FILE_PATH"` to filter tsc output. Can produce false positives or miss results when tsc reports relative paths.

**ECC implementation**: Node.js with multi-candidate path Set (absolute, relative, original). Uses `path.relative()` for accurate filtering. 30-second timeout, Windows `npx.cmd` support.

**Assessment**:
- Architecture: ECC — correct multi-path filtering vs our grep false-positive risk
- Features: ECC — symlink resolution, root-stop guard, candidate Set matching
- Error handling: ECC — 1MB stdin cap, graceful catch, existsSync pre-check
- Cross-platform: ECC — npx.cmd on Windows, path.parse for drive roots

**Verdict**: **Adopt** — ECC's path filtering is a correctness fix. Self-contained, no lib dependencies. Drop-in replacement.

---

#### dev-server-blocker.sh vs pre-bash-dev-server-block.js + auto-tmux-dev.js — ADAPT

**Our implementation**: Single hook that blocks dev servers outside tmux. Covers Node, Flask, uvicorn, Hugo, Jekyll, Cargo watch.

**ECC implementation**: Two-hook split. `auto-tmux-dev.js` transparently rewrites `npm/pnpm/yarn/bun dev` into tmux invocations. `pre-bash-dev-server-block.js` is safety net with proper shell parser handling `sudo`, `env`, compound commands.

**Assessment**:
- Architecture: ECC — auto-tmux is strictly better than block-and-ask
- Features: ECC — shell parser, Windows fallback; ours — polyglot server patterns (Flask, Hugo, etc.)
- Error handling: ECC — proper shell parsing catches edge cases our case-match misses

**Verdict**: **Adapt** — Adopt both ECC hooks. Extend their server detection to include Flask, uvicorn, Hugo, Jekyll, Cargo from our patterns.

---

#### build-analysis.sh vs post-bash-build-complete.js — KEEP

**Our implementation**: Genuine build output analysis — error/warning counting across 6 build system families (Node, Rust, Go, Java, Python, Make), with structured summary and `/build-fix` suggestion.

**ECC implementation**: Stub — prints "async analysis running in background" but performs no actual analysis.

**Verdict**: **Keep** — ECC's hook is empty. Ours provides real diagnostic value.

---

#### console-log-audit.sh vs post-edit-console-warn.js + check-console-log.js — ADAPT

**Our implementation**: Single PostToolUse hook covering 5 languages (Python, JS/TS, Go, Java, Ruby).

**ECC implementation**: Two-hook strategy. `post-edit-console-warn.js` gives immediate per-edit feedback. `check-console-log.js` (Stop hook) sweeps all modified files at session end — catches debug statements across multiple edits. Principled exclusion list (test files, config files).

**Assessment**:
- Architecture: ECC — two-hook (per-edit + session-sweep) catches more cases
- Features: Ours — 5-language coverage vs ECC's JS/TS only
- Error handling: ECC — structured try/catch, shared utilities

**Verdict**: **Adapt** — Adopt ECC's two-hook architecture. Extend both hooks with our polyglot patterns (Python, Go, Java, Ruby).

---

### Category D: Auxiliary & Monitoring

#### suggest-compact.sh vs suggest-compact.js — ADAPT

**Our implementation**: Bash, tracks tool-call counter in temp file. 50-call threshold, 25-call repeat. Has unique `/learn` reminder at 75 calls.

**ECC implementation**: Node.js, atomic fd-based counter write (reduces race conditions), value clamping to prevent integer overflow from corrupted files.

**Verdict**: **Adapt** — Adopt ECC's atomic counter write and value clamping. Keep our `/learn` reminder at 75 calls. Use temp-file-then-mv pattern in bash for atomicity.

---

#### pattern-extraction.sh — NEW

Stop hook analyzing `git log --since="4 hours ago"` for commit-type patterns. Emits structured JSON candidates into `.claude/instincts/candidates/`. Unique git-history-based learning — complementary to observe.sh's live tool observation.

**Verdict**: **New** — No ECC equivalent. Architecturally sound.

---

#### observe.sh — NEW

Pre/PostToolUse hook writing observations to `.claude/instincts/observations.jsonl`. Signals observer daemon via SIGUSR1. Phase passed as `$1` from hook config.

**Verdict**: **New** — Different architecture from ECC's daemon approach. Works without daemon running. Keep as-is. Known trade-off: Python3 subprocess overhead (two forks per tool call).

---

#### pr-url-extract.sh vs post-bash-pr-created.js — ADAPT

**Our implementation**: Fires on `git push`, extracts PR creation URLs from stdout/stderr. Covers GitHub, GitLab.

**ECC implementation**: Fires on `gh pr create`, extracts resulting PR number URL. 16 lines.

**Assessment**: These fire at different workflow moments and are complementary, not competing.

**Verdict**: **Adapt** — Merge both trigger points. Our `git push` URL extraction + ECC's `gh pr create` PR number extraction = full workflow coverage.

---

#### long-running-tmux-hint.sh vs pre-bash-tmux-reminder.js — KEEP

**Our implementation**: Broad language coverage (Node, Python pip/poetry/pdm, Rust, Go, Java mvn/gradle, Make, Docker) with reason-specific messages.

**ECC implementation**: Single regex, generic message. Covers Node, Cargo, Make, Docker, pytest, vitest, playwright. 10 lines.

**Verdict**: **Keep** — Ours is strictly superior on coverage and message quality. Absorb `vitest`, `playwright`, `bun` patterns from ECC.

---

#### pre-commit-check.sh — NEW

PreToolUse hook intercepting `git commit` commands. Five checks: branch protection, conventional commit format, ruff lint, pytest, debug/secret scanning. Per-check skip flags.

**ECC uses git native hooks** instead. Our approach can show Claude failures before git runs, allowing self-correction.

**Verdict**: **New** — Different interception layer, correct for Claude Code-centric workflow. Known limitation: heredoc commit messages cause silent parsing errors (use multiple `-m` flags).

---

#### pre-bash-git-push-reminder.js (ECC-only) — SKIP

28-line stub that prints "review changes before push" on every `git push`. Self-described as a placeholder. Our pre-commit-check.sh already provides quality gates.

---

## Action Items (Phase 5 Execution)

### Adopt (replace our version with ECC's)
1. **session-end.sh** → Replace with ECC's session-end.js + add Taskmaster query + project-local sessions dir
2. **typescript-check.sh** → Replace with ECC's post-edit-typecheck.js (self-contained, drop-in)

### Adapt (start from ECC's, merge our features)
3. **session-init.sh** → Add ECC's stdout session injection to our existing hook
4. **post-edit-format.sh** → Adopt ECC's two-hook + resolve-formatter.js + merge rustfmt/shfmt
5. **dev-server-blocker.sh** → Adopt ECC's auto-tmux + block hooks + merge polyglot patterns
6. **console-log-audit.sh** → Adopt ECC's two-hook architecture + merge polyglot patterns
7. **suggest-compact.sh** → Adopt atomic counter + keep /learn reminder
8. **pr-url-extract.sh** → Add `gh pr create` trigger from ECC

### Keep (with fixes)
9. **pre-compact.sh** — Add `timeout 10` guard on pytest call
10. **doc-file-blocker.sh** — Add MEMORY.md, AGENTS.md, WORKLOG.md to allowed files
11. **build-analysis.sh** — No changes needed
12. **long-running-tmux-hint.sh** — Add vitest, playwright, bun patterns

### Remove
13. **session-summary.sh** — Vestigial, superseded by session-end.sh

### Dependencies needed for Adapt items
- `scripts/lib/utils.js` (for console-log-audit, suggest-compact Node.js versions)
- `scripts/lib/resolve-formatter.js` (for post-edit-format)
- `scripts/lib/shell-split.js` or equivalent (for dev-server-blocker)
