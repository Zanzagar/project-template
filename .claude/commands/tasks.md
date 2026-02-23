List Taskmaster tasks for the current or specified tag.

Usage:
- `/tasks` — list tasks for current tag
- `/tasks <tag-name>` — list tasks for a specific tag
- `/tasks ready` — show only actionable tasks (dependencies satisfied)
- `/tasks blocking` — show tasks on the critical path
- `/tasks compact` — minimal one-line output (fewer tokens)

If no tag specified, uses current tag from `.taskmaster/state.json`.

Execute based on arguments:

If `$ARGUMENTS` is "ready":
```bash
task-master list --ready
```

If `$ARGUMENTS` is "blocking":
```bash
task-master list --blocking
```

If `$ARGUMENTS` is "compact":
```bash
task-master list -c
```

Otherwise (tag name or empty):
```bash
task-master list --tag $ARGUMENTS --with-subtasks
```
