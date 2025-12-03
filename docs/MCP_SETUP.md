# MCP Server Setup for Claude Code

MCP (Model Context Protocol) servers extend Claude Code with additional capabilities.
This guide covers setting up commonly used MCPs globally.

## Global vs Project Configuration

- **Global**: `~/.claude/mcp.json` - Available in all projects
- **Project**: `.mcp.json` in project root - Project-specific servers

## Recommended Global MCPs

### Task Master AI
Task management and project planning.

```json
{
  "mcpServers": {
    "task-master-ai": {
      "command": "npx",
      "args": ["-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "your-key"
      }
    }
  }
}
```

### Context7
Documentation lookup for libraries and frameworks.

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/context7-mcp"]
    }
  }
}
```

### GitHub
GitHub operations (issues, PRs, repos).

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token"
      }
    }
  }
}
```

## WSL Configuration

When running Claude Code in WSL, prefix commands with `wsl`:

```json
{
  "mcpServers": {
    "task-master-ai": {
      "command": "wsl",
      "args": ["npx", "-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "your-key"
      }
    }
  }
}
```

## Complete Example (~/.claude/mcp.json)

```json
{
  "mcpServers": {
    "task-master-ai": {
      "command": "npx",
      "args": ["-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "your-anthropic-key"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/context7-mcp"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-github-token"
      }
    }
  }
}
```

## Verification

After configuring, restart Claude Code and check available tools:
- Task Master tools: `task-master list`, `task-master next`
- Context7: `resolve library-name` for documentation
- GitHub: `gh_*` prefixed tools for GitHub operations

## Environment Variables

Store sensitive keys in environment variables rather than the config file:

```bash
# ~/.bashrc or ~/.zshrc
export ANTHROPIC_API_KEY="your-key"
export GITHUB_PERSONAL_ACCESS_TOKEN="your-token"
```

Then reference in mcp.json without hardcoding values.
