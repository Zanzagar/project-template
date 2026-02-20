#!/bin/bash
# init-project.sh - Initialize local .claude/ structure for command/skill registration
# Version: 1.0.0
#
# Usage:
#   ./scripts/init-project.sh [options]
#
# Options:
#   --mode symlink|copy   Override auto-detection (default: auto)
#   --template PATH       Template source path (default: auto-detect or ~/projects/project-template)
#   --dry-run             Preview changes without applying
#   --force               Recreate even if dirs already exist
#   --help                Show this help
#
# Auto-detection:
#   - If a parent directory contains .claude/commands/ with >10 files, uses symlinks
#   - Otherwise, copies from --template path
#
# What it creates in local .claude/:
#   commands/   - Slash commands (/health, /commit, etc.)
#   skills/     - Skills (/code-review, /debugging, etc.)
#   agents/     - Sub-agent definitions (planner, code-reviewer, etc.)
#   contexts/   - Context modes (dev, review, research)
#   hooks/      - Automation hooks (session-init, pre-commit, etc.)
#
# What it does NOT touch:
#   instincts/  - User-specific learned patterns
#   sessions/   - Runtime session data
#   plugins/    - User-installed plugins
#
# Note on rules/:
#   Rules inherit from parent directories in Claude Code, so nested projects
#   don't need local copies. However, standalone projects (copy mode) DO need
#   rules copied locally since there's no parent to inherit from.

set -e

# --- Constants ---

# Directories to initialize (order doesn't matter)
# rules/ is included because standalone projects need them (no parent inheritance)
TARGET_DIRS=("rules" "commands" "skills" "agents" "contexts" "hooks")

# Minimum command count to identify a directory as a template
MIN_TEMPLATE_COMMANDS=10

# Max parent levels to walk when auto-detecting
MAX_PARENT_DEPTH=5

# Default template path (can be overridden by --template or $TEMPLATE_PATH)
DEFAULT_TEMPLATE_PATH="$HOME/projects/project-template"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- State ---
MODE="auto"          # auto | symlink | copy
TEMPLATE_PATH="${TEMPLATE_PATH:-$DEFAULT_TEMPLATE_PATH}"
TEMPLATE_DETECTED=""  # Set by auto-detection
FORCE=false
DRY_RUN=false
PROJECT_DIR="$PWD"

# Counters for summary
CREATED=0
SKIPPED=0
WARNED=0

# --- Helper Functions ---

show_usage() {
    head -30 "$0" | tail -n +2 | sed 's/^# \?//'
}

log_info() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARNED=$((WARNED + 1))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_skip() {
    echo -e "${DIM}[SKIP]${NC} $1"
    SKIPPED=$((SKIPPED + 1))
}

log_create() {
    echo -e "${GREEN}[CREATE]${NC} $1"
    CREATED=$((CREATED + 1))
}

log_dry() {
    echo -e "${BLUE}[DRY-RUN]${NC} $1"
}

# --- Auto-Detection ---

# Walk parent directories looking for a template with >MIN_TEMPLATE_COMMANDS commands
find_template_parent() {
    local dir="$PROJECT_DIR"
    local depth=0

    while [ "$depth" -lt "$MAX_PARENT_DEPTH" ] && [ "$dir" != "/" ]; do
        dir="$(dirname "$dir")"
        depth=$((depth + 1))

        if [ -d "$dir/.claude/commands" ]; then
            local cmd_count
            cmd_count=$(find "$dir/.claude/commands" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l)
            if [ "$cmd_count" -gt "$MIN_TEMPLATE_COMMANDS" ]; then
                echo "$dir"
                return 0
            fi
        fi
    done
    return 1
}

# Determine mode and template path
auto_detect() {
    if [ "$MODE" != "auto" ]; then
        # Mode explicitly set, validate template path
        if [ ! -d "$TEMPLATE_PATH/.claude" ]; then
            log_error "Template not found at: $TEMPLATE_PATH"
            log_error "Use --template PATH to specify the template location"
            exit 1
        fi
        return
    fi

    # Try to find a template parent
    local parent
    if parent=$(find_template_parent); then
        MODE="symlink"
        TEMPLATE_DETECTED="$parent"
        TEMPLATE_PATH="$parent"
    elif [ -d "$TEMPLATE_PATH/.claude" ]; then
        MODE="copy"
    else
        log_error "Could not auto-detect template parent directory"
        log_error "And default template path not found: $TEMPLATE_PATH"
        echo ""
        echo "Options:"
        echo "  1. Run from within a project nested under the template directory"
        echo "  2. Set TEMPLATE_PATH environment variable"
        echo "  3. Use --template /path/to/project-template"
        exit 1
    fi
}

# --- Symlink Creation ---

# Calculate relative path from source to target
calc_relative_path() {
    python3 -c "import os.path; print(os.path.relpath('$1', '$2'))"
}

# Create symlinks from project .claude/ to template .claude/
create_symlinks() {
    local template_dir="$1"

    for subdir in "${TARGET_DIRS[@]}"; do
        local target="$template_dir/.claude/$subdir"
        local link="$PROJECT_DIR/.claude/$subdir"

        if [ ! -d "$target" ]; then
            log_skip "$subdir/ (not in template)"
            continue
        fi

        if [ -L "$link" ]; then
            if [ "$FORCE" = true ]; then
                if [ "$DRY_RUN" = true ]; then
                    log_dry "Would recreate symlink: $subdir/"
                else
                    rm "$link"
                    local rel_path
                    rel_path=$(calc_relative_path "$target" "$PROJECT_DIR/.claude")
                    ln -s "$rel_path" "$link"
                    log_create "$subdir/ -> $rel_path (recreated)"
                fi
            else
                log_skip "$subdir/ (symlink exists -> $(readlink "$link"))"
            fi
            continue
        fi

        if [ -d "$link" ]; then
            if [ "$FORCE" = true ]; then
                if [ "$DRY_RUN" = true ]; then
                    log_dry "Would replace directory with symlink: $subdir/"
                else
                    rm -rf "$link"
                    local rel_path
                    rel_path=$(calc_relative_path "$target" "$PROJECT_DIR/.claude")
                    ln -s "$rel_path" "$link"
                    log_create "$subdir/ -> $rel_path (replaced directory)"
                fi
            else
                log_warn "$subdir/ exists as directory (may shadow template — use --force to replace with symlink)"
            fi
            continue
        fi

        # Create new symlink
        if [ "$DRY_RUN" = true ]; then
            local rel_path
            rel_path=$(calc_relative_path "$target" "$PROJECT_DIR/.claude")
            log_dry "Would create symlink: $subdir/ -> $rel_path"
        else
            local rel_path
            rel_path=$(calc_relative_path "$target" "$PROJECT_DIR/.claude")
            ln -s "$rel_path" "$link"
            log_create "$subdir/ -> $rel_path"
        fi
    done
}

# --- Copy Mode ---

# Copy directories from template to project
copy_dirs() {
    local template_dir="$1"

    for subdir in "${TARGET_DIRS[@]}"; do
        local source="$template_dir/.claude/$subdir"
        local dest="$PROJECT_DIR/.claude/$subdir"

        if [ ! -d "$source" ]; then
            log_skip "$subdir/ (not in template)"
            continue
        fi

        if [ -L "$dest" ]; then
            if [ "$FORCE" = true ]; then
                if [ "$DRY_RUN" = true ]; then
                    log_dry "Would replace symlink with copy: $subdir/"
                else
                    rm "$dest"
                    cp -r "$source" "$dest"
                    local count
                    count=$(find "$dest" -type f | wc -l)
                    log_create "$subdir/ ($count files copied, replaced symlink)"
                fi
            else
                log_skip "$subdir/ (symlink exists -> $(readlink "$dest"))"
            fi
            continue
        fi

        if [ -d "$dest" ]; then
            if [ "$FORCE" = true ]; then
                if [ "$DRY_RUN" = true ]; then
                    log_dry "Would replace directory: $subdir/"
                else
                    rm -rf "$dest"
                    cp -r "$source" "$dest"
                    local count
                    count=$(find "$dest" -type f | wc -l)
                    log_create "$subdir/ ($count files copied, replaced existing)"
                fi
            else
                log_skip "$subdir/ (directory exists — use --force to replace)"
            fi
            continue
        fi

        # Copy new
        if [ "$DRY_RUN" = true ]; then
            local count
            count=$(find "$source" -type f | wc -l)
            log_dry "Would copy: $subdir/ ($count files)"
        else
            cp -r "$source" "$dest"
            local count
            count=$(find "$dest" -type f | wc -l)
            log_create "$subdir/ ($count files copied)"
        fi
    done
}

# --- Security Checks ---

# Verify symlink targets don't escape the template tree
verify_symlink_safety() {
    local template_dir="$1"
    local template_real
    template_real=$(realpath "$template_dir")

    for subdir in "${TARGET_DIRS[@]}"; do
        local link="$PROJECT_DIR/.claude/$subdir"
        if [ -L "$link" ]; then
            local target_real
            target_real=$(realpath "$link" 2>/dev/null || echo "BROKEN")
            if [ "$target_real" = "BROKEN" ]; then
                log_warn "$subdir/ symlink is broken"
            elif [[ "$target_real" != "$template_real"* ]]; then
                log_warn "$subdir/ symlink points outside template tree: $target_real"
            fi
        fi
    done
}

# --- Main ---

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --template) TEMPLATE_PATH="$2"; shift ;;
        --mode)
            if [[ "$2" != "symlink" && "$2" != "copy" ]]; then
                log_error "Invalid mode: $2 (must be 'symlink' or 'copy')"
                exit 1
            fi
            MODE="$2"; shift
            ;;
        --force) FORCE=true ;;
        --dry-run) DRY_RUN=true ;;
        --help|-h) show_usage; exit 0 ;;
        *) log_error "Unknown parameter: $1"; show_usage; exit 1 ;;
    esac
    shift
done

# Header
echo -e "${BLUE}${BOLD}init-project.sh v1.0.0${NC}"
echo "========================"
echo ""

# Auto-detect mode and template
auto_detect

echo -e "Mode:     ${BOLD}$MODE${NC}"
echo -e "Template: ${BOLD}$TEMPLATE_PATH${NC}"
echo -e "Project:  ${BOLD}$PROJECT_DIR${NC}"
if [ -n "$TEMPLATE_DETECTED" ]; then
    echo -e "Detected: ${GREEN}Parent template found at $TEMPLATE_DETECTED${NC}"
fi
if [ "$DRY_RUN" = true ]; then
    echo -e "          ${YELLOW}(dry-run — no changes will be made)${NC}"
fi
if [ "$FORCE" = true ]; then
    echo -e "          ${YELLOW}(force — existing dirs will be replaced)${NC}"
fi
echo ""

# Ensure .claude/ exists
if [ ! -d "$PROJECT_DIR/.claude" ]; then
    if [ "$DRY_RUN" = true ]; then
        log_dry "Would create .claude/ directory"
    else
        mkdir -p "$PROJECT_DIR/.claude"
        log_info "Created .claude/ directory"
    fi
fi

# Execute based on mode
case $MODE in
    symlink)
        echo -e "${BOLD}Creating symlinks to template...${NC}"
        echo ""
        create_symlinks "$TEMPLATE_PATH"
        ;;
    copy)
        echo -e "${BOLD}Copying from template...${NC}"
        echo ""
        copy_dirs "$TEMPLATE_PATH"
        ;;
esac

# Security verification for symlinks
if [ "$MODE" = "symlink" ] && [ "$DRY_RUN" = false ]; then
    echo ""
    verify_symlink_safety "$TEMPLATE_PATH"
fi

# Summary
echo ""
echo -e "${BOLD}Summary:${NC}"
echo -e "  Created: ${GREEN}$CREATED${NC}"
echo -e "  Skipped: ${DIM}$SKIPPED${NC}"
echo -e "  Warnings: ${YELLOW}$WARNED${NC}"

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "Dry run complete. Run without --dry-run to apply changes."
fi

if [ "$CREATED" -gt 0 ] && [ "$DRY_RUN" = false ]; then
    echo ""
    echo -e "${GREEN}Done!${NC} Slash commands and skills should now be available."
    echo "Start a new Claude Code session to pick up the changes."
fi

exit 0
