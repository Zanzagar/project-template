# Project Template Onboarding

Get from `git clone` to productive work in under 10 minutes.

## Quick Start (experienced users)

```bash
# 1. Clone and enter
git clone <template-url> my-project && cd my-project

# 2. Initialize (creates symlinks, Task Master config, hooks)
./scripts/init-project.sh

# 3. Set your skill profile
./scripts/manage-skill-profiles.sh set python    # or: java, go, typescript, fullstack, etc.

# 4. Install Superpowers (required for TDD enforcement)
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# 5. Customize CLAUDE.md with your project details
# Edit the [PROJECT_NAME], tech stack, and structure sections

# 6. Start working
task-master init    # If using Task Master
```

Done. The rest of this document explains what each step does and how to make the right choices.

---

## Step-by-Step Guide

### Step 1: Choose Your Skill Profile

The template has **153 skills** across 22 categories, but you should only load the ones relevant to your project. Skill profiles control which skills are active.

**Run this to see all profiles:**
```bash
./scripts/manage-skill-profiles.sh list
```

**Decision tree — pick the profile that matches your project:**

```
What are you building?
│
├─ Python app (Django, FastAPI, Flask)?
│  └─ ./scripts/manage-skill-profiles.sh set python
│     (44 skills: universal + Python + Django + database)
│
├─ Java/Spring Boot app?
│  └─ ./scripts/manage-skill-profiles.sh set java
│     (41 skills: universal + Java + Spring + database)
│
├─ Go service?
│  └─ ./scripts/manage-skill-profiles.sh set go
│     (33 skills: universal + Go)
│
├─ TypeScript/Node.js app?
│  └─ ./scripts/manage-skill-profiles.sh set typescript
│     (44 skills: universal + TS + frontend)
│
├─ Kotlin/Android app?
│  └─ ./scripts/manage-skill-profiles.sh set kotlin
│     (42 skills: universal + Kotlin + Java + database)
│
├─ Rust project?
│  └─ ./scripts/manage-skill-profiles.sh set rust
│     (33 skills: universal + Rust)
│
├─ Swift/iOS app?
│  └─ ./scripts/manage-skill-profiles.sh set swift
│     (39 skills: universal + Swift + mobile)
│
├─ Full-stack web app?
│  └─ ./scripts/manage-skill-profiles.sh set fullstack
│     (60 skills: universal + Python + TS + frontend + database + infra)
│
├─ Mobile app (cross-platform)?
│  └─ ./scripts/manage-skill-profiles.sh set mobile-dev
│     (44 skills: universal + Kotlin + Swift + mobile)
│
├─ AI/ML project?
│  └─ ./scripts/manage-skill-profiles.sh set ai-engineer
│     (59 skills: universal + Python + AI ops + research)
│
├─ Production/DevOps work?
│  └─ ./scripts/manage-skill-profiles.sh set ops
│     (47 skills: universal + ops + infra)
│
├─ Multiple languages or unsure?
│  └─ ./scripts/manage-skill-profiles.sh set all
│     (153 skills — loads everything, highest token cost)
│
└─ Template development / meta work?
   └─ ./scripts/manage-skill-profiles.sh set minimal
      (31 skills: universal only, lowest token cost)
```

**Custom combos** — mix categories for unique stacks:
```bash
# Python + Kubernetes + frontend
./scripts/manage-skill-profiles.sh set python,ops,frontend

# Rust + infrastructure
./scripts/manage-skill-profiles.sh set rust,infra,ops

# Universal always included automatically
```

**You can change profiles anytime.** Changes take effect next session.

**Set via environment variable** (persists across sessions):
```bash
export TEMPLATE_SKILL_PROFILE=python
```

### Step 2: Install Required Plugins

**Superpowers (required)** — TDD enforcement, structured workflow:
```bash
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**Document processing (optional)** — PDF, Word, PowerPoint, Excel:
```bash
# Install the plugin
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills

# Check and install system dependencies
./scripts/check-doc-deps.sh --install
```

### Step 3: Customize CLAUDE.md

Open `CLAUDE.md` and replace the placeholders:

1. **`[PROJECT_NAME]`** — Your project name
2. **Tech Stack** — List your actual frameworks, databases, tools
3. **Structure** — Describe your actual directory layout
4. **Project-Specific Patterns** — Add your conventions
5. **Key Decisions** — Document architectural choices
6. **Current Focus** — What you're working on now

Keep it lean — CLAUDE.md loads every session (~1-2K tokens).

### Step 4: Configure Task Master (optional)

If using Task Master for task management:

```bash
# Initialize (creates .taskmaster/ directory)
task-master init

# IMPORTANT: Re-run init-project.sh after task-master init
# (task-master overwrites config with defaults)
./scripts/init-project.sh
```

**Task Master workflow:**
1. Write a PRD in `.taskmaster/docs/prd_<name>.txt`
2. Parse it: `task-master parse-prd --input=<file> --num-tasks=0 --force`
3. Analyze complexity: `task-master analyze-complexity`
4. View report: `task-master complexity-report`
5. Expand complex tasks: `task-master expand --id=<id> --force`
6. Start working: `task-master next`

### Step 5: Verify Setup

Run this checklist to confirm everything is configured:

```bash
# 1. Skill profile active?
./scripts/manage-skill-profiles.sh current

# 2. Harness audit passing?
node scripts/harness-audit.js

# 3. Hooks working? (start a new session and check output)
# You should see "Project Status" banner on session start

# 4. Superpowers installed?
/plugin list
# Should show: superpowers@superpowers-marketplace

# 5. Document skills working? (if installed)
./scripts/check-doc-deps.sh
```

---

## What You Get

### By Profile

| Profile | Skills | Agents | Tokens | Best For |
|---------|--------|--------|--------|----------|
| `minimal` | 31 | 40 | ~3K | Template development, simple scripts |
| `python` | 44 | 40 | ~9K | Python/Django apps |
| `java` | 41 | 40 | ~6K | Spring Boot services |
| `go` | 33 | 40 | ~7K | Go microservices |
| `typescript` | 44 | 40 | ~5K | Node.js/React apps |
| `fullstack` | 60 | 40 | ~11K | Full-stack web apps |
| `ops` | 47 | 40 | ~6K | DevOps/SRE work |
| `ai-engineer` | 59 | 40 | ~8K | ML/AI projects |
| `all` | 153 | 40 | ~28K | Everything (use sparingly) |

Note: Agents (40) and commands (88) are always available regardless of profile.

### Key Commands

| Command | What It Does |
|---------|-------------|
| `/plan` | Create implementation plan before coding |
| `/tdd` | Enforce test-driven development |
| `/test` | Run project test suite |
| `/lint` | Run linting and code quality |
| `/commit` | Create conventional commit |
| `/pr` | Create GitHub pull request |
| `/code-review` | Review uncommitted changes |
| `/brainstorm` | Structured ideation session |
| `/research` | Deep research with citations |
| `/tasks` | List Task Master tasks |
| `/health` | Project health check |
| `/verify` | Full verification pipeline |

**Language-specific commands** (available per profile):
- Python: `/python-review`
- Go: `/go-build`, `/go-review`, `/go-test`
- Kotlin: `/kotlin-build`, `/kotlin-review`, `/kotlin-test`
- Rust: `/rust-build`, `/rust-review`, `/rust-test`
- C++: `/cpp-build`, `/cpp-review`, `/cpp-test`

**Operations commands** (with `ops` profile or category):
- `/incident-response` — Production incident triage
- `/accessibility-audit` — WCAG compliance check
- `/monitor-setup` — Observability configuration
- `/slo-implement` — SLO definition and implementation

### Context Budget

With a 200K context window, here's what's consumed at startup:

| Component | Tokens | Notes |
|-----------|--------|-------|
| MCP tools | ~25-30K | Task Master + Context7 |
| Skill metadata | ~3-28K | Depends on profile |
| Core rules | ~19K | 11 always-loaded rules |
| Language rules | ~1-3K | Only for active languages |
| Superpowers | ~5K | 14 skills (plugin) |
| CLAUDE.md | ~1-2K | Keep it lean |
| **Total startup** | **~55-90K** | |
| **Working context** | **~110-145K** | |

The `minimal` profile gives you ~145K working context. The `all` profile gives ~110K. Choose wisely.

---

## Upgrading from v2.5.0

If you're already using the template and want the v2.6.0 features:

### What Changed

| Feature | v2.5.0 | v2.6.0 |
|---------|--------|--------|
| Skills | 48 | **153** (+84 ECC, +8 Anthropic, +13 ops) |
| Agents | 14 | **40** (+15 ECC, +11 ops) |
| Commands | 56 | **88** (+27 ECC, +5 ops) |
| Rules | 16 files / 4 langs | **68 files / 12 langs** |
| Skill profiles | None | **15 profiles, 22 categories** |
| Document skills | None | **PDF, DOCX, PPTX, XLSX** (plugin) |
| Languages | 7 | **14** (+C#, Kotlin, Perl, PHP, Rust, Swift, Laravel) |

### Migration Steps

```bash
# 1. Pull latest template changes
git pull origin main

# 2. Skills moved from .claude/skills/ to .claude/skills-available/
#    .claude/skills/ now contains symlinks (managed by profiles)
#    If your skills/ is empty, run:
./scripts/manage-skill-profiles.sh set all

# 3. Set your preferred profile
./scripts/manage-skill-profiles.sh list              # see options
./scripts/manage-skill-profiles.sh set python         # pick one

# 4. Optional: install document skills
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
./scripts/check-doc-deps.sh --install

# 5. Start a new session to pick up changes
```

### Breaking Changes

- **Skills directory restructured**: `.claude/skills/` now contains symlinks to `.claude/skills-available/`. If you added custom skills directly to `.claude/skills/`, move them to `.claude/skills-available/` and re-run your profile.
- **`.gitignore` updated**: `.claude/skills/` is now gitignored (symlinks are generated, not tracked).
- **`init-project.sh` updated**: Now copies `skills-available/` instead of `skills/`.

---

## Adding Custom Skills

To add your own skills to the template:

```bash
# 1. Create skill in skills-available
mkdir .claude/skills-available/my-custom-skill
cat > .claude/skills-available/my-custom-skill/SKILL.md << 'EOF'
---
name: my-custom-skill
description: What this skill does and when to trigger it.
---

# My Custom Skill

Instructions for Claude when this skill activates...
EOF

# 2. Add to a category in manage-skill-profiles.sh
#    Or it will only load with the 'all' profile

# 3. Refresh your profile
./scripts/manage-skill-profiles.sh set <your-profile>
```

---

## Troubleshooting

**Skills not loading after profile change:**
Skills load at session start. Start a new Claude Code session after changing profiles.

**`manage-skill-profiles.sh` says "skills-available not found":**
Run `./scripts/init-project.sh` first — it creates the directory structure.

**Document skills fail at runtime:**
Run `./scripts/check-doc-deps.sh --install` — system dependencies (LibreOffice, Python packages) may be missing.

**Too many skills consuming context:**
Switch to a narrower profile: `./scripts/manage-skill-profiles.sh set minimal`

**Custom skill not triggering:**
1. Check it's in `.claude/skills-available/<name>/SKILL.md` (not `.claude/skills/`)
2. Check it has a symlink: `ls -la .claude/skills/<name>`
3. Check the `description:` field is specific enough to trigger on your use case
