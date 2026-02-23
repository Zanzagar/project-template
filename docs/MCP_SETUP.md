# MCP Server Setup for Claude Code

Model Context Protocol (MCP) servers extend Claude Code's capabilities with specialized tools. This guide covers setting up commonly used MCPs globally so they're available across all projects.

## Global vs Project-Level Configuration

- **Global MCPs** (`~/.claude/mcp.json`): Available in all projects
- **Project MCPs** (`.mcp.json` in project root): Project-specific servers

## Recommended Global MCPs

### 1. Task Master AI

Task management and project planning directly in Claude Code.

```bash
# Install
npm install -g task-master-ai

# Add to ~/.claude/mcp.json
```

```json
{
  "mcpServers": {
    "task-master-ai": {
      "command": "npx",
      "args": ["-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "your-api-key"
      }
    }
  }
}
```

**Key Commands:**
- `task-master list` - List all tasks
- `task-master next` - Get next task to work on
- `task-master init` - Initialize task tracking in a project

### 2. Context7

Access up-to-date documentation for libraries and frameworks.

```bash
# Add to ~/.claude/mcp.json
```

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

**Usage:** When working with libraries, Context7 provides current documentation so Claude has accurate, version-specific information.

### 3. GitHub MCP

Direct GitHub integration for issues, PRs, and repository management.

```bash
# Add to ~/.claude/mcp.json
```

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "your-github-token"
      }
    }
  }
}
```

**Key Capabilities:**
- Create/manage issues and PRs
- Search repositories
- Read file contents from repos
- Manage branches

### 4. Playwright MCP

Browser automation for web interaction, testing, and scraping via accessibility snapshots.

```bash
# Add to ~/.claude/mcp.json
```

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

**Configuration Options:**

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--browser", "chromium",
        "--headless"
      ]
    }
  }
}
```

| Flag | Description |
|------|-------------|
| `--browser` | Browser engine: `chromium`, `firefox`, `webkit`, `msedge` |
| `--headless` | Run without visible browser window |
| `--port <port>` | Enable HTTP transport on specified port |
| `--user-data-dir <path>` | Persist browser profile to disk |
| `--storage-state <path>` | Load saved authentication state |
| `--caps <caps>` | Enable optional capabilities (comma-separated) |

**Optional Capabilities** (via `--caps`):
- `vision` - Coordinate-based interactions using screenshots
- `pdf` - PDF generation from pages
- `testing` - Assertions and element verification

**Key Tools:**
- Navigate to URLs
- Click elements, fill forms, type text
- Take screenshots
- Manage browser tabs
- Execute JavaScript
- Handle authentication flows

### 5. PostgreSQL MCP

Read-only PostgreSQL database access for schema inspection and queries.

```bash
# Add to ~/.claude/mcp.json (replace with your connection string)
```

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/mydb"]
    }
  }
}
```

**Key Tools:**
- Execute read-only SQL queries
- Inspect table schemas and column types
- List databases and tables

**Note:** This server provides read-only access only. Data cannot be modified.

### 6. MongoDB MCP

MongoDB database access with Atlas management and query capabilities.

```bash
# Add to ~/.claude/mcp.json
```

```json
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server@latest", "--readOnly"],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "mongodb://localhost:27017"
      }
    }
  }
}
```

**For MongoDB Atlas:**

```json
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server@latest", "--readOnly"],
      "env": {
        "MDB_MCP_API_CLIENT_ID": "${MDB_CLIENT_ID}",
        "MDB_MCP_API_CLIENT_SECRET": "${MDB_CLIENT_SECRET}"
      }
    }
  }
}
```

**Key Tools:**
- Find, aggregate, count documents
- Insert, update, delete (when not in read-only mode)
- Manage indexes and collections
- Atlas: List clusters, manage access lists, view performance recommendations

**Note:** The `--readOnly` flag is recommended for safety. Remove it only when write access is needed.

### 7. Magic (21st.dev)

AI-powered UI component generation from natural language descriptions.

```bash
# Get API key from https://21st.dev/magic/console
# Add to ~/.claude/mcp.json
```

```json
{
  "mcpServers": {
    "magic": {
      "command": "npx",
      "args": ["-y", "@21st-dev/magic@latest"],
      "env": {
        "API_KEY": "${MAGIC_API_KEY}"
      }
    }
  }
}
```

**Key Tools:**
- Generate React UI components from descriptions
- Search and fetch brand logos (via SVGL)
- Get design inspiration from 21st.dev library
- Refine existing components

**Get API Key:** [21st.dev Magic Console](https://21st.dev/magic/console)

### 8. Figma Context

Extract Figma designs for AI-powered code implementation.

```bash
# Get API key from Figma account settings
# Add to ~/.claude/mcp.json
```

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "figma-developer-mcp", "--figma-api-key=YOUR-KEY", "--stdio"]
    }
  }
}
```

**Or using environment variables:**

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "figma-developer-mcp", "--stdio"],
      "env": {
        "FIGMA_API_KEY": "${FIGMA_API_KEY}"
      }
    }
  }
}
```

**Key Tools:**
- Extract design data from Figma files
- Get layout and styling information
- Translate designs into implementation-ready specs

**Get API Key:** [Figma Personal Access Tokens](https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens)

## Complete Example Configuration

Here's a full `~/.claude/mcp.json` with all recommended servers:

```json
{
  "mcpServers": {
    "task-master-ai": {
      "command": "npx",
      "args": ["-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--headless"]
    }
  }
}
```

## Setup Steps

1. **Create the config file:**
   ```bash
   mkdir -p ~/.claude
   touch ~/.claude/mcp.json
   ```

2. **Add your configuration** (copy from examples above)

3. **Set environment variables** (add to `~/.bashrc` or `~/.zshrc`):
   ```bash
   export ANTHROPIC_API_KEY="sk-ant-..."
   export GITHUB_TOKEN="ghp_..."
   ```

4. **Restart Claude Code** to load the new MCPs

## Verifying MCP Setup

After configuration, Claude Code will have access to tools from each MCP server. You can verify by asking Claude to:
- "List my tasks" (Task Master)
- "Look up the latest React documentation" (Context7)
- "Show my open GitHub issues" (GitHub)
- "Navigate to example.com and describe what you see" (Playwright)

## Troubleshooting

### MCP server not starting
- Check `npx` is installed: `npm install -g npx`
- Verify environment variables are set
- Check Claude Code logs for errors

### Authentication errors
- Regenerate API keys/tokens
- Ensure tokens have required permissions
- Check token hasn't expired

## Managing MCPs Per-Project

MCPs consume context tokens. You can enable/disable MCPs per-project to optimize token usage.

### Interactive Selection

```bash
# Use the slash command
/mcps

# Or use the management script
./scripts/manage-mcps.sh select
```

### Manual Enable/Disable

```bash
# Disable an MCP for this project only
claude mcp disable paypal --scope project

# Re-enable it later
claude mcp enable paypal --scope project

# Check current status
claude mcp list
```

### Presets

Apply a preset configuration based on project type:

```bash
./scripts/manage-mcps.sh preset              # List available presets
./scripts/manage-mcps.sh preset python-backend  # Apply preset
```

| Preset | MCPs Enabled | Measured Tokens |
|--------|--------------|-----------------|
| `minimal` | task-master-ai, context7 | ~8,000 |
| `python-backend` | + github, postgres | ~8,100 |
| `frontend` | + github, playwright, magic | ~12,950 |
| `fullstack` | + github, playwright, postgres | ~11,610 |
| `e-commerce` | + github, paypal, postgres | ~18,060 |
| `content` | + github, wpcom-mcp | ~13,900 |
| `testing` | + playwright | ~11,450 |
| `data-engineering` | + github, postgres, mongodb | ~11,760 |

### Token Usage

Check your current token overhead:

```bash
./scripts/manage-mcps.sh tokens
```

**Note:** Changes require restarting Claude Code to take effect.

## MCP Token Cost Reference

Each MCP server consumes context tokens for its tool definitions. These costs are **per-session overhead** - paid regardless of whether tools are used.

### Measured Token Costs (January 2026)

| MCP Server | Tools | Tokens | Notes |
|------------|-------|--------|-------|
| **task-master-ai** | 7-36 | ~1,200-7,100 | Core: 7 tools (~1.2k), Standard: 15 (~3.5k), All: 36 (~7.1k) |
| **paypal** | 28 | ~9,900 | Invoices, subscriptions, orders, disputes |
| **wpcom-mcp** | 16 | ~5,900 | WordPress.com site management |
| **mongodb** | 16 | ~3,600 | Queries, aggregations, Atlas |
| **playwright** | 21 | ~3,450 | Browser automation |
| **canva-dev** | 11 | ~2,500 | Canva app development |
| **magic** | 4 | ~1,400 | 21st.dev UI components |
| **context7** | 2 | ~900 | Library documentation |
| **postgres** | 1 | ~60 | Read-only SQL queries |

### Token Budget Guidelines

| Context Window | Recommended Max MCP Tokens | Remaining for Work |
|----------------|---------------------------|-------------------|
| 200k (Opus) | ~40k (20%) | ~160k |
| 200k (Sonnet) | ~40k (20%) | ~160k |
| 128k (Haiku) | ~25k (20%) | ~103k |

**Your current config**: 35.4k tokens (17.7%) - within healthy range.

### Cost Optimization Strategies

1. **Enable deferred MCP loading** (saves ~33k tokens for Task Master alone):
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export ENABLE_EXPERIMENTAL_MCP_CLI=true
   ```
   This makes Claude Code load MCP tool definitions lazily instead of at startup. Savings apply to ALL MCP servers.

2. **Reduce Task Master tool count** via `TASK_MASTER_TOOLS` env var:
   | Mode | Tools | Best For |
   |------|-------|----------|
   | `all` | 36 | Full access (default) |
   | `standard` | 15 | Most workflows |
   | `core` | 7 | AI-heavy workflows using CLI for expansions (recommended) |

   Set in your MCP server config: `export TASK_MASTER_TOOLS='core'`

   You can also use a **custom comma-separated list** for surgical precision:
   ```
   TASK_MASTER_TOOLS='get_tasks,next_task,get_task,set_task_status,update_subtask,parse_prd,expand_task,add_subtask,analyze_project_complexity'
   ```
   This gives you exactly 9 tools — core workflow + the two most-used standard tools. Recommended for this template's workflow where AI-heavy ops (update, scope, research) go through the CLI.

3. **Enable task metadata** for GitHub issue linking:
   ```
   export TASK_MASTER_ALLOW_METADATA_UPDATES='true'
   ```
   Enables the `metadata` field on tasks for storing arbitrary JSON (GitHub issue URLs, story points, sprint IDs).

4. **Disable unused MCPs per-project**:
   ```bash
   claude mcp disable paypal --scope project
   ```

5. **Use presets matching your project type** (see below)

6. **Essential MCPs only**: `task-master-ai` + `context7` = ~8k tokens (or ~1-2k with deferred loading)

### The 10/80 Rule

Keep your MCP configuration within these limits for healthy context budgets:

| Limit | Value | Rationale |
|-------|-------|-----------|
| Max MCPs enabled | **10** | Each server adds tool definitions at startup |
| Max total tools | **80** | Tool schemas consume ~200-500 tokens each |

**Why this matters:** MCP tool definitions are loaded into every API call, consuming 25-30k tokens before you even start working. Exceeding 80 tools can push overhead past 20% of your context window, causing quality degradation (forgotten instructions, repeated approaches).

**Check your budget:**
```bash
./scripts/manage-mcps.sh audit    # Full budget report with visual bars
./scripts/manage-mcps.sh tokens   # Token overhead + budget summary
```

### Per-Project Disabling with disabledMcpServers

Disable globally-installed MCPs at the project level using `.mcp.json`:

```json
{
  "mcpServers": {},
  "disabledMcpServers": ["paypal", "wpcom-mcp", "canva-dev", "magic"]
}
```

This is **declarative** (checked into git, shared with team) vs `claude mcp disable --scope project` which is **imperative** (local only). Use `.mcp.json` when the team should agree on which MCPs a project needs.

See `.claude/examples/mcp-config-example.json` for a complete example.

### Recommended Configurations by Project Type

| Project Type | MCPs | Tools | Token Cost |
|-------------|------|-------|------------|
| Python minimal | task-master, context7 | 47 | ~4,300 |
| Python backend | + github, postgres | 62 | ~7,500 |
| Full-stack | + playwright | 82 | ~10,800 |
| E-commerce | + paypal | 90 | ~11,500 |
| Content/CMS | + wpcom-mcp | 74 | ~8,800 |
| Data engineering | + postgres, mongodb | 77 | ~9,100 |

Apply via: `./scripts/manage-mcps.sh preset <name>`

## Security Notes

- Never commit `~/.claude/mcp.json` to version control
- Use environment variables for sensitive values
- Regularly rotate API keys and tokens
- Review MCP server permissions before installing

## Companion Tools (Community)

These tools from the Claude Code community enhance your workflow. They're not MCPs but complement this template.

### Usage Monitoring

| Tool | Description | Install |
|------|-------------|---------|
| **ccusage** | CLI analyzing local Claude Code logs with metrics | `pip install ccusage` |
| **ccflare** | Web-based usage dashboard | [github.com/snipeship/ccflare](https://github.com/snipeship/ccflare) |
| **better-ccflare** | Enhanced ccflare with more providers | [github.com/tombii/better-ccflare](https://github.com/tombii/better-ccflare) |

Recommended: Install **ccusage** for real token usage tracking (vs. our estimates).

### Session Search & History

| Tool | Description | Install |
|------|-------------|---------|
| **recall** | Full-text search across sessions | [github.com/zippoxer/recall](https://github.com/zippoxer/recall) |
| **cchistory** | View Bash commands from sessions | [github.com/eckardt/cchistory](https://github.com/eckardt/cchistory) |
| **claudex** | Web-based conversation browser | [github.com/kunwar-shah/claudex](https://github.com/kunwar-shah/claudex) |

Useful for: Finding what you worked on last week, auditing changes.

### Advanced Hooks Development

Our template provides shell-based hooks. For more sophisticated hooks:

| Tool | Language | Description |
|------|----------|-------------|
| **cchooks** | Python | Clean API for hook development |
| **claude-hooks** | TypeScript | Declarative hook configuration |
| **claude-hooks-sdk** | PHP | Laravel-style fluent API |

See: [github.com/GowayLee/cchooks](https://github.com/GowayLee/cchooks)

### Quality Enforcement

| Tool | Purpose |
|------|---------|
| **TDD Guard** | Blocks commits that violate TDD practices |
| **TypeScript Quality Hooks** | ESLint + Prettier enforcement |

### Notifications

| Tool | Description |
|------|-------------|
| **CC Notify** | Desktop notifications with VS Code integration |
| **Claudio** | OS-native sounds for Claude events |

### Resources

For the full ecosystem of 150+ tools:
- **Awesome Claude Code**: [github.com/hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
