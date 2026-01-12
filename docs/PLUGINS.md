# Claude Code Plugins

This project template supports plugins from the [wshobson/agents](https://github.com/wshobson/agents) repository, which provides 65+ specialized agents, commands, and skills for various development domains.

## Why Plugins?

Plugins provide domain-specific expertise without bloating every conversation with unused context. The system is designed with **token efficiency** in mind:

- **Isolated Loading**: Each plugin loads only its own agents/skills (~200-400 tokens)
- **On-Demand**: Install only what you need for your project
- **Presets**: Curated combinations for common project types

## Quick Start

### Interactive Selection (Recommended)

Use the slash command to interactively select plugins:

```
/plugins
```

Or run the shell script:

```bash
./scripts/manage-plugins.sh select
```

### Using Presets

Install a preset for your project type:

```bash
# List available presets
./scripts/manage-plugins.sh list

# Install via interactive preset selection
./scripts/manage-plugins.sh install-preset
```

Available presets:

| Preset | Description | Est. Tokens |
|--------|-------------|-------------|
| `python-web` | Full Python web stack | ~1,360 |
| `fullstack-js` | Complete JS/TS stack | ~1,480 |
| `devops-sre` | Infrastructure & reliability | ~1,500 |
| `security-focused` | Security scanning & compliance | ~1,100 |
| `ai-ml-engineer` | LLM apps, MLOps, data | ~1,270 |
| `minimal` | Just the essentials | ~540 |

### Individual Plugin Installation

```bash
# Install a specific plugin
./scripts/manage-plugins.sh install python-development

# Get plugin info before installing
./scripts/manage-plugins.sh info kubernetes-operations
```

## Available Plugin Categories

### Python Development
- `python-development` - Python 3.12+ with uv, ruff, pytest, async patterns

### JavaScript/TypeScript
- `javascript-typescript` - Modern JS/TS, React, Vue, Node.js

### Backend Development
- `backend-development` - API design, authentication, caching
- `database-design` - Schema design, query optimization
- `database-migrations` - Safe migrations, rollback patterns

### Frontend & Mobile
- `frontend-mobile-development` - React Native, Flutter, responsive design
- `multi-platform-apps` - Electron, Tauri cross-platform

### DevOps & Infrastructure
- `cicd-automation` - GitHub Actions, GitLab CI, pipelines
- `kubernetes-operations` - K8s deployment, scaling, troubleshooting
- `cloud-infrastructure` - AWS, GCP, Azure, Terraform
- `observability-monitoring` - Logging, metrics, tracing

### Code Quality & Testing
- `code-review-ai` - Automated code review
- `unit-testing` - Testing strategies, mocking
- `tdd-workflows` - Test-driven development
- `debugging-toolkit` - Advanced debugging tools

### Security & Compliance
- `security-scanning` - SAST, DAST, dependency scanning
- `security-compliance` - SOC2, GDPR, HIPAA patterns
- `incident-response` - Security incident handling

### AI/ML & Data
- `llm-application-dev` - LLM apps, RAG, prompt engineering
- `machine-learning-ops` - Model deployment, MLOps
- `data-engineering` - Data pipelines, ETL

### Documentation & APIs
- `api-scaffolding` - OpenAPI, GraphQL design
- `documentation-generation` - Automated docs
- `c4-architecture` - Architecture diagrams

### Specialized Domains
- `blockchain-web3` - Smart contracts, DeFi
- `game-development` - Unity, Unreal, game architecture
- `quantitative-trading` - Algorithmic trading
- `systems-programming` - Rust, C/C++, low-level systems

## Managing Installed Plugins

```bash
# List installed plugins
./scripts/manage-plugins.sh list-installed

# Remove a plugin
./scripts/manage-plugins.sh remove python-development
```

## Using Claude Code's Native Plugin System

The wshobson/agents repository is designed to work with Claude Code's built-in plugin marketplace:

```
/plugin marketplace add wshobson/agents
/plugin install python-development
```

This project's plugin management script provides an additional layer for:
- Tracking installed plugins and token estimates
- Interactive selection based on project type
- Preset-based installation

## Token Budget Considerations

Claude Code has a context window that's shared between:
- System prompts and instructions
- Plugin agents, commands, and skills
- Your conversation history
- Code being analyzed

**Recommendations:**
1. Start with the `minimal` preset and add as needed
2. Keep total plugin tokens under 2,000 for most projects
3. Remove unused plugins with `./scripts/manage-plugins.sh remove`
4. Check current usage with `./scripts/manage-plugins.sh list-installed`

## File Structure

```
.claude/plugins/
├── registry.json        # Available plugins catalog
├── installed.json       # Tracking installed plugins
└── installed/           # Plugin reference files
    └── <plugin-id>/
        └── SOURCE.md    # Link to source repository
```

## Contributing

To add new plugins or presets to this template:

1. Update `.claude/plugins/registry.json`
2. Add the plugin to appropriate category
3. Include token estimates (check source repo)
4. Test with `./scripts/manage-plugins.sh install <plugin>`

## Resources

- [wshobson/agents Repository](https://github.com/wshobson/agents)
- [Claude Code Plugin Documentation](https://docs.anthropic.com/claude-code/plugins)
