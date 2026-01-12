#!/bin/bash
# session-init.sh - Comprehensive project initialization and health check
# Hook type: SessionStart
# Triggers when: A new Claude Code session begins
#
# This hook:
# 1. Detects project state (new, adopting, existing)
# 2. Checks for critical setup gaps
# 3. Loads relevant context for the session
# 4. Provides actionable next steps

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATE_FILE="$PROJECT_DIR/.claude/project-state.json"
MCP_CONFIG="$PROJECT_DIR/.claude/mcp-project.json"
REGISTRY="$PROJECT_DIR/.claude/mcp-registry.json"
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"
TASKMASTER_DIR="$PROJECT_DIR/.taskmaster"
TEMPLATE_VERSION_FILE="$PROJECT_DIR/.template/version"
TEMPLATE_SOURCE_FILE="$PROJECT_DIR/.template/source"
SYNC_SCRIPT="$PROJECT_DIR/scripts/sync-template.sh"

# Current template version (update when releasing new versions)
CURRENT_TEMPLATE_VERSION="2.0.0"

# Only run for projects using this template
# Check for registry OR template tracking OR resembling structure
HAS_REGISTRY=false
HAS_TEMPLATE_TRACKING=false
HAS_TEMPLATE_STRUCTURE=false

[ -f "$REGISTRY" ] && HAS_REGISTRY=true
[ -f "$TEMPLATE_SOURCE_FILE" ] && HAS_TEMPLATE_TRACKING=true

# Check for template-like structure (proto-template detection)
if [ -f "$CLAUDE_MD" ] && [ -d "$PROJECT_DIR/.claude" ]; then
    # Has CLAUDE.md and .claude/ directory - likely template-based
    if [ -d "$PROJECT_DIR/.claude/commands" ] || [ -d "$PROJECT_DIR/.claude/hooks" ]; then
        HAS_TEMPLATE_STRUCTURE=true
    fi
fi

# Exit if this doesn't look like a template project at all
if [ "$HAS_REGISTRY" = false ] && [ "$HAS_TEMPLATE_TRACKING" = false ] && [ "$HAS_TEMPLATE_STRUCTURE" = false ]; then
    exit 0
fi

# Collect project state
HAS_STATE_FILE=false
HAS_MCP_CONFIG=false
HAS_TASKMASTER=false
HAS_CUSTOMIZED_CLAUDE_MD=false
HAS_SRC=false
HAS_UNCOMMITTED=false
HAS_SYNC_SCRIPT=false
CURRENT_BRANCH=""
CURRENT_TASK=""
INSTALLED_VERSION=""
MISSING_COMPONENTS=()

[ -f "$STATE_FILE" ] && HAS_STATE_FILE=true
[ -f "$MCP_CONFIG" ] && HAS_MCP_CONFIG=true
[ -d "$TASKMASTER_DIR" ] && HAS_TASKMASTER=true
[ -d "$PROJECT_DIR/src" ] && HAS_SRC=true
[ -f "$SYNC_SCRIPT" ] && HAS_SYNC_SCRIPT=true

# Get installed template version
if [ -f "$TEMPLATE_VERSION_FILE" ]; then
    INSTALLED_VERSION=$(cat "$TEMPLATE_VERSION_FILE" 2>/dev/null | tr -d '[:space:]')
fi

# Check for missing template components
[ ! -f "$REGISTRY" ] && MISSING_COMPONENTS+=("mcp-registry.json")
[ ! -d "$PROJECT_DIR/.claude/hooks" ] && MISSING_COMPONENTS+=("hooks/")
[ ! -d "$PROJECT_DIR/.claude/commands" ] && MISSING_COMPONENTS+=("commands/")
[ ! -f "$SYNC_SCRIPT" ] && MISSING_COMPONENTS+=("sync-template.sh")

# Check if CLAUDE.md has been customized (not still placeholder)
if [ -f "$CLAUDE_MD" ]; then
    if ! grep -q "\[PROJECT_NAME\]" "$CLAUDE_MD" 2>/dev/null; then
        HAS_CUSTOMIZED_CLAUDE_MD=true
    fi
fi

# Git status
if [ -d "$PROJECT_DIR/.git" ]; then
    CURRENT_BRANCH=$(cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "")
    UNCOMMITTED=$(cd "$PROJECT_DIR" && git status --porcelain 2>/dev/null | head -5)
    [ -n "$UNCOMMITTED" ] && HAS_UNCOMMITTED=true
fi

# Get current Taskmaster task if available
if [ "$HAS_TASKMASTER" = true ] && command -v task-master &> /dev/null; then
    CURRENT_TASK=$(cd "$PROJECT_DIR" && task-master next 2>/dev/null | head -3 || echo "")
fi

# Determine project scenario
# Priority: upgrade > proto > adopting > new > existing
SCENARIO="existing"

# Check for version mismatch (needs upgrade)
NEEDS_UPGRADE=false
if [ -n "$INSTALLED_VERSION" ] && [ "$INSTALLED_VERSION" != "$CURRENT_TEMPLATE_VERSION" ]; then
    NEEDS_UPGRADE=true
fi

# Check for missing components (partial installation)
HAS_MISSING_COMPONENTS=false
if [ ${#MISSING_COMPONENTS[@]} -gt 0 ]; then
    HAS_MISSING_COMPONENTS=true
fi

# Scenario logic
# Priority: upgrade (if has tracking) > proto > adopting > new > existing

# First: Check for upgrade (has template tracking but outdated/incomplete)
if [ "$HAS_TEMPLATE_TRACKING" = true ] && { [ "$NEEDS_UPGRADE" = true ] || [ "$HAS_MISSING_COMPONENTS" = true ]; }; then
    SCENARIO="upgrade"
# Second: No state file - determine if new, adopting, or proto
elif [ "$HAS_STATE_FILE" = false ]; then
    if [ "$HAS_TEMPLATE_STRUCTURE" = true ] && [ "$HAS_TEMPLATE_TRACKING" = false ]; then
        # Has template-like structure but wasn't synced - proto-template
        SCENARIO="proto"
    elif [ "$HAS_SRC" = false ] && [ "$HAS_TASKMASTER" = false ]; then
        SCENARIO="new"
    else
        SCENARIO="adopting"
    fi
fi
# Default: existing (has state file and is current)

# Build output based on scenario
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│  Project Status                                             │"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Critical issues first
CRITICAL_ISSUES=()
SETUP_NEEDED=()
RECOMMENDATIONS=()

# Check Taskmaster
if [ "$HAS_TASKMASTER" = false ]; then
    CRITICAL_ISSUES+=("Taskmaster not initialized")
    SETUP_NEEDED+=("Run: task-master init")
fi

# Check CLAUDE.md customization
if [ "$HAS_CUSTOMIZED_CLAUDE_MD" = false ]; then
    SETUP_NEEDED+=("Customize CLAUDE.md with project details")
fi

# Check MCP configuration
if [ "$HAS_MCP_CONFIG" = false ]; then
    RECOMMENDATIONS+=("Configure MCPs for your project type: /mcps")
fi

# Check git branch (should not be on main for active development)
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    RECOMMENDATIONS+=("Create a feature branch before making changes")
fi

# Output scenario-specific guidance
case $SCENARIO in
    new)
        echo "📦 NEW PROJECT DETECTED"
        echo ""
        echo "This appears to be a fresh project. Recommended setup:"
        echo ""
        echo "  1. Update CLAUDE.md with your project name and details"
        echo "  2. Initialize Taskmaster: task-master init"
        echo "  3. Create a PRD in .taskmaster/docs/prd.txt"
        echo "  4. Generate tasks: task-master parse-prd"
        echo "  5. Configure MCPs: /mcps"
        echo ""
        ;;
    proto)
        echo "🔍 PROTO-TEMPLATE DETECTED"
        echo ""
        echo "This project has template-like structure but wasn't officially synced."
        echo "This could be an older template version or manual setup."
        echo ""
        echo "To fully integrate the latest template:"
        echo ""
        if [ "$HAS_SYNC_SCRIPT" = true ]; then
            echo "  ./scripts/sync-template.sh adopt"
        else
            echo "  1. Get sync script: curl -O https://raw.githubusercontent.com/[your-org]/project-template/main/scripts/sync-template.sh"
            echo "  2. Run: ./scripts/sync-template.sh adopt --git [template-url]"
        fi
        echo ""
        echo "Missing components: ${MISSING_COMPONENTS[*]:-none detected}"
        echo ""
        ;;
    upgrade)
        echo "⬆️  TEMPLATE UPDATE AVAILABLE"
        echo ""
        if [ -n "$INSTALLED_VERSION" ]; then
            echo "Installed: v$INSTALLED_VERSION → Latest: v$CURRENT_TEMPLATE_VERSION"
        fi
        if [ "$HAS_MISSING_COMPONENTS" = true ]; then
            echo "Missing components: ${MISSING_COMPONENTS[*]}"
            echo ""
            echo "To get all new features:"
            echo "  ./scripts/sync-template.sh sync --all"
            echo ""
            echo "Or selectively add:"
            echo "  ./scripts/sync-template.sh sync --hooks    # Add automation hooks"
            echo "  ./scripts/sync-template.sh sync --commands # Add new slash commands"
        else
            echo ""
            echo "To update:"
            echo "  ./scripts/sync-template.sh update"
        fi
        echo ""
        echo "Preview changes first:"
        echo "  ./scripts/sync-template.sh sync --all --dry-run"
        echo ""
        ;;
    adopting)
        echo "🔄 EXISTING PROJECT - TEMPLATE INTEGRATION"
        echo ""
        echo "Integrating template into existing project. Setup needed:"
        echo ""
        if [ "$HAS_TASKMASTER" = false ]; then
            echo "  • Initialize Taskmaster: task-master init"
        fi
        if [ "$HAS_CUSTOMIZED_CLAUDE_MD" = false ]; then
            echo "  • Update CLAUDE.md with your project details"
        fi
        if [ "$HAS_MCP_CONFIG" = false ]; then
            echo "  • Configure MCPs for project type: /mcps"
        fi
        echo ""
        echo "Your existing code will not be modified."
        echo ""
        ;;
    existing)
        # For existing projects, show context loading
        if [ -n "$CURRENT_TASK" ]; then
            echo "📋 Current Task:"
            echo "$CURRENT_TASK"
            echo ""
        fi

        if [ "$HAS_UNCOMMITTED" = true ]; then
            echo "⚠️  Uncommitted changes detected:"
            echo "$UNCOMMITTED"
            echo ""
        fi

        if [ -n "$CURRENT_BRANCH" ]; then
            echo "🌿 Branch: $CURRENT_BRANCH"
            echo ""
        fi
        ;;
esac

# Show critical issues if any
if [ ${#CRITICAL_ISSUES[@]} -gt 0 ]; then
    echo "❌ CRITICAL:"
    for issue in "${CRITICAL_ISSUES[@]}"; do
        echo "   • $issue"
    done
    echo ""
fi

# Show setup items if any (for new/adopting/proto)
if [ ${#SETUP_NEEDED[@]} -gt 0 ] && [ "$SCENARIO" != "existing" ] && [ "$SCENARIO" != "upgrade" ]; then
    echo "📝 Setup needed:"
    for item in "${SETUP_NEEDED[@]}"; do
        echo "   • $item"
    done
    echo ""
fi

# Show recommendations if any
if [ ${#RECOMMENDATIONS[@]} -gt 0 ]; then
    echo "💡 Recommendations:"
    for rec in "${RECOMMENDATIONS[@]}"; do
        echo "   • $rec"
    done
    echo ""
fi

# Quick commands reminder
case $SCENARIO in
    existing)
        echo "Quick commands: /tasks | /commit | /test | /lint"
        ;;
    upgrade)
        echo "Quick commands: /health | ./scripts/sync-template.sh status"
        ;;
esac

exit 0
