#!/usr/bin/env bash
# suggest-compact.sh — Suggests context compaction at optimal times
# Trigger: UserPromptSubmit (lightweight, runs on every prompt)
#
# Checks tool call count via session state and suggests compaction
# at phase transitions or after significant exploration.
#
# This hook is advisory — it prints a suggestion, not a command.

set -euo pipefail

SESSIONS_DIR="${PROJECT_DIR:-.}/.claude/sessions"
COMPACT_STATE="${SESSIONS_DIR}/compact-state.tmp"

# Ensure sessions directory exists
mkdir -p "$SESSIONS_DIR"

# Initialize or read tool call counter
if [ -f "$COMPACT_STATE" ]; then
    TOOL_CALLS=$(cat "$COMPACT_STATE" 2>/dev/null || echo "0")
else
    TOOL_CALLS=0
fi

# Increment counter
TOOL_CALLS=$((TOOL_CALLS + 1))
echo "$TOOL_CALLS" > "$COMPACT_STATE"

# Suggest compaction at thresholds
# These are advisory — the user/Claude decides whether to act
if [ "$TOOL_CALLS" -eq 50 ]; then
    echo "💡 Context check: ~50 tool calls this session. If quality is declining, consider /compact or starting fresh."
elif [ "$TOOL_CALLS" -eq 75 ]; then
    echo "💡 Context note: ~75 tool calls. Watch for signs of quality degradation (forgetting, contradicting, declining output)."
elif [ "$TOOL_CALLS" -eq 100 ]; then
    echo "💡 High context usage: ~100 tool calls. Strongly consider compacting or starting a fresh session."
fi

# Reset counter if session-end runs (detected by absence of state file on next start)
