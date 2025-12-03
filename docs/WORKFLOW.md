# Standard Workflow: Cursor → PRDs/AGENTS → GitHub → Task Master

## Overview
Use Cursor (or any editor) to draft PRDs/AGENTS, set up repo hygiene, then switch to Codex + Task Master for execution. Adapt steps to your org, but keep the sequence consistent.

## Phases
1. **Cursor / Docs Phase**
   - Author PRDs in `.taskmaster/docs/` and `AGENTS.md`.
   - Maintain sources in `research-documents/`.
   - Keep guardrails mapped in `docs/GUARDRAILS.md`.

2. **GitHub Hygiene**
   - Commit/push docs and scaffolding.
   - Ensure CI (lint/tests) is green.

3. **Codex + Task Master**
   - Configure Codex CLI + Task Master.
   - Parse one PRD per tag, analyze, expand tasks.
   - Package-first restructure after switching: create `src/<package>/`, update `pyproject.toml`, ensure CI installs the package.

4. **Implementation**
   - Work the Task Master backlog, append notes, keep docs updated.

5. **QA & Release**
   - Run smoke + pytest, update CHANGELOG, collect review findings, and release.
