# mgrep Evaluation

**Date:** 2026-02-12
**Status:** Deferred (Optional Plugin)
**Task:** #14

## Overview

mgrep is a semantic search CLI tool by Mixedbread AI that uses AI embeddings to understand the *meaning* of search queries, enabling natural language searches like "where do we set up auth?" instead of regex patterns.

## How It Works

1. **Indexing:** `mgrep watch` indexes files to Mixedbread cloud using their Search API
2. **Search:** Natural language queries processed through semantic retrieval + reranking
3. **Integration:** `mgrep install-claude-code` for automated Claude Code setup

## Token Efficiency Evidence

| Metric | mgrep + Claude | Standard grep + Claude | Improvement |
|--------|---------------|------------------------|-------------|
| Token context | ~2,000 lines | ~5,000 lines | ~40-45% reduction |
| Cost per task | $0.23 | $0.49 | 53% savings |
| Time per task | 82 sec | 158 sec | 48% faster |
| Quality win rate | 76% | 24% | 3x better |

*Source: Official benchmarks from GitHub repo and Elite AI Coding blog*

**Mechanism:** mgrep finds relevant code in 2-3 semantic queries instead of 10+ grep iterations, so Claude spends tokens on reasoning rather than scanning irrelevant code.

## Pricing

| Tier | Cost | Queries/month |
|------|------|---------------|
| Basic (Free) | $0 | 100 (~3/day) |
| Scale | $20/month | Pay-as-you-go ($4-7.50/1K queries) |

Free tier is insufficient for active development. Scale tier costs ~$22/month for 20 queries/day.

## Pros

- 40-50% fewer tokens per task (proven in benchmarks)
- Natural language search (no regex needed for conceptual queries)
- Works on code, PDFs, images (multimodal)
- Built specifically for AI coding agent workflows
- 76% quality win rate in blind tests

## Cons

- **Cloud dependency** — no offline mode, code indexed to Mixedbread servers
- **Privacy concern** — uploads code to third-party cloud (blocks enterprise/proprietary use)
- **Cost** — free tier too limited (100 queries/month); $20/month adds adoption friction
- **Not a replacement** — still need grep/ripgrep for exact matches and regex
- **Vendor lock-in** — tied to Mixedbread service availability

## Recommendation: DEFER

**Do NOT add to core template because:**
- Cloud indexing conflicts with security-conscious users
- $20/month adds friction to template adoption
- Internet dependency breaks offline workflows
- Small projects (<1000 files) see marginal gains over ripgrep

**Document as optional plugin because:**
- Proven 40-50% token reduction for large codebases
- Unique semantic capability (no local alternative matches it)
- First-class Claude Code support

### Who Should Use It

- Large codebases (>5k files)
- Open source projects (privacy OK)
- Heavy Claude Code users (savings exceed $22/month cost)
- Teams with Mixedbread Scale tier

### Who Should NOT Use It

- Security-sensitive/proprietary code
- Small projects (<500 files)
- Offline-first workflows
- Budget-constrained users

## Alternative

**osgrep** — open source fork with local embeddings. Lacks mgrep's performance but avoids cloud dependency. Worth monitoring.

## Sources

- [GitHub - mixedbread-ai/mgrep](https://github.com/mixedbread-ai/mgrep)
- [Elite AI Coding - mgrep benchmarks](https://elite-ai-assisted-coding.dev/p/boosting-claude-faster-clearer-code)
- [Mixedbread Pricing](https://www.mixedbread.com/pricing)
