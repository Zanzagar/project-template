# Chat Scripts (Copy/Paste)

Useful prompts for Claude Code and Task Master workflows.

## Documentation Phase
```
Draft a PRD for <scope>. Include Overview, Core Features, Architecture, Acceptance Criteria, Sources, Metrics, Out of Scope, Glossary.
```

```
Summarize guardrails for <system> and map them to source files in docs/GUARDRAILS.md.
```

## Task Master Phase
```
Parse the PRD and generate tasks:
task-master parse-prd --file .taskmaster/docs/prd_primary.txt
```

```
Analyze task complexity and expand into subtasks:
task-master analyze-complexity --research
task-master expand --all
```

```
Show current tasks and recommend next action:
task-master list
task-master next
```

## Implementation
```
For task <id>, outline plan (files, functions, risks), then implement.
```

```
Mark task complete and update any affected documentation:
task-master set-status --id=<id> --status=done
```
