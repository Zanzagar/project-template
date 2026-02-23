# Workflow Guardrails — Design Document

Date: 2026-02-23
Status: Approved (brainstorm complete)
Approach: Hybrid (hard gates for critical gaps + clear rules for ambiguity gaps)

## Problem

The template has 5 hard enforcement points but ~20+ soft enforcement points that rely entirely on prompt instructions. Soft enforcement drifts during long sessions, after compaction, or with ambiguous user requests.

## Audit Findings

### Critical Gaps (5)
1. No PRD gate before implementation
2. No commit message format validation (conventional commits)
3. No main branch protection (commits land directly on main)
4. No task-in-progress requirement for commits
5. User override vs Superpowers TDD contradiction unresolved

### High Gaps (5)
6. Refactoring workflow unspecified
7. Emergency hotfix path missing
8. Tag context lost on compaction
9. Multi-feature scope mixing not prevented
10. Task status not enforced on task switch

### Medium Gaps (4)
11. Docs workflow under-specified
12. Dependency update workflow missing
13. Session resume priority unclear
14. Superpowers "required" but no fallback spec

## Approach: Hybrid

Hard enforcement (hooks) for critical gaps where technically feasible.
Clear, explicit rules for all remaining gaps.

## Deliverables

1. **Enhanced `pre-commit-check.sh`** — conventional commit format + main branch block
2. **Enhanced `pre-compact.sh`** — save active tag, TDD phase, uncommitted work warning
3. **New rule: `workflow-enforcement.md`** — scenario-by-scenario workflow guide
4. **Updated `authority-hierarchy.md`** — resolve user-override vs Superpowers contradiction
5. **New `/phase-check` command** — validates phase prerequisites
6. **Updated `proactive-steering.md`** — add `/phase-check` to auto-invoke table

## Workflow Applied

- TDD for hook scripts (deliverables 1-2)
- Direct implementation + review for rules/commands (deliverables 3-6)
- Feature branch: `feature/workflow-guardrails`
- Tag: `workflow-guardrails`
