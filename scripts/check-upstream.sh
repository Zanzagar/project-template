#!/bin/bash
# check-upstream.sh - Check all upstream sources for updates
#
# Compares current template state against upstream repos to identify
# changes worth reviewing. Run monthly or when planning updates.
#
# Usage: ./scripts/check-upstream.sh [--since YYYY-MM-DD] [--verbose]
#
# Upstreams tracked:
#   1. obra/superpowers           - Workflow enforcement plugin (14 skills)
#   2. affaan-m/everything-claude-code - ECC patterns (hooks, agents, commands)
#   3. anthropics/claude-plugins-official - Official Anthropic skills
#   4. task-master-ai (npm)       - Task management MCP server
#   5. wshobson/agents            - Plugin marketplace (65+ agents/skills)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Defaults
DEFAULT_SINCE="2026-02-22"  # Template v2.2.1 release date
SINCE="${DEFAULT_SINCE}"
VERBOSE=false

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --since) SINCE="$2"; shift 2 ;;
        --verbose) VERBOSE=true; shift ;;
        --help|-h)
            echo "Usage: $0 [--since YYYY-MM-DD] [--verbose]"
            echo ""
            echo "Check upstream repos for changes since a date (default: ${DEFAULT_SINCE})"
            echo ""
            echo "Options:"
            echo "  --since DATE    Check changes after this date (ISO 8601)"
            echo "  --verbose       Show commit messages, not just counts"
            echo "  --help          Show this help"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Check prerequisites
if ! command -v gh &>/dev/null; then
    echo -e "${RED}Error: gh CLI required. Install: https://cli.github.com/${NC}"
    exit 1
fi

if ! gh auth status &>/dev/null 2>&1; then
    echo -e "${RED}Error: gh not authenticated. Run: gh auth login${NC}"
    exit 1
fi

echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Upstream Sync Check — since ${SINCE}            ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

total_changes=0

# ─────────────────────────────────────────────────────────────
# 1. Superpowers (obra/superpowers)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}━━━ 1. Superpowers (obra/superpowers) ━━━${NC}"
echo -e "   Integration: Plugin marketplace install"
echo -e "   What we use: 14 workflow skills (TDD, debugging, brainstorming, etc.)"
echo -e "   Local patches: EnterPlanMode guard in brainstorming/SKILL.md"
echo ""

# Current installed version
INSTALLED_VERSION=""
if [[ -d "$HOME/.claude/plugins/cache/superpowers-marketplace/superpowers" ]]; then
    INSTALLED_VERSION=$(ls "$HOME/.claude/plugins/cache/superpowers-marketplace/superpowers/" 2>/dev/null | sort -V | tail -1)
    echo -e "   Installed version: ${GREEN}${INSTALLED_VERSION:-unknown}${NC}"
fi

# Latest release
LATEST_RELEASE=$(gh api repos/obra/superpowers/releases/latest --jq '.tag_name // "none"' 2>/dev/null || echo "no releases")
echo -e "   Latest release:    ${BLUE}${LATEST_RELEASE}${NC}"

# Compare versions (marketplace versions may be ahead of GitHub releases)
SP_INSTALLED_NUM="${INSTALLED_VERSION//v/}"
SP_LATEST_NUM="${LATEST_RELEASE//v/}"
if [[ "$SP_INSTALLED_NUM" == "$SP_LATEST_NUM" ]]; then
    echo -e "   Status: ${GREEN}Up to date${NC}"
elif [[ "$(printf '%s\n' "$SP_INSTALLED_NUM" "$SP_LATEST_NUM" | sort -V | tail -1)" == "$SP_INSTALLED_NUM" ]]; then
    echo -e "   Status: ${GREEN}Installed is ahead of latest release (marketplace pre-release)${NC}"
else
    echo -e "   Status: ${YELLOW}Update available${NC}"
    echo -e "   ${YELLOW}⚠ Re-apply EnterPlanMode patch after updating${NC}"
    total_changes=$((total_changes + 1))
fi

# Recent commits
SP_COMMITS=$(gh api "repos/obra/superpowers/commits?since=${SINCE}T00:00:00Z&per_page=100" --jq 'length' 2>/dev/null || echo "0")
echo -e "   Commits since ${SINCE}: ${BOLD}${SP_COMMITS}${NC}"

if [[ "$VERBOSE" == "true" ]] && [[ "$SP_COMMITS" -gt 0 ]]; then
    echo ""
    gh api "repos/obra/superpowers/commits?since=${SINCE}T00:00:00Z&per_page=10" \
        --jq '.[] | "     \(.commit.author.date | split("T")[0]) \(.commit.message | split("\n")[0])"' 2>/dev/null || true
fi
echo ""

# ─────────────────────────────────────────────────────────────
# 2. ECC (affaan-m/everything-claude-code)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}━━━ 2. ECC (affaan-m/everything-claude-code) ━━━${NC}"
echo -e "   Integration: Manually adapted (deep — hooks, agents, commands, scripts)"
echo -e "   What we use: Observer daemon, session hooks, multi-model, eval, orchestrate"
echo -e "   Divergences: 11 observer bug fixes, restructured hooks, authority hierarchy"
echo ""

ECC_COMMITS=$(gh api "repos/affaan-m/everything-claude-code/commits?since=${SINCE}T00:00:00Z&per_page=100" --jq 'length' 2>/dev/null || echo "error")
if [[ "$ECC_COMMITS" == "error" ]]; then
    echo -e "   ${RED}Could not reach repo (may be private or renamed)${NC}"
else
    echo -e "   Commits since ${SINCE}: ${BOLD}${ECC_COMMITS}${NC}"
    if [[ "$ECC_COMMITS" -gt 0 ]]; then
        total_changes=$((total_changes + 1))
        echo -e "   ${YELLOW}⚠ Review for: new skills, new agents, hook improvements${NC}"
        echo -e "   ${YELLOW}  Skip: bugs we already fixed, structural differences${NC}"
    fi
fi

if [[ "$VERBOSE" == "true" ]] && [[ "$ECC_COMMITS" -gt 0 ]] && [[ "$ECC_COMMITS" != "error" ]]; then
    echo ""
    echo -e "   Key directories to watch:"
    for dir in skills commands agents hooks; do
        count=$(gh api "repos/affaan-m/everything-claude-code/commits?since=${SINCE}T00:00:00Z&path=${dir}&per_page=100" \
            --jq 'length' 2>/dev/null || echo "?")
        echo -e "     ${dir}/: ${count} commits"
    done
    echo ""
    echo -e "   Recent commits:"
    gh api "repos/affaan-m/everything-claude-code/commits?since=${SINCE}T00:00:00Z&per_page=10" \
        --jq '.[] | "     \(.commit.author.date | split("T")[0]) \(.commit.message | split("\n")[0])"' 2>/dev/null || true
fi
echo ""

# ─────────────────────────────────────────────────────────────
# 3. Anthropic Official (anthropics/claude-plugins-official)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}━━━ 3. Anthropic Official (anthropics/claude-plugins-official) ━━━${NC}"
echo -e "   Integration: Manually copied skills"
echo -e "   What we use: frontend-design skill"
echo ""

ANTH_COMMITS=$(gh api "repos/anthropics/claude-plugins-official/commits?since=${SINCE}T00:00:00Z&per_page=100" --jq 'length' 2>/dev/null || echo "error")
if [[ "$ANTH_COMMITS" == "error" ]]; then
    echo -e "   ${RED}Could not reach repo (may be private)${NC}"
else
    echo -e "   Commits since ${SINCE}: ${BOLD}${ANTH_COMMITS}${NC}"
    if [[ "$ANTH_COMMITS" -gt 0 ]]; then
        total_changes=$((total_changes + 1))
        echo -e "   ${YELLOW}⚠ Check for new official skills or skill updates${NC}"
    else
        echo -e "   Status: ${GREEN}No changes${NC}"
    fi
fi

if [[ "$VERBOSE" == "true" ]] && [[ "$ANTH_COMMITS" -gt 0 ]] && [[ "$ANTH_COMMITS" != "error" ]]; then
    echo ""
    gh api "repos/anthropics/claude-plugins-official/commits?since=${SINCE}T00:00:00Z&per_page=10" \
        --jq '.[] | "     \(.commit.author.date | split("T")[0]) \(.commit.message | split("\n")[0])"' 2>/dev/null || true
fi
echo ""

# ─────────────────────────────────────────────────────────────
# 4. Task Master AI (npm: task-master-ai)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}━━━ 4. Task Master AI (npm: task-master-ai) ━━━${NC}"
echo -e "   Integration: MCP server (npm global install)"
echo -e "   What we use: Task management, PRD parsing, complexity analysis, autopilot"
echo ""

# Current installed version
INSTALLED_TM=$(npm list -g task-master-ai --depth=0 2>/dev/null | grep task-master-ai | sed 's/.*@//' || echo "not installed")
echo -e "   Installed version: ${GREEN}${INSTALLED_TM}${NC}"

# Latest npm version
LATEST_TM=$(npm view task-master-ai version 2>/dev/null || echo "unknown")
echo -e "   Latest on npm:     ${BLUE}${LATEST_TM}${NC}"

if [[ "$INSTALLED_TM" == "$LATEST_TM" ]]; then
    echo -e "   Status: ${GREEN}Up to date${NC}"
else
    echo -e "   Status: ${YELLOW}Update available${NC}"
    echo -e "   ${YELLOW}⚠ Review changelog for breaking changes before updating${NC}"
    echo -e "   ${YELLOW}  Update: npm install -g task-master-ai@latest${NC}"
    total_changes=$((total_changes + 1))
fi

# Check GitHub for recent activity
TM_COMMITS=$(gh api "repos/eyaltoledano/claude-task-master/commits?since=${SINCE}T00:00:00Z&per_page=100" --jq 'length' 2>/dev/null || echo "?")
echo -e "   GitHub commits since ${SINCE}: ${BOLD}${TM_COMMITS}${NC}"

if [[ "$VERBOSE" == "true" ]] && [[ "$TM_COMMITS" -gt 0 ]] && [[ "$TM_COMMITS" != "?" ]]; then
    echo ""
    gh api "repos/eyaltoledano/claude-task-master/commits?since=${SINCE}T00:00:00Z&per_page=10" \
        --jq '.[] | "     \(.commit.author.date | split("T")[0]) \(.commit.message | split("\n")[0])"' 2>/dev/null || true
fi
echo ""

# ─────────────────────────────────────────────────────────────
# 5. wshobson/agents (Plugin Marketplace)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}━━━ 5. Plugin Marketplace (wshobson/agents) ━━━${NC}"
echo -e "   Integration: Plugin source for manage-plugins.sh"
echo -e "   What we use: Plugin registry, downloadable domain-specific agents/skills"
echo ""

WS_COMMITS=$(gh api "repos/wshobson/agents/commits?since=${SINCE}T00:00:00Z&per_page=100" --jq 'length' 2>/dev/null || echo "error")
if [[ "$WS_COMMITS" == "error" ]]; then
    echo -e "   ${RED}Could not reach repo (may be private or renamed)${NC}"
else
    echo -e "   Commits since ${SINCE}: ${BOLD}${WS_COMMITS}${NC}"
    if [[ "$WS_COMMITS" -gt 0 ]]; then
        total_changes=$((total_changes + 1))
        echo -e "   ${YELLOW}⚠ Check for new plugins or updates to installed plugins${NC}"
    else
        echo -e "   Status: ${GREEN}No changes${NC}"
    fi
fi

if [[ "$VERBOSE" == "true" ]] && [[ "$WS_COMMITS" -gt 0 ]] && [[ "$WS_COMMITS" != "error" ]]; then
    echo ""
    gh api "repos/wshobson/agents/commits?since=${SINCE}T00:00:00Z&per_page=10" \
        --jq '.[] | "     \(.commit.author.date | split("T")[0]) \(.commit.message | split("\n")[0])"' 2>/dev/null || true
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
if [[ "$total_changes" -eq 0 ]]; then
    echo -e "${BOLD}║  ${GREEN}All upstreams up to date${NC}${BOLD}                              ║${NC}"
else
    echo -e "${BOLD}║  ${YELLOW}${total_changes} upstream(s) have changes to review${NC}${BOLD}              ║${NC}"
fi
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Update the --since date after reviewing: ${CYAN}${0} --since $(date +%Y-%m-%d)${NC}"
echo ""
echo -e "${BOLD}Local patches to re-apply after updates:${NC}"
echo -e "  • Superpowers brainstorming/SKILL.md: EnterPlanMode prohibition (2 lines after HARD-GATE)"
echo ""
