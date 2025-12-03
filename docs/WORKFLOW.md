# Standard Workflow: Claude Code → PRDs → GitHub → Task Master

## Overview
Use Claude Code to draft PRDs, set up repo structure, then use Task Master for task management. Adapt steps to your team, but keep the sequence consistent.

## Phases

1. **Documentation Phase**
   - Author PRDs in `.taskmaster/docs/`
   - Maintain research in `research-documents/`
   - Map guardrails in `docs/GUARDRAILS.md`

2. **GitHub Hygiene**
   - Commit/push docs and scaffolding
   - Ensure CI (lint/tests) is green

3. **Task Master Setup**
   - Parse PRD: `task-master parse-prd --file .taskmaster/docs/prd_primary.txt`
   - Analyze complexity: `task-master analyze-complexity`
   - Expand tasks: `task-master expand --all`

4. **Implementation**
   - Work Task Master backlog
   - Update docs as behavior changes

5. **QA & Release**
   - Run `pytest`, update CHANGELOG, release
