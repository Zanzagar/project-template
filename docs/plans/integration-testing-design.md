# Design: Integration/Deployment Test Step

**Date**: 2026-03-18
**Status**: Proposal
**Problem**: Unit tests miss deployment issues (dogfood finding — 263 tests passed, 5 deployment bugs found)

## Problem Statement

Dogfood Run 2 had 263 passing unit tests but discovered 5 deployment bugs:
1. PYTHONPATH not set correctly in Docker container
2. Docker module resolution differs from local development
3. Streamlit auto-discovery patterns break in containerized environments
4. Auth gates not applied per-page (worked in dev, failed in prod)
5. Config loading paths differ between host and container

Unit tests validate logic correctness. They don't validate that the application starts, connects to services, and serves requests in a deployment environment.

## Current Pipeline

```
TDD (unit tests) → Code Review → Push → PR → Squash Merge
```

There is no step that validates the application works as a deployed unit.

## Proposed Approaches

### Approach A: Smoke Test Phase in Branch Completion

**How**: Add a smoke test step between code review and PR creation in the branch completion workflow (`workflow-enforcement.md` Phase 8).

```
Review → Smoke Test → Push → PR → Merge
```

Smoke tests would be project-specific, defined in a `tests/smoke/` directory:
- `smoke_start.sh` — verify application starts (e.g., `docker compose up -d && curl health_endpoint`)
- `smoke_config.sh` — verify config loads in deployment mode
- `smoke_auth.sh` — verify auth gates work end-to-end

**Pros**:
- Catches deployment issues before merge
- Project-specific (no one-size-fits-all)
- Lightweight — a few shell scripts, not a test framework

**Cons**:
- Requires Docker (or deployment target) to be available locally
- Adds time to the branch completion workflow
- Not all projects have Docker — needs graceful skip

### Approach B: Integration Test Phase After Unit Tests

**How**: Add an integration test phase to the `/verify` pipeline, between unit tests and security scan.

```
verify: build → types → lint → unit tests → INTEGRATION → security → diff review
```

Integration tests use Docker Compose to spin up the full stack and run basic checks.

**Pros**:
- Integrated into existing verification pipeline
- Runs earlier (during development, not just at merge time)

**Cons**:
- Heavy — requires Docker to be running for every /verify
- Slows down the feedback loop
- Overkill for projects without Docker

### Approach C: Deployment Checklist in PR Template (Recommended)

**How**: Add a deployment validation checklist to the `/pr` command's PR body template. The checklist reminds developers to manually verify deployment-sensitive changes.

```markdown
## Deployment Checklist
- [ ] Application starts in Docker (if applicable): `docker compose up`
- [ ] Config loads correctly in target environment
- [ ] Auth/permissions work end-to-end (not just unit-tested)
- [ ] Paths/imports work in containerized environment
- [ ] No hardcoded localhost/development URLs
```

**Pros**:
- Zero overhead for projects without Docker
- Works as a reminder, not a gate
- Easy to implement (just update PR template)
- Can be customized per project

**Cons**:
- Advisory, not enforced — can be ignored
- Doesn't actually run anything
- Relies on developer discipline

## Recommendation

**Approach C for now** — add deployment checklist to PR template. It's the lightest touch and addresses the root cause (nobody thought to check deployment behavior).

**Future**: If a project has Docker, encourage adding `tests/smoke/` scripts and invoke them in the `/verify` pipeline as an optional step (skip if Docker not available).

## Implementation

1. Update `.claude/commands/pr.md` to include deployment checklist in PR body template
2. Add note in `workflow-enforcement.md` about deployment validation at branch completion
3. Create `docs/DEPLOYMENT_TESTING.md` with guidance on writing smoke tests

## Out of Scope

- Implementing an actual integration test framework
- Requiring Docker for all projects
- Adding e2e testing infrastructure (covered separately by `/e2e` command)
