# Chat Scripts (Copy/Paste)

Adapt these prompts when coordinating in Cursor/Codex/Task Master.

## Docs Phase
```
Draft a PRD for <scope>. Include Overview, Core Features, Architecture, Acceptance Criteria, Sources, Metrics, Out of Scope, Glossary.
```

```
Summarize guardrails for <system> and map them to source files in docs/GUARDRAILS.md.
```

## Codex Prep
```
Confirm Codex CLI + Task Master install. Show `codex --version` and config path (read-only).
```

```
Document how to set Task Master main model to gpt-5-codex. Do not run the command now.
```

## Task Master Phase
```
Parse each PRD into its own tag (<primary_tag>, etc.) and stop after parsing.
```

```
Analyze current tag, cite sources, expand tasks with tool mode standard.
```

```
For subtask <id>, outline plan (files, functions, risks), mark in-progress, append notes, and record tests.
```

```
Update task statuses and summarize blockers.
```
