# Session Handoff: Roadmap & Remaining Work

## BRANCH: main (clean, pushed through 40f3d17 template, 73c7d4e postiz)

## COMPLETED THIS SESSION
1. **Orchestrate fix** (cf62596) — Removed conflicting feature/bugfix pipelines from /orchestrate. Now analysis-only: review, security, refactor. Updated 7 files across rules, commands, docs.
2. **Test 3 prompt updated** (302cf21) — Uses /orchestrate review on existing code instead of implementing new feature.
3. **Honesty gaps documented** (40f3d17) — Added SIMULATED/NOT IMPLEMENTED/STUB warnings to 5 multi-model commands + plugin download.
4. **Review pipeline validated** — Ran /orchestrate review on postiz health monitoring code. 3 agents (code-reviewer, security-reviewer, database-reviewer) ran in parallel, all artifacts persisted to `.claude/orchestrate/review/`.
5. **Both repos pushed** — template and postiz up to date.

## ROADMAP: What's Left

### Phase 1: Make Real What's Fake (highest value)
- **Real multi-model integration** for /multi-plan and /multi-execute
  - Need: API wrapper that calls Gemini (GOOGLE_AI_KEY) and OpenAI (OPENAI_API_KEY)
  - Could be a simple Python script or bash wrapper that the command invokes
  - The output format is already defined — just need real API calls instead of Claude simulating
- **Real plugin download** — implement GitHub API enumeration in download_plugin()
  - Use `gh api` to list files in wshobson/agents plugin directories
  - Download each file to the correct local path
- **Decision needed**: Remove or fix /multi-backend, /multi-frontend, /multi-workflow (need codeagent-wrapper or equivalent)

### Phase 2: Session Persistence (reliability)
- **Fix session-end.sh** — it's not firing on Stop events (known from Test 2, friction F18)
  - Root cause likely: hook event type mismatch or settings.local.json config
  - This blocks cross-session continuity (session summaries never get written)
- **Test pre-compact.sh** — untested, should preserve state before auto-compaction

### Phase 3: Continuous Learning Validation
- **Run /instinct-status, /evolve in anger** — these have real logic but zero real-world testing
- **Verify instinct lifecycle**: candidate → active → decayed
- **Test /learn** — extract patterns from a real coding session

### Phase 4: Production Hardening
- **Address review findings** from the orchestrate review pipeline:
  - Rotate secrets in postiz .env
  - Add webhook URL validation (SSRF)
  - Switch health_storage to persistent connection + WAL mode
  - Fix details JSON deserialization bug
- **Add integration tests** for hooks (currently only manual testing)

### Phase 5: Documentation & Polish
- **Create TEMPLATE_OVERVIEW.md** — user-facing guide to what the template provides
- **Update CHANGELOG.md** — comprehensive entry for all ECC integration work
- **Clean up docs/** — remove session handoff files, consolidate test results

### Phase 6: Release
- **Tag v2.0.0** — major version for ECC integration
- **Write release notes** — what's new, migration guide from v1
- **Publish** — update README, announce

## KEY FILES
- `docs/SESSION_HANDOFF_ORCHESTRATE_FIX.md` — previous handoff (can be archived)
- `docs/TEST3_ORCHESTRATION_EVAL_PROMPT.md` — updated test prompt
- `.claude/rules/superpowers-integration.md` — the critical workflow override rule
- MEMORY.md — up to date with all current state
