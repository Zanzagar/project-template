#!/bin/bash
# manage-plugins.sh - Install and manage Claude Code plugins from wshobson/agents
# Version: 1.0.0
#
# Usage:
#   ./scripts/manage-plugins.sh [command] [options]
#
# Commands:
#   list              List available plugins by category
#   list-installed    List currently installed plugins
#   install <plugin>  Install a specific plugin
#   install-preset    Interactive preset selection
#   remove <plugin>   Remove an installed plugin
#   info <plugin>     Show detailed plugin information
#   select            Interactive plugin selection wizard
#
# Options:
#   --dry-run         Preview changes without applying
#   --force           Overwrite existing files
#   --quiet           Minimal output

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REGISTRY_FILE="$PROJECT_ROOT/.claude/plugins/registry.json"
INSTALLED_FILE="$PROJECT_ROOT/.claude/plugins/installed.json"
PLUGINS_DIR="$PROJECT_ROOT/.claude/plugins/installed"
GITHUB_RAW="https://raw.githubusercontent.com/wshobson/agents/main/plugins"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Options
DRY_RUN=false
FORCE=false
QUIET=false

# Check for jq
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is required but not installed.${NC}"
        echo "Install with: sudo apt install jq (Linux) or brew install jq (macOS)"
        exit 1
    fi
}

# Parse global options - modifies ARGS array
parse_options() {
    ARGS=()
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --dry-run) DRY_RUN=true ;;
            --force) FORCE=true ;;
            --quiet) QUIET=true ;;
            *) ARGS+=("$1") ;;
        esac
        shift
    done
}

# List available plugins
list_plugins() {
    check_jq

    echo -e "${BOLD}${BLUE}Available Plugins${NC}"
    echo "=================="
    echo ""

    # Get categories
    local categories=$(jq -r '.categories | keys[]' "$REGISTRY_FILE")

    for category in $categories; do
        local cat_name=$(jq -r ".categories[\"$category\"].name" "$REGISTRY_FILE")
        local cat_desc=$(jq -r ".categories[\"$category\"].description" "$REGISTRY_FILE")

        echo -e "${BOLD}${CYAN}$cat_name${NC}"
        echo -e "  ${cat_desc}"
        echo ""

        # List plugins in category
        jq -r ".categories[\"$category\"].plugins[] | \"  - \(.id): \(.description) (~\(.tokens) tokens)\"" "$REGISTRY_FILE"
        echo ""
    done

    echo -e "${BOLD}Presets:${NC}"
    jq -r '.presets | to_entries[] | "  - \(.key): \(.value.description) (~\(.value.estimated_tokens) tokens)"' "$REGISTRY_FILE"
}

# List installed plugins
list_installed() {
    check_jq

    echo -e "${BOLD}${BLUE}Installed Plugins${NC}"
    echo "=================="

    if [ ! -f "$INSTALLED_FILE" ]; then
        echo -e "${YELLOW}No plugins installed yet.${NC}"
        echo "Run: ./scripts/manage-plugins.sh select"
        return
    fi

    local count=$(jq '.plugins | length' "$INSTALLED_FILE")
    if [ "$count" = "0" ]; then
        echo -e "${YELLOW}No plugins installed yet.${NC}"
        return
    fi

    echo ""
    jq -r '.plugins[] | "  - \(.id): \(.name) (\(.installed_at))"' "$INSTALLED_FILE"
    echo ""
    echo -e "Total estimated tokens: ${CYAN}$(jq '.total_tokens' "$INSTALLED_FILE")${NC}"
}

# Get plugin info
plugin_info() {
    check_jq
    local plugin_id="$1"

    if [ -z "$plugin_id" ]; then
        echo -e "${RED}Error: Plugin ID required${NC}"
        echo "Usage: $0 info <plugin-id>"
        exit 1
    fi

    # Search for plugin in registry
    local found=$(jq -r ".categories[].plugins[] | select(.id == \"$plugin_id\")" "$REGISTRY_FILE")

    if [ -z "$found" ]; then
        echo -e "${RED}Plugin '$plugin_id' not found${NC}"
        echo "Run: $0 list"
        exit 1
    fi

    echo -e "${BOLD}${BLUE}Plugin: $plugin_id${NC}"
    echo "========================"
    echo ""
    echo "$found" | jq -r '"Name: \(.name)\nDescription: \(.description)\nEstimated Tokens: \(.tokens)\n\nAgents:\n\(.agents | map("  - " + .) | join("\n"))\n\nSkills:\n\(.skills | map("  - " + .) | join("\n"))"'
}

# Download plugin files
# STUB: This function creates a pointer file (SOURCE.md) instead of downloading
# actual plugin files. Real download would require GitHub API enumeration of the
# plugin directory contents. For now, users should follow the SOURCE.md instructions
# or use Claude Code's built-in plugin system when available.
download_plugin() {
    local plugin_id="$1"
    local target_dir="$PLUGINS_DIR/$plugin_id"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would download: $plugin_id${NC}"
        return
    fi

    mkdir -p "$target_dir/agents" "$target_dir/commands" "$target_dir/skills"

    # Download agents
    local agents_url="$GITHUB_RAW/$plugin_id/agents"
    local commands_url="$GITHUB_RAW/$plugin_id/commands"
    local skills_url="$GITHUB_RAW/$plugin_id/skills"

    echo -e "  Downloading plugin files..."
    echo -e "  ${YELLOW}[STUB] Creating reference file — actual files not downloaded${NC}"

    # STUB: In production, we'd enumerate the actual files via GitHub API.
    # For now, we create a pointer that documents where to get the real files.
    cat > "$target_dir/SOURCE.md" << EOF
# Plugin: $plugin_id

Source: https://github.com/wshobson/agents/tree/main/plugins/$plugin_id

## Installation

This plugin's agents, commands, and skills are available from the wshobson/agents repository.

To fully activate this plugin, use Claude Code's built-in plugin system:
\`\`\`
/plugin marketplace add wshobson/agents
/plugin install $plugin_id
\`\`\`

Or manually copy the files from the repository to:
- Agents: .claude/plugins/installed/$plugin_id/agents/
- Commands: .claude/plugins/installed/$plugin_id/commands/
- Skills: .claude/plugins/installed/$plugin_id/skills/
EOF

    echo -e "  ${GREEN}Plugin reference created${NC}"
}

# Install a plugin
install_plugin() {
    check_jq
    local plugin_id="$1"

    if [ -z "$plugin_id" ]; then
        echo -e "${RED}Error: Plugin ID required${NC}"
        echo "Usage: $0 install <plugin-id>"
        exit 1
    fi

    # Find plugin in registry
    local plugin=$(jq -r ".categories[].plugins[] | select(.id == \"$plugin_id\")" "$REGISTRY_FILE")

    if [ -z "$plugin" ]; then
        echo -e "${RED}Plugin '$plugin_id' not found${NC}"
        exit 1
    fi

    local plugin_name=$(echo "$plugin" | jq -r '.name')
    local plugin_tokens=$(echo "$plugin" | jq -r '.tokens')

    echo -e "${BLUE}Installing: ${BOLD}$plugin_name${NC}"

    # Check if already installed
    if [ -f "$INSTALLED_FILE" ]; then
        local existing=$(jq -r ".plugins[] | select(.id == \"$plugin_id\")" "$INSTALLED_FILE")
        if [ -n "$existing" ] && [ "$FORCE" != true ]; then
            echo -e "${YELLOW}Plugin already installed. Use --force to reinstall.${NC}"
            return
        fi
    fi

    # Download plugin
    download_plugin "$plugin_id"

    # Update installed.json
    if [ "$DRY_RUN" != true ]; then
        local timestamp=$(date -Iseconds)

        if [ ! -f "$INSTALLED_FILE" ]; then
            echo '{"plugins": [], "total_tokens": 0}' > "$INSTALLED_FILE"
        fi

        # Remove existing entry if reinstalling
        local temp=$(mktemp)
        jq ".plugins = [.plugins[] | select(.id != \"$plugin_id\")]" "$INSTALLED_FILE" > "$temp"
        mv "$temp" "$INSTALLED_FILE"

        # Add new entry
        jq ".plugins += [{\"id\": \"$plugin_id\", \"name\": \"$plugin_name\", \"tokens\": $plugin_tokens, \"installed_at\": \"$timestamp\"}]" "$INSTALLED_FILE" > "$temp"
        mv "$temp" "$INSTALLED_FILE"

        # Update total tokens
        local total=$(jq '[.plugins[].tokens] | add // 0' "$INSTALLED_FILE")
        jq ".total_tokens = $total" "$INSTALLED_FILE" > "$temp"
        mv "$temp" "$INSTALLED_FILE"

        echo -e "${GREEN}Installed successfully${NC}"
        echo -e "Estimated tokens: ${CYAN}$plugin_tokens${NC}"
    fi
}

# Remove a plugin
remove_plugin() {
    check_jq
    local plugin_id="$1"

    if [ -z "$plugin_id" ]; then
        echo -e "${RED}Error: Plugin ID required${NC}"
        exit 1
    fi

    if [ ! -f "$INSTALLED_FILE" ]; then
        echo -e "${YELLOW}No plugins installed${NC}"
        return
    fi

    local existing=$(jq -r ".plugins[] | select(.id == \"$plugin_id\")" "$INSTALLED_FILE")
    if [ -z "$existing" ]; then
        echo -e "${YELLOW}Plugin '$plugin_id' is not installed${NC}"
        return
    fi

    echo -e "${BLUE}Removing: $plugin_id${NC}"

    if [ "$DRY_RUN" != true ]; then
        # Remove from installed.json
        local temp=$(mktemp)
        jq ".plugins = [.plugins[] | select(.id != \"$plugin_id\")]" "$INSTALLED_FILE" > "$temp"
        mv "$temp" "$INSTALLED_FILE"

        # Update total tokens
        local total=$(jq '[.plugins[].tokens] | add // 0' "$INSTALLED_FILE")
        jq ".total_tokens = $total" "$INSTALLED_FILE" > "$temp"
        mv "$temp" "$INSTALLED_FILE"

        # Remove plugin directory
        rm -rf "$PLUGINS_DIR/$plugin_id"

        echo -e "${GREEN}Removed successfully${NC}"
    fi
}

# Interactive plugin selection
interactive_select() {
    check_jq

    echo -e "${BOLD}${BLUE}Plugin Selection Wizard${NC}"
    echo "========================"
    echo ""
    echo "This wizard helps you select plugins based on your project needs."
    echo "Each plugin adds specialized agents and skills to Claude Code."
    echo ""
    echo -e "${YELLOW}Note: More plugins = more context tokens used per conversation.${NC}"
    echo ""

    # Ask about project type
    echo -e "${BOLD}What type of project are you working on?${NC}"
    echo ""
    echo "  1) Python web application (FastAPI, Django)"
    echo "  2) JavaScript/TypeScript full-stack"
    echo "  3) DevOps/Infrastructure"
    echo "  4) AI/ML Engineering"
    echo "  5) Security-focused development"
    echo "  6) Custom selection"
    echo "  7) Minimal (just essentials)"
    echo ""
    read -p "Select [1-7]: " project_type

    local selected_plugins=()

    case $project_type in
        1)
            selected_plugins=($(jq -r '.presets["python-web"].plugins[]' "$REGISTRY_FILE"))
            echo -e "\n${GREEN}Selected Python Web preset${NC}"
            ;;
        2)
            selected_plugins=($(jq -r '.presets["fullstack-js"].plugins[]' "$REGISTRY_FILE"))
            echo -e "\n${GREEN}Selected Full-Stack JS preset${NC}"
            ;;
        3)
            selected_plugins=($(jq -r '.presets["devops-sre"].plugins[]' "$REGISTRY_FILE"))
            echo -e "\n${GREEN}Selected DevOps/SRE preset${NC}"
            ;;
        4)
            selected_plugins=($(jq -r '.presets["ai-ml-engineer"].plugins[]' "$REGISTRY_FILE"))
            echo -e "\n${GREEN}Selected AI/ML preset${NC}"
            ;;
        5)
            selected_plugins=($(jq -r '.presets["security-focused"].plugins[]' "$REGISTRY_FILE"))
            echo -e "\n${GREEN}Selected Security preset${NC}"
            ;;
        6)
            echo ""
            echo -e "${BOLD}Custom Selection${NC}"
            echo "Select categories to include (comma-separated numbers):"
            echo ""

            local categories=($(jq -r '.categories | keys[]' "$REGISTRY_FILE"))
            local i=1
            for cat in "${categories[@]}"; do
                local cat_name=$(jq -r ".categories[\"$cat\"].name" "$REGISTRY_FILE")
                echo "  $i) $cat_name"
                ((i++))
            done
            echo ""
            read -p "Categories: " cat_selection

            # Parse selection and collect plugins
            IFS=',' read -ra SELECTED <<< "$cat_selection"
            for sel in "${SELECTED[@]}"; do
                sel=$(echo "$sel" | tr -d ' ')
                if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#categories[@]}" ]; then
                    local cat_key="${categories[$((sel-1))]}"
                    local cat_plugins=($(jq -r ".categories[\"$cat_key\"].plugins[].id" "$REGISTRY_FILE"))
                    selected_plugins+=("${cat_plugins[@]}")
                fi
            done
            ;;
        7)
            selected_plugins=($(jq -r '.presets["minimal"].plugins[]' "$REGISTRY_FILE"))
            echo -e "\n${GREEN}Selected Minimal preset${NC}"
            ;;
        *)
            echo -e "${RED}Invalid selection${NC}"
            exit 1
            ;;
    esac

    # Show selection and confirm
    echo ""
    echo -e "${BOLD}Selected plugins:${NC}"
    local total_tokens=0
    for plugin in "${selected_plugins[@]}"; do
        local info=$(jq -r ".categories[].plugins[] | select(.id == \"$plugin\") | \"\(.name) (~\(.tokens) tokens)\"" "$REGISTRY_FILE" | head -1)
        local tokens=$(jq -r ".categories[].plugins[] | select(.id == \"$plugin\") | .tokens" "$REGISTRY_FILE" | head -1)
        echo "  - $info"
        total_tokens=$((total_tokens + tokens))
    done
    echo ""
    echo -e "Total estimated tokens: ${CYAN}$total_tokens${NC}"
    echo ""

    read -p "Install these plugins? [Y/n]: " confirm
    if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
        echo ""
        for plugin in "${selected_plugins[@]}"; do
            install_plugin "$plugin"
        done
        echo ""
        echo -e "${GREEN}${BOLD}Plugin installation complete!${NC}"
        echo ""
        echo "To use these plugins with Claude Code, you can either:"
        echo "  1. Use the native plugin system: /plugin marketplace add wshobson/agents"
        echo "  2. Reference the installed plugin docs in .claude/plugins/installed/"
        echo ""
        echo "See docs/PLUGINS.md for more information."
    else
        echo "Installation cancelled."
    fi
}

# Install preset
install_preset() {
    check_jq

    echo -e "${BOLD}${BLUE}Available Presets${NC}"
    echo "=================="
    echo ""

    local presets=($(jq -r '.presets | keys[]' "$REGISTRY_FILE"))
    local i=1
    for preset in "${presets[@]}"; do
        local name=$(jq -r ".presets[\"$preset\"].name" "$REGISTRY_FILE")
        local desc=$(jq -r ".presets[\"$preset\"].description" "$REGISTRY_FILE")
        local tokens=$(jq -r ".presets[\"$preset\"].estimated_tokens" "$REGISTRY_FILE")
        echo "  $i) $name"
        echo "     $desc (~$tokens tokens)"
        echo ""
        ((i++))
    done

    read -p "Select preset [1-${#presets[@]}]: " selection

    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#presets[@]}" ]; then
        local preset_key="${presets[$((selection-1))]}"
        local plugins=($(jq -r ".presets[\"$preset_key\"].plugins[]" "$REGISTRY_FILE"))

        echo ""
        for plugin in "${plugins[@]}"; do
            install_plugin "$plugin"
        done

        echo ""
        echo -e "${GREEN}Preset installed successfully${NC}"
    else
        echo -e "${RED}Invalid selection${NC}"
        exit 1
    fi
}

# Main
main() {
    parse_options "$@"

    local command="${ARGS[0]:-help}"
    local remaining_args=("${ARGS[@]:1}")

    case "$command" in
        list)
            list_plugins
            ;;
        list-installed|installed)
            list_installed
            ;;
        install)
            install_plugin "${remaining_args[@]}"
            ;;
        install-preset|preset)
            install_preset
            ;;
        remove|uninstall)
            remove_plugin "${remaining_args[@]}"
            ;;
        info)
            plugin_info "${remaining_args[@]}"
            ;;
        select|wizard)
            interactive_select
            ;;
        help|--help|-h)
            head -20 "$0" | tail -n +2 | sed 's/^# //'
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            echo "Run: $0 help"
            exit 1
            ;;
    esac
}

main "$@"
