# Upstream Sync Maintenance

How to keep template components current with upstream sources (ECC, Superpowers, Task Master).

## Monthly Workflow

### 1. Check for upstream changes

```bash
# Quick repo-level overview (all 5 upstreams)
/check-upstream

# Per-file change detection against manifest
/check-upstream --manifest

# Show actual diffs for changed files
/check-upstream --manifest --diff
```

### 2. Triage changes

For each changed file reported by `--manifest`:

| File verdict | Action |
|-------------|--------|
| **Adopt** (our copy is a direct port) | Fetch latest, re-apply documented adaptations, update SHA |
| **Adapt** (our copy has additions) | Review upstream diff, merge relevant changes, keep our additions |
| **Content merge** (rule section from upstream) | Check if the upstream section changed, merge if improved |

### 3. Apply updates

```bash
# Fetch the upstream version
gh api repos/affaan-m/everything-claude-code/contents/<sourcePath> \
  -H 'Accept: application/vnd.github.raw' > /tmp/upstream-file

# Compare with our version
diff /tmp/upstream-file <our-local-path>

# Apply changes, then validate
node scripts/ci/validate-agents.js
node scripts/ci/validate-skills.js
node scripts/ci/validate-rules.js
node scripts/ci/validate-commands.js
node scripts/ci/validate-hooks.js
node scripts/ci/validate-no-personal-paths.js
```

### 4. Update manifest

After adopting changes, update `adaptedFromSha` in `.claude/upstream-manifest.json`:

```bash
# Get current ECC HEAD
NEW_SHA=$(gh api repos/affaan-m/everything-claude-code/commits/HEAD --jq '.sha' | head -c 7)

# Update manifest entry (use jq or manual edit)
# Set adaptedFromSha to $NEW_SHA for updated files
# Set adaptedDate to today's date
```

### 5. Commit

```bash
git commit -m "chore: sync <component> with upstream <sha>"
```

## Adoption Criteria

### Adopt when

- ECC version has features we lack
- ECC version fixes bugs we have
- ECC version is better maintained (more tests, better error handling)
- No philosophical conflict with our template approach

### Keep when

- Our version integrates with Task Master or Superpowers
- Our version has unique features ECC lacks (polyglot coverage, workflow rules)
- Adoption would require significant rework of dependent components
- ECC version is JS/TS-only and we need polyglot support

### Skip when

- ECC component serves their install system (NanoClaw, DevFleet, state store)
- Component duplicates our existing capability without improvement
- Component requires infrastructure we don't have (SQLite, multi-target)

## Local Patches to Re-apply

After updating **Superpowers** plugin (`/plugin update superpowers`):
- `brainstorming/SKILL.md`: EnterPlanMode prohibition (2 lines after HARD-GATE)
- Verify all 4 override rules still align (see `.claude/rules/superpowers-integration.md`)

## Manifest Schema

The manifest at `.claude/upstream-manifest.json` tracks:

| Field | Purpose |
|-------|---------|
| `source` | GitHub repo (owner/name) |
| `sourcePath` | Path in upstream repo |
| `adaptedFromSha` | Commit SHA we adapted from |
| `adaptedDate` | ISO date of last adaptation |
| `adaptations` | List of changes made |
| `verdict` | Adopt or Adapt |
| `mergeType` | "contentMerge" for rule section merges |

The `_stats` section provides aggregate counts. Update it when adding/removing entries.

## Cadence

| Check | Frequency | Command |
|-------|-----------|---------|
| Repo-level overview | Monthly | `/check-upstream` |
| Per-file manifest check | Monthly or before releases | `/check-upstream --manifest` |
| Full re-audit | Major ECC version bump | Manual (follow Phase 1-4 process from audit) |
