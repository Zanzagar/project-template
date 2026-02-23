#!/bin/bash
# start-observer.sh - Background observer agent for Continuous Learning v2
# Adapted from ECC (affaan-m/everything-claude-code)
#
# Starts a background agent that analyzes observations and creates instincts.
# Uses Haiku model for cost efficiency.
#
# Usage:
#   scripts/start-observer.sh        # Start observer in background
#   scripts/start-observer.sh stop   # Stop running observer
#   scripts/start-observer.sh status # Check if observer is running

set -e

# Project-scoped paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_ROOT/.claude/instincts"
PID_FILE="$CONFIG_DIR/.observer.pid"
LOG_FILE="$CONFIG_DIR/observer.log"
OBSERVATIONS_FILE="$CONFIG_DIR/observations.jsonl"
PERSONAL_DIR="$CONFIG_DIR/personal"

mkdir -p "$CONFIG_DIR" "$PERSONAL_DIR"

case "${1:-start}" in
    stop)
        if [ -f "$PID_FILE" ]; then
            pid=$(cat "$PID_FILE")
            if kill -0 "$pid" 2>/dev/null; then
                echo "Stopping observer (PID: $pid)..."
                kill "$pid"
                rm -f "$PID_FILE"
                echo "Observer stopped."
            else
                echo "Observer not running (stale PID file)."
                rm -f "$PID_FILE"
            fi
        else
            echo "Observer not running."
        fi
        exit 0
        ;;

    status)
        if [ -f "$PID_FILE" ]; then
            pid=$(cat "$PID_FILE")
            if kill -0 "$pid" 2>/dev/null; then
                echo "Observer is running (PID: $pid)"
                echo "Log: $LOG_FILE"
                echo "Observations: $(wc -l < "$OBSERVATIONS_FILE" 2>/dev/null || echo 0) lines"
                exit 0
            else
                echo "Observer not running (stale PID file)"
                rm -f "$PID_FILE"
                exit 1
            fi
        else
            echo "Observer not running"
            exit 1
        fi
        ;;

    start)
        # Check if already running via PID file
        if [ -f "$PID_FILE" ]; then
            pid=$(cat "$PID_FILE")
            if kill -0 "$pid" 2>/dev/null; then
                echo "Observer already running (PID: $pid)"
                exit 0
            fi
            rm -f "$PID_FILE"
        fi

        # Kill any orphaned observers (PID file lost but process still running)
        for orphan_pid in $(pgrep -f "start-observer.sh" 2>/dev/null); do
            [ "$orphan_pid" != "$$" ] && kill "$orphan_pid" 2>/dev/null || true
        done
        sleep 0.5

        echo "Starting observer agent..."

        # The observer loop
        (
            trap 'rm -f "$PID_FILE"; exit 0' TERM INT

            analyze_observations() {
                # Only analyze if observations file exists and has enough entries
                if [ ! -f "$OBSERVATIONS_FILE" ]; then
                    return
                fi
                obs_count=$(wc -l < "$OBSERVATIONS_FILE" 2>/dev/null || echo 0)
                if [ "$obs_count" -lt 20 ]; then
                    return
                fi

                echo "[$(date)] Analyzing $obs_count observations..." >> "$LOG_FILE"

                # Use Claude Code with Haiku to analyze observations
                # Must unset CLAUDECODE to avoid nested-session detection when
                # observer is started from within a Claude Code session (via session-init.sh)
                # Count instincts before analysis to detect if new ones were created
                local before_count
                before_count=$(find "$PERSONAL_DIR" -name "*.md" -o -name "*.json" 2>/dev/null | wc -l)

                if command -v claude &> /dev/null; then
                    exit_code=0
                    CLAUDECODE= claude --model haiku --max-turns 15 --allowedTools "Read,Write,Glob" --print \
                        "You are an autonomous background agent. Do NOT ask questions or request permission — act immediately. Read the last 100 lines of $OBSERVATIONS_FILE (use Read with offset if large). Identify tool usage patterns with 3+ occurrences. For each pattern found, immediately Write a JSON file to $PERSONAL_DIR/<pattern-id>.json with fields: id, pattern, action, trigger, confidence (0.3-0.7), domain, source. Create at most 3 instinct files. Do not explain — just read and write." \
                        >> "$LOG_FILE" 2>&1 || exit_code=$?
                    if [ "$exit_code" -ne 0 ]; then
                        echo "[$(date)] Claude analysis failed (exit $exit_code)" >> "$LOG_FILE"
                        return  # Don't archive — analysis didn't process them
                    fi
                else
                    echo "[$(date)] claude CLI not found, skipping analysis" >> "$LOG_FILE"
                    return  # Don't archive without analysis
                fi

                # Verify instincts were actually created (not just max-turns exit)
                local after_count
                after_count=$(find "$PERSONAL_DIR" -name "*.md" -o -name "*.json" 2>/dev/null | wc -l)

                if [ "$after_count" -le "$before_count" ]; then
                    echo "[$(date)] Analysis ran but created no instincts (before=$before_count, after=$after_count) — keeping observations for retry" >> "$LOG_FILE"
                    return  # Don't archive — nothing was produced
                fi

                echo "[$(date)] Created $((after_count - before_count)) instinct(s)" >> "$LOG_FILE"

                # Archive only after verified instinct creation
                if [ -f "$OBSERVATIONS_FILE" ]; then
                    archive_dir="$CONFIG_DIR/observations.archive"
                    mkdir -p "$archive_dir"
                    mv "$OBSERVATIONS_FILE" "$archive_dir/processed-$(date +%Y%m%d-%H%M%S).jsonl" 2>/dev/null || true
                    touch "$OBSERVATIONS_FILE"
                fi
            }

            # Handle SIGUSR1 for on-demand analysis
            trap 'analyze_observations' USR1

            echo "$BASHPID" > "$PID_FILE"
            echo "[$(date)] Observer started (PID: $$)" >> "$LOG_FILE"

            while true; do
                # Check every 5 minutes
                sleep 300
                analyze_observations
            done
        ) &

        disown

        # Wait a moment for PID file
        sleep 1

        if [ -f "$PID_FILE" ]; then
            echo "Observer started (PID: $(cat "$PID_FILE"))"
            echo "Log: $LOG_FILE"
        else
            echo "Failed to start observer"
            exit 1
        fi
        ;;

    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
