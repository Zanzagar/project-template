# Claude Code Hooks

Hooks are shell scripts that run automatically during Claude Code's workflow, enabling automation, validation, and guardrails.

## Quick Start

1. **Enable a preset with hooks:**
   ```
   /settings safe
   ```

2. **Or manually copy the example settings:**
   ```bash
   cp .claude/hooks/settings-example.json .claude/settings.local.json
   ```

3. **Restart Claude Code** for changes to take effect.

## Available Hook Scripts

This template includes eight ready-to-use hooks in `.claude/hooks/`:

### pre-commit-check.sh
**Event:** PreToolUse (matcher: "Bash")
**Purpose:** Validates code before git commits

- Runs linter (ruff) if available
- Runs tests (pytest) if available
- Checks for debug statements (pdb, breakpoint, console.log)
- Scans for hardcoded secrets
- **Blocks** commit if validation fails

### post-edit-format.sh
**Event:** PostToolUse (matcher: "Edit|Write")
**Purpose:** Auto-formats files after Claude edits them

Supports:
- Python (ruff)
- JavaScript/TypeScript (prettier)
- Go (gofmt)
- Rust (rustfmt)
- Shell (shfmt)

### protect-sensitive-files.sh
**Event:** PreToolUse (matcher: "Edit|Write")
**Purpose:** Prevents Claude from editing sensitive files

Blocks edits to:
- `.env`, `.env.local`, `.env.production`
- `credentials.json`, `secrets.json`
- Private keys (`*.pem`, `*.key`, `id_rsa`)
- Protected directories (`.git`, `node_modules`, `__pycache__`)

### session-end.sh
**Event:** Stop
**Purpose:** Generates detailed session summary for cross-session continuity

Captures on session end:
- Git branch, recent commits, modified files, diff stats
- Task Master progress (in-progress and pending tasks)
- Writes to `.claude/sessions/session-summary-YYYYMMDD-HHMMSS.md`

Only fires on `end_turn` stop reason (not on tool errors or interrupts).

### session-summary.sh
**Event:** Stop
**Purpose:** Lightweight session activity logging

Creates entries in `.claude/logs/sessions.log` with:
- Timestamp
- Stop reason
- Git changes summary

*Note: `session-end.sh` is the recommended replacement. It provides richer context for session reload.*

### pre-compact.sh
**Event:** UserPromptSubmit (auto) or manual
**Purpose:** Saves working state before context compaction

Preserves:
- Active Task Master task
- Current branch and uncommitted changes
- Placeholder for manual context notes

**Auto-trigger:** Fires when user message matches `/compact` or compact-related keywords.
**Manual trigger:** `./claude/hooks/pre-compact.sh`

Saved state is detected by `session-init.sh` on next session start.

### session-init.sh
**Event:** SessionStart
**Purpose:** Comprehensive project initialization and context loading

Detects five project scenarios:

| Scenario | Detection | Action |
|----------|-----------|--------|
| **New** | No src/, no Taskmaster, placeholder CLAUDE.md | Full setup guide |
| **Adopting** | Has code but no Taskmaster/state file | Integration steps |
| **Proto** | Has template-like structure but no sync tracking | Suggests official sync |
| **Upgrade** | Has state file but outdated version or missing components | Shows update command |
| **Existing** | Fully configured and current | Loads context |

Displays (for existing projects):
- Current Taskmaster task (if any)
- Uncommitted git changes
- Current branch (warns if on main)
- Critical issues and recommendations

Activates for projects with:
- `.claude/mcp-registry.json`, OR
- `.template/source` (sync tracking), OR
- Template-like structure (CLAUDE.md + .claude/commands or hooks)

### project-index.sh
**Event:** SessionStart
**Purpose:** Maintains a lightweight JSON index of codebase structure

Generates `.claude/project-index.json` containing:
- File paths and directory structure
- Import/export statements (with line numbers)
- Function and class signatures (with line numbers)

**Why this matters:**
- Sub-agents can understand codebase structure without loading full files
- Reduces context consumption during exploration
- Regenerates automatically if older than 5 minutes

**Token benefit:** Instead of reading 10 files to understand structure (~5-10k tokens), reference the index (~500-1k tokens).

Supports: Python, TypeScript, JavaScript

## Configuration

Hooks are configured in settings files. Create `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-commit-check.sh",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

### Settings File Precedence

1. `~/.claude/settings.json` - User global (all projects)
2. `.claude/settings.json` - Project (committed)
3. `.claude/settings.local.json` - Project local (gitignored)

Later files override earlier ones.

## Hook Events Reference

| Event | Trigger | Can Block? | Use Cases |
|-------|---------|------------|-----------|
| `PreToolUse` | Before tool execution | Yes | Validation, protection |
| `PostToolUse` | After tool completes | No | Formatting, logging |
| `UserPromptSubmit` | User sends message | Yes | Input validation |
| `Stop` | Claude finishes | No | Logging, cleanup |
| `SubagentStop` | Subagent finishes | No | Logging |
| `Notification` | Notifications sent | No | Custom alerts |
| `SessionStart` | Session begins | No | Context loading |
| `SessionEnd` | Session ends | No | Cleanup |

## Matchers

For `PreToolUse` and `PostToolUse`, use regex matchers:

| Pattern | Matches |
|---------|---------|
| `"Bash"` | Bash tool only |
| `"Edit\|Write"` | Edit or Write tools |
| `"mcp__*"` | All MCP tools |
| `".*"` | Any tool |

## Exit Codes

For blocking events (`PreToolUse`, `UserPromptSubmit`):

| Code | Meaning |
|------|---------|
| `0` | Allow the action |
| `2` | Block the action |
| `1` | Warning (doesn't block) |

## Environment Variables

Available in all hooks:
- `$CLAUDE_PROJECT_DIR` - Absolute path to project root

## Input/Output

Hooks receive JSON via stdin:

```json
{
  "session_id": "abc123",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/path/to/file.py",
    "old_string": "...",
    "new_string": "..."
  }
}
```

Write to stdout/stderr for feedback shown to Claude.

## Creating Custom Hooks

1. Create script in `.claude/hooks/`:
   ```bash
   #!/bin/bash
   INPUT=$(cat)
   # Your logic here
   exit 0  # or exit 2 to block
   ```

2. Make executable:
   ```bash
   chmod +x .claude/hooks/my-hook.sh
   ```

3. Add to settings:
   ```json
   {
     "hooks": {
       "PreToolUse": [{
         "matcher": "Bash",
         "hooks": [{
           "type": "command",
           "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/my-hook.sh"
         }]
       }]
     }
   }
   ```

## Security Considerations

⚠️ **Hooks execute shell commands automatically.** Review any hook scripts before enabling:

- Don't blindly copy hooks from untrusted sources
- Test hooks manually first
- Use absolute paths (`$CLAUDE_PROJECT_DIR`)
- Validate inputs from stdin

## Settings Presets

Use `/settings` to quickly configure common hook combinations:

| Preset | Hooks Enabled |
|--------|--------------|
| `fast` | None |
| `thorough` | Pre-commit check, session-init, session-end |
| `safe` | Pre-commit + file protection, session-init, session-end |
| `autoformat` | Post-edit formatting |
| `optimized` | Session-init, pre-compact, session-end |

See `.claude/settings-presets.json` for full configurations.

## Troubleshooting

### Hook not running
- Check settings file syntax (valid JSON)
- Verify matcher pattern matches the tool
- Ensure script is executable (`chmod +x`)
- Restart Claude Code after changes

### Hook blocking unexpectedly
- Test script manually with sample input
- Check exit codes in your script
- Review stdout/stderr for error messages

### Testing a hook
```bash
echo '{"tool_input":{"file_path":"test.py"}}' | .claude/hooks/your-hook.sh
echo $?  # Check exit code
```
